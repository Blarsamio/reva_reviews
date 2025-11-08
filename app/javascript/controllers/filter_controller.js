import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["panel", "button", "icon"]

    toggle() {
        this.panelTarget.classList.toggle("hidden")

        const isExpanded = !this.panelTarget.classList.contains("hidden")
        this.buttonTarget.setAttribute("aria-expanded", isExpanded)

        if (isExpanded) {
            this.iconTarget.classList.add("rotate-180")
        } else {
            this.iconTarget.classList.remove("rotate-180")
        }
    }
}