require 'test_helper'

class Asciibook::Builders::PdfBuilderTest < Asciibook::Test
  def test_prepare_toc_xsl
    book = Asciibook::Book.load_file fixture_path('example/source.adoc')
    book.process
    page = book.pages.find {|page| page.node.is_a?(Asciidoctor::Section) && page.node.sectname == 'toc' }
    builder = Asciibook::Builders::PdfBuilder.new(book)
    builder.prepare_workdir
    builder.prepare_toc_xsl(page)
    doc = Nokogiri::XML(File.read fixture_path('example/build/pdf/tmp/toc.xsl'))
    assert_equal 'Table of Contents', doc.css('h1').text
    builder.clean_workdir
  end
end
