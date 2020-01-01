module Asciibook
  class Book
    def initialize(source:, options: {})
      @source = source
      @options = options
    end

    def build
      asciidoc = Asciidoctor.load_file @source, backend: 'htmlbook'
      doc = REXML::Document.new asciidoc.convert(header_footer: true)
      dir = File.dirname(File.expand_path @source)
      Builders::HtmlBuilder.new(doc, dir).build
    end
  end
end
