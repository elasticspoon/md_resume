require 'webrick'
require 'socket'
require 'filewatcher'

class Server
  attr_reader :opts, :generator

  def initialize(generator, cli_opts)
    @opts = cli_opts
    @generator = generator
    @needs_reload = false
  end

  def start
    watch_files
    start_reload_server
    start_local_server
  end

  def filewatcher
    puts "watching #{opts.input} and #{opts.css_path}" if opts.verbose
    @filewatcher ||= Filewatcher.new([opts.input, opts.css_path])
  end

  def watch_files
    generator.send(:write_html)
    @thread = Thread.new(filewatcher) do |fw|
      fw.watch do |change|
        puts "Change detected: #{change}" if opts.verbose
        generator.send(:write_html)
        @needs_reload = true
      end
    end
  end

  def start_reload_server
    puts 'Starting reload server on port 12345'
    @reload_thread = Thread.new do
      reload_server
    end
  end

  def reload_server
    server = TCPServer.new('localhost', 12_345)

    loop do
      socket = server.accept
      request = socket.gets
      warn request
      sleep 0.5 until @needs_reload
      @needs_reload = false
      socket.print(headers)
      socket.close
    end
  end

  def start_local_server
    puts "Starting local server on port #{opts.port}"
    root = opts.html_path
    server = WEBrick::HTTPServer.new(Port: opts.port, DocumentRoot: root)

    trap 'INT' do server.shutdown end

    server.start
  end

  private

  def headers
    headers = [
      'HTTP/1.1 200 OK',
      'Content-Type: text/html',
      "Access-Control-Allow-Origin: http://localhost:#{opts.port}"
    ]
    @headers ||= "#{headers.join("\r\n")}\r\n\r\n"
  end
end
