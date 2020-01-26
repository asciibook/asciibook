require 'test_helper'

class Asciibook::Converter::IndexTest < Asciibook::Test
  def test_convert_index
    doc = <<~EOF
      == Section

      ((one))

      (((one, two, three)))

      [index]
      == index
    EOF

    html = <<~EOF
      <section class='section' id='_section'>
        <h1>Section</h1>
        <p><a class='indexterm' id='_indexterm_1'>one</a></p>
        <p><a class='indexterm' id='_indexterm_2'>&#8203;</a></p>
      </section>
      <section class='index' id='_index'>
        <h1>index</h1>
        <ul class='index'>
          <li>
            <p>
              one
              <a href='#_indexterm_1'>[1]</a>
            </p>
            <ul>
              <li>
                <p>
                  two
                </p>
                <ul>
                  <li>
                    <p>
                      three
                      <a href='#_indexterm_2'>[1]</a>
                    </p>
                  </li>
                </ul>
              </li>
            </ul>
          </li>
        </ul>
      </section>
    EOF

    assert_convert_body html, doc
  end
end
