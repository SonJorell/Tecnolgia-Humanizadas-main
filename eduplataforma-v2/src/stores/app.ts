// ═══════════════════════════════════
// Store: Estado global de la aplicación (Pinia)
// Portado desde Zustand appStore
// ═══════════════════════════════════

import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import type { EstadoConexion, Toast } from '@/types/app'

export const useAppStore = defineStore('app', () => {
  const conexion = ref<EstadoConexion>('OFFLINE_TOTAL')
  const darkMode = ref(false)
  const sidebarOpen = ref(false)
  const toasts = ref<Toast[]>([])

  // Computed
  const isOnline = computed(() => conexion.value === 'ONLINE_SUPABASE')
  const isLanOnly = computed(() => conexion.value === 'ONLINE_LAN_ONLY')
  const isOffline = computed(() => conexion.value === 'OFFLINE_TOTAL')

  function setConexion(estado: EstadoConexion): void {
    conexion.value = estado
  }

  function toggleDarkMode(): void {
    darkMode.value = !darkMode.value
    if (darkMode.value) {
      document.documentElement.classList.add('dark')
      localStorage.setItem('darkMode', 'true')
    } else {
      document.documentElement.classList.remove('dark')
      localStorage.setItem('darkMode', 'false')
    }
  }

  function initDarkMode(): void {
    const saved = localStorage.getItem('darkMode')
    if (saved === 'true') {
      darkMode.value = true
      document.documentElement.classList.add('dark')
    }
  }

  function setSidebarOpen(open: boolean): void {
    sidebarOpen.value = open
  }

  function addToast(toast: Omit<Toast, 'id'>): void {
    const id = crypto.randomUUID()
    const newToast = { ...toast, id }
    toasts.value.push(newToast)

    const dur = toast.duracion || 3000
    setTimeout(() => {
      removeToast(id)
    }, dur)
  }

  function removeToast(id: string): void {
    toasts.value = toasts.value.filter(t => t.id !== id)
  }

  return {
    // State
    conexion,
    darkMode,
    sidebarOpen,
    toasts,
    // Computed
    isOnline,
    isLanOnly,
    isOffline,
    // Actions
    setConexion,
    toggleDarkMode,
    initDarkMode,
    setSidebarOpen,
    addToast,
    removeToast
  }
})
