# frozen_string_literal: true

class Forecast
  # A simple class that represents a day's forecast data
  Day = Data.define(:date, :high, :low, :condition, :chance_of_rain, :chance_of_snow) do
    def chance_of_precipitation
      [chance_of_rain, chance_of_snow].max
    end
  end
end
