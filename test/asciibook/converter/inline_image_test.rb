require 'test_helper'

class Asciibook::Converter::InlineImageTest < Asciibook::Test
  def test_convert_inline_image
    doc = <<~EOF
      image:http://example.com/logo.png[]
    EOF

    html = <<~EOF
      <p><img src="http://example.com/logo.png" alt="logo" /></p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_image_with_title
    doc = <<~EOF
      image:http://example.com/logo.png[alt, title="title"]
    EOF

    html = <<~EOF
      <p><img src="http://example.com/logo.png" alt="alt" title="title" /></p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_image_with_imagesdir
    doc = <<~EOF
      :imagesdir: images

      image:logo.png[alt, title="title"]
    EOF

    html = <<~EOF
      <p><img src="images/logo.png" alt="alt" title="title" /></p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_image_with_size_and_link
    doc = <<~EOF
      image:http://example.com/logo.png[logo, 400, 300]
    EOF

    html = <<~EOF
      <p><img src="http://example.com/logo.png" alt="logo" width="400" height="300" /></p>
    EOF

    assert_convert_body html, doc
  end

end
