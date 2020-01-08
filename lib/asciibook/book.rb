module Asciibook
  class Book
    attr_reader :data, :options, :doc, :pages

    def initialize(data, options = {})
      @data = data
      @options = options

      @page_level = @options[:page_level] || 1
      @doc = Asciidoctor.load(@data, backend: 'asciibook')
      process_pages
    end

    def title
      doc.attributes['doctitle']
    end

    def toc
      doc.converter.outline doc
    end

    def build
      Builders::HtmlBuilder.new(self).build
    end

    def process_pages
      @pages = []
      process_page(doc)
      @pages
    end

    def process_page(node)
      append_page(node)

      if node.level < @page_level
        node.sections.each do |section|
          process_page(section)
        end
      end
    end

    def append_page(node)
      page = Page.new(node)

      if last_page = @pages.last
        page.prev_page = last_page
        last_page.next_page = page
      end

      node.page = page
      @pages << page
    end
  end
end
