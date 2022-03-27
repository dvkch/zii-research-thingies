class CreateTwitterSearchSources < ActiveRecord::Migration[6.1]
  def change
    create_table :twitter_search_sources do |t|
      t.belongs_to :twitter_search
      t.string :query, null: false
      t.string :kind, null: false
      t.boolean :include_replies, null: false, default: false

      t.timestamps
    end
  end
end
