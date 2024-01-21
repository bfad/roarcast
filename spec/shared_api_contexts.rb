RSpec.shared_context 'forecast api responses' do
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

  let(:expect_location_not_found_error) do
    expect(WeatherApiClient).to receive(:get)
      .and_return({"error" => {"code" => 1006, "message" => "No matching location found."}})
  end

  before do
    allow(WeatherApiClient).to receive(:get)
      .with('/forecast.json', anything)
      .and_return(valid_api_response)
  end
end
