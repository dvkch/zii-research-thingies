class RemoveIncludeReplies < ActiveRecord::Migration[6.1]
  def change
    remove_column :twitter_search_sources, :include_replies, :boolean, null: false, default: false
  end
end
