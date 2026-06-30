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
end
