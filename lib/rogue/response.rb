module Rogue
  class Response
    attr_accessor :status, :headers, :body

    def initialize
      @status = 200
      @keep_alive = false
      @headers = {}
    end

    def close
      @body.close if @body.respond_to?(:close)
    end

    def each
      yield head
      @body.each { |chunk| yield chunk }
    end

    def keep_alive!
      @keep_alive = true
    end

    private

    def head
      lines = []
      lines << "HTTP/1.1 #{@status}\r\n"
      lines += generate_header_lines(@headers)
      lines << "\r\n"
      lines.join
    end

    def generate_header_lines(headers)
      output = []
      headers.each do |header, value|
        output << "#{header}: #{value}\r\n"
      end
      output
    end
  end
end
