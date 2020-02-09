require 'test_helper'

class Asciibook::Converter::StemTest < Asciibook::Test
  def test_convert_stem_latexmath
    doc = <<~'EOF'
      :imagesdir: tmp

      [latexmath]
      ++++
      C = \alpha + \beta Y^{\gamma} + \epsilon
      ++++
    EOF

    html = <<~'EOF'
      <figure class='image'>
        <img src='tmp/stem-85bf4fca8fed5e01907287200263ca82.png' alt='$$C = \alpha + \beta Y^{\gamma} + \epsilon$$' width='95' height='12'/>
      </figure>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_stem_asciimath
    doc = <<~'EOF'
      [asciimath]
      ++++
      sqrt(4) = 2
      ++++
    EOF

    html = <<~'EOF'
      <div class="stem">
        \\$sqrt(4) = 2\\$
      </div>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_stem_with_title
    doc = <<~EOF
      .Math Title
      [stem]
      ++++
      sqrt(4) = 2
      ++++
    EOF

    html = <<~'EOF'
      <div class="stem">
        <h5>Math Title</h5>
        \\$sqrt(4) = 2\\$
      </div>
    EOF

    assert_convert_body html, doc
  end

end
