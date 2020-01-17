module Asciibook
  module Builders
    class MobiBuilder < EpubBuilder
      def initialize(book)
        super

        @build_dir = File.join(@book.build_dir, 'mobi')
        @theme_dir = File.join(@book.theme_dir, 'mobi')
      end

      def build
        super

        epub_file = File.join(@build_dir, 'output.epub')
        system 'kindlegen', epub_file

        #FileUtils.rm epub_file
      end
    end
  end
end
