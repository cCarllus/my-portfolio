require "rails_helper"

RSpec.describe Portfolio::MarkdownRenderer do
  it "renders common Markdown blocks and escapes HTML" do
    html = described_class.call("## Título\n\n**forte** e *ênfase*\n\n- item\n- <script>alert(1)</script>")

    expect(html).to include("<h2>Título</h2>")
    expect(html).to include("<strong>forte</strong>")
    expect(html).to include("<em>ênfase</em>")
    expect(html).to include("<ul><li>item</li>")
    expect(html).to include("&lt;script&gt;")
    expect(html).not_to include("<script>")
  end

  it "renders links, quotes, ordered lists, strikethrough and fenced code" do
    markdown = <<~MARKDOWN
      [GitHub](https://github.com/cCarllus) and ~~legacy~~

      > A useful quote

      1. first
      2. second

      ```ruby
      puts "<safe>"
      ```
    MARKDOWN

    html = described_class.call(markdown)

    expect(html).to include('href="https://github.com/cCarllus"')
    expect(html).to include('target="_blank"')
    expect(html).to include("<del>legacy</del>")
    expect(html).to include("<blockquote>A useful quote</blockquote>")
    expect(html).to include("<ol><li>first</li><li>second</li></ol>")
    expect(html).to include('<pre><code class="language-ruby">puts &quot;&lt;safe&gt;&quot;')
  end

  it "does not render unsafe links" do
    html = described_class.call("[unsafe](javascript:alert(1))")

    expect(html).not_to include("href=")
    expect(html).to include("unsafe")
  end
end
