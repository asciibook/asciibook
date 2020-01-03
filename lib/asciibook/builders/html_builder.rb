module Asciibook
  module Builders
    class HtmlBuilder
      def initialize(book)
        @book = book
        @build_dir = File.join(@book.dir, 'build/html')
        @theme_dir = File.expand_path('../../../../themes/default/html', __FILE__)
      end

      def build
        FileUtils.rm_r @build_dir
        FileUtils.mkdir_p @build_dir

        split_pages
        generate_pages
        copy_assets
      end

      def split_pages
        @pages = []
        @page_index = {}
        @book.doc.elements.each('/html/body/*[self::section or self::nav or self::div]') do |element|
          page = Asciibook::Page.new(
            id: element['id'],
            title: element.elements['h1']&.text,
            content: element.to_s
          )
          if @pages.last
            page.prev_page = @pages.last
            @pages.last.next_page = page
          end
          @pages << page
          @page_index[page.id] = page
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
          item = { 'title' => anchor.text, 'url' => find_anchor(anchor['href']) }
          if element.elements['ol/li']
            item['items'] = toc_data(element)
          end
          data << item
        end
        data
      end

      # Todo: support data-type="part"
      def find_anchor(anchor)
        _, id = anchor.split('#')
        element = @book.doc.elements["//*[@id='#{id}']"]
        page_element = element

        if page_element.parent.name == 'body'
          "#{id}.html"
        else
          while page_element.parent.name != 'body'
            page_element = page_element.parent
          end
          "#{page_element['id']}.html##{id}"
        end
      end
    end
  end
end
