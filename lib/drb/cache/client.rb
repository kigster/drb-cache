require 'drb/drb'
require 'rbconfig'
require 'forwardable'

module DRb
  module Cache
    class Client
      extend Forwardable
      def_delegators :server, :write, :read_and_delete, :delete, :clear, :length


      public

      def read(key, lifetime=300)
        value = server.read(key)
        if value.nil? && block_given?
          value = yield
          write(key, value, lifetime)
        end
        value
      end
    end
  end
end
