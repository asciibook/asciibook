require 'test_helper'

class Asciibook::Converter::InlineFootnoteTest < Asciibook::Test
  def test_convert_footnote
    doc = <<~EOF
      Content.footnote:[Footnote content.]
    EOF

    html = <<~EOF
      <p>Content.<sup class="footnote" id="_footnoteref_1"><a epub:type='noteref' href="#_footnotedef_1">[1]</a></sup></p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_footnoteref
    doc = <<~EOF
      Content one.footnote:refid[Footnote content.]

      Content two.footnote:refid[]
    EOF

    html = <<~EOF
      <p>Content one.<sup class="footnote" id="_footnoteref_1"><a epub:type='noteref' href="#_footnotedef_1">[1]</a></sup></p>

      <p>Content two.<sup class="footnote"><a epub:type='noteref' href="#_footnotedef_1">[1]</a></sup></p>
    EOF

    assert_convert_body html, doc
  end
end
