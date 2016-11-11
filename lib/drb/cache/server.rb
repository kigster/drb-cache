require 'singleton'
module DRb
  module Cache
    class Server

      attr_accessor :port, :uri, :remote_url

      private

      def initialize(name:, port: 8955, uri: "druby://127.0.0.1:#{port}", remote_url:)
        self.port       = port
        self.uri        = uri
        self.remote_url = remote_url
        self.server
      end
      
      
      def configure(&block)
        yield self if block_given?
        
        if server_running?
          if @server
            begin
              @server.ok? if @server
            rescue DRb::DRbConnError => ex
              @server = nil
            end
          end
      
          if @server.nil?
            begin
              @server = DRbObject.new_with_uri(uri)
              @server.ok?
            rescue DRb::DRbConnError => ex
              @server = nil
            end
          end
        end
      
        return @server if @server && server_running?
      
        start_server
        @server = DRbObject.new_with_uri(uri)
      end
      
      def remote_server
        DRb.start_service
        @server = DRbObject.new_with_uri(remote_uri)
      end
      
      def pid_file
        '/tmp/coin-pid-63f95cb5-0bae-4f66-88ec-596dfbac9244'
      end
      
      def pid
        File.read(DRb::Cache::Server.pid_file) if File.exist?(DRb::Cache::Server.pid_file)
      end
      
      def running?
        @pid = pid
        return false unless @pid
        begin
          Process.kill(0, @pid.to_i)
        rescue Errno::ESRCH => ex
          return false
        end
        true
      end
      
      def start(force=nil)
        return if server_running? && !force
        stop_server if force
        ruby   = "#{RbConfig::CONFIG["bindir"]}/ruby"
        script = File.expand_path(File.join(File.dirname(__FILE__), "..", "bin", "coin"))
        env    = {
          "COIN_URI" => DRb::Cache::Server.uri
        }
        pid    = spawn(env, "#{ruby} #{script}")
        Process.detach(pid)
      
        sleep 0.1 while !server_running?
        DRb.start_service
        true
      end
      
      def stop
        Process.kill("HUP", @pid.to_i) if server_running?
        sleep 0.1 while server_running?
        DRb.stop_service
        true
      end
      
    end
  end
end
