# frozen_string_literal: true

module RequestMethods
  def parsed_body
    return @_parsed_body if defined?(@_parsed_body)

    @_parsed_body = Nokogiri::HTML5.parse(response.body)
  end
end
