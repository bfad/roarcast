# frozen_string_literal: true

# This is the model that handles fetching and caching the forecast data.
class Forecast
  include ActiveModel::Validations

  CACHE_LENGTH = 30.minutes

  attr_reader :zipcode

  validate :no_weather_data_errors

  def initialize(zipcode)
    self.zipcode = zipcode
  end

  # Look up the weather forecast for a zipcode.
  #
  # @return [Array<Forecast::Day>] a list of the basic weather conditions for the next
  #   five days. Returns an empty array if there is an error.
  def forecast
    data = weather_api_data.dig('forecast', 'forecastday')
    return [] if invalid? || data.nil?

    data.map do |data|
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
  # @return [Forecast::Now, nil] the current weather conditions for the forecast's zipcode.
  #   Returns `nil` if there is an error.
  def current
    data = weather_api_data['current']
    return if invalid? || data.nil?

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

  def no_weather_data_errors
    return unless weather_api_data.has_key?("error")

    errors.add(:base, weather_api_data.dig('error', 'message'))
  end
end
