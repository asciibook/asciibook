module Asciibook
  class Book
    def initialize(source:, options: {})
      @source = source
      @options = options
    end

    def build
      asciidoc = Asciidoctor.load_file @source, backend: 'htmlbook'
      doc = REXML::Document.new asciidoc.convert(header_footer: true)

      output = ""
      doc.write output: output, indent: 2

      path = File.dirname(@source)
      build_path = File.join(path, 'build/html')
      FileUtils.rm_r build_path
      FileUtils.mkdir_p build_path

      book_title = doc.elements['html/head/title'].text
      layout = Liquid::Template.parse(File.read(File.expand_path('../../../themes/default/html/layout.html', __FILE__)))
      doc.elements.each('html/body/section') do |section|
        File.open(File.join(build_path, section['id']), 'w') do |file|
          file.write layout.render({
            'book' => {
              'title' => book_title
            },
            'page' => {
              'title' => section.elements['h1'].text,
              'content' => doc.elements['html/body'].elements.map(&:to_s).join
            }
          })
        end
      end
    end
  end
end
