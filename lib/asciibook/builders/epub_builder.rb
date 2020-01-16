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

        # Satisfy epub specifications
        @book.pages.each do |page|
          page.path = page.path.gsub(/.html$/, '.xhtml')
        end

        epub = GEPUB::Book.new do |book|
          book.identifier = 'testid'
          book.title = @book.title
          book.language = 'zh'

          @book.assets.each do |path|
            book.add_item path, content: File.open(File.join(@book.base_dir, path))
          end

          Dir.glob('**/*.{jpb,png,gif,svg,css,js}', File::FNM_CASEFOLD, base: @theme_dir).each do |path|
            book.add_item path, content: File.open(File.join(@theme_dir, path))
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

        # restore page path
        @book.pages.each do |page|
          page.path = page.path.gsub(/.xhtml$/, '.html')
        end
      end

      def tocdata
        outline(@book.doc, 1)
      end

      def outline(node, level)
        data = []
        node.sections.each do |section|
          data << {
            text: section.xreftext,
            link: section.page ? section.page.path : "#{@book.find_page_node(section).page.path}##{section.id}",
            level: level
          }
          if section.sections.count > 0 and section.level < (@book.doc.attributes['toclevels'] || 2).to_i
            data.concat outline(section, level + 1)
          end
        end
        data
      end
    end
  end
end
