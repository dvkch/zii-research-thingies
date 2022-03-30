# frozen_string_literal: true

ActiveAdmin.register_page 'Twitter Stats' do
  menu parent: 'twitter', priority: 3, label: proc { I18n.t('admin.pages.twitter_stats') }

  content do
    h2 I18n.t('admin.labels.stats')

    # Filters
    show_filters([:twitter_search, :keywords, :from, :to, :date_granularity, :smooth_extent])
    next if selected_twitter_search.nil?

    # Counts
    sources = [selected_twitter_search, *selected_twitter_search.twitter_search_sources]
    tweets = sources.map do |source|
      query = source.twitter_tweets
      query = query.where('date < ?', selected_to) if selected_to.present?
      query = query.where('date > ?', selected_from) if selected_from.present?
      [source, query.send(selected_date_granularity, :date).count]
    end.to_h

    tweets = sources.map do |source|
      name = source.is_a?(TwitterSearch) ? 'Total' : source.query
      { name: name, data: tweets[source] }
    end
    GraphHelper.smooth!(tweets, selected_smooth_extent)
    panel I18n.t('activerecord.models.twitter_tweet.other') do
      line_chart tweets
    end

    # Keywords
    tweets = [nil, *selected_keywords].map do |keyword|
      query = selected_twitter_search.twitter_tweets
      query = query.search(keyword).reorder('') if keyword
      query = query.where('date < ?', selected_to) if selected_to.present?
      query = query.where('date > ?', selected_from) if selected_from.present?
      query = query.send(selected_date_granularity, :date).count
      { name: keyword || 'Total', data: query }
    end
    GraphHelper.smooth!(tweets, selected_smooth_extent)
    panel I18n.t('attributes.keywords') do
      line_chart tweets
    end
  end
end
