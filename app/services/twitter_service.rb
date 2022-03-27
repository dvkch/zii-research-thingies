require 'open-uri'

class TwitterService
  def initialize
    @token = Rails.application.credentials.dig(:omniauth, :twitter_app_token).presence || raise('No token')
    @client = Tweetkit::Client.new(bearer_token: @token)
  end

  def search(query)
    options = {
      'tweet.fields': 'created_at,public_metrics',
      'user.fields': 'username',
      expansions: 'author_id'
    }

    json = @client.search(
      query,
      type: :tweets,
      **options
    ).response

    users = json.dig('includes', 'users').map { |u| [u['id'], u['username']] }.to_h
    json['data'].map do |tweet|
      TwitterTweet.new(
        twitter_id: tweet['id'],
        content: tweet['text'],
        username: users[tweet['author_id']],
        date: tweet['created_at'],
        **tweet['public_metrics'].slice('retweet_count', 'reply_count', 'like_count', 'quote_count')
      )
    end
  end

  def embed_html(url)
    json = RestClient.get("https://publish.twitter.com/oembed?url=#{url}")
    json = JSON.parse(json)
    json['html']
  end
end
