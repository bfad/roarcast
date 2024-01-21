# frozen_string_literal: true

class Forecast
  # A simple class that represents the current weather conditions
  Now = Data.define(:temperature, :feels_like, :condition, :updated_at)
end
