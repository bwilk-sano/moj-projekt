import { Controller } from "@hotwired/stimulus"

// Toast that slides in and disappears on its own after a few seconds.
export default class extends Controller {
  static values = { timeout: { type: Number, default: 4500 } }

  connect() {
    this.timer = setTimeout(() => this.dismiss(), this.timeoutValue)
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  dismiss() {
    this.element.classList.add("toast--leaving")
    this.element.addEventListener("animationend", () => this.element.remove(), { once: true })
  }
}
