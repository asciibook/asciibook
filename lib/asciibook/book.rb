module Asciibook
  class Book
    attr_reader :data, :options, :doc, :pages, :basename, :base_dir, :dest_dir, :theme_dir, :template_dir

    def initialize(data, options = {})
      @data = data
      @options = options
      @basename = options[:basename] || 'output'
      @base_dir = options[:base_dir] || '.'
      @dest_dir = options[:dest_dir] || File.join(@base_dir, 'build')
      @theme_dir = options[:theme_dir] || File.expand_path('../../../theme', __FILE__)
      @formats = options[:formats] || %w(html pdf epub)
      @template_dir = options[:template_dir]

      @page_level = @options[:page_level] || 1

      @logger = @options[:logger] || Logger.new(STDERR, level: :warn)

      @exclude_patterns = ["build/**/*"]
    end

    def self.load_file(path, options = {})
      options.merge!(
        basename: File.basename(path, '.*'),
        base_dir: File.dirname(path)
      )

      if File.exist?(path)
        new(File.open(path, 'r:utf-8').read, options)
      else
        raise "File not exists #{path}"
      end
    end

    def process
      @doc = Asciidoctor.load(@data, base_dir: @base_dir, backend: 'asciibook', logger: @logger, safe: :unsafe, template_dirs: [@template_dir].compact)
      @toc = nil
      process_pages
    end

    def title
      doc.attributes['doctitle']
    end

    def cover_image_path
      doc.attributes['cover-image']
    end

    def outline
      outline_node(doc)
    end

    # book outline only list sections that split as page
    def outline_node(node)
      data = []
      node.sections.each do |section|
        if section.page
          section_data = {
            'title' => section.xreftext,
            'path' => section.page.path
          }
          if section.sections.count > 0 and section.level < @page_level
            section_data['items'] = outline_node(section)
          end
          data << section_data
        end
      end
      data
    end

    def find_page_node(node)
      page_node = node

      until page_node.page or page_node.parent.nil?
        page_node = page_node.parent
      end

      page_node
    end

    def to_hash
      {
        'title' => doc.attributes['doctitle'],
        'attributes' => doc.attributes,
        'outline' => outline
      }
    end

    def build
      if @formats.include?('html')
        Builders::HtmlBuilder.new(self).build
      end

      if @formats.include?('pdf')
        Builders::PdfBuilder.new(self).build
      end

      if @formats.include?('epub')
        Builders::EpubBuilder.new(self).build
      end
    end

    def process_pages
      @pages = []

      append_page('index.html', doc)

      if @page_level > 0
        doc.sections.each do |section|
          process_page(section)
        end
      end
    end

    def process_page(node)
      append_page("#{node.id}.html", node)

      if node.level < @page_level
        node.sections.each do |section|
          process_page(section)
        end
      end
    end

    def append_page(path, node)
      if @pages.map(&:path).include?(path)
        @logger.warn("Page path already in use: #{path}")
      end

      page = Page.new(
        path: path,
        node: node
      )

      if last_page = @pages.last
        page.prev_page = last_page
        last_page.next_page = page
      end

      node.page = page
      @pages << page
    end

    def assets
      Dir.glob('**/*.{jpg,png,svg,gif,mp3,mp4,ogg,wav}', File::FNM_CASEFOLD, base: @base_dir).reject do |path|
        @exclude_patterns.any? do |pattern|
          File.fnmatch?(pattern, path)
        end
      end
    end
  end
end
