require 'test_helper'

class Asciibook::Converter::VerseTest < Asciibook::Test
  def test_convert_verse
    doc = <<~EOF
      [verse, attribution, citetitle]
      ____
      Line one
      Line two.
      ____
    EOF

    html = <<~EOF

      <blockquote class="verse">
        <pre>Line one
        Line two.</pre>
        <p data-type="attribution">attribution</p>
        <p data-type="citetitle">citetitle</p>
      </blockquote>
    EOF

    assert_convert_body html, doc
  end
end
