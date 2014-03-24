require "test_helper"

describe Rogue::Request do
  before do
    @request = Rogue::Request.new
  end

  it "should setup parser and initial body" do
    @request.parser.must_be_instance_of Http::Parser
    @request.body.string.must_be_empty
  end

  it "should include basic headers" do
    @request.parse("GET / HTTP/1.1\r\nHost: localhost\r\n\r\n")

    @request.env["HTTP_VERSION"].must_equal "HTTP/1.1"
    @request.env["REQUEST_METHOD"].must_equal "GET"
    @request.env["REQUEST_URI"].must_equal "/"
    @request.env["REQUEST_PATH"].must_equal "/"
    @request.env["QUERY_STRING"].must_be_empty
    @request.env["FRAGMENT"].must_be_empty
  end

  it "should support fragment in uri" do
    @request.parse("GET /path?custom=1#page1\r\nHost: localhost\r\n\r\n")

    @request.env["REQUEST_URI"].must_equal "/path?custom=1#page1"
    @request.env["PATH_INFO"].must_equal "/path"
    @request.env["QUERY_STRING"].must_equal "custom=1"
    @request.env["FRAGMENT"].must_equal 'page1'
  end

  it "should parse path with query string" do
    @request.parse("GET /index.html?234235 HTTP/1.1\r\nHost: localhost\r\n\r\n")

    @request.env['REQUEST_PATH'].must_equal '/index.html'
    @request.env['QUERY_STRING'].must_equal '234235'
    @request.env['FRAGMENT'].must_be_nil
  end

  it "should upcase headers" do
    @request.parse("GET / HTTP/1.1\r\nX-Custom: custom\r\n\r\n")

    @request.env["HTTP_X_CUSTOM"].must_equal "custom"
  end

  it "should not prepend HTTP_ to Content-Type and Content-Length" do
    @request.parse("POST / HTTP/1.1\r\nHost: localhost\r\nContent-Type: text/html\r\nContent-Length: 2\r\n\r\naa")

    @request.env.keys.must_include "CONTENT_TYPE"
    @request.env.keys.must_include "CONTENT_LENGTH"
    @request.env.keys.wont_include "HTTP_CONTENT_TYPE"
    @request.env.keys.wont_include "HTTP_CONTENT_LENGTH"
  end

  it 'should parse headers from GET request' do
    @request.parse(<<-EOS)
GET / HTTP/1.1
Host: myhost.com:3000
User-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.9) Gecko/20071025 Firefox/2.0.0.9
Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
Accept-Language: en-us,en;q=0.5
Accept-Encoding: gzip,deflate
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
Cookie: mium=7
Keep-Alive: 300
Connection: keep-alive

EOS
    @request.env['HTTP_HOST'].must_equal 'myhost.com:3000'
    @request.env['SERVER_NAME'].must_equal 'myhost.com'
    @request.env['SERVER_PORT'].must_equal '3000'
    @request.env['HTTP_COOKIE'].must_equal 'mium=7'

    @request.keep_alive?.must_equal true
  end

    it 'should parse POST request with data' do
      @request.parse(<<-EOS.chomp)
POST /postit HTTP/1.1
Host: localhost:3000
User-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.9) Gecko/20071025 Firefox/2.0.0.9
Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
Accept-Language: en-us,en;q=0.5
Accept-Encoding: gzip,deflate
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
Keep-Alive: 300
Connection: keep-alive
Content-Type: text/html
Content-Length: 37

name=marc&email=macournoyer@gmail.com
EOS

    @request.env['REQUEST_METHOD'].must_equal 'POST'
    @request.env['REQUEST_URI'].must_equal '/postit'
    @request.env['CONTENT_TYPE'].must_equal 'text/html'
    @request.env['CONTENT_LENGTH'].must_equal '37'
    @request.env['HTTP_ACCEPT'].must_equal 'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5'
    @request.env['HTTP_ACCEPT_LANGUAGE'].must_equal 'en-us,en;q=0.5'

    @request.body.rewind
    @request.body.read.must_equal 'name=marc&email=macournoyer@gmail.com'
    @request.body.class.must_equal StringIO
  end
end
