require 'drb/drb'
require 'drb/cache'
require 'tempfile'

require File.join(File.dirname(__FILE__), '../..', 'exe', 'drb-cache-server')

Signal.trap('HUP') do
  File.delete(DRb::Cache::Server.pid_file) if File.exist?(DRb::Cache::Server.pid_file)
  DRb.thread.kill if DRb.thread
end

if File.exist?(DRb::Cache::Server.pid_file)
  begin
    Process.kill('HUP', File.read(DRb::Cache::Server.pid_file).to_i)
  rescue Exception => ex
  end
end

File.open(DRb::Cache::Server.pid_file, 'w') do |file|
  file.write Process.pid
end

DRb.start_service ENV['COIN_URI'], DRb::Cache::Server::Vault.instance
puts "DRb::Cache::Server::Vault listening at: #{ENV['COIN_URI']}" if ENV['COIN_DEBUG']
DRb.thread.join


module DRb
  class CLI
    
  end
end
