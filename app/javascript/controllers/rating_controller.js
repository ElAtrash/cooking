import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["stars", "ratingInput"]

  connect() {
    this.updateStars(parseInt(this.ratingInputTarget.value) || 0)
  }

  selectRating(event) {
    event.preventDefault()
    const rating = parseInt(event.currentTarget.dataset.ratingValue)
    this.ratingInputTarget.value = rating
    this.updateStars(rating)
  }

  updateStars(rating) {
    const stars = this.starsTarget.querySelectorAll('button')

    stars.forEach((star, index) => {
      const starValue = index + 1
      const svg = star.querySelector('svg')

      if (starValue <= rating) {
        svg.classList.remove('text-gray-300')
        svg.classList.add('text-yellow-400')
      } else {
        svg.classList.remove('text-yellow-400')
        svg.classList.add('text-gray-300')
      }
    })
  }

  hoverStar(event) {
    const rating = parseInt(event.currentTarget.dataset.ratingValue)
    this.updateStars(rating)
  }

  leaveStar() {
    const currentRating = parseInt(this.ratingInputTarget.value) || 0
    this.updateStars(currentRating)
  }
}
