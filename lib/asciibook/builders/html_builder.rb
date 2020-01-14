module Asciibook
  module Builders
    class HtmlBuilder
      def initialize(book)
        @book = book
        @base_dir = @book.options[:base_dir]
        @build_dir = File.expand_path('build/html', @base_dir)
        @theme_dir = File.expand_path('../../../../themes/default/html', __FILE__)

        @exclude_patterns = ["build/**/*"]
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
        Dir.glob('**/*.{jpg,png,gif,mp3,mp4,ogg,wav}', File::FNM_CASEFOLD, base: @base_dir).each do |path|
          if !exclude_file?(path)
            copy_file(path, @base_dir, @build_dir)
          end
        end

        Dir.glob('**/*.{jpb,png,gif,svg,css,js}', File::FNM_CASEFOLD, base: @theme_dir).each do |path|
          copy_file(path, @theme_dir, @build_dir)
        end
      end

      def exclude_file?(path)
        @exclude_patterns.any? do |pattern|
          File.fnmatch?(pattern, path)
        end
      end

      def copy_file(path, src_dir, dest_dir)
        src_path = File.join(src_dir, path)
        dest_path = File.join(dest_dir, path)
        FileUtils.mkdir_p File.dirname(dest_path)
        FileUtils.cp src_path, dest_path
      end
    end
  end
end
