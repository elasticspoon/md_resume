require 'webrick'

class Server
  attr_reader :opts

  def initialize(opts)
    @opts = opts
  end

  def start
    if opts.serve_only
      start_local_server
    else
      foreman_start
    end
  ensure
    FileUtils.rm_rf('tmp')
  end

  def create_guardfile
    guardfile = <<~GUARDFILE
      guard 'process', :name => 'Rebuild Dev Site', :command => 'md_resume build #{opts.input} --no-pdf --html-path tmp/resume.html', :stop_signal => "KILL"  do
        watch(%r{#{opts.input}})
        watch(%r{#{opts.css_path}})
      end
    GUARDFILE

    livereload = <<~LIVERELOAD
      guard 'livereload' do
        watch(#{opts.input})
        watch(%r{tmp/resume.html})
      end
    LIVERELOAD
    File.write('tmp/Guardfile', guardfile)
    File.write('tmp/Guardfile', livereload, { mode: 'a' }) if opts.live_reload
  end

  def create_tmp_dir
    FileUtils.mkdir_p('tmp')
  end

  def foreman_start
    create_tmp_dir
    create_guardfile
    create_procfile

    exec 'foreman start -f tmp/Procfile'
  rescue Errno::EEXIST => e
    puts "Error: #{e.message}"
  end

  def guardfile_path
    @guardfile_path ||= File.expand_path './tmp/Guardfile'
  end

  def create_procfile
    procfile = <<~PROCFILE
      live-server: md_resume serve #{opts.input} --serve-only --html-path tmp/resume.html
      guard-watch: bundle exec guard -w #{File.dirname(opts.input)} -G #{guardfile_path}
    PROCFILE

    File.write('tmp/Procfile', procfile)
  end

  def start_local_server
    root = opts.html_path
    server = WEBrick::HTTPServer.new Port: 8000, DocumentRoot: root

    trap 'INT' do server.shutdown end

    server.start
  end
end
