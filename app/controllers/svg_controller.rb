class SvgController < ApplicationController
  def today
  end

  def recent_contrib
    require 'open-uri'
    username = 'kawarimidoll'
    url = "https://github.com/#{username}"
    begin
      d = Date.today
      svg_data = Rails.cache.fetch("#{d.strftime}-#{username}", expires_in: 15.minutes) do
        OpenURI.open_uri(url) do |io|
          scope_str = ''
          scope_str = io.readline while scope_str.exclude?('data-scope-id')
          {
            user_id: scope_str[/data-scope-id="(\d+)"/, 1],
            contributions: io.readlines.grep(/rect.*(#{[*1..7].map { |n| (d - n).strftime } * '|'})/).map { |line|
              {
                date: line[/date="(\d{4}-\d{2}-\d{2})"/, 1],
                count: line[/count="(\d+)"/, 1],
                fill: line[/fill="(#[\da-f]{6})"/, 1]
              }
            }
          }
        end
      end
      # contributions = OpenURI.open_uri(url) { |io|
      #     io.readlines.grep(/fill.*(#{[*(1..7)].map { |n| d.prev_day(n).strftime }.join('|')})/)
      #   }.map { |line|
      #     {
      #       date: line[/date="(\d{4}-\d{2}-\d{2})"/, 1],
      #       count: line[/count="(\d+)"/, 1],
      #       fill: line[/fill="(#[\da-f]{6})"/, 1]
      #     }
      #   }
      Rails.logger.debug svg_data
      user_id = svg_data[:user_id]
      contributions = svg_data[:contributions]
    rescue OpenURI::HTTPError => e
      Rails.logger.warn e
      return head :not_found
    rescue => e
      Rails.logger.error e
      return head :internal_server_error
    end

    size = 200
    font_size = 20
    span = 5
    xoffset = font_size * 8
    svg = %[<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}">
    <image href="https://avatars3.githubusercontent.com/u/#{user_id}?s=200&v=4" width="#{size}" height="#{size}" />
    <rect width="#{size}" height="#{size}" fill="#ffffff" opacity="0.8" />
    <g transform="translate(10,14)" font-family="monospace,sans-serif" font-size="#{font_size}">
    #{contributions.each_with_index.reduce('') { |acc, (contrib, idx)|
    yoffset = (font_size + span) * idx
    %[#{acc}
      <text y="#{yoffset + font_size}">#{contrib[:date]}: #{contrib[:count]}</text>
      <rect x="#{xoffset}" y="#{yoffset}" width="#{font_size}" height="#{font_size}" fill="#{contrib[:fill]}" />]
    }}
    </g></svg>]
    Rails.logger.info svg

    render inline: svg
  end
end
