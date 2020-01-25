require 'test_helper'

class Asciibook::Converter::ExampleTest < Asciibook::Test
  def test_convert_example
    doc = <<~EOF
      ====
      Example
      ====
    EOF

    html = <<~EOF
      <div class="example">
        <p>Example</p>
      </div>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_example_with_title
    doc = <<~EOF
      .Example Title
      ====
      Example
      ====
    EOF

    html = <<~EOF
      <div class="example">
        <h5>Example 1. Example Title</h5>
        <p>Example</p>
      </div>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_example_with_title_and_custom_caption
    doc = <<~EOF
      :example-caption: Sample

      .Example Title
      ====
      Example
      ====
    EOF

    html = <<~EOF
      <div class="example">
        <h5>Sample 1. Example Title</h5>
        <p>Example</p>
      </div>
    EOF

    assert_convert_body html, doc
  end
end
