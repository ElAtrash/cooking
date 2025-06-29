import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "container", "item"]
  static values = { wrapperSelector: String }

  add(event){
    event.preventDefault()

    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    this.containerTarget.insertAdjacentHTML('beforeend', content)

    this.updateStepNumbers()
  }

  remove(event){
    event.preventDefault()

    const item = event.target.closest(this.wrapperSelectorValue)
    if (!item) return

    const destroyField = item.querySelector('input[name*="_destroy"]')
    if (destroyField) {
      destroyField.value = '1'
      item.style.display = 'none'
    } else {
      this.remove()
    }

    this.updateStepNumbers()
  }

  moveUp(event){
    event.preventDefault()

    const item = event.target.closest(this.wrapperSelectorValue)
    const previousItem = item.previousElementSibling

    if (previousItem && previousItem.matches(this.wrapperSelectorValue)) {
      item.parentNode.insertBefore(item, previousItem)
      this.updateStepNumbers()
    }
  }

  moveDown(event){
    event.preventDefault()

    const item = event.target.closest(this.wrapperSelectorValue)
    const nextItem = item.nextElementSibling

    if (nextItem && nextItem.matches(this.wrapperSelectorValue)) {
      item.parentNode.insertBefore(nextItem, item)
      this.updateStepNumbers()
    }
  }

  updateStepNumbers() {
    const visibleItems = this.containerTarget.querySelectorAll(`${this.wrapperSelectorValue}:not([style*="display: none"])`)

    visibleItems.forEach((item, index) => {
      const stepNumber = index + 1

      const stepNumberDisplay = item.querySelector('[data-step-number]')
      if (stepNumberDisplay) {
        stepNumberDisplay.textContent = stepNumber
      }

      const stepNumberField = item.querySelector('input[name*="step_number"]')
      if (stepNumberField) {
        stepNumberField.value = stepNumber
      }
    })
  }
}
