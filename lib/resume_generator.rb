require 'kramdown'
require 'base64'
require 'open3'
require 'fileutils'
require 'pathname'

class ResumeGenerator
  attr_reader :opts

  ValueError = Class.new(StandardError)

  POSTAMBLE = <<~POSTAMBLE.freeze
      </div>
      </body>
      <script>
    #{File.read(File.expand_path('../assets/reload.js', __dir__))}
      </script>
      </html>
  POSTAMBLE

  CHROME_GUESSES_MACOS = [
    '/Applications/Chromium.app/Contents/MacOS/Chromium',
    '/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary',
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
  ].freeze

  LINUX_CHROME_DIRS = [
    '/usr/local/sbin',
    '/usr/local/bin',
    '/usr/sbin',
    '/usr/bin',
    '/sbin',
    '/bin',
    '/opt/google/chrome',
    "/etc/profiles/per-user/#{ENV['USER']}/bin" # NixOS
  ].freeze

  LINUX_CHROME_EXECUTABLES = %w[google-chrome chrome chromium chromium-browser].freeze

  def initialize(cli_opts, is_cli: true)
    @opts = cli_opts
    @opts.chrome_path = guess_chrome_path if @opts.pdf && @opts.chrome_path.nil?
    set_server_opts unless is_cli
  end

  def write
    valid_input?
    write_html
    write_pdf
  end

  def valid_input?
    puts "Input file: #{@opts.input}"
    return if File.exist?(@opts.input)

    puts "Resume not found at #{@opts.input}"
    exit
  end

  def write_template
    curr = Pathname.new(__FILE__).dirname
    relative = Pathname.new('../assets/sample-resume.md')
    template = File.expand_path(relative, curr)
    FileUtils.copy_file(template, @opts.input)
  end

  private

  def chrome_guesses_linux
    LINUX_CHROME_DIRS.product(LINUX_CHROME_EXECUTABLES).map do |dir, exe|
      "#{dir}/#{exe}"
    end
  end

  def chrome_guesses_windows
    [
      # Windows 10
      File.expand_path('Google/Chrome/Application/chrome.exe', ENV.fetch('ProgramFiles(x86)', nil)),
      File.expand_path('Google/Chrome/Application/chrome.exe', ENV.fetch('ProgramFiles(x86)', nil)),
      File.expand_path('Google/Chrome/Application/chrome.exe', ENV.fetch('ProgramFiles(x86)', nil)),
      # Windows 7
      'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
      'C:/Program Files/Google/Chrome/Application/chrome.exe',
      # Vista
      'C:/Users/UserName/AppData/Local/Google/Chrome',
      # XP
      'C:/Documents and Settings/UserName/Local Settings/Application Data/Google/Chrome'
    ]
  end

  def guess_chrome_path
    guesses = case RUBY_PLATFORM
              when /darwin/
                CHROME_GUESSES_MACOS
              when /cygwin|mswin|mingw|bccwin|wince|emx/
                chrome_guesses_windows
              else
                chrome_guesses_linux
              end
    guesses.each do |path|
      if File.exist?(path)
        puts "Guessed Chrome path: #{path}" if opts.verbose
        return path
      end
    end

    raise ValueError,
          "Cannot guess Chrome path on platform #{RUBY_PLATFORM}.
           Please set --chrome_path= manually."
  end

  def to_html
    markdown = File.read(opts.input)
    make_html(markdown, css_file: opts.css_path)
  end

  def to_pdf
    make_pdf(to_html)
  end

  def make_pdf(html)
    html64 = Base64.encode64(html.encode('utf-8')).chomp
    prefix = opts.pdf_path.basename
    tmp_dir = Pathname.new(Dir.pwd).join('tmp')
    FileUtils.mkdir(tmp_dir) unless File.directory?(tmp_dir)
    options = pdf_opts_string(tmp_dir)
    create_output_dir(opts.pdf_path)

    begin
      cmd = "#{opts.chrome_path} #{options} --print-to-pdf=#{opts.pdf_path} 'data:text/html;base64,#{html64}'"
      _stdout, stderr, status = Open3.capture3(cmd)
      raise stderr unless status.success?

      puts "Wrote #{prefix}" if opts.verbose
    rescue StandardError => e
      puts e.message
    ensure
      FileUtils.rm_rf(tmp_dir)
      puts "Could not delete #{tmp_dir}" if File.directory?(tmp_dir)
    end
  end

  def pdf_opts_string(tmp_dir)
    options = [
      '--no-sandbox',
      '--headless',
      '--no-pdf-header-footer',
      '--enable-logging=stderr',
      '--log-level=2',
      '--in-process-gpu',
      '--disable-gpu'
    ]
    options.push("--crash-dumps-dir=#{tmp_dir}")
    options.push("--user-data-dir=#{tmp_dir}")
    options.join(' ')
  end

  def preamable(title, css)
    <<~PREAMBLE
      <html lang="en">
      <head>
      <meta charset="UTF-8">
      <meta property="time_built" content="#{Time.now.iso8601}">
      <title>#{title}</title>
      <style>
      #{css}
      </style>
      </head>
      <body>
      <div id="resume">
    PREAMBLE
  end

  def title(markdown)
    # Return the contents of the first markdown heading in md, which we
    #   assume to be the title of the document.
    markdown.each_line do |line|
      return Regexp.last_match(1) if line =~ /^#([^#]*)$/
    end

    raise ValueError,
          'Cannot find any lines that look like markdown h1 headings to use as the title'
  end

  def reload_script
    File.read(File.expand_path('assets/reload.js', __dir__))
  end

  def make_html(markdown, css_file: nil)
    title = title(markdown)
    html = Kramdown::Document.new(markdown).to_html
    begin
      css = File.read(css_file.to_s)
    rescue Errno::ENOENT
      warn "Cannot find CSS file #{css_file}"
      warn 'Output will not be styled'
      css = ''
    end
    preamable(title, css) + html + POSTAMBLE
  end

  def write_html
    puts "Writing HTML to #{opts.html_path}"
    File.write(opts.html_path, to_html, mode: 'w') if opts.html
  rescue Errno::ENOENT => e
    raise e unless e.message =~ /No such file or directory/

    create_output_dir(opts.html_path)
    retry
  end

  def write_pdf
    to_pdf if opts.pdf
  end

  def create_output_dir(path)
    FileUtils.mkdir_p(File.dirname(path))
  end

  def set_server_opts
    opts.html_path = Pathname.new(Dir.pwd).join('tmp/resume.html')
    opts.html = true
    opts.pdf = false
    opts.verbose = true
  end
end
