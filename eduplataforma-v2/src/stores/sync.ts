// ═══════════════════════════════════
// Store: Estado de sincronización (Pinia)
// Portado desde Zustand syncStore
// ═══════════════════════════════════

import { ref, computed } from 'vue'
import { defineStore } from 'pinia'

export const useSyncStore = defineStore('sync', () => {
  const syncing = ref(false)
  const pendientes = ref(0)
  const fallidos = ref(0)
  const ultimoSync = ref<number | null>(null)

  const hasPendientes = computed(() => pendientes.value > 0)
  const hasFallidos = computed(() => fallidos.value > 0)
  const ultimoSyncFormatted = computed(() => {
    if (!ultimoSync.value) return 'Sin sincronización reciente'
    return new Date(ultimoSync.value).toLocaleString('es-CL')
  })

  function setSyncing(val: boolean): void {
    syncing.value = val
  }

  function setPendientes(n: number): void {
    pendientes.value = n
  }

  function setFallidos(n: number): void {
    fallidos.value = n
  }

  function setUltimoSync(ts: number): void {
    ultimoSync.value = ts
  }

  return {
    syncing,
    pendientes,
    fallidos,
    ultimoSync,
    hasPendientes,
    hasFallidos,
    ultimoSyncFormatted,
    setSyncing,
    setPendientes,
    setFallidos,
    setUltimoSync
  }
})
