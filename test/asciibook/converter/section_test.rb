require 'test_helper'

class Asciibook::Converter::SectionTest < Asciibook::Test
  def test_convert_section_part
    doc = <<~EOF
      = Book
      :doctype: book

      [[part]]
      = Part Title

      [[chapter]]
      == Chapter Title
    EOF

    html = <<~EOF
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset=\"utf-8\" />
          <title>Book</title>
        </head>
        <body data-type="book">
          <h1>Book</h1>
          <div id="part" data-type="part">
            <h1>Part Title</h1>
            <section id="chapter" data-type="chapter">
              <h1>Chapter Title</h1>
            </section>
          </div>
        </body>
      </html>
    EOF

    assert_convert_html html, doc
  end

  def test_convert_section_chapter
    doc = <<~EOF
      [[chapter]]
      == Chapter Title
    EOF

    html = <<~EOF
      <section id="chapter" data-type="chapter">
        <h1>Chapter Title</h1>
      </section>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_section_sect1
    doc = <<~EOF
      [[section]]
      === Section Title
    EOF

    html = <<~EOF
      <section id="section" data-type="sect1">
        <h2>Section Title</h2>
      </section>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_section_sect2
    doc = <<~EOF
      [[section]]
      ==== Section Title
    EOF

    html = <<~EOF
      <section id="section" data-type="sect2">
        <h3>Section Title</h3>
      </section>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_section_preface
    doc = <<~EOF
      [preface]
      [[preface]]
      == Preface Title
    EOF

    html = <<~EOF
      <section id="preface" data-type="preface">
        <h1>Preface Title</h1>
      </section>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_section_with_sectnum
    doc = <<~EOF
      :sectnums!:

      [preface]
      == Preface

      :sectnums:

      == Chapter One

      === Section One

      == Chapter Two

      [appendix]
      == First Appendix

      [appendix]
      == Second Appendix
    EOF

    html = <<~EOF
      <section id='_preface' data-type='preface'>
        <h1>Preface</h1>
      </section>
      <section id='_chapter_one' data-type='chapter'>
        <h1>1. Chapter One</h1>
        <section id='_section_one' data-type='sect1'>
          <h2>1.1. Section One</h2>
        </section>
      </section>
      <section id='_chapter_two' data-type='chapter'>
        <h1>2. Chapter Two</h1>
      </section>
      <section id='_first_appendix' data-type='appendix'>
        <h1>Appendix A: First Appendix</h1>
      </section>
      <section id='_second_appendix' data-type='appendix'>
        <h1>Appendix B: Second Appendix</h1>
      </section>
    EOF

    assert_convert_body html, doc
  end
end
