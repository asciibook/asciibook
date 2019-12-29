module Asciibook
  class Book
    def initialize(source:, options: {})
      @source = source
      @options = options
    end

    def build
      path = File.dirname(@source)
      build_path = File.join(path, 'build/html')
      FileUtils.rm_r build_path
      FileUtils.mkdir_p build_path

      theme_path = File.expand_path('../../../themes/default/', __FILE__)
      layout = Liquid::Template.parse(File.read(File.join(theme_path, 'html', 'layout.html')))
      doc.elements['/html/body'].elements.each do |section|
        case section['data-type']
        when 'part'
          # Todo
        else
          File.open(File.join(build_path, "#{section['id']}.html"), 'w') do |file|
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

      # copy theme assets
      theme_assets = Dir.glob(File.join(theme_path, 'html', '*'))
      FileUtils.cp_r theme_assets, build_path
    end

    def doc
      @doc ||= begin
        asciidoc = Asciidoctor.load_file @source, backend: 'htmlbook'
        REXML::Document.new asciidoc.convert(header_footer: true)
      end
    end

    def book_data
      @book_data ||= {
        'title' => doc.elements['html/head/title'].text,
        'toc' => toc_data(doc.elements['html/body/nav'])
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
      element = doc.elements["//*[@id='#{id}']"]
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
