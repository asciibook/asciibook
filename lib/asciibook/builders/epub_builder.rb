module Asciibook
  module Builders
    class EpubBuilder < BaseBuilder
      def initialize(book)
        super
        @dest_dir = File.join(@book.dest_dir, 'epub')
        @theme_dir = File.join(@book.theme_dir, 'epub')
      end

      def build
        FileUtils.mkdir_p @dest_dir

        layout = Liquid::Template.parse(File.read(File.join(@theme_dir, 'layout.html')))

        # Satisfy epub specifications
        @book.pages.each do |page|
          page.path = page.path.gsub(/.html$/, '.xhtml')
        end

        epub = GEPUB::Book.new do |book|
          book.title = @book.title
          book.identifier = @book.doc.attributes['identifier'] || 'undefined'
          book.language = @book.doc.attributes['language'] || 'en'

          id_pool = GEPUB::Package::IDPool.new

          @book.assets.each do |path|
            book.add_item path, content: File.open(File.join(@book.base_dir, path)), id: id_pool.generate_key(prefix: 'asset_')
          end

          Dir.glob('**/*.{jpb,png,gif,svg,css,js}', File::FNM_CASEFOLD, base: @theme_share_dir).each do |path|
            book.add_item path, content: File.open(File.join(@theme_share_dir, path)), id: id_pool.generate_key(prefix: 'theme_asset_')
          end

          Dir.glob('**/*.{jpb,png,gif,svg,css,js}', File::FNM_CASEFOLD, base: @theme_dir).each do |path|
            book.add_item path, content: File.open(File.join(@theme_dir, path)), id: id_pool.generate_key(prefix: 'theme_asset_')
          end

          book.ordered do
            @book.pages.each do |page|
              page_hash = page.to_hash
              page_hash['content'] = postprocess(page_hash['content'])

              html = layout.render(
                'book' => @book.to_hash,
                'page' => page_hash
              )
              book.add_item page.path, content: StringIO.new(html), id: id_pool.generate_key(prefix: 'page_')
            end
          end

          book.add_tocdata tocdata
        end

        epub.generate_epub(File.join(@dest_dir, "#{@book.basename}.epub"))

        # restore page path
        @book.pages.each do |page|
          page.path = page.path.gsub(/.xhtml$/, '.html')
        end
      end

      def postprocess(xhtml)
        doc = Nokogiri::XML.fragment(xhtml)

        footnotes = []
        doc.css('span[data-type="footnote"]').each do |node|
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
            <a epub:type="noteref" href="#_footnotedef_#{index}">[#{index}]</a>
          EOF

          if first
            node['id'] = "_footnoteref_#{index}"
          end
        end

        if footnotes.any?
          footnote_html = '<div class="footnotes">'
          footnotes.each_with_index do |footnote, index|
            index += 1
            footnote_html << <<~EOF
              <aside epub:type="footnote" id="_footnotedef_#{index}">
                <a href="#_footnoteref_#{index}">#{index}</a>. #{footnote}
              </aside>
            EOF
          end
          footnote_html << '</div>'
          doc.add_child footnote_html
        end

        doc.to_s
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
