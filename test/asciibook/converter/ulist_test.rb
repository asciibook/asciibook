require 'test_helper'

class Asciibook::Converter::UlistTest < Asciibook::Test
  def test_convert_ulist
    doc = <<~EOF
      * listitem
      * listitem
      * listitem
    EOF

    html = <<~EOF
      <ul class="ulist">
        <li>
          <p>listitem</p>
        </li>
        <li>
          <p>listitem</p>
        </li>
        <li>
          <p>listitem</p>
        </li>
      </ul>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_ulist_nested
    doc = <<~EOF
      * listitem
      ** listitem
      * listitem
    EOF

    html = <<~EOF
      <ul class="ulist">
        <li>
          <p>listitem</p>
          <ul class="ulist">
            <li>
              <p>listitem</p>
            </li>
          </ul>
        </li>
        <li>
          <p>listitem</p>
        </li>
      </ul>
    EOF

    assert_convert_body html, doc
  end
end
