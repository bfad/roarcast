# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherApiClient do
  let(:zipcode) { '90210' }

  describe '#current' do
    it 'calls the current Weather API endpoint with the zipcode' do
      expect(described_class).to receive(:get).with('/current.json', query: {q: zipcode})
      described_class.new.current(zipcode)
    end
  end

  describe '#forecast' do
    it 'calls the forecast Weather API endpoint with the zipcode and default number of days' do
      expect(described_class).to receive(:get).with('/forecast.json', query: {q: zipcode, days: 5})
      described_class.new.forecast(zipcode)
    end

    it 'calls the forecast Weather API endpoint with the zipcode and specified number of days' do
      expect(described_class).to receive(:get).with('/forecast.json', query: {q: zipcode, days: 3})
      described_class.new.forecast(zipcode, days: 3)
    end
  end
end
