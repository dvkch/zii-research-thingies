require 'nokogiri'

class TwitterTrendingArchive
  def start_date
    '2018-11-26'
  end

  def countries
    countries = get_xml('https://archive.twitter-trending.com/', '#dsad option')
    countries
      .reject { |c| c.text.empty? }
      .map { |c| [c.text, c['value']] }
  end

  def keywords(country, from, to)
    data = date_range_data(country, from, to)
    data.map(&:keys).flatten.sort.uniq.to_a
  end

  def date_range_trends(country, from, to)
    data = date_range_data(country, from, to)

    series = {}
    data.each do |s|
      series.merge!(s) do |_, value1, value2|
        value1.merge(value2)
      end
    end
    series
  end

  protected

  def date_range_data(country, from, to)
    dates = (from..to).to_a
    Parallel.map(dates, in_threads: 4) do |day|
      Rails.cache.fetch("TwitterTrendingArchive-#{country}-#{day}") do
        day_data(country, day)
      end
    end
  end

  def day_data(country, date)
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

  def get_xml(url, css)
    data = Rails.cache.fetch(url) do
      CachedItem.fetch(url) do
        puts "Fetching archive at #{url}"
        RestClient.get(url).body
      end
    end

    xml = Nokogiri::HTML.parse(data, url)
    xml.css(css)

  rescue RestClient::Exception
    []
  end
end
