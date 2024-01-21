# frozen_string_literal: true

class WeatherApiClient
  include HTTParty
  base_uri 'https://api.weatherapi.com/v1'
  default_params key: ENV.fetch('WEATHER_API_KEY')

  # Takes in a string for the location to pass to the "q" parameter to Weather API. This can
  # be a zipcode (ex "90210"), or latituded and logited pair, etc. (See their documentation
  # for all valid values.)
  def current(location)
    self.class.get('/current.json', query: {q: location})
  end

  # Takes in a string for the location to pass to the "q" parameter to Weather API. This can
  # be a zipcode (ex "90210"), or latituded and logited pair, etc. (See their documentation
  # for all valid values.)
  def forecast(location, days: 5)
    self.class.get('/forecast.json', query: {q: location, days: days})
  end
end
