module Rogue
  class Connection < EventMachine::Connection
    attr_accessor :request, :response, :app, :server

    def initialize(app, server)
      @app = app
      @server = server
    end

    def post_init
      @request  = Rogue::Request.new
      @response = Rogue::Response.new
      @request.parser.on_message_complete = method(:process)
    end

    def receive_data(data)
      @request.parse(data)
    end

    def process
      @request.body.rewind
      rack_response = process_request
      send_response(rack_response)
    end

    def process_request
      @request.env["REMOTE_ADDR"] = remote_address
      @app.call(@request.env)
    end

    def send_response(result)
      return unless result
      result = result.to_a

      @response.status, @response.headers, @response.body = *result

      @response.persist! if @request.persistent?

      @response.each do |chunk|
        send_data chunk
      end

      finish_request
    end

    def finish_request
      if keep_alive?
        @response.close
        post_init
      else
        close_connection_after_writing rescue nil
        @response.close
      end
    end

    def keep_alive?
      @request.keep_alive?
    end

    def unbind
      @server.finish_connection(self)
    end

    def remote_address
      Socket.unpack_sockaddr_in(get_peername)[1]
    rescue
      nil
    end
  end
end
