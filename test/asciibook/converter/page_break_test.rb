require 'test_helper'

class Asciibook::Converter::PageBreakTest < Asciibook::Test
  def test_convert_page_break
    doc = <<~EOF
      <<<
    EOF

    html = <<~EOF
      <div class="page-break" />
    EOF

    assert_convert_body html, doc
  end
end
