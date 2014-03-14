module Rogue
  class Request
    attr_reader :parser, :env, :body

    PROTOTYPE_ENV = {
      "SERVER_SOFTWARE"   => "Rogue #{::Rogue::VERSION}".freeze,
      "SCRIPT_NAME"       => "",
      "GATEWAY_INTERFACE" => "CGI/1.2",
      "rack.url_scheme"   => "http",
      "rack.errors"       => STDERR,
      "rack.multithread"  => false,
      "rack.multiprocess" => false,
      "rack.run_once"     => false,
      "rack.version"      => Rack::VERSION
    }.freeze

    BLANK = ''
    BLANK.encode!(Encoding::ASCII_8BIT) if BLANK.respond_to?(:encode!)
    BLANK.freeze

    def initialize
      @parser = Http::Parser.new
      @parser.on_body = proc { |chunk| @body << chunk }
      @parser.on_headers_complete = proc { |headers| @headers = headers }

      @body = StringIO.new(BLANK.dup)
    end

    def parse(data)
      @parser << data
    end

    def env
      @env ||= begin
        uri = URI(@parser.request_url)
        server = URI("http://#{@headers["Host"] || "localhost"}")
        http_version = "HTTP/#{@parser.http_version.join(".")}"

        env = PROTOTYPE_ENV.dup
        env.merge!({
          "HTTP_VERSION"    => http_version,
          "SERVER_PROTOCOL" => http_version,
          "REQUEST_METHOD"  => @parser.http_method,
          "REQUEST_URI"     => @parser.request_url,
          "REQUEST_PATH"    => uri.path,
          "QUERY_STRING"    => uri.query || "",
          "FRAGMENT"        => uri.fragment,
          "PATH_INFO"       => uri.path,
          "SERVER_NAME"     => server.host,
          "SERVER_PORT"     => server.port.to_s,
          "rack.input"      => @body
        })

        if @headers.key?("Content-Length")
          env["CONTENT_LENGTH"] = @headers.delete("Content-Length")
        end

        if @headers.key?("Content-Type")
          env["CONTENT_TYPE"] = @headers.delete("Content-Type")
        end

        @headers.each do |header, value| 
          env["HTTP_#{header.upcase.gsub('-','_')}"] = value
        end
        env
      end
    end

    def keep_alive?
      @parser.keep_alive?
    end
  end
end
