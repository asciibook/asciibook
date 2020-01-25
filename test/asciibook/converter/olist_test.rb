require 'test_helper'

class Asciibook::Converter::OlistTest < Asciibook::Test
  def test_convert_olist
    doc = <<~EOF
      . listitem
      . listitem
      . listitem
    EOF

    html = <<~EOF
      <ol class="olist">
        <li>
          <p>listitem</p>
        </li>
        <li>
          <p>listitem</p>
        </li>
        <li>
          <p>listitem</p>
        </li>
      </ol>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_olist_nested
    doc = <<~EOF
      . listitem
      .. listitem
      . listitem
    EOF

    html = <<~EOF
      <ol class="olist">
        <li>
          <p>listitem</p>
          <ol class="olist">
            <li>
              <p>listitem</p>
            </li>
          </ol>
        </li>
        <li>
          <p>listitem</p>
        </li>
      </ol>
    EOF

    assert_convert_body html, doc
  end

end
