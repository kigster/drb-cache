module DRb
  module Cache
    class Datum
      attr_accessor :value, :cached_at, :lifetime

      def initialize(*args)
        self.value, self.cached_at, self.lifetime = *args
      end

      def inspect
        "<#{self.class.name}##{'%x' % (self.object_id << 1)} value: #{value}, cached_at: #{cached_at}, lifetime: #{}>"
      end
    end
  end
end
