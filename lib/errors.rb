# frozen_string_literal: true

module ZiiResearchThingies
  class Error < RuntimeError
    attr_accessor :error

    def initialize(msg = nil, error: nil)
      super(msg)
      @error = error
    end
  end
end
