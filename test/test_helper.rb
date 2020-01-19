$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'asciibook'

require 'minitest/autorun'

class Asciibook::Test < Minitest::Test
  def fixture_path(path)
    File.join File.expand_path('../fixtures', __FILE__), path
  end

  def assert_convert_body(html, doc, options = {})
    except_html = <<~EOF
      <body data-type="book">
        #{html}
      </body>
    EOF

    actual_html = <<~EOF
      <body data-type="book">
        #{Asciidoctor.convert doc, options.merge(backend: 'asciibook')}
      </body>
    EOF

    assert_equal pretty_format(except_html), pretty_format(actual_html)
  end

  def assert_convert_html(html, doc, options = {})
    actual_html = Asciidoctor.convert doc, options.merge(backend: 'asciibook', header_footer: true)

    assert_equal pretty_format(html), pretty_format(actual_html)
  end

  def assert_equal_html(except, actual, options = {})
    except_html = <<~EOF
      <body>
        #{except}
      </body>
    EOF

    actual_html = <<~EOF
      <body>
        #{actual}
      </body>
    EOF
    assert_equal pretty_format(except_html), pretty_format(actual_html)
  end

  def pretty_format(html)
    out = ""
    REXML::Document.new(html).write(out, 2)
    out.gsub(/\s*$/, '')
  rescue
    puts html
    raise
  end
end
