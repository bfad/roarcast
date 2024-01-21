# frozen_string_literal: true

# This is the model that handles fetching and caching the forecast data.
class Forecast
  CACHE_LENGTH = 30.minutes

  attr_reader :zipcode

  def initialize(zipcode)
    self.zipcode = zipcode
  end

  # Look up the weather forecast for a zipcode.
  #
  # @return [Array<Forecast::Day>] a list of the basic weather conditions for the next
  #   five days.
  def forecast
    weather_api_data.dig('forecast', 'forecastday').map do |data|
      Day.new(
        date: Date.parse(data['date']),
        high: data.dig('day', 'maxtemp_f').round,
        low: data.dig('day', 'mintemp_f').round,
        condition: Condition.new(
          name: data.dig('day', 'condition', 'text'),
          icon_url: data.dig('day', 'condition', 'icon')
        ),
        chance_of_rain: data.dig('day', 'daily_chance_of_rain'),
        chance_of_snow: data.dig('day', 'daily_chance_of_snow')
      )
    end
  end

  # Look up the current weather conditions for a zipcode
  #
  # @return [Forecast::Now] the current weather conditions for
  def current
    data = weather_api_data['current']

    Now.new(
      temperature: data['temp_f'].round,
      feels_like: data['feelslike_f'].round,
      condition: Condition.new(
        name: data.dig('condition', 'text'),
        icon_url: data.dig('condition', 'icon')
      ),
      updated_at: data['last_updated']
    )
  end

  private

  attr_writer :zipcode

  def weather_api_data
    return @weather_api_data if defined?(@weather_api_data)

    @weather_api_data = Rails.cache.fetch("forecast:#{zipcode}", expires_in: CACHE_LENGTH) do
      WeatherApiClient.new.forecast(zipcode)
    end
  end
end
