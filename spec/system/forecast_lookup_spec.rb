# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared_api_contexts'

RSpec.describe 'Looking up a forecast' do
  include_context 'forecast api responses'

  it 'allows for looking up a forecast' do
    visit '/'

    fill_in 'Zip Code', with: '90210'
    click_button 'Get Forecast'

    expect(page).to have_text 'Current Conditions'
    expect(page).to have_text 'Forecast'
  end
end
