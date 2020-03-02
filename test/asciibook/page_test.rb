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
end
