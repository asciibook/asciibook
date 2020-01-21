require 'test_helper'

class Asciibook::Converter::ListingTest < Asciibook::Test
  def test_convert_listing
    doc = <<~EOF
      [source]
      ----
      def hello
        puts "hello world!"
      end
      ----
    EOF

    html = <<~EOF
      <figure>
        <pre data-type="programlisting">def hello
          puts "hello world!"
        end</pre>
      </figure>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_listing_with_attributes
    doc = <<~EOF
      [[id]]
      [source, ruby]
      .Title
      ----
      def hello
        puts "hello world!"
      end
      ----
    EOF

    html = <<~EOF
      <figure id="id">
        <figcaption>Title</figcaption>
        <pre data-type="programlisting" data-code-language="ruby">def hello
          puts "hello world!"
        end</pre>
      </figure>
    EOF

    assert_convert_body html, doc
  end

end
