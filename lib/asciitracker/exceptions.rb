module AsciiTracker

  class Exception < RuntimeError
    attr_accessor :reason
    attr_reader :callstack

    def initialize *args
      super *args
      @callstack = caller
    end
  end

  class InvalidInterrupt < AsciiTracker::Exception; end
  class NotYetImplemented < AsciiTracker::Exception; end

  module Exceptions
    def not_yet_implemented txt = nil
      txt ||= "#{caller[0]} (caller: #{caller[1]})"
      raise NotYetImplemented, txt
    end
  end
end
