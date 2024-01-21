import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dynamic-url"
export default class extends Controller {
  static targets = ["value"]
  static values = {
    base: String
  }

  go() {
    window.location = this.baseValue.replace('::value::', encodeURIComponent(this.valueTarget.value))
  }
}
