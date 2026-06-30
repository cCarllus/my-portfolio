import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "feedback"]

  submit(event) {
    event.preventDefault()
    this.feedbackTarget.hidden = false
    this.inputTarget.focus()
  }
}
