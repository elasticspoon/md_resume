# frozen_string_literal: true

require_relative 'lib/md_resume/version'

Gem::Specification.new do |spec|
  spec.name = 'md_resume'
  spec.version = MdResume::VERSION
  spec.authors = ['YuriBocharov']
  spec.email = ['quesadillaman@gmail.com']

  spec.summary = 'Ruby gem for creating resume from markdown file.'
  spec.description = 'Write a resume in markdown, style it with CSS, distribute it as either HTML or PDF. Now with even faster feedback cycles, make changes and preview them immediately!</br></br><code>md-resume</code> is a resume generator written in Ruby styled with CSS. Instead of stopping at exclusively generation of a resume in HTML or PDF format, the project goes further in letting you perfect your resume. Running <code>resume.rb</code> in development mode will spin up a local server that will watch your changes to the resume styles and content. The server will live update an HTML preview of your resume letting you move quickly with changes and updates. The project uses <code>kramdown</code> to translate markdown to HTML, bringing with it additional inline markdown customization options.'
  spec.homepage = 'https://github.com/elasticspoon/markdown-resume'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/elasticspoon/markdown-resume'
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'foreman', '~> 0.87'
  spec.add_dependency 'guard', '~> 2.18'
  spec.add_dependency 'guard-livereload', '~> 2.5'
  spec.add_dependency 'guard-process', '~> 1.0'
  spec.add_dependency 'guard-shell', '~> 0.7'
  spec.add_dependency 'kramdown', '~> 2.4'
  spec.add_dependency 'webrick', '~> 1.8'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
