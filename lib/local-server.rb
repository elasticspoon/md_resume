require 'webrick'
require 'filewatcher'

class Server
  attr_reader :opts, :generator

  def initialize(generator, cli_opts)
    @opts = cli_opts
    @generator = generator
  end

  def start
    watch_files
    start_local_server
  end

  def filewatcher
    @filewatcher ||= Filewatcher.new([opts.input, opts.css_path])
  end

  def watch_files
    generator.send(:write_html)
    @thread = Thread.new(filewatcher) do |fw|
      fw.watch do |change|
        puts "Change detected: #{change}"
        generator.send(:write_html)
      end
    end
  ensure
    filewatcher.stop
    @thread.kill
  end

  def start_local_server
    root = opts.html_path
    server = WEBrick::HTTPServer.new Port: 8000, DocumentRoot: root

    trap 'INT' do server.shutdown end

    server.start
  end
end
