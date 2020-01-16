module Asciibook
  module Builders
    class EpubBuilder < BaseBuilder
      def initialize(book)
        super
        @build_dir = File.join(@book.build_dir, 'epub')
        @theme_dir = File.join(@book.theme_dir, 'epub')
      end

      def build
        FileUtils.mkdir_p @build_dir

        layout = Liquid::Template.parse(File.read(File.join(@theme_dir, 'layout.html')))

        epub = GEPUB::Book.new do |book|
          book.identifier = 'testid'
          book.title = @book.title
          book.language = 'zh'

          @book.assets.each do |path|
            book.add_item path, content: File.open(File.join(@book.base_dir, path))
          end

          book.ordered do
            @book.pages.each do |page|
              html = layout.render(
                'book' => @book.to_hash,
                'page' => page.to_hash
              )
              book.add_item(page.path, content: StringIO.new(html))
            end
          end

          book.add_tocdata tocdata
        end

        epub.generate_epub(File.join(@build_dir, 'output.epub'))
      end

      def tocdata
        flatten_toc_items @book.toc, 1
      end

      def flatten_toc_items(items, level)
        data = []
        items.each do |item|
          data << {
            link: item['path'],
            text: item['title'],
            level: level
          }

          if item['items']
            data += flatten_toc_items(item['items'], level + 1)
          end
        end
        data
      end
    end
  end
end
