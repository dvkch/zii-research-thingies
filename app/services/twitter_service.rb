require 'open-uri'

class TwitterService
  def initialize
    @token = Rails.application.credentials.dig(:omniauth, :twitter_app_token).presence || raise('No token')
    @client = Tweetkit::Client.new(bearer_token: @token)
  end

  def load_tweets(source)
    load_and_save_tweets(source, source.query)
  end

  def load_replies(source)
    conversation_ids = TwitterTweet.where(twitter_search_source_id: source.id).pluck(:twitter_id).uniq
    return if conversation_ids.empty?

    query = conversation_ids.map { |id| "conversation_id:#{id}" }.join(' OR ')
    load_and_save_tweets(source, query)
  end

  def embed_html(url)
    json = RestClient.get("https://publish.twitter.com/oembed?url=#{url}")
    json = JSON.parse(json)
    json['html']
  end

  protected

  def load_and_save_tweets(source, query, next_token: nil)
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

    puts json

    users = (json.dig('includes', 'users') || []).map { |u| [u['id'], u['username']] }.to_h
    json['data']&.each do |tweet|
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
      load_and_save_tweets(source, query, next_token: next_token)
    end
  end
end
