import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "filter", "item", "count", "empty"]

  connect() {
    this.category = "all"
    this.filter()
  }

  selectCategory(event) {
    this.category = event.currentTarget.dataset.category
    this.filterTargets.forEach((button) => {
      button.classList.toggle("is-active", button === event.currentTarget)
    })
    this.filter()
  }

  filter() {
    const query = this.normalize(this.searchTarget.value)
    let visible = 0

    this.itemTargets.forEach((item) => {
      const matchesCategory = this.category === "all" || item.dataset.category === this.category
      const matchesQuery = this.normalize(item.dataset.searchText).includes(query)
      item.hidden = !(matchesCategory && matchesQuery)
      if (!item.hidden) visible += 1
    })

    this.countTarget.textContent = this.countTarget.dataset.template
      ? this.countTarget.dataset.template.replace("%{count}", visible)
      : visible
    this.emptyTarget.hidden = visible > 0
  }

  normalize(value) {
    return (value || "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase()
  }
}
