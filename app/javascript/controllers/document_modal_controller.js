import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "panel", "title"]

  open({ params: { panel, title } }) {
    this.panelTargets.forEach((candidate) => {
      candidate.hidden = candidate.dataset.panel !== panel
    })

    this.titleTarget.textContent = title
    this.dialogTarget.showModal()
    document.body.classList.add("modal-open")
  }

  close() {
    this.dialogTarget.close()
  }

  closeFromBackdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  closed() {
    document.body.classList.remove("modal-open")
  }
}
