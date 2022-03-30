require 'tweetkit'

module Tweetkit
  class Client
    module Tweets
      def count(query = '', type: :tweet, **options, &block)
        search = Search.new(query)
        search.evaluate(&block) if block_given?
        get 'tweets/counts/recent', **options.merge!({ query: search.current_query })
      end
    end
  end
end
