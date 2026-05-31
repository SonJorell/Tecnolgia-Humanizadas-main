// ═══════════════════════════════════
// Composable: Monitoreo de conectividad
// Portado desde React useAuth hook
// ═══════════════════════════════════

import { onMounted, onUnmounted, ref } from 'vue'
import { iniciarMonitoreo, type EstadoConexion } from '@/services/connectivity'
import { procesarColaSync, contarPendientes, contarFallidos } from '@/services/sync'
import { useAppStore } from '@/stores/app'
import { useSyncStore } from '@/stores/sync'

export function useConnectivity() {
  const appStore = useAppStore()
  const syncStore = useSyncStore()
  const cleanup = ref<(() => void) | null>(null)

  onMounted(() => {
    let prevEstado: EstadoConexion = appStore.conexion

    cleanup.value = iniciarMonitoreo(async (estado) => {
      appStore.setConexion(estado)

      // Al transicionar de offline/LAN a Supabase → sincronizar
      if (prevEstado !== 'ONLINE_SUPABASE' && estado === 'ONLINE_SUPABASE') {
        syncStore.setSyncing(true)
        const count = await procesarColaSync()
        syncStore.setSyncing(false)
        syncStore.setUltimoSync(Date.now())

        if (count > 0) {
          appStore.addToast({
            tipo: 'sync',
            mensaje: `✅ ${count} elemento${count > 1 ? 's' : ''} sincronizado${count > 1 ? 's' : ''}`
          })
        }
      }

      // Actualizar contadores
      const pendientes = await contarPendientes()
      const fallidos = await contarFallidos()
      syncStore.setPendientes(pendientes)
      syncStore.setFallidos(fallidos)

      prevEstado = estado
    })
  })

  onUnmounted(() => {
    cleanup.value?.()
  })

  return {
    conexion: appStore.conexion,
    isOnline: appStore.isOnline,
    isLanOnly: appStore.isLanOnly,
    isOffline: appStore.isOffline
  }
}
