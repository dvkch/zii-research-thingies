require 'rails_helper'

RSpec.describe GraphHelper, type: :helper do

  it 'can complete series that dont have the same points' do
    data1 = {
      oranges: 1,
      bananas: 2
    }
    data2 = {
      apples: 0,
      bananas: 5
    }
    series = [
      { name: 'First', data: data1 },
      { name: 'Last', data: data2 }
    ]

    GraphHelper.add_missing_points!(series, 10)

    expect(series.first[:data]).to contain_keys [:oranges, :apples, :bananas]
    expect(series.first[:data][:oranges]).to eq 1 # unchanged
    expect(series.first[:data][:bananas]).to eq 2 # unchanged
    expect(series.first[:data][:apples]).to eq 10 # added with given value

    expect(series.last[:data]).to contain_keys [:oranges, :apples, :bananas]
    expect(series.last[:data][:apples]).to eq 0  # unchanged
    expect(series.last[:data][:bananas]).to eq 5 # unchanged
    expect(series.last[:data][:oranges]).to eq 10 # added with given value
  end

  it 'can smooth series by averaging with near points' do
    # e.g. number of games per score. since scores can be very distinct this will result in a weird
    # serie, by averaging with neighbouring points it can be better
    data = {
      a: 0,
      b: 10,
      c: 20,
      d: 40,
      g: 40,
      h: 40,
      i: 60,
      j: 80
    }

    # no smoothing
    series = [{ name: 'Days', data: data.dup }]
    GraphHelper.smooth!(series, 0)
    expect(series.first[:data]).to eq data

    # smoothing with prev and next point
    series = [{ name: 'Days', data: data.dup }]
    expected_smooth1 = {
      a: 0, # original
      b: 10,
      c: 23.333.to_i,
      d: 33.3333.to_i,
      g: 40,
      h: 46.6666.to_i,
      i: 60,
      j: 80 # original
    }
    GraphHelper.smooth!(series, 1)
    expect(series.first[:data]).to eq expected_smooth1

    # smoothing with 2 prev + 2 next points
    series = [{ name: 'Days', data: data.dup }]
    expected_smooth2 = {
      a: 0,   # original
      b: 10,  # original
      c: 22,
      d: 30,
      g: 40,
      h: 52,
      i: 60,  # original
      j: 80   # original
    }
    GraphHelper.smooth!(series, 2)
    expect(series.first[:data]).to eq expected_smooth2

    # smoothing with 3 prev + 3 next points
    series = [{ name: 'Days', data: data.dup }]
    expected_smooth3 = {
      a: 0,
      b: 10,
      c: 20,
      d: 30,      # smoothed
      g: 290 / 7, # smoothed
      h: 40,
      i: 60,
      j: 80
    }
    GraphHelper.smooth!(series, 3)
    expect(series.first[:data]).to eq expected_smooth3
  end

  it 'can change the scale of a serie indexed by integers' do
    # e.g. counts per score. scores are all very distinct, but by grouping them we can achieve a better graph;
    # instead of showing count for score=1, count for score=2, etc, we can show count for score in 0..10, then
    # for score in 10..20, etc
    data = {
      0 => 10, # e.g. 10 persons scored 0
      1 => 6,
      2 => 8,
      5 => 29,
      7 => 1,
      10 => 4,
      18 => 3,
      19 => 1,
      65 => 2
    }

    # no scaling
    series = [{ name: 'Scores', data: data.dup }]
    GraphHelper.apply_numeric_granularity!(series, 0)
    expect(series.first[:data]).to eq data

    # asking for around 10 evenly distributed points of data
    series = [{ name: 'Scores', data: data.dup }]
    expected_scaled1 = {
      0 => 24, # from 0 to 4 : 10 + 6 + 8 => 24
      5 => 30,
      10 => 4,
      15 => 4,
      20 => 0,
      25 => 0,
      30 => 0,
      35 => 0,
      40 => 0,
      45 => 0,
      50 => 0,
      55 => 0,
      60 => 0,
      65 => 2
    }
    GraphHelper.apply_numeric_granularity!(series, 10)
    # :step is added in the serie by the method. can only be in  [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]
    expect(series.first[:step]).to eq 5
    expect(series.first[:data]).to eq expected_scaled1

    # asking for around 4 evenly distributed points of data
    series = [{ name: 'Scores', data: data.dup }]
    expected_scaled2 = {
      0 => 54,
      10 => 8,
      20 => 0,
      30 => 0,
      40 => 0,
      50 => 0,
      60 => 2
    }
    GraphHelper.apply_numeric_granularity!(series, 4)
    expect(series.first[:step]).to eq 10
    expect(series.first[:data]).to eq expected_scaled2
  end
end
