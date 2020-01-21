require 'test_helper'

class Asciibook::Converter::ThematicBreakTest < Asciibook::Test
  def test_convert_thematic_break
    doc = <<~EOF
      '''
    EOF

    html = <<~EOF
      <hr />
    EOF

    assert_convert_body html, doc
  end
end
