require 'test_helper'

class Asciibook::Converter::LiteralTest < Asciibook::Test
  def test_convert_literal
    doc = <<~EOF
      ....
      Text
      ....
    EOF

    html = <<~EOF
      <pre>Text</pre>
    EOF

    assert_convert_body html, doc
  end
end
