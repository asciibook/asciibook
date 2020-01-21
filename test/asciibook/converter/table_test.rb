require 'test_helper'

class Asciibook::Converter::TableTest < Asciibook::Test
  def test_convert_table
    doc = <<~EOF
      |===

      | Cell in column 1, row 1 | Cell in column 2, row 1

      | Cell in column 1, row 2 | Cell in column 2, row 2

      | Cell in column 1, row 3 | Cell in column 2, row 3

      |===
    EOF

    html = <<-EOF
      <table>
        <tbody>
          <tr>
            <td>Cell in column 1, row 1</td>
            <td>Cell in column 2, row 1</td>
          </tr>
          <tr>
            <td>Cell in column 1, row 2</td>
            <td>Cell in column 2, row 2</td>
          </tr>
          <tr>
            <td>Cell in column 1, row 3</td>
            <td>Cell in column 2, row 3</td>
          </tr>
        </tbody>
      </table>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_table_with_title_header
    doc = <<~EOF
      .Table Title
      |===
      | Name of Column 1 | Name of Column 2 | Name of Column 3

      | Cell in column 1, row 1
      | Cell in column 2, row 1
      | Cell in column 3, row 1

      | Cell in column 1, row 2
      | Cell in column 2, row 2
      | Cell in column 3, row 2
      |===
    EOF

    html = <<-EOF
      <table>
        <caption>Table 1. Table Title</caption>
        <thead>
          <tr>
            <th>Name of Column 1</th>
            <th>Name of Column 2</th>
            <th>Name of Column 3</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Cell in column 1, row 1</td>
            <td>Cell in column 2, row 1</td>
            <td>Cell in column 3, row 1</td>
          </tr>
          <tr>
            <td>Cell in column 1, row 2</td>
            <td>Cell in column 2, row 2</td>
            <td>Cell in column 3, row 2</td>
          </tr>
        </tbody>
      </table>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_table_with_colspan_rowspan
    doc = <<~EOF
      .Table Title
      |===
      | Name of Column 1 | Name of Column 2 | Name of Column 3

      2+| Cell in column 1, 2, row 1
      | Cell in column 3, row 1

      .2+| Cell in column 1, row 2, 3
      | Cell in column 2, row 2
      | Cell in column 3, row 2

      | Cell in column 2, row 2
      | Cell in column 3, row 2
      |===
    EOF

    html = <<-EOF
      <table>
        <caption>Table 1. Table Title</caption>
        <thead>
          <tr>
            <th>Name of Column 1</th>
            <th>Name of Column 2</th>
            <th>Name of Column 3</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td colspan="2">Cell in column 1, 2, row 1</td>
            <td>Cell in column 3, row 1</td>
          </tr>
          <tr>
            <td rowspan="2">Cell in column 1, row 2, 3</td>
            <td>Cell in column 2, row 2</td>
            <td>Cell in column 3, row 2</td>
          </tr>
          <tr>
            <td>Cell in column 2, row 2</td>
            <td>Cell in column 3, row 2</td>
          </tr>
        </tbody>
      </table>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_table_with_title_and_custom_caption
    doc = <<~EOF
      :table-caption: Data
      .Table Title
      |===
      |===
    EOF

    html = <<~EOF
      <table>
        <caption>Data 1. Table Title</caption>
      </table>
    EOF

    assert_convert_body html, doc
  end
end
