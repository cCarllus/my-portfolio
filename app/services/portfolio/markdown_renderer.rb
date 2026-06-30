require "erb"
require "uri"

module Portfolio
  class MarkdownRenderer
    class << self
      def call(markdown)
        new(markdown.to_s).render
      end
    end

    def initialize(markdown)
      @lines = markdown.gsub("\r\n", "\n").lines.map(&:chomp)
    end

    def render
      blocks = []
      paragraph = []
      index = 0

      while index < lines.length
        line = lines[index]

        if (fence = line.match(/\A```([A-Za-z0-9_+-]*)\s*\z/))
          flush_paragraph(blocks, paragraph)
          code, index = collect_code_block(index + 1)
          language = fence[1].presence
          class_name = language ? %( class="language-#{ERB::Util.html_escape(language)}") : ""
          blocks << "<pre><code#{class_name}>#{ERB::Util.html_escape(code.join("\n"))}</code></pre>"
        elsif line.blank?
          flush_paragraph(blocks, paragraph)
        elsif (heading = line.match(/\A([#]{1,3})\s+(.+)\z/))
          flush_paragraph(blocks, paragraph)
          level = heading[1].length
          blocks << "<h#{level}>#{inline(heading[2])}</h#{level}>"
        elsif line.match?(/\A[-*]\s+/)
          flush_paragraph(blocks, paragraph)
          items, index = collect_list(index, /\A[-*]\s+(.+)\z/)
          blocks << "<ul>#{items.map { |item| "<li>#{inline(item)}</li>" }.join}</ul>"
        elsif line.match?(/\A\d+\.\s+/)
          flush_paragraph(blocks, paragraph)
          items, index = collect_list(index, /\A\d+\.\s+(.+)\z/)
          blocks << "<ol>#{items.map { |item| "<li>#{inline(item)}</li>" }.join}</ol>"
        elsif (quote = line.match(/\A>\s?(.+)\z/))
          flush_paragraph(blocks, paragraph)
          blocks << "<blockquote>#{inline(quote[1])}</blockquote>"
        else
          paragraph << line
        end

        index += 1
      end

      flush_paragraph(blocks, paragraph)
      blocks.join.html_safe
    end

    private

    attr_reader :lines

    def collect_list(index, pattern)
      items = []

      while index < lines.length && (match = lines[index].match(pattern))
        items << match[1]
        index += 1
      end

      [ items, index - 1 ]
    end

    def collect_code_block(index)
      code = []
      while index < lines.length && !lines[index].match?(/\A```\s*\z/)
        code << lines[index]
        index += 1
      end
      [ code, index ]
    end

    def flush_paragraph(blocks, paragraph)
      return if paragraph.empty?

      blocks << "<p>#{paragraph.map { |line| inline(line) }.join("<br>")}</p>"
      paragraph.clear
    end

    def inline(value)
      ERB::Util.html_escape(value)
        .gsub(/`([^`]+)`/, '<code>\1</code>')
        .gsub(/\[([^\]]+)\]\(([^)\s]+)\)/) { safe_link(Regexp.last_match(1), Regexp.last_match(2)) }
        .gsub(/\*\*([^*]+)\*\*/, '<strong>\1</strong>')
        .gsub(/\*([^*]+)\*/, '<em>\1</em>')
        .gsub(/~~([^~]+)~~/, '<del>\1</del>')
    end

    def safe_link(label, url)
      uri = URI.parse(url)
      return label unless uri.scheme.in?(%w[http https mailto])

      attributes = %(href="#{ERB::Util.html_escape(url)}")
      attributes += ' target="_blank" rel="noopener"' if uri.scheme.in?(%w[http https])
      "<a #{attributes}>#{label}</a>"
    rescue URI::InvalidURIError
      label
    end
  end
end
