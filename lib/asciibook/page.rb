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

    def to_hash
      {
        'path' => path,
        'title' => title,
        'content' => content,
        'image_url' => image_url,
        'description' => description,
        'prev_page' => prev_page && { 'path' => prev_page.path, 'title' => prev_page.title },
        'next_page' => next_page && { 'path' => next_page.path, 'title' => next_page.title }
      }
    end
  end
end
