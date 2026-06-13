import { defineStore } from 'pinia'
import { ref, watch } from 'vue'

export const useAccessibilityStore = defineStore('accessibility', () => {
  const fontSize = ref(localStorage.getItem('accessibility_font_size') || 'normal')

  watch(fontSize, (newVal) => {
    localStorage.setItem('accessibility_font_size', newVal)
    document.documentElement.className = document.documentElement.className
      .replace(/font-size-\w+/g, '')
      .trim()
    if (newVal !== 'normal') {
      document.documentElement.classList.add(`font-size-${newVal}`)
    }
  }, { immediate: true })

  function increaseFontSize() {
    if (fontSize.value === 'normal') fontSize.value = 'large'
    else if (fontSize.value === 'large') fontSize.value = 'xlarge'
  }

  function decreaseFontSize() {
    if (fontSize.value === 'xlarge') fontSize.value = 'large'
    else if (fontSize.value === 'large') fontSize.value = 'normal'
  }

  return { fontSize, increaseFontSize, decreaseFontSize }
})
