module Rogue
  class Server
    attr_accessor :app
    attr_reader :host, :port

    def initialize(app, &block)
      @app = app
      @app = Rack::Builder.new(&block).to_app if block
      @connections = []
    end

    def start(host, port)
      @host = host
      @port = port
      starter = proc do
        @signature = EventMachine.start_server(@host, @port, Connection, @app, self) do |conn|
          @connections << conn
        end
        @running = true
      end

      EventMachine.error_handler{ |error| puts error.message }

      Signal.trap("INT")  { stop }
      Signal.trap("TERM") { stop }

      puts "Rogue #{::Rogue::VERSION} starting..."
      puts "-> Listening on http://#{@host}:#{@port} <-"

      if EventMachine.reactor_running?
        starter.call
      else
        EventMachine.run(&starter)
      end
    end

    def finish_connection(connection)
      @connections.delete(connection)
    end

    def stop
      puts "-> Stopping server..."
      return unless @running
      @running = false

      EventMachine.stop_server(@signature)

      unless wait_for_connections_and_stop
        Signal.trap("INT")  { EventMachine.stop }
        Signal.trap("TERM") { EventMachine.stop }
        puts "Waiting for connection(s) to finish..."
        EventMachine.add_periodic_timer(1) { wait_for_connections_and_stop }
      end
    end

    private

    def wait_for_connections_and_stop
      if @connections.empty?
        EventMachine.stop
        true
      else
        false
      end
    end
  end
end
