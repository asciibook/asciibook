module Asciibook
  class Page
    attr_accessor :id, :title, :element, :parent, :children, :prev_page, :next_page

    def initialize(id:, title:, element:)
      @id = id
      @title = title
      @element = element
    end

    def to_hash
      {
        'id' => id,
        'title' => title,
        'content' => element.to_s,
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
