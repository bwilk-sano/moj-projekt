import { Controller } from "@hotwired/stimulus"

// Light/dark switch. The choice is remembered per browser; without it we follow the OS.
export default class extends Controller {
  toggle() {
    const root = document.documentElement
    const current = root.dataset.theme ||
      (matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")
    const next = current === "dark" ? "light" : "dark"

    root.dataset.theme = next
    try { localStorage.setItem("theme", next) } catch (_) {}
  }
}
