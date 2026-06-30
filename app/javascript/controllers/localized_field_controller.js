import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editor", "stored", "localeButton", "preview"]
  static values = { locale: String, markdown: Boolean }

  connect() {
    this.loadLocale()
  }

  changeLocale(event) {
    this.sync()
    this.localeValue = event.currentTarget.dataset.locale
    this.loadLocale()
  }

  sync() {
    this.currentStored.value = this.editorTarget.value
    if (this.markdownValue && !this.previewTarget.hidden) this.renderPreview()
  }

  format(event) {
    const formats = {
      bold: ["**", "**"],
      italic: ["*", "*"],
      heading1: ["# ", ""],
      heading2: ["## ", ""],
      heading3: ["### ", ""],
      list: ["- ", ""],
      orderedList: ["1. ", ""],
      link: ["[", "](https://)"],
      code: ["```\n", "\n```"],
      quote: ["> ", ""],
      strikethrough: ["~~", "~~"]
    }
    const [before, after] = formats[event.currentTarget.dataset.format]
    const start = this.editorTarget.selectionStart
    const end = this.editorTarget.selectionEnd
    const selected = this.editorTarget.value.slice(start, end)

    this.editorTarget.setRangeText(`${before}${selected}${after}`, start, end, "end")
    this.editorTarget.focus()
    this.sync()
  }

  togglePreview(event) {
    const showingPreview = this.previewTarget.hidden
    this.previewTarget.hidden = !showingPreview
    this.editorTarget.hidden = showingPreview
    event.currentTarget.classList.toggle("is-active", showingPreview)
    if (showingPreview) this.renderPreview()
  }

  loadLocale() {
    this.editorTarget.value = this.currentStored.value
    this.localeButtonTargets.forEach((button) => {
      button.classList.toggle("is-active", button.dataset.locale === this.localeValue)
    })
    if (this.markdownValue && !this.previewTarget.hidden) this.renderPreview()
  }

  renderPreview() {
    const escaped = this.escapeHtml(this.editorTarget.value)
      .replace(/`([^`]+)`/g, "<code>$1</code>")
      .replace(/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/g, '<a href="$2" target="_blank" rel="noopener">$1</a>')
      .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
      .replace(/\*([^*]+)\*/g, "<em>$1</em>")
      .replace(/~~([^~]+)~~/g, "<del>$1</del>")

    const blocks = escaped.split(/\n{2,}/).map((block) => {
      const lines = block.split("\n")
      if (lines.every((line) => /^[-*]\s+/.test(line))) {
        return `<ul>${lines.map((line) => `<li>${line.replace(/^[-*]\s+/, "")}</li>`).join("")}</ul>`
      }
      if (lines.every((line) => /^\d+\.\s+/.test(line))) {
        return `<ol>${lines.map((line) => `<li>${line.replace(/^\d+\.\s+/, "")}</li>`).join("")}</ol>`
      }
      if (/^```/.test(block)) return `<pre><code>${block.replace(/^```[^\n]*\n?/, "").replace(/\n?```$/, "")}</code></pre>`
      if (/^>\s?/.test(block)) return `<blockquote>${block.replace(/^>\s?/, "")}</blockquote>`
      if (/^###\s+/.test(block)) return `<h3>${block.replace(/^###\s+/, "")}</h3>`
      if (/^##\s+/.test(block)) return `<h2>${block.replace(/^##\s+/, "")}</h2>`
      if (/^#\s+/.test(block)) return `<h1>${block.replace(/^#\s+/, "")}</h1>`
      return `<p>${lines.join("<br>")}</p>`
    })

    this.previewTarget.innerHTML = blocks.join("")
  }

  get currentStored() {
    return this.storedTargets.find((field) => field.dataset.locale === this.localeValue)
  }

  escapeHtml(value) {
    return value.replace(/[&<>"']/g, (character) => ({
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#039;"
    })[character])
  }
}
