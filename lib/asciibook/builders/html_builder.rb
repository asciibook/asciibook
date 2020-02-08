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
          File.open(File.join(@dest_dir, page.path), 'w') do |file|
            file.write layout.render({
              'book' => @book.to_hash,
              'page' => page.to_hash
            })
          end
        end
      end

      def copy_assets
        @book.assets.each do |path|
          copy_file(path, @book.base_dir, @dest_dir)
        end

        Dir.glob('**/*.{jpb,png,gif,svg,css,js,eot,ttf,woff,woff2}', File::FNM_CASEFOLD, base: @theme_share_dir).each do |path|
          copy_file(path, @theme_share_dir, @dest_dir)
        end

        Dir.glob('**/*.{jpb,png,gif,svg,css,js,eot,ttf,woff,woff2}', File::FNM_CASEFOLD, base: @theme_dir).each do |path|
          copy_file(path, @theme_dir, @dest_dir)
        end
      end
    end
  end
end
