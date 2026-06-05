import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  select(event) {
    const button = event.currentTarget
    const signedId = button.dataset.galleryId

    this.element.querySelectorAll("button").forEach(b => {
      b.classList.remove("border-emerald-500", "ring-2", "ring-emerald-500/50")
    })
    button.classList.add("border-emerald-500", "ring-2", "ring-emerald-500/50")

    this.inputTarget.value = signedId
  }
}
