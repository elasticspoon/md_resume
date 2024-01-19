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
    puts "watching #{opts.input} and #{opts.css_path}" if opts.verbose
    @filewatcher ||= Filewatcher.new([opts.input, opts.css_path])
  end

  def watch_files
    generator.send(:write_html)
    @thread = Thread.new(filewatcher) do |fw|
      fw.watch do |change|
        puts "Change detected: #{change}" if opts.verbose
        generator.send(:write_html)
      end
    end
  end

  def start_local_server
    puts "Starting local server on port #{opts.port}"
    root = opts.html_path
    server = WEBrick::HTTPServer.new(Port: opts.port, DocumentRoot: root)

    trap 'INT' do server.shutdown end

    server.start
  end
end
