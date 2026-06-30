import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["time", "date"]
  static values = { locale: String }

  connect() {
    this.render()
    this.timer = window.setInterval(() => this.render(), 30_000)
  }

  disconnect() {
    window.clearInterval(this.timer)
  }

  render() {
    const now = new Date()
    const locale = { pt: "pt-BR", en: "en-US" }[this.localeValue] || "pt-BR"

    this.timeTarget.textContent = new Intl.DateTimeFormat(locale, {
      hour: "2-digit",
      minute: "2-digit"
    }).format(now)

    this.dateTarget.textContent = new Intl.DateTimeFormat(locale, {
      day: "2-digit",
      month: "short",
      year: "numeric"
    }).format(now)
  }
}
