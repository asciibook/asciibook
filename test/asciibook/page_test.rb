require 'test_helper'

class Asciibook::PageTest < Asciibook::Test
  def test_content_constant
    doc = Asciidoctor.load <<~EOF, backend: 'asciibook'
      == Section

      footnote:[content]
    EOF

    section = doc.sections.last
    page = Asciibook::Page.new path: 'test.html', node: section
    section.page = page
    html = page.content
    assert_equal html, page.content
  end
end
