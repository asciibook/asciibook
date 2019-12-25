module Asciibook
  class Book
    def initialize(source:, options: {})
      @source = source
      @options = options
    end

    def build
      asciidoc = Asciidoctor.load_file @source, backend: 'htmlbook'
      doc = REXML::Document.new asciidoc.convert(header_footer: true)

      path = File.dirname(@source)
      build_path = File.join(path, 'build/html')
      FileUtils.rm_r build_path
      FileUtils.mkdir_p build_path

      book_title = doc.elements['html/head/title'].text
      theme_path = File.expand_path('../../../themes/default/', __FILE__)
      layout = Liquid::Template.parse(File.read(File.join(theme_path, 'html', 'layout.html')))
      doc.elements.each('html/body/section') do |section|
        File.open(File.join(build_path, "#{section['id']}.html"), 'w') do |file|
          file.write layout.render({
            'book' => {
              'title' => book_title,
              'toc' => book_toc(doc)
            },
            'page' => {
              'title' => section.elements['h1']&.text,
              'content' => section.to_s
            }
          })
        end
      end

      # copy theme assets
      theme_assets = Dir.glob(File.join(theme_path, 'html', '*'))
      FileUtils.cp_r theme_assets, build_path
    end

    # Fixme: url from anchor to page url
    # Todo: tree toc
    def book_toc(doc)
      toc = []
      doc.elements.each('html/body/nav/ol/li/a') do |element|
        toc << { 'title' => element.text, 'url' => element['href'] }
      end
      toc
    end
  end
end
