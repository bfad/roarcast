Date::DATE_FORMATS[:short_relative_day] = ->(date) {
  case date - Date.today
  when -1
    'Yesterday'
  when 0
    'Today'
  when 1
    'Tomorrow'
  else
    date.strftime('%b %-d')
  end
}
