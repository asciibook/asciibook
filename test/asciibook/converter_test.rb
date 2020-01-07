require 'test_helper'

class Asciibook::ConverterTest < Minitest::Test
  include ConverterTestHelper

  def test_convert_xref_with_page
    doc = <<~EOF
      = Book Title

      == Chapter 1

      === Chapter 1.1

      == Chapter 2

      <<Chapter 1>>
      <<Chapter 1.1>>
    EOF

    html = <<~EOF
      <h1>Book Title</h1>
      <section id='_chapter_1' data-type='chapter'>
        <h1>Chapter 1</h1>
        <section id='_chapter_1_1' data-type='sect1'>
          <h1>Chapter 1.1</h1>
        </section>
      </section>
      <section id='_chapter_2' data-type='chapter'>
        <h1>Chapter 2</h1>
        <p>
          <a data-type='xref' href='_chapter_1.html'>Chapter 1</a>
          <a data-type='xref' href='_chapter_1.html#_chapter_1_1'>Chapter 1.1</a>
        </p>
      </section>
    EOF

    book = Asciibook::Book.new doc
    book.doc.sections.each do |section|
      section.page = Asciibook::Page.new(section)
    end
    assert_equal_html html, book.doc.convert
  end
end
