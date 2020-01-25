require 'test_helper'

class Asciibook::Converter::AdmonitionTest < Asciibook::Test
  def test_convert_admonition
    doc = <<~EOF
      NOTE: Text
    EOF

    html = <<~EOF
      <div class="admonition admonition-note">
        Text
      </div>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_admonition_with_title
    doc = <<~EOF
      [NOTE]
      .Title
      ====
      Text
      ====
    EOF

    html = <<~EOF
      <div class="admonition admonition-note">
        <h5>Title</h5>
        <p>Text</p>
      </div>
    EOF

    assert_convert_body html, doc
  end
end
