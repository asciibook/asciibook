module Asciibook
  class Converter < Asciidoctor::Converter::Base
    register_for "asciibook"

    DEFAULT_TEMPLATE_PATH = File.expand_path('../../../templates', __FILE__)

    def initialize(backend, options = {})
      super
      init_backend_traits outfilesuffix: '.html', basebackend: 'html'
      @template_dirs = (options[:template_dirs] || []).unshift(DEFAULT_TEMPLATE_PATH)
      @templates = {}
    end

    def convert(node, transform = node.node_name, options = {})
      get_template(transform).render 'node' => node_to_hash(node)
    end

    private

    def get_template(name)
      return @templates[name] if @templates[name]

      @template_dirs.reverse.each do |template_dir|
        path = File.join template_dir, "#{name}.html"
        if File.exist?(path)
          @templates[name] = Liquid::Template.parse(File.read(path))
          break
        end
      end

      unless @templates[name]
        raise "Template not found #{name}"
      end

      @templates[name]
    end

    def node_to_hash(node)
      case node
      when Asciidoctor::Document
        document_to_hash(node)
      when Asciidoctor::Section
        section_to_hash(node)
      when Asciidoctor::Block
        block_to_hash(node)
      when Asciidoctor::List
        list_to_hash(node)
      when Asciidoctor::Table
        table_to_hash(node)
      when Asciidoctor::Inline
        inline_to_hash(node)
      else
        raise "Uncatched type #{node} #{node.attributes}"
      end
    end

    def abstract_node_to_hash(node)
      {
        'context' => node.context.to_s,
        'node_name' => node.node_name,
        'id' => node.id,
        'attributes' => node.attributes
      }
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
        if node.node_name == 'section' && node.sectname == 'toc'
          outline(node.document)
        elsif node.node_name == 'section' && node.sectname == 'index'
          get_template('index').render('indexterms' => node.document.references[:indexterms])
        else
          content = node.blocks.select { |b| b.page.nil? }.map {|b| b.convert }.join("\n")

          if node.page && node.page.footnotes.any?
            content += get_template('footnotes').render('footnotes' => node.page.footnotes)
          end

          content
        end
      else
        case node.node_name
        when 'listing'
          if node.style == 'source' && node.document.syntax_highlighter
            node.document.syntax_highlighter.format node, node.attributes['language'], { css_mode: :class }
          else
            "<pre>#{node.content}</pre>"
          end
        else
          node.content
        end
      end
    end

    def document_to_hash(node)
      title = node.attributes['doctitle'] && node.doctitle(partition: true)
      abstract_block_to_hash(node).merge!({
        'title' => title&.main,
        'subtitle' => title&.subtitle,
        'outline' => outline(node),
        'authors' => node.authors.map { |author| author.to_h.map { |key, value| [key.to_s, value] }.to_h }
      })
    end

    def section_to_hash(node)
      abstract_block_to_hash(node).merge!({
        'index' => node.index,
        'number' => node.number,
        'sectname' => node.sectname,
        'special' => node.special,
        'numbered' => node.numbered,
        'sectnum' => node.sectnum
      })
    end

    def block_to_hash(node)
      abstract_block_to_hash(node).merge!({
        'blockname' => node.blockname
      })
    end

    def list_to_hash(node)
      case node.context
      when :dlist
        abstract_block_to_hash(node).merge!({
          'items' => node.items.map { |terms, item|
            {
              'terms' => terms.map {|term| listitem_to_hash(term) },
              'description' => listitem_to_hash(item)
            }
          }
        })
      else
        abstract_block_to_hash(node).merge!({
          'items' => node.blocks.map { |item| listitem_to_hash(item) }
        })
      end
    end

    def listitem_to_hash(node)
      abstract_block_to_hash(node).merge!({
        'text' => (node.text? ? node.text : nil)
      })
    end

    def table_to_hash(node)
      abstract_block_to_hash(node).merge!({
        'columns' => node.columns,
        'rows' => {
          'head' => node.rows.head.map { |row| row.map {|cell| cell_to_hash(cell) } },
          'body' => node.rows.body.map { |row| row.map {|cell| cell_to_hash(cell) } },
          'foot' => node.rows.foot.map { |row| row.map {|cell| cell_to_hash(cell) } }
        }
      })
    end

    def cell_to_hash(node)
      abstract_node_to_hash(node).merge!({
        'text' => node.text,
        'content' => node.content,
        'style' => node.style,
        'colspan' => node.colspan,
        'rowspan' => node.rowspan
      })
    end

    def inline_to_hash(node)
      data = abstract_node_to_hash(node).merge!({
        'text' => node.text,
        'type' => node.type.to_s,
        'target' => node.target,
        'xreftext' => node.xreftext
      })

      case node.node_name
      when 'inline_anchor'
        data['text'] ||= node.document.references[:refs][node.attributes['refid']]&.xreftext || "[#{node.attributes['refid']}]"

        if (node.type == :xref) && (target_node = node.document.references[:refs][node.attributes['refid']])
          data['target'] = if target_node.page
            target_node.page.path
          else
            "#{find_page_node(target_node).page&.path}#{node.target}"
          end
        end
      when 'inline_footnote'
        if page = find_page_node(node).page
          if index = page.footnotes.find_index { |footnote| footnote['text'] == node.text }
            footnote = page.footnotes[index]
            data['id'] = nil
            data['index'] = footnote['index']
            data['target'] = "#_footnotedef_#{footnote['index']}"
          else
            index = page.footnotes.count + 1
            page.footnotes.push({
              'index' => index,
              'text' => node.text,
              'refid' => "_footnoteref_#{index}",
              'id' => "_footnotedef_#{index}"
            })
            data['id'] = "_footnoteref_#{index}"
            data['index'] = index
            data['target'] = "#_footnotedef_#{index}"
          end
        else
          index = node.attr 'index'
          data['id'] = (node.type == :xref ? nil : "_footnoteref_#{index}")
          data['index'] = index
          data['target'] = "#_footnotedef_#{index}"
        end
      when 'inline_indexterm'
        node.document.references[:indexterms] ||= []
        node.document.references[:indexcount] ||= 0
        indexterms = node.document.references[:indexterms]
        indexcount = node.document.references[:indexcount] += 1
        id = "_indexterm_#{indexcount}"
        target = "#{find_page_node(node).page&.path}#_indexterm_#{indexcount}"
        if node.type == :visible
          register_term(indexterms, [node.text], target)
        else
          register_term(indexterms, node.attributes['terms'], target)
        end

        data['id'] = id
      end

      data
    end

    def register_term(indexterms, terms, target)
      items = indexterms
      item = nil
      terms.each_with_index do |term, index|
        term_index = items.find_index { |item| item['term'] == term }
        if term_index
          item = items[term_index]
        else
          item = {
            'term' => term,
            'targets' => [],
            'items' => []
          }
          items.push item
          items.sort_by! { |item| item['term'] }
        end

        if index == terms.size - 1
          # save targe now
          item['targets'].push target
        else
          # go deeper
          items = item['items']
        end
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
            "#{find_page_node(section).page&.path}##{section.id}"
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
