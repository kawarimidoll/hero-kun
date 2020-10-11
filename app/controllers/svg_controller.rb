class SvgController < ApplicationController
  def today
  end

  def recent_contrib
    require 'open-uri'
    require 'base64'

    Rails.logger.debug params
    raise "Invalid Format: #{params[:format]}" if params[:format].present? && ['svg', 'json'].exclude?(params[:format])

    d = Date.today
    svg_data = Rails.cache.fetch("#{d.strftime}-#{params[:username]}", expires_in: 15.minutes) do
      OpenURI.open_uri("https://github.com/#{params[:username]}") do |io|
        scope_str = ''
        scope_str = io.readline while scope_str.exclude?('data-scope-id')
        {
          avatar: Base64.strict_encode64(
            OpenURI.open_uri("https://avatars3.githubusercontent.com/u/#{scope_str[/data-scope-id="(\d+)"/, 1]}?s=50&v=4").read
          ),
          contributions: io.readlines.grep(/rect.*(#{[*1..7].map { |n| (d - n).strftime } * '|'})/).map { |line|
            {
              date: line[/date="(\d{4}-\d{2}-\d{2})"/, 1],
              count: line[/count="(\d+)"/, 1],
              fill: line[/fill="(#[\da-f]{6})"/, 1]
            }
          }.reverse
        }
      end
    end
    avatar = svg_data[:avatar]
    contributions = svg_data[:contributions]
    Rails.logger.debug contributions

    return render inline: contributions.to_json, format: :json if params[:format] == 'json'

    size = 200
    font_size = size / 10
    span = font_size / 4
    xoffset = font_size * 8
    svg = %[<svg xmlns="http://www.w3.org/2000/svg" viewbox="0 0 #{size} #{size}" width="#{size}" height="#{size}">
    <image href="data:image/png;base64,#{avatar}" x="0" y="0" width="#{size}" height="#{size}" />
    <rect width="#{size}" height="#{size}" fill="#fff" opacity="0.8" />
    <g transform="translate(10,14)" font-family="monospace,sans-serif" font-size="#{font_size}">
    #{contributions.each_with_index.reduce('') { |acc, (contrib, idx)|
    yoffset = (font_size + span) * idx
    %[#{acc}
      <text y="#{yoffset + font_size}">#{contrib[:date]}: #{contrib[:count]}</text>
      <rect x="#{xoffset}" y="#{yoffset}" width="#{font_size}" height="#{font_size}" fill="#{contrib[:fill]}" stroke="gray" stroke-width="1" />]
    }}
    </g></svg>]
    Rails.logger.debug svg

    render inline: svg, format: :svg
  rescue OpenURI::HTTPError => e
    Rails.logger.warn e
    head :not_found
  end
end
