module Asciibook
  module Builders
    class HtmlBuilder
      def initialize(doc, dir)
        @doc = doc
        @dir = dir
      end

      def build
        build_dir = File.join(@dir, 'build/html')
        FileUtils.rm_r build_dir
        FileUtils.mkdir_p build_dir

        theme_dir = File.expand_path('../../../../themes/default/html', __FILE__)
        layout = Liquid::Template.parse(File.read(File.join(theme_dir, 'layout.html')))
        @doc.elements['/html/body'].elements.each do |section|
          case section['data-type']
          when 'part'
            # Todo
          else
            File.open(File.join(build_dir, "#{section['id']}.html"), 'w') do |file|
              file.write layout.render({
                'book' => book_data,
                'page' => {
                  'title' => section.elements['h1']&.text,
                  'content' => section.to_s
                }
              })
            end
          end
        end

        Dir.glob('**/*.{jpg,png,gif,mp3,mp4,ogg,wav}', File::FNM_CASEFOLD, base: @dir).each do |path|
          # ignore build dir assets
          if !File.join(@dir, path).start_with?(build_dir)
            copy_file(path, @dir, build_dir)
          end
        end

        Dir.glob('**/*.{jpb,png,gif,svg,css,js}', File::FNM_CASEFOLD, base: theme_dir).each do |path|
          copy_file(path, theme_dir, build_dir)
        end
      end

      def copy_file(path, src_dir, dest_dir)
        src_path = File.join(src_dir, path)
        dest_path = File.join(dest_dir, path)
        FileUtils.mkdir_p File.dirname(dest_path)
        FileUtils.cp src_path, dest_path, verbose: true
      end

      def book_data
        @book_data ||= {
          'title' => @doc.elements['html/head/title'].text,
          'toc' => toc_data(@doc.elements['html/body/nav'])
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
        element = @doc.elements["//*[@id='#{id}']"]
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
