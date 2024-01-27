require 'optparse'
require 'pathname'

class Parser
  class ScriptOptions
    attr_accessor :chrome_path, :html, :pdf, :css_path, :pdf_path, :html_path, :verbose, :input,
                  :serve_only, :port, :open_browser, :generate_md, :generate_css

    def initialize
      self.chrome_path = nil
      self.html = true
      self.pdf = true
      self.open_browser = true
      self.css_path = default_css_path
      self.pdf_path = Pathname.new('resume.pdf').expand_path
      self.html_path = Pathname.new('resume.html').expand_path
      self.verbose = false
      self.serve_only = false
      self.input = nil
      self.port = 3000
      self.generate_md = true
      self.generate_css = false
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
      specify_server_port_option(parser)
      # TODO: remove this?
      boolean_serve_only_option(parser)
      boolean_open_browser_option(parser)
      boolean_verbosity_option(parser)
      boolean_generate_md_option(parser)
      boolean_generate_css_option(parser)
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

    def specify_server_port_option(parser)
      parser.on('--server-port=PORT', 'Specify the localhost port number for the server') do |port|
        port = port.to_i
        raise OptionParser::InvalidArgument unless (1..65_535).cover?(port)

        self.port = port
      end
    end

    def boolean_verbosity_option(parser)
      parser.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
        self.verbose = v
      end
    end

    def boolean_pdf_option(parser)
      # Boolean switch.
      parser.on('--no-pdf', 'Do [not] write pdf output') do |v|
        self.pdf = v
      end
    end

    def boolean_html_option(parser)
      # Boolean switch.
      parser.on('--[no-]html', 'Do [not] write html output') do |v|
        self.html = v
      end
    end

    def boolean_serve_only_option(parser)
      # Boolean switch.
      parser.on('--serve-only') do |v|
        self.serve_only = v
      end
    end

    def boolean_open_browser_option(parser)
      # Boolean switch.
      parser.on('--no-open', 'Do not automatically open browser when starting server') do |v|
        self.open_browser = v
      end
    end

    def boolean_generate_md_option(parser)
      parser.on('--no-generate-md', 'Do not generate markdown template.') do |v|
        self.generate_md = v
      end
    end

    def boolean_generate_css_option(parser)
      parser.on('--[no-]generate-css', 'Generate CSS template.') do |v|
        self.generate_css = v
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
  def parse(command, args)
    @options = ScriptOptions.new
    @args = OptionParser.new do |parser|
      @options.define_options(parser)
      parser.parse!(args)
      set_command_defaults(command)
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
      puts e
      puts
      puts parser
      exit
    end
    @options
  end

  def set_command_defaults(command)
    case command
    when 'serve'
      serve_defaults
    when 'build'
      build_defaults
    when 'generate'
      generate_defaults
    end
  end

  def serve_defaults
    options.pdf = false
    options.html = true
    options.html_path = internal_tmp_dir.join('resume.html')
  end

  def build_defaults(parser); end

  def generate_defaults(parser); end

  attr_reader :parser, :options, :args

  private

  def internal_tmp_dir
    Pathname.new('../../tmp').expand_path(__FILE__)
  end
end
