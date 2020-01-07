module Asciibook
  class Converter < Asciidoctor::Htmlbook::Converter
    register_for "asciibook"

    def inline_to_hash(node)
      if (node.type == :xref) && (target_node = node.document.references[:refs][node.attributes['refid']])
        if target_node.page
          super.merge!({
            'target' => target_node.page.path
          })
        else
          page_node = target_node

          until page_node.page or page_node.parent.nil?
            page_node = page_node.parent
          end

          super.merge!({
            'target' => "#{page_node.page.path}#{node.target}"
          })
        end
      else
        super
      end
    end
  end
end
