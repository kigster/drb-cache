require 'thread'
require 'drb/cache/store'
module DRb
  module Cache
    class GC
      PERIOD_SECONDS = 30

      attr_accessor :resource, :period

      def initialize(resource)
        self.resource = resource
        self.period   = PERIOD_SECONDS
        periodically { sweep }
      end

      def periodically
        @thread ||= Thread.new do
          loop do
            sleep(PERIOD_SECONDS)
            yield(resource) if block_given?
          end
        end
      end

      def gc!
        begin
          resource.gc!
        rescue Exception => e
          STDERR.puts "error sweeping the store, #{e.message}"
          STDERR.puts e.inspect
          sleep period
        end
      end
    end
  end
end
