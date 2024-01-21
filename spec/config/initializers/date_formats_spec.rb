# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'custom date formats' do
  describe 'short_relative_day' do
    it 'returns "Yesterday" when the date is yesterday' do
      expect(Date.yesterday.to_fs(:short_relative_day)).to eql("Yesterday")
    end

    it 'returns "Today" when the date is today' do
      expect(Date.today.to_fs(:short_relative_day)).to eql("Today")
    end

    it 'returns "Tomorrow" when the date is tomorrow' do
      expect(Date.tomorrow.to_fs(:short_relative_day)).to eql("Tomorrow")
    end

    it "returns a month abbreviation and the day when the date isn't close" do
      date = Date.today - 1.year
      expect(date.to_fs(:short_relative_day)).to eql(date.strftime('%b %-d'))
    end
  end
end

