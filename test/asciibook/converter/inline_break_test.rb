require 'test_helper'

class Asciibook::Converter::InlineBreakTest < Asciibook::Test
  def test_convert_inline_break
    doc = <<~EOF
      line +
      line
    EOF

    html = <<~EOF
      <p>line<br/>
      line</p>
    EOF

    assert_convert_body html, doc
  end
end
