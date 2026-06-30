import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "label"]
  static values = { storageKey: String }

  connect() {
    const savedTheme = window.localStorage.getItem(this.storageKeyValue)
    this.apply(savedTheme === "light" ? "light" : "dark")
  }

  toggle() {
    this.apply(document.documentElement.dataset.theme === "dark" ? "light" : "dark")
  }

  apply(theme) {
    document.documentElement.dataset.theme = theme
    window.localStorage.setItem(this.storageKeyValue, theme)

    const dark = theme === "dark"
    this.buttonTarget.setAttribute("aria-pressed", dark)
    this.labelTarget.textContent = dark ? this.labelTarget.dataset.darkLabel || "Dark" : this.labelTarget.dataset.lightLabel || "Light"
  }
}
