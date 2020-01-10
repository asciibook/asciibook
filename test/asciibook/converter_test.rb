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

    document_html = <<~EOF
      <h1>Book Title</h1>
    EOF

    section_1_html = <<~EOF
      <section id='_chapter_1' data-type='chapter'>
        <h1>Chapter 1</h1>
        <section id='_chapter_1_1' data-type='sect1'>
          <h1>Chapter 1.1</h1>
        </section>
      </section>
    EOF

    section_2_html = <<~EOF
      <section id='_chapter_2' data-type='chapter'>
        <h1>Chapter 2</h1>
        <p>
          <a data-type='xref' href='_chapter_1.html'>Chapter 1</a>
          <a data-type='xref' href='_chapter_1.html#_chapter_1_1'>Chapter 1.1</a>
        </p>
      </section>
    EOF


    book = Asciibook::Book.new doc
    book.process
    assert_equal_html document_html, book.doc.convert
    assert_equal_html section_1_html, book.doc.sections[0].convert
    assert_equal_html section_2_html, book.doc.sections[1].convert
  end

  def test_toc_marco
    adoc = <<~EOF
      = Book Name
      :toc: macro
      :toc-title:

      == Table of Content

      toc::[]

      == Chapter 1

      === Chapter 1.1

      == Chapter 2
    EOF

    html = <<~EOF
      <section id='_table_of_content' data-type='chapter'>
        <h1>Table of Content</h1>
        <nav data-type='toc'>
          <ol>
            <li>
              <a href='_table_of_content.html'>Table of Content</a>
            </li>
            <li>
              <a href='_chapter_1.html'>Chapter 1</a>
              <ol>
                <li>
                  <a href='_chapter_1.html#_chapter_1_1'>Chapter 1.1</a>
                </li>
              </ol>
            </li>
            <li>
              <a href='_chapter_2.html'>Chapter 2</a>
            </li>
          </ol>
        </nav>
      </section>
    EOF

    book = Asciibook::Book.new(adoc)
    book.process
    assert_equal 4, book.pages.count
    assert_equal 'Table of Content', book.pages[1].title
    assert_equal_html html, book.pages[1].content
  end
end
