require 'test_helper'

class Asciibook::Converter::PreambleTest < Asciibook::Test
  def test_convert_preamble
    doc = <<~EOF
      = Doc Title

      Preamble Text.

      == Chapter Title
    EOF

    html = <<~EOF
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset='utf-8' />
          <title>Doc Title</title>
        </head>
        <body>
          <header>
            <h1>Doc Title</h1>
          </header>
          <section class='preamble'>
            <p>Preamble Text.</p>
          </section>
          <section class="section" id='_chapter_title'>
            <h1>Chapter Title</h1>
          </section>
        </body>
      </html>
    EOF

    assert_convert_html html, doc
  end
end
