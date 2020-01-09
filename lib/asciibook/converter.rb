module Asciibook
  class Converter < Asciidoctor::Htmlbook::Converter
    register_for "asciibook"

    def initialize(backend, options = {})
      super
    end

    def abstract_block_to_hash(node)
      abstract_node_to_hash(node).merge!({
        'level' => node.level,
        'title' => node.title,
        'caption' => node.caption,
        'captioned_title' => node.captioned_title,
        'style' => node.style,
        'content' => node_content(node),
        'xreftext' => node.xreftext
      })
    end

    def node_content(node)
      case node
      when Asciidoctor::Document, Asciidoctor::Section
        node.blocks.select { |b| b.page.nil? }.map {|b| b.convert }.join("\n")
      else
        node.content
      end
    end

    def inline_to_hash(node)
      if (node.type == :xref) && (target_node = node.document.references[:refs][node.attributes['refid']])
        if target_node.page
          super.merge!({
            'target' => target_node.page.path
          })
        else
          super.merge!({
            'target' => "#{find_page_node(target_node).page.path}#{node.target}"
          })
        end
      else
        super
      end
    end

    def find_page_node(node)
      page_node = node

      until page_node.page or page_node.parent.nil?
        page_node = page_node.parent
      end

      page_node
    end

    def outline(node)
      result = ''
      if node.sections.any? && node.level < (node.document.attributes['toclevels'] || 2).to_i
        result << "<ol>"
        node.sections.each do |section|
          result << "<li>"
          target = if section.page
            "#{section.page.path}"
          else
            "#{find_page_node(section).page.path}##{section.id}"
          end
          result << %Q(<a href="#{target}">)
          result << "#{section.sectnum} " if section.numbered && section.level < (node.document.attributes['sectnumlevels'] || 3).to_i
          result << section.title
          result << "</a>"
          result << outline(section)
          result << "</li>"
        end
        result << "</ol>"
      end
      result
    end
  end
end
