# md_resume

https://github.com/elasticspoon/md_resume/assets/14540596/d5034437-2842-4974-bffb-dbeacc742030

Write your resume in [Markdown](https://raw.githubusercontent.com/mikepqr/resume.md/main/resume.md), style it with [CSS](resume.css), output to [HTML](resume.html) and [PDF](resume.pdf). Open a your resume in the browser and watch it update live with changes made to the markdown.

## Prerequisites

- Ruby ≥ 3.0
- Optional, required for PDF output: Google Chrome or Chromium

## Installation

```bash
gem install md_resume
```

## Usage

```
Usage: md_resume command filename [options…]

Commands:
serve         Start a local server to preview your resume
build         Build your resume in html and pdf formats.
generate      Generate a template with given name (defaults to markdown)

Specific options:
        --chrome-path=PATH      Path to Chrome executable
        --no-pdf                Do not write pdf output
        --no-html               Do not write html output
    -p, --pdf-path=PATH         Path of pdf output
    -h, --html-path=PATH        Path of html output
        --css-path=PATH         Path of css inputs.
        --server-port=PORT      Specify the localhost port number for the server
        --serve-only
    -v, --[no-]verbose          Run verbosely

Common options:
        --help Show this message
```

## Customization

You can generate the default style sheet with `md_resume generate-css FILENAME`. The default style is extremely generic, which is perhaps what you want in a resume,
but CSS gives you a lot of flexibility. See, e.g. [The Tech Resume Inside-Out](https://www.thetechinterview.com/) for good advice about what a resume should look like (and what it should say).

Change the appearance of the PDF version (without affecting the HTML version) by adding rules under the `@media print` CSS selector.
Change the margins and paper size of the PDF version by editing the [`@page` CSS rule](https://developer.mozilla.org/en-US/docs/Web/CSS/%40page/size).

## Note

The idea for the project is based off of https://github.com/mikepqr/resume.md. I could not get python to play nice so I rewrote it in Ruby and added features.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elasticspoon/md_resume.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
