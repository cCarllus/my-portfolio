import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  select(event) {
    const selectedTab = event.currentTarget
    const selectedIndex = this.tabTargets.indexOf(selectedTab)

    this.tabTargets.forEach((tab, index) => {
      const selected = index === selectedIndex
      tab.classList.toggle("tab--active", selected)
      tab.setAttribute("aria-selected", selected)
      tab.tabIndex = selected ? 0 : -1
      this.panelTargets[index].hidden = !selected
    })
  }
}
