module Asciibook
  module Builders
    class BaseBuilder
      def initialize(book)
        @book = book
        @theme_share_dir = File.join(@book.theme_dir, 'share')

        # reset book doc
        @book.process
      end

      def build
        raise NotImplementedError
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
