# frozen_string_literal: true

ActiveAdmin.register_page 'Twitter Trends' do
  menu parent: 'twitter', priority: 4, label: proc { I18n.t('admin.pages.twitter_trends') }

  content do
    h2 I18n.t('admin.pages.twitter_trends')

    # Filters
    if selected_from.blank? || selected_to.blank? || selected_trend_country.blank?
      show_filters([:trend_country, :from, :to])
      next
    else
      show_filters([:trend_country, :from, :to, :trend_keywords])
    end
    next if selected_trend_keywords.empty?

    # Obtain data
    data = TwitterTrendingArchive.new.date_range_trends(selected_trend_country, Date.parse(selected_from), Date.parse(selected_to))
    data = data.map do |name, values|
      { name: name, data: values }
    end
    keys = GraphHelper.all_keys(data)
    data = data.filter { |serie| selected_trend_keywords.include?(serie[:name]) }
    data = GraphHelper.add_missing_points!(data, keys)

    data.each do |serie|
      serie[:data].transform_values! do |count|
        (count.zero? ? -11 : -count)
      end
    end

    # Present data
    panel I18n.t('admin.pages.twitter_trends') do
      line_chart data, min: -10, max: -1
    end
  end
end
