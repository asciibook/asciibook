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
        <pre>def hello
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
        <pre>def hello
          puts "hello world!"
        end</pre>
      </figure>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_listing_with_highlight
    doc = <<~EOF
      :source-highlighter: rouge

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
        <pre class='rouge highlight'><code data-lang='ruby'><span class='k'>def</span> <span class='nf'>hello</span>
        <span class='nb'>puts</span> <span class='s2'>\"hello world!\"</span>
        <span class='k'>end</span></code></pre>
      </figure>
    EOF

    assert_convert_body html, doc
  end
end
