module Asciibook
  module Builders
    class HtmlBuilder < BaseBuilder
      def initialize(book)
        super
        @build_dir = File.join(@book.build_dir, 'html')
        @theme_dir = File.join(@book.theme_dir, 'html')
      end

      def build
        FileUtils.mkdir_p @build_dir
        FileUtils.rm_r Dir.glob("#{@build_dir}/*")

        generate_pages
        copy_assets
      end

      def generate_pages
        layout = Liquid::Template.parse(File.read(File.join(@theme_dir, 'layout.html')))
        @book.pages.each do |page|
          File.open(File.join(@build_dir, page.path), 'w') do |file|
            file.write layout.render({
              'book' => @book.to_hash,
              'page' => page.to_hash
            })
          end
        end
      end

      def copy_assets
        @book.assets.each do |path|
          copy_file(path, @book.base_dir, @build_dir)
        end

        Dir.glob('**/*.{jpb,png,gif,svg,css,js}', File::FNM_CASEFOLD, base: @theme_dir).each do |path|
          copy_file(path, @theme_dir, @build_dir)
        end
      end
    end
  end
end
