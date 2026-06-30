import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "status"]
  static values = { url: String, error: String }

  start(event) {
    if (this.draggedItem) return

    event.preventDefault()
    this.draggedItem = event.currentTarget.closest('[data-sortable-target="item"]')
    if (event.pointerId && event.currentTarget.setPointerCapture) {
      event.currentTarget.setPointerCapture(event.pointerId)
    }
    this.draggedItem.classList.add("is-dragging")
  }

  move(event) {
    if (!this.draggedItem) return

    event.preventDefault()
    const target = document.elementFromPoint(event.clientX, event.clientY)?.closest('[data-sortable-target="item"]')
    if (!this.draggedItem || target === this.draggedItem) return

    const afterTarget = event.clientY > target.getBoundingClientRect().top + target.offsetHeight / 2
    target.insertAdjacentElement(afterTarget ? "afterend" : "beforebegin", this.draggedItem)
  }

  async finish(event) {
    if (!this.draggedItem) return

    event.preventDefault()
    if (event.pointerId && event.currentTarget.releasePointerCapture) {
      event.currentTarget.releasePointerCapture(event.pointerId)
    }
    this.draggedItem.classList.remove("is-dragging")
    this.draggedItem = null
    await this.persist()
  }

  cancel() {
    this.draggedItem?.classList.remove("is-dragging")
    this.draggedItem = null
  }

  async persist() {
    const response = await fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ ids: this.itemTargets.map((item) => item.dataset.id) })
    })

    if (response.ok) {
      this.statusTarget.textContent = "✓"
      window.setTimeout(() => { this.statusTarget.textContent = "" }, 1200)
    } else {
      this.statusTarget.textContent = this.errorValue
      window.setTimeout(() => window.location.reload(), 1200)
    }
  }
}
