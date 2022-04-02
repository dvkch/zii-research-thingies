class AddFromToToTwitterSearchSource < ActiveRecord::Migration[6.1]
  def change
    add_column :twitter_search_sources, :end_time, :datetime
    add_column :twitter_search_sources, :start_time, :datetime
  end
end
