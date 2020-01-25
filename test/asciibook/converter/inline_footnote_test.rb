require 'test_helper'

class Asciibook::Converter::InlineFootnoteTest < Asciibook::Test
  def test_convert_footnote
    doc = <<~EOF
      Content.footnote:[Footnote content.]
    EOF

    html = <<~EOF
      <p>Content.<sup class="footnote" id="_footnoteref_1"><a href="_footnotedef_1">[1]</a></sup></p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_footnoteref
    doc = <<~EOF
      Content one.footnote:refid[Footnote content.]

      Content two.footnote:refid[]
    EOF

    html = <<~EOF
      <p>Content one.<sup class="footnote" id="_footnoteref_1"><a href="_footnotedef_1">[1]</a></sup></p>

      <p>Content two.<sup class="footnote"><a href="_footnotedef_1">[1]</a></sup></p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_footnote_in_multi_page
    doc = <<~EOF
      == Section One
      Content.footnote:[Footnote content.]

      == Section Two
      Content.footnote:[Footnote content.]
    EOF

    page_1_html = <<~EOF
      <section class='section' id='_section_one'>
        <h1>Section One</h1>
        <p>Content. <sup class='footnote' id='_footnoteref_1'><a href='_footnotedef_1'>[1]</a></sup></p>
      </section>
    EOF

    page_2_html = <<~EOF
      <section class='section' id='_section_two'>
        <h1>Section Two</h1>
        <p>Content. <sup class='footnote' id='_footnoteref_1'><a href='_footnotedef_1'>[1]</a></sup></p>
      </section>
    EOF

    book = Asciibook::Book.new doc
    book.process
    assert_equal_html page_1_html, book.pages[1].content
    assert_equal_html page_2_html, book.pages[2].content
  end
end
