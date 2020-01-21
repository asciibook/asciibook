require 'test_helper'

class Asciibook::Converter::PassTest < Asciibook::Test
  def test_convert_pass
    doc = <<~EOF
      ++++
      Pass
      ++++
    EOF

    html = <<~EOF
      Pass
    EOF

    assert_convert_body html, doc
  end
end
