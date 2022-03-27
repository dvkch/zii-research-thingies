# frozen_string_literal: true

class ActiveAdmin::Views::Pages::Page
  def selected_date_granularity
    params.dig(:config, :date_granularity)&.presence&.to_sym || :group_by_day
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

  def show_filters(filters)
    date_granularities = [
      [I18n.t('admin.labels.date_granularity.minute'), 'group_by_minute'],
      [I18n.t('admin.labels.date_granularity.hourly'), 'group_by_hour'],
      [I18n.t('admin.labels.date_granularity.daily'), 'group_by_day'],
      [I18n.t('admin.labels.date_granularity.weekly'), 'group_by_week'],
      [I18n.t('admin.labels.date_granularity.monthly'), 'group_by_month']
    ]

    twitter_searches = TwitterSearch.all.map { |model| [model.name, model.id] }

    smooth_extents = [
      [I18n.t('admin.labels.smoothing.none'), 0],
      [I18n.t('admin.labels.smoothing.extent_1'), 1]
    ]
    (2..8).each { |n| smooth_extents << [I18n.t('admin.labels.smoothing.extent_n', n: n), n] }

    numeric_granularities = [
      [I18n.t('admin.labels.numeric_granularity.all'), 0]
    ]
    [2000, 1000, 500, 200, 100, 50, 20, 10]
      .each { |n| numeric_granularities << [I18n.t('admin.labels.numeric_granularity.n', n: n), n] }

    page = self
    panel '' do
      active_admin_form_for(:config, url: request.path, html: { method: :get, class: 'admin-input' }) do |f|
        f.inputs do
          filters.each do |filter|
            case filter
            when :twitter_search
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

            when :from
              f.input :from, as: :date_time_picker, value: page.selected_from, required: false
            when :to
              f.input :to, as: :date_time_picker, value: page.selected_to, required: false
            when :date_granularity
              f.input :date_granularity,
                      as: :select, required: false,
                      label: I18n.t('admin.labels.date_granularity.label'),
                      collection: date_granularities,
                      selected: page.selected_date_granularity.to_s
            when :smooth_extent
              f.input :smooth_extent,
                      as: :select, required: false,
                      label: I18n.t('admin.labels.smoothing.label'),
                      hint: I18n.t('admin.labels.smoothing.hint'),
                      collection: smooth_extents,
                      selected: page.selected_smooth_extent
            when :numeric_granularity
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
