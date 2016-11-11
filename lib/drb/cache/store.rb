require 'thread'
require 'singleton'
require 'forwardable'
require 'monitor'
require 'drb/cache/gc'
require 'drb/cache/datum'

module DRb
  module Cache
    class Store
      DEFAULT_LIFETIME        = 300 # 5 minutes

      include MonitorMixin

      attr_accessor :dictionary, :gc_provider, :gc, 
                    
      def initialize(gc_provider: DRb::Cache::GC)
        self.clear! # creates a new dictionary
        self.gc = gc_provider.new(self)
      end

      def size
        dictionary.size
      end

      alias_method :length, :size

      def read(key)
        value = dictionary[key]
        value = nil if value && value_expired?(value)
        return value[:value] if value
        nil
      end

      alias_method :[], :read

      def write(key, value, lifetime = DEFAULT_LIFETIME)
        synchronize do
          # TODO: encrypt the value with a private key generated in process.
          dictionary[key] = Datum.new(value, Time.now, lifetime)
        end
        value
      end

      alias_method :[]=, :write

      # Returns the value being deleted that used to map to this key.
      def delete(key)
        value = nil
        synchronize do
          value = read(key)
          dictionary.delete(key)
        end
        value
      end

      def clear!
        synchronize { self.dictionary = {} }
      end

      def gc!
        synchronize { dictionary.delete_if { |*, value| value_expired?(value) } }
      end

      def expires_in?(key)
        value_expires_in?(self[key])
      end

      def expired?(key)
        value_expired?(self[key])
      end

      private

      def value_expires_in?(value)
        result = value.lifetime - (Time.now - value.cached_at)
        result < 0 ? 0 : result
      end

      def value_expired?(value)
        value_expires_in?(value) <= 0 ? true : false
      end

    end
  end
end
