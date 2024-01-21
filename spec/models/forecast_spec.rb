# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared_api_contexts'

RSpec.describe Forecast do
  include_context 'forecast api responses'

  let(:zipcode) { '90210' }

  shared_examples 'caches weather lookup' do
    # Normally, we ignore caching by using the NullStore, but we actually want to test it
    # for these tests.
    around do |example|
      backup = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      example.run
    ensure
      Rails.cache = backup
    end

    it 'requests weather data when it is not in the cache' do
      expect(WeatherApiClient).to receive(:get)
        .with('/forecast.json', query: {q: zipcode, days: 5})
        .and_return(valid_api_response)
      tested_action
    end

    it 'uses the weather data cached for the zipcode' do
      Rails.cache.write("forecast:#{zipcode}", valid_api_response, expires_in: 10.minutes)
      expect(WeatherApiClient).not_to receive(:get)
      tested_action
    end
  end

  describe '#valid?' do
    subject(:weather) { described_class.new('90210') }

    it 'returns true with a valid response' do
      expect(weather).to be_valid
    end

    context 'when an error is returned' do
      before { expect_location_not_found_error }

      it { is_expected.to be_invalid }

      it 'sets the error on the "base" attribute' do
        weather.valid?

        expect(weather.errors.messages_for(:base).first)
          .to eql('No matching location found.')
      end
    end
  end

  describe '#forecast' do
    let(:tested_action) { described_class.new(zipcode).forecast }

    it_behaves_like 'caches weather lookup'

    it 'returns a list of forecast days for the next few days' do
      forecast = tested_action
      expect(forecast).not_to be_empty
      expect(forecast).to all(be_a(Forecast::Day))
    end

    it 'returns an empty array when there is a lookup error' do
      expect_location_not_found_error
      weather = described_class.new('333')

      expect(weather).to be_invalid
      expect(weather.forecast).to be_empty
    end

    it 'returns an empty array if there is unexpected data returned from the API' do
      expect(WeatherApiClient).to receive(:get).and_return({"bad" => {"data" => 42}})
      weather = described_class.new('90210')

      expect(weather.forecast).to be_empty
    end
  end

  describe '#current' do
    let(:tested_action) { described_class.new(zipcode).current }

    it_behaves_like 'caches weather lookup'

    it 'returns the current weather conditions' do
      expected_data = valid_api_response["current"]
      expect(tested_action).to be_a(Forecast::Now)
        .and have_attributes(
          temperature: expected_data['temp_f'].round,
          feels_like: expected_data['feelslike_f'].round,
          condition: Forecast::Condition.new(
            name: expected_data.dig('condition', 'text'),
            icon_url: expected_data.dig('condition', 'icon')
          ),
          updated_at: expected_data['last_updated']
        )
    end

    it 'returns nil when there is a lookup error' do
      expect_location_not_found_error
      weather = described_class.new('333')

      expect(weather).to be_invalid
      expect(weather.current).to be nil
    end

    it 'returns nil if there is unexpected data returned from the API' do
      expect(WeatherApiClient).to receive(:get).and_return({"bad" => {"data" => 42}})
      weather = described_class.new('90210')

      expect(weather.current).to be nil
    end
  end
end
