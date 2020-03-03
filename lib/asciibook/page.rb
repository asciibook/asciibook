module Asciibook
  class Page
    attr_accessor :path, :node, :prev_page, :next_page, :footnotes

    def initialize(path:, node:)
      @path = path
      @node = node

      @footnotes = []
    end

    def title
      node.title
    end

    def content
      @content ||= node.convert
    end

    def doc
      @doc ||= Nokogiri::HTML.fragment(content)
    end

    def image_url
      doc.css('img').first&.attr('src')
    end

    def description
      doc.css('p').first&.text
    end

    def outline
      outline_node(@node)
    end

    # page outline only list sections that not split as page
    def outline_node(node)
      data = []
      node.sections.each do |section|
        if !section.page
          section_data = {
            'title' => section.xreftext,
            'path' => "##{section.id}"
          }
          if section.sections.count > 0
            section_data['items'] = outline_node(section)
          end
          data << section_data
        end
      end
      data
    end

    def to_hash
      {
        'path' => path,
        'title' => title,
        'content' => content,
        'image_url' => image_url,
        'description' => description,
        'outline' => outline,
        'prev_page' => prev_page && { 'path' => prev_page.path, 'title' => prev_page.title },
        'next_page' => next_page && { 'path' => next_page.path, 'title' => next_page.title }
      }
    end
  end
end
