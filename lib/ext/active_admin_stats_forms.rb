# frozen_string_literal: true

class ActiveAdmin::Views::Pages::Page
  def selected_date_granularity
    params.dig(:config, :date_granularity)&.presence&.to_sym || :group_by_day
  end

  def selected_limit
    (1..2000).bound(params.dig(:config, :limit)&.to_i || 50)
  end

  def selected_min_character_count
    (1..100).bound(params.dig(:config, :min_character_count)&.to_i || 2)
  end

  def selected_from
    params.dig(:config, :from)
  end

  def selected_to
    params.dig(:config, :to)
  end

  def selected_smooth_extent
    params.dig(:config, :smooth_extent)&.to_i || 0
  end

  def selected_numeric_granularity
    params.dig(:config, :numeric_granularity)&.to_i || 0
  end

  def selected_twitter_search
    id = params.dig(:config, :twitter_search)&.to_i
    TwitterSearch.find_by_id(id) unless id.nil?
  end

  def selected_keywords
    (params.dig(:config, :keywords) || []).reject(&:empty?)
  end

  def selected_trend_country
    params.dig(:config, :trend_country)
  end

  def selected_trend_keywords
    (params.dig(:config, :trend_keywords) || []).reject(&:empty?)
  end

  def show_filters(filters)
    from_to_options = {}
    if filters.include?(:trend_country)
      from_to_options[:minDate] = TwitterTrendingArchive.new.start_date.strftime('%Y-%m-%d')
      from_to_options[:maxDate] = Date.today.strftime('%Y-%m-%d')
    end

    page = self
    panel '' do
      active_admin_form_for(:config, url: request.path, html: { method: :get, class: 'admin-input' }) do |f|
        f.inputs do
          filters.each do |filter|
            case filter
            when :twitter_search
              twitter_searches = TwitterSearch.all.map { |model| [model.name, model.id] }
              f.input :twitter_search,
                      as: :select, required: true,
                      label: I18n.t('activerecord.models.twitter_search.one'),
                      collection: twitter_searches,
                      selected: page.selected_twitter_search&.id&.to_s
            when :keywords
              f.input :keywords,
                      as: :array,
                      label: I18n.t('attributes.keywords'),
                      value: page.selected_keywords
            when :trend_country
              f.input :trend_country,
                      as: :select, required: true,
                      label: I18n.t('admin.labels.trend_country'),
                      collection: TwitterTrendingArchive.new.countries,
                      selected: page.selected_trend_country
            when :trend_keywords
              trend_keywords = TwitterTrendingArchive.new.keywords(page.selected_trend_country, Date.parse(page.selected_from), Date.parse(page.selected_to))
              f.input :trend_keywords,
                      as: :select, required: true, multiple: true,
                      label: I18n.t('admin.labels.trend_keywords'),
                      collection: trend_keywords,
                      selected: page.selected_trend_keywords,
                      hint: "#{trend_keywords.size} #{I18n.t('admin.labels.trend_keywords').downcase}"

            when :from
              f.input :from,
                      as: :datepicker, required: false,
                      input_html: { value: page.selected_from, data: { 'datepicker-options': from_to_options } }
            when :to
              f.input :to,
                      as: :datepicker, required: false,
                      input_html: { value: page.selected_to, data: { 'datepicker-options': from_to_options } }

            when :limit
              f.input :limit, as: :number, required: false, in: 1..2000, input_html: { value: page.selected_limit }

            when :min_character_count
              f.input :min_character_count, as: :number, required: false, in: 1..100, input_html: { value: page.selected_min_character_count }

            when :date_granularity
              date_granularities = [
                [I18n.t('admin.labels.date_granularity.minute'), 'group_by_minute'],
                [I18n.t('admin.labels.date_granularity.hourly'), 'group_by_hour'],
                [I18n.t('admin.labels.date_granularity.daily'), 'group_by_day'],
                [I18n.t('admin.labels.date_granularity.weekly'), 'group_by_week'],
                [I18n.t('admin.labels.date_granularity.monthly'), 'group_by_month']
              ]

              f.input :date_granularity,
                      as: :select, required: false,
                      label: I18n.t('admin.labels.date_granularity.label'),
                      collection: date_granularities,
                      selected: page.selected_date_granularity.to_s
            when :smooth_extent
              smooth_extents = [
                [I18n.t('admin.labels.smoothing.none'), 0],
                [I18n.t('admin.labels.smoothing.extent_1'), 1]
              ]
              (2..8).each { |n| smooth_extents << [I18n.t('admin.labels.smoothing.extent_n', n: n), n] }

              f.input :smooth_extent,
                      as: :select, required: false,
                      label: I18n.t('admin.labels.smoothing.label'),
                      hint: I18n.t('admin.labels.smoothing.hint'),
                      collection: smooth_extents,
                      selected: page.selected_smooth_extent
            when :numeric_granularity
              numeric_granularities = [
                [I18n.t('admin.labels.numeric_granularity.all'), 0]
              ]
              [2000, 1000, 500, 200, 100, 50, 20, 10]
                .each { |n| numeric_granularities << [I18n.t('admin.labels.numeric_granularity.n', n: n), n] }

              f.input :numeric_granularity,
                      as: :select, required: false,
                      label: I18n.t('admin.labels.numeric_granularity.label'),
                      hint: I18n.t('admin.labels.numeric_granularity.hint'),
                      collection: numeric_granularities,
                      selected: page.selected_numeric_granularity
            else
              puts "Unknown filter: #{filter}"
            end
          end
        end
        f.actions do
          f.action :submit, label: I18n.t('admin.actions.apply')
          f.action :cancel, as: :link, label: I18n.t('admin.actions.reset'), url: request.path
        end
      end
    end
  end
end
