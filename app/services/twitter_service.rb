require 'open-uri'

class TwitterService
  def initialize
    @token = Rails.application.credentials.dig(:omniauth, :twitter_app_token).presence || raise('No token')
    @client = Tweetkit::Client.new(bearer_token: @token)
  end

  def load_tweets(source)
    internal_load_and_save_tweets(source, source.query)
  end

  def count_tweets(source)
    internal_count_tweets(source.query)
  end

  def embed_html(url)
    json = RestClient.get("https://publish.twitter.com/oembed?url=#{url}")
    json = JSON.parse(json)
    json['html']
  end

  protected

  def internal_count_tweets(query)
    options = {
      granularity: 'day'
    }
    json = @client.count(
      query,
      type: :tweets,
      **options
    ).response

    if json['errors']
      messages = json['errors'].map { |e| e['message'] }
      raise ZiiResearchThingies::Error, messages.join(', ')
    end

    count = (json['data'] || []).map { |item| item['tweet_count'] || 0 }
    count.reduce(0, :+)
  end

  def internal_load_and_save_tweets(source, query, next_token: nil)
    options = {
      'tweet.fields': 'created_at,public_metrics,conversation_id',
      'user.fields': 'username',
      'expansions': 'author_id',
      'max_results': 100
    }
    options[:next_token] = next_token if next_token
    options

    json = @client.search(
      query,
      type: :tweets,
      **options
    ).response

    if json['errors']
      messages = json['errors'].map { |e| e['message'] }
      raise ZiiResearchThingies::Error, messages.join(', ')
    end

    users = (json.dig('includes', 'users') || []).map { |u| [u['id'], u['username']] }.to_h
    tweets = json['data'] || []
    puts "#{query}: #{tweets.count} elements"
    tweets.each do |tweet|
      TwitterTweet.create(
        twitter_search_source: source,
        twitter_id: tweet['id'],
        content: tweet['text'],
        username: users[tweet['author_id']],
        date: tweet['created_at'],
        **tweet['public_metrics'].slice('retweet_count', 'reply_count', 'like_count', 'quote_count')
      )
    end

    if (next_token = json.dig('meta', 'next_token'))
      internal_load_and_save_tweets(source, query, next_token: next_token)
    else
      puts "#{query}: Done"
    end
  end
end
