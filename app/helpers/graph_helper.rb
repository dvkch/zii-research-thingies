# frozen_string_literal: true

module GraphHelper
  class << self
    def all_keys(series)
      series
        .map { |serie| serie[:data].keys }
        .flatten
        .uniq
        .sort
    end

    def add_missing_points!(series, keys = nil, value = 0)
      # makes sure there is the same number of points in all series. that doesn't mean
      # that the resulting list of points will be complete. we may still jump from a Monday to Saturday if
      # there was no data in between in all series
      keys ||= all_keys(series)
      series.each do |serie|
        missing_keys = keys.to_set - serie[:data].keys.to_set
        missing_keys.each { |key| serie[:data][key] = value }
      end
    end

    def smooth!(series, extent = 0)
      return series if extent.nil? || extent <= 0

      # will smooth series using the mean of current point +/- extent.
      # for a 3 day smoothing, use extent = 1, for a 5 day smoothing, extent = 2, etc.
      series.each do |serie|
        serie[:data] = smooth_single_serie_data(serie[:data].dup, extent)
      end
    end

    def apply_numeric_granularity!(series, points_count = nil)
      return series if points_count.nil? || points_count <= 0

      min = series.map { |s| s[:data].keys.min }.min
      max = series.map { |s| s[:data].keys.max }.max

      ideal_steps = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]

      raw_step = (max - min) / points_count
      selected_step = ideal_steps.reject { |s| s > raw_step }.last || 1

      series.each do |serie|
        serie[:data] = apply_numeric_granularity_single_serie_data(serie[:data].dup, selected_step)
        serie[:step] = selected_step
      end
    end

    private

    def smooth_single_serie_data(data, extent)
      new_data = {}

      integer = data.values.first.class == Integer

      # copy points that can't easily be smoothed
      sorted_keys = data.keys.sort
      (0...extent).each do |index|
        key = sorted_keys[index]
        new_data[key] = data[key]

        key = sorted_keys[sorted_keys.size - index - 1]
        new_data[key] = data[key]
      end

      chunk_size = extent * 2 + 1
      sorted_keys.each_cons(chunk_size) do |keys|
        current_key = keys[extent]
        value = keys.map { |k| data[k] }.sum / chunk_size.to_f
        value = value.to_i if integer
        new_data[current_key] = value
      end

      new_data
    end

    def apply_numeric_granularity_single_serie_data(data, step)
      new_data = {}

      min = data.keys.min
      min -= (min % step)

      max = data.keys.max
      max -= (max % step)

      new_keys = (min..max).step(step).to_a

      new_keys.each do |new_key|
        old_keys = data.keys.select { |k| k >= new_key && k < new_key + step }
        new_data[new_key] = old_keys.map { |k| data[k] }.sum
      end

      new_data
    end
  end
end
