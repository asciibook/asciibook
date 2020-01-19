module Asciibook
  module Builders
    class MobiBuilder < EpubBuilder
      def initialize(book)
        super

        @dest_dir = File.join(@book.dest_dir, 'mobi')
        @theme_dir = File.join(@book.theme_dir, 'mobi')
      end

      def build
        super

        epub_file = File.join(@dest_dir, "#{@book.basename}.epub")
        system 'kindlegen', epub_file

        #FileUtils.rm epub_file
      end
    end
  end
end
