# frozen_string_literal: true

require_relative 'lib/md_resume/version'

Gem::Specification.new do |spec|
  spec.name = 'md_resume'
  spec.version = MdResume::VERSION
  spec.authors = ['elasticspoon']
  spec.email = ['quesadillaman@gmail.com']

  spec.summary = 'Ruby gem for creating resume from markdown file.'
  spec.description = 'Write a resume in markdown, style it with CSS,
    edit it with a live server and distribute it as either HTML or PDF.'
  spec.homepage = 'https://github.com/elasticspoon/md_resume'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/elasticspoon/md_resume'
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
  spec.add_dependency 'filewatcher', '~> 2.1'
  spec.add_dependency 'kramdown', '~> 2.4'
  spec.add_dependency 'webrick', '~> 1.8'
end
