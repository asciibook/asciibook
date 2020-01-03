module Asciibook
  class Page
    attr_accessor :id, :title, :content, :parent, :children, :prev_page, :next_page

    def initialize(id:, title:, content:)
      @id = id
      @title = title
      @content = content
    end

    def to_hash
      {
        'id' => id,
        'title' => title,
        'content' => content,
        'url' => url,
        'prev_page' => prev_page && { 'id' => prev_page.id, 'title' => prev_page.title, 'url' => prev_page.url },
        'next_page' => next_page && { 'id' => next_page.id, 'title' => next_page.id, 'url' => next_page.url }
      }
    end

    def url
      "#{id}.html"
    end
  end
end
