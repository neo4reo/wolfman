module Wolfman
  class Jumpbox
    class JumpboxError < StandardError
    end

    def self.configured?
      Config.exists?(:jumpbox, :host)
    end

    def self.connected?(host: nil, port: nil)
      host ||= config_host
      port ||= config_port
      Timeout::timeout(1) do
        socket = TCPSocket.new(host, port)
        socket.close
      end
      true
    rescue SocketError, Timeout::Error
      false
    end

    def self.check_connection!(host: nil, port: nil)
      connected?(host: host, port: port) or raise JumpboxError.new("Unable to connect to jumpbox.")
    end

    def self.config_host
      Config.get!(:jumpbox, :host)
    end

    def self.config_port
      (Config.get(:jumpbox, :port) || 22).to_i
    end
  end
end
