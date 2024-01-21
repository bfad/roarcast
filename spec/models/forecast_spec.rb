# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Forecast do
  let(:zipcode) { '90210' }
  let(:valid_api_response) do
    {
      "current" => {
        "last_updated_epoch" => 1705761900,
        "last_updated" => "2024-01-20 08:45",
        "temp_f" => -4,
        "is_day" => 1,
        "condition" => {
          "text" => "Sunny",
          "icon" => "//cdn.weatherapi.com/weather/64x64/day/113.png",
          "code" => 1000
        },
        "precip_in" => 0,
        "humidity" => 71,
        "feelslike_f" => -13.2
      },
      "forecast" => {
        "forecastday" => [
          {
            "date" => "2024-01-20",
            "date_epoch" => 1705708800,
            "day" => {
              "maxtemp_f" => 8.4,
              "mintemp_f" => -2.8,
              "totalprecip_in" => 0,
              "daily_chance_of_rain" => 0,
              "daily_chance_of_snow" => 0,
              "condition" => {
                "text" => "Sunny",
                "icon" => "//cdn.weatherapi.com/weather/64x64/day/113.png",
                "code" => 1000
              }
            }
          },
          {
            "date" => "2024-01-21",
            "date_epoch" => 1705795200,
            "day" => {
              "maxtemp_f" => 18,
              "mintemp_f" => -1.5,
              "totalprecip_in" => 0,
              "daily_chance_of_rain" => 0,
              "daily_chance_of_snow" => 0,
              "condition" => {
                "text" => "Partly cloudy",
                "icon" => "//cdn.weatherapi.com/weather/64x64/day/116.png",
                "code" => 1003
              }
            }
          },
          {
            "date" => "2024-01-22",
            "date_epoch" => 1705881600,
            "day" => {
              "maxtemp_f" => 28.7,
              "mintemp_f" => 18.2,
              "totalprecip_in" => 0.01,
              "daily_chance_of_rain" => 79,
              "daily_chance_of_snow" => 39,
              "condition" => {
                "text" => "Light freezing rain",
                "icon" => "//cdn.weatherapi.com/weather/64x64/day/311.png",
                "code" => 1198
              }
            }
          }
        ]
      }
    }
  end

  before do
    allow(WeatherApiClient).to receive(:get)
      .with('/forecast.json', query: {q: zipcode, days: 5})
      .and_return(valid_api_response)
  end

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
      before do
        expect(WeatherApiClient).to receive(:get)
          .and_return({"error" => {"code" => 1006, "message" => "No matching location found."}})
      end

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
      expect(WeatherApiClient).to receive(:get)
        .and_return({"error" => {"code" => 1006, "message" => "No matching location found."}})
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
      expect(WeatherApiClient).to receive(:get)
        .and_return({"error" => {"code" => 1006, "message" => "No matching location found."}})
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
