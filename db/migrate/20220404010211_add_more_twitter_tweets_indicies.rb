class AddMoreTwitterTweetsIndicies < ActiveRecord::Migration[6.1]
  def change
    add_index :twitter_tweets, :username
    add_index :twitter_tweets, :retweet_count
    add_index :twitter_tweets, :like_count
    add_index :twitter_tweets, :reply_count
    add_index :twitter_tweets, :quote_count
  end
end
