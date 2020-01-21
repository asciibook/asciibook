require 'test_helper'

class Asciibook::Converter::DocumentTest < Asciibook::Test
  def test_convert_document
    doc = <<~EOF
    EOF

    html = <<~EOF
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset=\"utf-8\" />
        </head>
        <body data-type="book">
        </body>
      </html>
    EOF

    assert_convert_html html, doc
  end

  def test_convert_document_with_title
    doc = <<~EOF
      = Doc Title
    EOF

    html = <<~EOF
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset=\"utf-8\" />
          <title>Doc Title</title>
        </head>
        <body data-type="book">
          <h1>Doc Title</h1>
        </body>
      </html>
    EOF

    assert_convert_html html, doc
  end

  def test_convert_document_with_author
    doc = <<~EOF
      = Doc Title
      Author
    EOF

    html = <<~EOF
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset=\"utf-8\" />
          <title>Doc Title</title>
        </head>
        <body data-type="book">
          <header>
            <h1>Doc Title</h1>
            <p data-type="author">Author</p>
          </header>
        </body>
      </html>
    EOF

    assert_convert_html html, doc
  end

  def test_convert_document_with_title_and_subtitle_and_author
    doc = <<~EOF
      = Doc Title: Subtitle
      Author
    EOF

    html = <<~EOF
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset=\"utf-8\" />
          <title>Doc Title</title>
        </head>
        <body data-type="book">
          <header>
            <h1>Doc Title</h1>
            <p data-type="subtitle">Subtitle</p>
            <p data-type="author">Author</p>
          </header>
        </body>
      </html>
    EOF

    assert_convert_html html, doc
  end
end
