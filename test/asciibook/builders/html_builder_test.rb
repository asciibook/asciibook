require 'test_helper'

class Asciibook::Builders::HtmlBuilderTest < Asciibook::Test
  def test_process_footnotes
    adoc = <<~EOF
      footnote:foobar[footnote text]
      footnote:foobar[]

      footnote:[another footnote]
    EOF

    book = Asciibook::Book.new adoc
    book.process
    builder = Asciibook::Builders::HtmlBuilder.new(book)

    html = <<~EOF
      <p>
        <span data-type='footnote' id='_footnoteref_1'>
          <a href='#_footnotedef_1'>[1]</a>
        </span>
        <span data-type='footnote'>
          <a href='#_footnotedef_1'>[1]</a>
        </span>
      </p>
      <p>
        <span data-type='footnote' id='_footnoteref_2'>
          <a href='#_footnotedef_2'>[2]</a>
        </span>
      </p>
      <footer>
        <aside id='_footnotedef_1'>
          <a href='#_footnoteref_1'>1</a>. footnote text </aside>
        <aside id='_footnotedef_2'>
          <a href='#_footnoteref_2'>2</a>. another footnote
        </aside>
      </footer>
    EOF

    assert_equal_html html, builder.postprocess(book.pages.first.content)
  end
end
