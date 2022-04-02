require 'tweetkit'

module Tweetkit
  class Client
    module Tweets
      def archive(query = '', type: :tweet, **options, &block)
        search = Search.new(query)
        search.evaluate(&block) if block_given?
        get 'tweets/search/all', **options.merge!({ query: search.current_query })
      end

      def count(query = '', type: :tweet, **options, &block)
        search = Search.new(query)
        search.evaluate(&block) if block_given?
        get 'tweets/counts/all', **options.merge!({ query: search.current_query })
      end
    end
  end
end
