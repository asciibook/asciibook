require 'test_helper'

class Asciibook::Converter::ImageTest < Asciibook::Test
  def test_convert_image
    doc = <<~EOF
      image::http://example.com/logo.png[]
    EOF

    html = <<~EOF
      <figure class="image">
        <img src="http://example.com/logo.png" alt="logo" />
      </figure>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_image_with_title
    doc = <<~EOF
      .Image Title
      image::http://example.com/logo.png[]
    EOF

    html = <<~EOF
      <figure class="image">
        <img src="http://example.com/logo.png" alt="logo" />
        <figcaption>Figure 1. Image Title</figcaption>
      </figure>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_image_with_title_and_custom_caption
    doc = <<~EOF
      :figure-caption: Image

      .Image Title
      image::http://example.com/logo.png[]
    EOF

    html = <<~EOF
      <figure class="image">
        <img src="http://example.com/logo.png" alt="logo" />
        <figcaption>Image 1. Image Title</figcaption>
      </figure>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_image_with_size_and_link
    doc = <<~EOF
      image::http://example.com/logo.png[logo, 400, 300, link="http://example.com/"]
    EOF

    html = <<~EOF
      <figure class="image">
        <a href="http://example.com/">
          <img src="http://example.com/logo.png" alt="logo" width="400" height="300" />
        </a>
      </figure>
    EOF

    assert_convert_body html, doc
  end
end
