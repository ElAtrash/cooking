import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }
  static targets = ["form"]

  connect() {
    this.timeout = null
  }

  perform() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.search()
    }, 300)
  }

  search() {
    const form = this.element.closest('form')
    const formData = new FormData(form)
    const params = new URLSearchParams(formData)

    const newUrl = `${this.urlValue}?${params.toString()}`

    fetch(newUrl, {
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'Turbo-Frame': 'recipes_list'
      }
    })
    .then(response => response.text())
    .then(html => {
      const frame = document.getElementById('recipes_list')
      if (frame) {
        frame.innerHTML = html
      }
    })
    .catch(error => {
      console.error('Search error:', error)
    })
  }
}
