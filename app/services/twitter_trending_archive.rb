require 'nokogiri'

class TwitterTrendingArchive
  def countries
    countries = get_xml('https://archive.twitter-trending.com/', '#dsad option')
    countries
      .reject { |c| c.text.empty? }
      .map { |c| [c.text, c['value']] }
  end

  def keywords(country, from, to)
    day_series = (from..to).map do |day|
      Rails.cache.fetch("TwitterTrendingArchive-#{country}-#{day}") do
        day_trends(country, day)
      end
    end

    day_series.map(&:keys).flatten.sort.uniq.to_a
  end

  def date_range_trends(country, from, to)
    day_series = (from..to).map do |day|
      day_trends(country, day)
    end

    series = {}
    day_series.each do |s|
      series.merge!(s) do |_, value1, value2|
        value1.merge(value2)
      end
    end
    series
  end

  def day_trends(country, date)
    series = {}

    times = get_xml("https://archive.twitter-trending.com/#{country}/#{date.strftime('%d-%m-%Y')}", '#all_table .tek_tablo')
    times.each do |time_table|
      time = time_table.css('.trend_baslik611').text
      time = Time.parse(time, date)

      data = time_table
               .css('table .tr_table span.word_ars')
               .map(&:text)

      data.each_with_index do |keyword, index|
        series[keyword.downcase] ||= {}
        series[keyword.downcase][time] = index + 1
      end
    end

    series
  end

  protected

  def get_xml(url, css)
    data = Rails.cache.fetch(url) do
      CachedItem.fetch(url) do
        RestClient.get(url).body
      end
    end

    xml = Nokogiri::HTML.parse(data, url)
    xml.css(css)

  rescue RestClient::Exception
    []
  end
end
