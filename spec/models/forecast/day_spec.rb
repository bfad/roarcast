# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Forecast::Day do
  describe '#chance_of_precipitation' do
    subject(:day) { described_class.new(date: '2024-01-20', high: 32, low: 8, condition: condition, chance_of_rain: 8, chance_of_snow: 78) }
    let(:condition) { Forecast::Condition.new(name: 'Cloudy', icon_url: 'http://example.com/image.png') }

    it 'returns the maximum chance of rain or snow' do
      expect(day.chance_of_precipitation).to eql(day.chance_of_snow)
    end
  end
end
