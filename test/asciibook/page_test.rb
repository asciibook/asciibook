require 'test_helper'

class Asciibook::PageTest < Asciibook::Test
  def test_image_path
    doc = Asciidoctor.load <<~EOF
      image::image/logo.png[]
    EOF
    page = Asciibook::Page.new path: 'test.html', node: doc
    assert_equal 'image/logo.png', page.image_url
  end

  def test_description
    doc = Asciidoctor.load <<~EOF
      text description

      other text
    EOF
    page = Asciibook::Page.new path: 'test.html', node: doc
    assert_equal 'text description', page.description
  end

  def test_outline
    book = Asciibook::Book.new <<~EOF
      = Book Title

      == Section 1

      === Seciton 1.1

      === Seciton 1.2
    EOF
    book.process

    assert_equal [], book.pages[0].outline
    assert_equal [
      {"title" => "Seciton 1.1", "path" => "#_seciton_1_1"},
      {"title" => "Seciton 1.2", "path"=>"#_seciton_1_2"}
    ], book.pages[1].outline
  end
end
