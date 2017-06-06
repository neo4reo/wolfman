module Wolfman
  class Jumpbox
    class JumpboxError < StandardError
    end

    REQUIRED_CONFIG = %w[host username]

    def self.configured?
      REQUIRED_CONFIG.all? do |key|
        Config.exists?(:jumpbox, key)
      end
    end

    def self.connected?(host: nil, port: nil)
      check_connection!(host: host, port: port)
      true
    rescue JumpboxError
      false
    end

    def self.check_connection!(host: nil, port: nil)
      host ||= config_host
      port ||= config_port
      Timeout::timeout(1) do
        socket = TCPSocket.new(host, port)
        socket.close
      end
      true
    rescue SocketError, Timeout::Error
      raise JumpboxError.new("Unable to connect to jumpbox #{Paint[host, :green]}:#{Paint[port, :green]}.")
    end

    def self.config_host
      Config.get!(:jumpbox, :host)
    end

    def self.config_port
      (Config.get(:jumpbox, :port) || 22).to_i
    end
  end
end
