module Asciibook
  module Builders
    class HtmlBuilder
      def initialize(book)
        @book = book
        @build_dir = File.join(@book.dir, 'build/html')
        @theme_dir = File.expand_path('../../../../themes/default/html', __FILE__)

        @pages = []
        @refs = {}
      end

      def build
        FileUtils.rm_r @build_dir
        FileUtils.mkdir_p @build_dir

        split_pages
        create_refs
        replace_links
        generate_pages
        copy_assets
      end

      def split_pages
        @book.doc.elements.each('/html/body/*[self::section or self::nav or self::div]') do |element|
          page = Asciibook::Page.new(
            id: element['id'],
            title: element.elements['h1']&.text,
            element: element
          )
          if @pages.last
            page.prev_page = @pages.last
            @pages.last.next_page = page
          end
          @pages << page
        end
      end

      def create_refs
        @pages.each do |page|
          @refs[page.id] = page.url

          page.element.elements.each('.//*[@id]') do |element|
            @refs[element['id']] = "#{page.url}##{element['id']}"
          end

          page.element.elements.each('.//*[@name]') do |element|
            @refs[element['name']] = "#{page.url}##{element['name']}"
          end
        end
      end

      def replace_links
        @book.doc.elements.each('/html/body/nav//a | /html/body//a[@data-type="xref"]') do |element|
          if element['href'].start_with?('#')
            _, id = element['href'].split('#')
            element.attributes['href'] = @refs[id]
          end
        end
      end

      def generate_pages
        layout = Liquid::Template.parse(File.read(File.join(@theme_dir, 'layout.html')))
        @pages.each do |page|
          File.open(File.join(@build_dir, "#{page.id}.html"), 'w') do |file|
            file.write layout.render({
              'book' => book_data,
              'page' => page.to_hash
            })
          end
        end
      end

      def copy_assets
        Dir.glob('**/*.{jpg,png,gif,mp3,mp4,ogg,wav}', File::FNM_CASEFOLD, base: @book.dir).each do |path|
          # ignore build dir assets
          if !File.join(@book.dir, path).start_with?(@build_dir)
            copy_file(path, @book.dir, @build_dir)
          end
        end

        Dir.glob('**/*.{jpb,png,gif,svg,css,js}', File::FNM_CASEFOLD, base: @theme_dir).each do |path|
          copy_file(path, @theme_dir, @build_dir)
        end
      end

      def copy_file(path, src_dir, dest_dir)
        src_path = File.join(src_dir, path)
        dest_path = File.join(dest_dir, path)
        FileUtils.mkdir_p File.dirname(dest_path)
        FileUtils.cp src_path, dest_path
      end

      def book_data
        @book_data ||= {
          'title' => @book.doc.elements['html/head/title'].text,
          'toc' => toc_data(@book.doc.elements['html/body/nav'])
        }
      end

      def toc_data(toc)
        data = []
        toc.elements.each('ol/li') do |element|
          item = {}
          anchor = element.elements['a']
          item = { 'title' => anchor.text, 'url' => anchor['href'] }
          if element.elements['ol/li']
            item['items'] = toc_data(element)
          end
          data << item
        end
        data
      end
    end
  end
end
