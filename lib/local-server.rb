require 'webrick'
require 'socket'
require 'filewatcher'

class Server
  attr_reader :opts, :generator

  def initialize(generator, opts)
    @opts = opts
    @generator = generator
    @needs_reload = false
  end

  def start
    start_file_watcher
    start_reload_server
    open_browser
    start_local_server
  ensure
    clean_build_dir
  end

  private

  def filewatcher
    puts "watching #{opts.input} and #{opts.css_path}" if opts.verbose
    @filewatcher ||= Filewatcher.new([opts.input, opts.css_path])
  end

  def open_browser
    link = "http://localhost:#{opts.port}"
    if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
      system "start #{link}"
    elsif RbConfig::CONFIG['host_os'] =~ /darwin/
      system "open #{link}"
    elsif RbConfig::CONFIG['host_os'] =~ /linux|bsd/
      system "xdg-open #{link}"
    end
  end

  def start_file_watcher
    generator.write
    @thread = Thread.new(filewatcher) do |fw|
      fw.watch do |change|
        puts "Change detected: #{change}" if opts.verbose
        generator.write
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

  def headers
    headers = [
      'HTTP/1.1 200 OK',
      'Content-Type: text/html',
      "Access-Control-Allow-Origin: http://localhost:#{opts.port}"
    ]
    @headers ||= "#{headers.join("\r\n")}\r\n\r\n"
  end

  def clean_build_dir
    tmp_dir = opts.html_path.dirname
    FileUtils.rm_rf(tmp_dir)
    puts "Could not delete #{tmp_dir}" if File.directory?(tmp_dir)
  end
end
