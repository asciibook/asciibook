module Asciibook
  module Builders
    class HtmlBuilder < BaseBuilder
      def initialize(book)
        super
        @dest_dir = File.join(@book.dest_dir, 'html')
        @theme_dir = File.join(@book.theme_dir, 'html')
      end

      def build
        FileUtils.mkdir_p @dest_dir
        FileUtils.rm_r Dir.glob("#{@dest_dir}/*")

        generate_pages
        copy_assets
      end

      def generate_pages
        layout = Liquid::Template.parse(File.read(File.join(@theme_dir, 'layout.html')))
        @book.pages.each do |page|
          page_hash = page.to_hash
          page_hash['content'] = postprocess(page_hash['content'])

          File.open(File.join(@dest_dir, page.path), 'w') do |file|
            file.write layout.render({
              'book' => @book.to_hash,
              'page' => page_hash
            })
          end
        end
      end

      def postprocess(xhtml)
        doc = Nokogiri::XML.fragment(xhtml)

        footnotes = []
        doc.css('span[class="footnote"]').each do |node|
          footnote = node.text

          if footnotes.include?(footnote)
            index = footnotes.index(footnote)
            first = false
          else
            footnotes.push footnote
            index = footnotes.index(footnote)
            first = true
          end
          index += 1

          node.inner_html = <<~EOF
            <a href="#_footnotedef_#{index}">[#{index}]</a>
          EOF

          if first
            node['id'] = "_footnoteref_#{index}"
          end
        end

        if footnotes.any?
          footnote_html = '<footer>'
          footnotes.each_with_index do |footnote, index|
            index += 1
            footnote_html << <<~EOF
              <aside id="_footnotedef_#{index}">
                <a href="#_footnoteref_#{index}">#{index}</a>. #{footnote}
              </aside>
            EOF
          end
          footnote_html << '</footer>'
          doc.add_child footnote_html
        end

        doc.to_s
      end

      def copy_assets
        @book.assets.each do |path|
          copy_file(path, @book.base_dir, @dest_dir)
        end

        Dir.glob('**/*.{jpb,png,gif,svg,css,js}', File::FNM_CASEFOLD, base: @theme_share_dir).each do |path|
          copy_file(path, @theme_share_dir, @dest_dir)
        end

        Dir.glob('**/*.{jpb,png,gif,svg,css,js}', File::FNM_CASEFOLD, base: @theme_dir).each do |path|
          copy_file(path, @theme_dir, @dest_dir)
        end
      end
    end
  end
end
