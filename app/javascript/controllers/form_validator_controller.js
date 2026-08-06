import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-validator"
// Validates all registration form fields with DaisyUI-style visual feedback
export default class extends Controller {
  static targets = ["input", "message", "group"]
  static values = { checkUrl: String }

  connect() {
    this.checkUrlValue ||= "/register/check_email"
  }

  // Generic validate action - reads data-validate for rules
  validate(event) {
    const input = event.target
    this.#validateField(input)
  }

  // Validate all fields on form submit, prevent submission if errors exist
  validateAll(event) {
    let hasErrors = false

    this.inputTargets.forEach(input => {
      if (this.#validateField(input)) {
        hasErrors = true
      }
    })

    // Also check password confirmation match on submit
    const confirmInput = this.inputTargets.find(i => i.name === "password_confirmation")
    if (confirmInput && confirmInput.value.trim()) {
      const passwordInput = this.inputTargets.find(i => i.name === "password")
      if (confirmInput.value !== passwordInput?.value) {
        const group = this.#groupFor(confirmInput)
        const message = this.#messageFor(confirmInput)
        this.#setError(confirmInput, message, "Password confirmation doesn't match", group)
        hasErrors = true
      }
    }

    if (hasErrors) {
      event.preventDefault()
      // Scroll to first error
      const firstError = this.element.querySelector('[data-form-validator-target="input"].border-red-500')
      if (firstError) {
        firstError.focus()
        firstError.scrollIntoView({ behavior: "smooth", block: "center" })
      }
    }
  }

  // Check email uniqueness via AJAX (called on blur of email field)
  checkEmail(event) {
    const input = event.target
    const value = input.value.trim()
    const group = this.#groupFor(input)
    const message = this.#messageFor(input)

    if (!value) {
      this.#clearField(input, message)
      return
    }

    // Basic format check first
    if (!this.#isValidEmail(value)) {
      this.#setError(input, message, "Email format is invalid", group)
      return
    }

    // Show loading
    this.#setLoading(input, message)

    // Check uniqueness via AJAX
    fetch(`${this.checkUrlValue}?email=${encodeURIComponent(value)}`, {
      headers: {
        "Accept": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.exists) {
        this.#setError(input, message, data.message || "Email has already been taken", group)
      } else {
        this.#setSuccess(input, message, "", group)
      }
    })
    .catch(() => {
      this.#clearField(input, message)
    })
  }

  // Validate password confirmation match
  checkPasswordMatch(event) {
    const confirmInput = event.target
    const passwordInput = this.inputTargets.find(i => i.dataset.validate?.includes("password") && i.name === "password")
    const group = this.#groupFor(confirmInput)
    const message = this.#messageFor(confirmInput)

    if (!confirmInput.value.trim()) {
      this.#clearField(confirmInput, message)
      return
    }

    if (confirmInput.value !== passwordInput?.value) {
      this.#setError(confirmInput, message, "Password confirmation doesn't match", group)
    } else {
      this.#setSuccess(confirmInput, message, "", group)
    }
  }

  // Core validation method - returns true if error found
  #validateField(input) {
    const value = input.value.trim()
    const rules = (input.dataset.validate || "").split(" ").filter(Boolean)
    const group = this.#groupFor(input)
    const message = this.#messageFor(input)

    if (!message) return false

    const errors = []

    // Required
    if (rules.includes("required") && !value) {
      errors.push(`${this.#label(input)} can't be blank`)
    }

    // Email format (client-side only, uniqueness handled separately)
    if (rules.includes("email") && value && !this.#isValidEmail(value)) {
      errors.push("Email format is invalid")
    }

    // Min length
    if (rules.includes("min6") && value && value.length < 6) {
      errors.push("Minimum 6 characters")
    }

    // Phone number format
    if (rules.includes("phone") && value && !/^\+?[\d\s\-()]*$/.test(value)) {
      errors.push("Only numbers, spaces, dashes, and parentheses allowed")
    }

    if (errors.length > 0) {
      this.#setError(input, message, errors[0], group)
      return true
    } else {
      if (value) {
        this.#setSuccess(input, message, "", group)
      } else {
        this.#clearField(input, message)
      }
      return false
    }
  }

  // --- Helpers ---

  #groupFor(input) {
    return input.closest('[data-form-validator-target="group"]')
  }

  #messageFor(input) {
    const group = this.#groupFor(input)
    return group?.querySelector('[data-form-validator-target="message"]')
  }

  #label(input) {
    const group = this.#groupFor(input)
    const label = group?.querySelector('label')
    return label?.textContent?.trim() || input.name?.replace(/_/g, " ") || "This field"
  }

  #isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
  }

  #setError(input, message, text, group) {
    // DaisyUI-style red border
    input.classList.remove(
      "border-zinc-800", "border-emerald-500", "ring-2", "ring-emerald-500/50"
    )
    input.classList.add("border-red-500", "focus:ring-2", "focus:ring-red-500/50")

    if (message) {
      message.textContent = text
      message.className = "text-xs mt-1 text-red-400"
      message.classList.remove("hidden")
    }

    if (group) {
      group.dataset.valid = "false"
    }
  }

  #setSuccess(input, message, text, group) {
    // Green border for valid field
    input.classList.remove(
      "border-zinc-800", "border-red-500", "focus:ring-red-500/50"
    )
    input.classList.add("border-emerald-500", "focus:ring-2", "focus:ring-emerald-500/50")

    if (message) {
      message.textContent = text || "✓"
      message.className = "text-xs mt-1 text-emerald-400"
      message.classList.remove("hidden")
    }

    if (group) {
      group.dataset.valid = "true"
    }
  }

  #setLoading(input, message) {
    input.classList.remove("border-red-500", "border-emerald-500")
    input.classList.add("border-zinc-500")

    if (message) {
      message.textContent = "Checking..."
      message.className = "text-xs mt-1 text-zinc-500"
      message.classList.remove("hidden")
    }
  }

  #clearField(input, message) {
    input.classList.remove(
      "border-red-500", "border-emerald-500", "border-zinc-500",
      "focus:ring-red-500/50", "focus:ring-emerald-500/50"
    )
    input.classList.add("border-zinc-800", "focus:ring-2", "focus:ring-emerald-500/50")

    if (message) {
      message.textContent = ""
      message.className = "text-xs mt-1 hidden"
    }
  }
}
