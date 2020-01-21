require 'test_helper'

class Asciibook::Converter::InlineQuoteTest < Asciibook::Test
  def test_convert_inline_quoted_em
    doc = <<~EOF
      __text__
    EOF

    html = <<~EOF
      <p>
        <em>text</em>
      </p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_quoted_strong
    doc = <<~EOF
      **text**
    EOF

    html = <<~EOF
      <p>
        <strong>text</strong>
      </p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_quoted_monospaced
    doc = <<~EOF
      `text`
    EOF

    html = <<~EOF
      <p>
        <code>text</code>
      </p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_quoted_sup
    doc = <<~EOF
      ^text^
    EOF

    html = <<~EOF
      <p>
        <sup>text</sup>
      </p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_quoted_sub
    doc = <<~EOF
      ~text~
    EOF

    html = <<~EOF
      <p>
        <sub>text</sub>
      </p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_quoted_double
    doc = <<~EOF
      "`text`"
    EOF

    html = <<~EOF
      <p>
        &#8220;text&#8221;
      </p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_quoted_single
    doc = <<~EOF
      '`text`'
    EOF

    html = <<~EOF
      <p>
        &#8216;text&#8217;
      </p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_quoted_mark
    doc = <<~EOF
      #text#
    EOF

    html = <<~EOF
      <p>
        <mark>text</mark>
      </p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_quoted_asciimath
    doc = <<~EOF
      asciimath:[math]
    EOF

    html = <<~'EOF'
      <p>
        \\$math\\$
      </p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_quoted_latexmath
    doc = <<~EOF
      latexmath:[math]
    EOF

    html = <<~'EOF'
      <p>
        \\(math\\)
      </p>
    EOF

    assert_convert_body html, doc
  end
end
