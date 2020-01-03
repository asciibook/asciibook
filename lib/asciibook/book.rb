module Asciibook
  class Book
    attr_reader :data, :dir, :options

    def initialize(data:, dir:, options: {})
      @data = data
      @dir = dir
      @options = options
    end

    def build
      Builders::HtmlBuilder.new(self).build
    end

    def doc
      @doc ||= begin
        asciidoc = Asciidoctor.load @data, backend: 'htmlbook'
        REXML::Document.new asciidoc.convert(header_footer: true)
      end
    end
  end
end
