import { Controller } from "@hotwired/stimulus"

// Live, client-side filtering of note cards. Press "/" to focus the search box.
export default class extends Controller {
  static targets = ["input", "item", "empty"]

  connect() {
    this.onKey = (event) => {
      if (event.key === "/" && document.activeElement !== this.inputTarget) {
        event.preventDefault()
        this.inputTarget.focus()
      }
    }
    document.addEventListener("keydown", this.onKey)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKey)
  }

  filter() {
    const query = this.inputTarget.value.trim().toLowerCase()
    let visible = 0

    this.element.classList.toggle("is-filtering", query.length > 0)

    this.itemTargets.forEach((item) => {
      const match = item.textContent.toLowerCase().includes(query)
      item.hidden = !match
      if (match) visible++
    })

    if (this.hasEmptyTarget) this.emptyTarget.hidden = visible > 0
  }
}
