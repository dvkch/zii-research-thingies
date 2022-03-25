# https://stackoverflow.com/a/5492207/1439489
module ActiveRecord
  class QueryCounter
    IGNORED_SQL = [
      /^PRAGMA (?!(table_info))/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/,
      /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/, /^RELEASE SAVEPOINT/, /^SHOW max_identifier_length/
    ].freeze

    @query_count = 0

    class << self
      attr_accessor :query_count
    end

    def call(name, start, finish, message_id, values)
      return if %w[CACHE SCHEMA].include?(values[:name])
      return if IGNORED_SQL.any? { |r| values[:sql] =~ r }

      self.class.query_count += 1
    end
  end
end

ActiveSupport::Notifications.subscribe('sql.active_record', ActiveRecord::QueryCounter.new)

module ActiveRecord
  class Base
    def self.count_queries(&block)
      ActiveRecord::QueryCounter.query_count = 0
      yield
      ActiveRecord::QueryCounter.query_count
    end
  end
end
