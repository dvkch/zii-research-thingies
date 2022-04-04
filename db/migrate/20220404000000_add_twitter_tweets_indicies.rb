class AddTwitterTweetsIndicies < ActiveRecord::Migration[6.1]
  def up
    add_index :twitter_tweets, :date
    add_index :twitter_tweets, :twitter_id
    execute "CREATE FUNCTION immutable_unaccent(text) RETURNS text LANGUAGE SQL IMMUTABLE AS 'SELECT unaccent($1)';"
    execute "CREATE INDEX twitter_tweets_content_search ON twitter_tweets USING gin( to_tsvector('simple', immutable_unaccent(coalesce(twitter_tweets.content::text, '')::text)) );"
  end

  def down
    execute 'DROP INDEX twitter_tweets_content_search'
    execute 'DROP FUNCTION immutable_unaccent'
    remove_index :twitter_tweets, :twitter_id
    remove_index :twitter_tweets, :date
  end
end
