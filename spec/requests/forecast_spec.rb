# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared_api_contexts'

RSpec.describe 'Forecasts', type: :request do
  include_context 'forecast api responses'

  describe 'GET show' do
    let(:zipcode) { '90210' }

    it 'renders the forecast for the specified zipcode' do
      get forecast_url(zipcode:)

      expect(response).to have_http_status(:ok)
      expect(parsed_body.at('.current_conditions')).to be_present
      expect(parsed_body.at('.forecast')).to be_present
    end

    it 'renders the error that the location cannot be found' do
      expect_location_not_found_error
      get forecast_url(zipcode: 'invalid_valid_zip')

      expect(response).to have_http_status(:bad_request)
      expect(parsed_body.at('.current_conditions')).not_to be_present
      expect(parsed_body.at('.forecast')).not_to be_present
      expect(parsed_body.at('.error_msg')).to be_present
    end
  end
end
