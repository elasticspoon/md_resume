require 'optparse'
require 'pathname'

class Parser
  class ScriptOptions
    attr_accessor :chrome_path, :html, :pdf, :css_path, :pdf_path, :html_path, :verbose, :live_reload, :input,
                  :serve_only

    def initialize
      self.chrome_path = nil
      self.html = true
      self.pdf = true
      self.css_path = default_css_path
      self.pdf_path = Pathname.new('resume.pdf').expand_path
      self.html_path = Pathname.new('resume.html').expand_path
      self.verbose = false
      self.live_reload = false
      self.serve_only = false
      self.input = nil
    end

    def define_options(parser)
      parser.banner = 'Usage: md_resume command filename [options...]'
      parser.separator ''
      parser.separator 'Commands:'
      parser.separator "serve\t\t\tStart a local server to preview your resume"
      parser.separator "build\t\t\tBuild your resume in html and pdf formats."
      parser.separator "generate\t\tGenerate a resume template with the given filename"
      parser.separator ''
      parser.separator 'Specific options:'

      # add additional options
      specify_chrome_path_option(parser)
      boolean_pdf_option(parser)
      boolean_html_option(parser)
      specify_output_pdf_option(parser)
      specify_output_html_option(parser)
      specify_input_css_option(parser)
      boolean_live_reload_option(parser)
      boolean_serve_only_option(parser)
      boolean_verbosity_option(parser)
      parser.separator ''
      parser.separator 'Common options:'
      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      parser.on_tail('-h', '--help', 'Show this message') do
        puts parser
        exit
      end
    end

    def specify_chrome_path_option(parser)
      # Specifies an optional option argument
      parser.on('--chrome-path=PATH', 'Path to Chrome executable') do |path|
        full_path = Pathname.new(path).expand_path
        self.chrome_path = full_path
      end
    end

    def specify_output_html_option(parser)
      parser.on('-h PATH', '--html-path=PATH', 'Path of html output') do |path|
        input_dir = Pathname.new(path).expand_path
        self.html_path = input_dir
      end
    end

    def specify_output_pdf_option(parser)
      parser.on('-p PATH', '--pdf-path=PATH', 'Path of pdf output') do |path|
        input_dir = Pathname.new(path).expand_path
        self.pdf_path = input_dir
      end
    end

    def specify_input_css_option(parser)
      parser.on('--css-path=PATH', 'Path of css inputs.') do |path|
        input_dir = Pathname.new(path).expand_path
        self.css_path = input_dir
      end
    end

    def boolean_verbosity_option(parser)
      parser.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
        self.verbose = v
      end
    end

    def boolean_live_reload_option(parser)
      # Boolean switch.
      parser.on('--live-reload', 'Start a live dev-server using foreman', 'This rebuild your html output and use livereload to refresh your browser',
                'You will need the livereload browser extension for the reloading to work') do |v|
        self.live_reload = v
      end
    end

    def boolean_pdf_option(parser)
      # Boolean switch.
      parser.on('--no-pdf', 'Do not write pdf output') do |v|
        self.pdf = v
      end
    end

    def boolean_html_option(parser)
      # Boolean switch.
      parser.on('--no-html', 'Do not write html output') do |v|
        self.html = v
      end
    end

    def boolean_serve_only_option(parser)
      # Boolean switch.
      parser.on('--serve-only') do |v|
        self.serve_only = v
      end
    end

    private

    def default_css_path
      curr = Pathname.new(__FILE__).dirname
      relative = Pathname.new('../assets/defaults.css')
      File.expand_path(relative, curr)
    end
  end

  #
  # Return a structure describing the options.
  #
  def parse(args)
    # The options specified on the command line will be collected in
    # *options*.

    @options = ScriptOptions.new
    @args = OptionParser.new do |parser|
      @options.define_options(parser)
      parser.parse!(args)
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
      puts e
      puts
      puts parser
      exit
    end
    @options
  end

  attr_reader :parser, :options, :args
end
