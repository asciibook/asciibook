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
          puts 'TODO'
        end
      end

      p.command(:build) do |c|
        c.description 'Build book by SOURCE'
        c.syntax 'build [SOURCE]'
        c.option :formats, '--format FORMAT1[,FORMAT2[,FORMAT3...]]', Array, 'Formats you want to build, allow: html,pdf,epub,mobi, default is all.'
        c.option :theme_dir, '--theme-dir DIR', 'Theme dir.'
        c.option :template_dir, '--template-dir DIR', 'Template dir.'
        c.option :dest_dir, '--dest-dir DIR', 'Destination dir.'
        c.option :page_level, '--page-level NUM', Integer, 'Page split base on section level, default is 1.'
        c.action do |args, options|
          source = args[0]
          Asciibook::Book.load_file(source, options).build
        end
      end

      p.action do |args, _|
        puts p
      end

      p.go(argv)
    end
  end
end