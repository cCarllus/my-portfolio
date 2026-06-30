module ApplicationHelper
  def render_markdown(value)
    Portfolio::MarkdownRenderer.call(value)
  end
end
