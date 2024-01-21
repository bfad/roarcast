# frozen_string_literal: true

class ForecastController < ApplicationController
  def index
    render locals: {zipcode: ''}
  end

  def show
    zipcode = params[:zipcode]
    forecast = Forecast.new(zipcode)

    if forecast.valid?
      render locals: {forecast:, zipcode:}
    else
      render :error, locals: {forecast:, zipcode:}, status: :bad_request
    end
  end
end
