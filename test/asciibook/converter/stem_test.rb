require 'test_helper'

class Asciibook::Converter::StemTest < Asciibook::Test
  def test_convert_stem_latexmath
    doc = <<~'EOF'
      [latexmath]
      ++++
      C = \alpha + \beta Y^{\gamma} + \epsilon
      ++++
    EOF

    html = <<~'EOF'
      <div data-type="equation">
        \\[C = \alpha + \beta Y^{\gamma} + \epsilon\\]
      </div>
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
      <div data-type="equation">
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
      <div data-type="equation">
        <h5>Math Title</h5>
        \\$sqrt(4) = 2\\$
      </div>
    EOF

    assert_convert_body html, doc
  end

end
