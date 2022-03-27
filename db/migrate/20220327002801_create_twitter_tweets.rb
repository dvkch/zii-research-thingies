class CreateTwitterTweets < ActiveRecord::Migration[6.1]
  def change
    create_table :twitter_tweets do |t|
      t.belongs_to :twitter_search
      t.belongs_to :twitter_search_source

      t.datetime :date, null: false
      t.string :username, null: false
      t.text :content, null: false
      t.string :twitter_id, null: false

      t.integer :retweet_count, null: false, default: 0
      t.integer :like_count, null: false, default: 0
      t.integer :reply_count, null: false, default: 0
      t.integer :quote_count, null: false, default: 0

      t.timestamps
    end
  end
end
