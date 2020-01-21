require 'test_helper'

class Asciibook::Converter::InlineAnchorTest < Asciibook::Test
  def test_convert_inline_anchor
    doc = <<~EOF
      [[paragraph]]paragraph content
    EOF

    html = <<~EOF
      <p><a id="paragraph"></a>paragraph content</p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_anchor_xref_with_text
    doc = <<~EOF
      <<target, text>>
    EOF

    html = <<~EOF
      <p><a data-type="xref" href="#target">text</a></p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_anchor_xref_with_section
    doc = <<~EOF
      <<Section>>

      [[target]]
      == Section
    EOF

    html = <<~EOF
      <p><a data-type="xref" href="#target">Section</a></p>
      <section id="target" data-type="chapter">
        <h1>Section</h1>
      </section>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_anchor_xref_with_refid
    doc = <<~EOF
      <<Section>>
    EOF

    html = <<~EOF
      <p><a data-type='xref' href='#Section'>[Section]</a></p>
    EOF

    assert_convert_body html, doc
  end


  def test_convert_inline_anchor_ref
    doc = <<~EOF
      [[target]] Content
    EOF

    html = <<~EOF
      <p><a id="target"></a> Content</p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_anchor_link
    doc = <<~EOF
      link:http://example.com/[text]
    EOF

    html = <<~EOF
      <p><a href="http://example.com/">text</a></p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_anchor_link_with_attributes
    doc = <<~EOF
      :linkattrs:

      link:http://example.com/[text, title="title" window="_blank"]
    EOF

    html = <<~EOF
      <p><a href="http://example.com/" title="title" target="_blank">text</a></p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_anchor_bibref
    doc = <<~EOF
      [bibliography]
      == References

      - [[[target]]] Content
      - [[[target2, 2]]] Content
    EOF

    html = <<~EOF
      <section id='_references' data-type='bibliography'>
       <h1>References</h1>
       <ul>
         <li>
           <p>
             <a id='target'/>[target] Content
           </p>
         </li>
         <li>
           <p>
             <a id='target2'/>[2] Content
           </p>
         </li>
       </ul>
     </section>
    EOF

    assert_convert_body html, doc
  end
end
