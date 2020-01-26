require 'test_helper'

class Asciibook::ConvertererTest < Asciibook::Test
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
      <header>
        <h1>Book Title</h1>
      </header>
    EOF

    section_1_html = <<~EOF
      <section class="section" id='_chapter_1'>
        <h1>Chapter 1</h1>
        <section class="section" id='_chapter_1_1'>
          <h2>Chapter 1.1</h2>
        </section>
      </section>
    EOF

    section_2_html = <<~EOF
      <section class="section" id='_chapter_2'>
        <h1>Chapter 2</h1>
        <p>
          <a class='xref' href='_chapter_1.html'>Chapter 1</a>
          <a class='xref' href='_chapter_1.html#_chapter_1_1'>Chapter 1.1</a>
        </p>
      </section>
    EOF


    book = Asciibook::Book.new doc
    book.process
    assert_equal_html document_html, book.doc.convert
    assert_equal_html section_1_html, book.doc.sections[0].convert
    assert_equal_html section_2_html, book.doc.sections[1].convert
  end

  def test_convert_footnote_in_multi_page
    doc = <<~EOF
      == Section One

      Content.footnote:[Footnote content.]

      == Section Two

      Content.footnote:refid[Footnote content.]

      Content.footnote:refid[]
    EOF

    page_1_html = <<~EOF
      <section class='section' id='_section_one'>
        <h1>Section One</h1>
        <p>Content. <sup class='footnote' id='_footnoteref_1'><a epub:type='noteref' href='#_footnotedef_1'>[1]</a></sup></p>
        <footer>
          <aside epub:type='footnote' id='_footnotedef_1'>
            <a href='#_footnoteref_1'>1</a>. Footnote content.
          </aside>
        </footer>
      </section>
    EOF

    page_2_html = <<~EOF
      <section class='section' id='_section_two'>
        <h1>Section Two</h1>
        <p>Content. <sup class='footnote' id='_footnoteref_1'><a epub:type='noteref' href='#_footnotedef_1'>[1]</a></sup></p>
        <p>Content. <sup class='footnote'><a epub:type='noteref' href='#_footnotedef_1'>[1]</a></sup></p>
        <footer>
          <aside epub:type='footnote' id='_footnotedef_1'>
            <a href='#_footnoteref_1'>1</a>. Footnote content.
          </aside>
        </footer>
      </section>
    EOF

    book = Asciibook::Book.new doc
    book.process
    assert_equal_html page_1_html, book.pages[1].content
    assert_equal_html page_2_html, book.pages[2].content
  end

  def test_register_terms
    doc = <<~EOF
      == Section one

      ((one))

      == Section two

      (((one, two, three)))
    EOF

    book = Asciibook::Book.new doc
    book.process
    # trigger convert
    book.pages.each(&:content)
    assert_equal [
      {
        "term" => "one",
        "targets" => ["_section_one.html#_indexterm_1"],
        "items" => [
          {
            "term" => "two",
            "targets" => [],
            "items" => [
              {
                "term" => "three",
                "targets" => ["_section_two.html#_indexterm_2"],
                "items"=>[]
              }
            ]
          }
        ]
      }
    ], book.doc.references[:indexterms]
  end
end
