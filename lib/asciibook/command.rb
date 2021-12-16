require "asciibook"
require "mercenary"

module Asciibook
  class Command
    def self.execute(argv)
      p = Mercenary::Program.new(:asciibook)

      p.version Asciibook::VERSION
      p.description 'Asciibook is a ebook generator from Asciidoc to html/pdf/epub/mobi'
      p.syntax 'asciibook <command> [options]'

      p.command(:new) do |c|
        c.description 'Create a new book scaffold in PATH'
        c.syntax 'new PATH'
        c.action do |args, options|
          path = args[0]
          if path
            FileUtils.mkdir_p path
            template_dir = File.expand_path('../../../book_template', __FILE__)
            files = Dir.glob('*', base: template_dir).map { |file| File.join(template_dir, file) }
            # TODO: confirm if file exists
            FileUtils.cp_r files, path
          else
            abort "Please specify PATH to create book"
          end
        end
      end

      p.command(:init) do |c|
        c.description 'Init a asciibook config for a Asciidoc file'
        c.syntax 'init FILE'
        c.action do |args, options|
          source = args[0]
          if File.file?(source)
            dir = File.dirname source
            filename = File.basename source
            File.open(File.join(dir, 'asciibook.yml'), 'w') do |file|
              file.write <<~EOF
                source: #{filename}
                # formats:
                #   - html
                #   - pdf
                #   - epub
                #   - mobi
                #
                # theme_dir:
                # template_dir:
                # page_level: 1
                #
                # plugins:
                #   - asciidoctor-diagram
              EOF
            end
          else
            abort "Please specify the Asciidoc document to build"
          end
        end
      end

      p.command(:build) do |c|
        c.description 'Build book'
        c.syntax 'build [FILE|DIR]'
        c.option :formats, '--format FORMAT1[,FORMAT2[,FORMAT3...]]', Array, 'Formats you want to build, allow: html,pdf,epub,mobi, default is all.'
        c.option :theme_dir, '--theme-dir DIR', 'Theme dir.'
        c.option :template_dir, '--template-dir DIR', 'Template dir.'
        c.option :dest_dir, '--dest-dir DIR', 'Destination dir.'
        c.option :page_level, '--page-level NUM', Integer, 'Page split base on section level, default is 1.'
        c.option :plugins, '-r', '--require PLUGIN1[,PLUGIN2[,PLUGIN3...]]', Array, 'Require plugins'
        c.action do |args, options|
          source = args[0] || '.'
          if File.directory?(source)
            config_options = YAML.safe_load(File.read(File.join(source, 'asciibook.yml'))).reduce({}) do |hash, (key, value)|
              hash[key.to_sym] = %w(source theme_dir template_dir dest_dir).include?(key) ? File.join(source, value) : value
              hash
            end
            options = config_options.merge(options)
            load_plugins(options[:plugins])
            Asciibook::Book.load_file(options.delete(:source), options).build
          elsif File.file?(source)
            load_plugins(options[:plugins])
            Asciibook::Book.load_file(source, options).build
          else
            abort "Build target '#{source}' neither a folder nor a file"
          end
        end
      end

      p.action do |args, _|
        puts p
      end

      p.go(argv)
    end

    def self.load_plugins(plugins)
      if plugins
        plugins.each do |plugin|
          require plugin
        end
      end
    end
  end
end
