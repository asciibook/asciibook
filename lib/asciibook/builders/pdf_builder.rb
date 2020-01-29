module Asciibook
  module Builders
    class PdfBuilder < BaseBuilder
      def initialize(book)
        super
        @dest_dir = File.join(@book.dest_dir, 'pdf')
        @tmp_dir = File.join(@dest_dir, 'tmp')
        @theme_dir = File.join(@book.theme_dir, 'pdf')
        @theme_config = YAML.safe_load(File.read(File.join(@theme_dir, 'config.yml')))
      end

      def build
        prepare_workdir
        generate_pages
        copy_assets
        generate_header_footer
        generate_pdf
        #clean_workdir
      end

      def prepare_workdir
        FileUtils.mkdir_p @tmp_dir
        FileUtils.rm_r Dir.glob("#{@tmp_dir}/*")
      end

      def clean_workdir
        FileUtils.rm_r @tmp_dir
      end

      def generate_pages
        layout = Liquid::Template.parse(File.read(File.join(@theme_dir, 'layout.html')))
        @book.pages.each do |page|
          File.open(File.join(@tmp_dir, page.path), 'w') do |file|
            file.write layout.render({
              'book' => @book.to_hash,
              'page' => page.to_hash
            })
          end
        end
      end

      def copy_assets
        @book.assets.each do |path|
          copy_file(path, @book.base_dir, @tmp_dir)
        end

        Dir.glob('**/*.{jpb,png,gif,svg,css,js}', File::FNM_CASEFOLD, base: @theme_share_dir).each do |path|
          copy_file(path, @theme_share_dir, @tmp_dir)
        end

        Dir.glob('**/*.{jpb,png,gif,svg,css,js}', File::FNM_CASEFOLD, base: @theme_dir).each do |path|
          copy_file(path, @theme_dir, @tmp_dir)
        end
      end

      def generate_header_footer
        layout = Liquid::Template.parse <<~EOF
          <!DOCTYPE html>
          <html>
            <head>
              <script>
                function subst() {
                    var vars = {};
                    var query_strings_from_url = document.location.search.substring(1).split('&');
                    for (var query_string in query_strings_from_url) {
                        if (query_strings_from_url.hasOwnProperty(query_string)) {
                            var temp_var = query_strings_from_url[query_string].split('=', 2);
                            vars[temp_var[0]] = decodeURI(temp_var[1]);
                        }
                    }
                    var css_selector_classes = ['page', 'frompage', 'topage', 'webpage', 'section', 'subsection', 'date', 'isodate', 'time', 'title', 'doctitle', 'sitepage', 'sitepages'];
                    for (var css_class in css_selector_classes) {
                        if (css_selector_classes.hasOwnProperty(css_class)) {
                            var element = document.getElementsByClassName(css_selector_classes[css_class]);
                            for (var j = 0; j < element.length; ++j) {
                                element[j].textContent = vars[css_selector_classes[css_class]];
                            }
                        }
                    }
                }
              </script>
              <style>
                html, body {
                  margin: 0;
                  padding: 0;
                }
              </style>
            </head>
            <body onload="subst()">
              {{ content }}
            </body>
          </html>
        EOF

        File.open(File.join(@tmp_dir, 'header.html'), 'w') do |file|
          file.write layout.render('content' => File.read(File.join(@theme_dir, 'header.html')))
        end

        File.open(File.join(@tmp_dir, 'footer.html'), 'w') do |file|
          file.write layout.render('content' => File.read(File.join(@theme_dir, 'footer.html')))
        end
      end

      def generate_pdf
        command = ['wkhtmltopdf']
        command << '--header-html' << File.expand_path('header.html', @tmp_dir)
        command << '--footer-html' << File.expand_path('footer.html', @tmp_dir)
        command << '--margin-top' << @theme_config.fetch('margin_top', 10).to_s
        command << '--margin-left' << @theme_config.fetch('margin_left', 10).to_s
        command << '--margin-right' << @theme_config.fetch('margin_right', 10).to_s
        command << '--margin-bottom' << @theme_config.fetch('margin_bottom', 10).to_s
        command << '--header-spacing' << @theme_config.fetch('header_spacing', 0).to_s
        command << '--footer-spacing' << @theme_config.fetch('footer_spacing', 0).to_s

        @book.pages.each do |page|
          if page.node.is_a?(Asciidoctor::Section) && page.node.sectname == 'toc'
            prepare_toc_xsl(page)
            command << 'toc' << '--xsl-style-sheet' << 'toc.xsl'
          else
            command << page.path
          end
        end
        filename = "#{@book.basename}.pdf"
        command << filename
        command << { chdir: @tmp_dir }
        system(*command)

        FileUtils.cp File.join(@tmp_dir, filename), @dest_dir
      end

      def prepare_toc_xsl(page)
        File.open(File.join(@tmp_dir, 'toc.xsl'), 'w') do |file|
          file.write Liquid::Template.parse(File.read(File.join(@theme_dir, 'toc.xsl'))).render({
            'book' => @book.to_hash,
            'page' => page.to_hash
          })
        end
      end
    end
  end
end
