// ═══════════════════════════════════
// Composable: Sincronización manual
// Portado desde React useSync hook
// ═══════════════════════════════════

import { procesarColaSync, contarPendientes } from '@/services/sync'
import { useAppStore } from '@/stores/app'
import { useSyncStore } from '@/stores/sync'

export function useSync() {
  const appStore = useAppStore()
  const syncStore = useSyncStore()

  async function syncAhora(): Promise<void> {
    if (!appStore.isOnline) {
      appStore.addToast({ tipo: 'error', mensaje: '⚠️ Sin conexión a Supabase' })
      return
    }

    syncStore.setSyncing(true)
    try {
      const count = await procesarColaSync()
      const remaining = await contarPendientes()
      syncStore.setPendientes(remaining)
      syncStore.setUltimoSync(Date.now())

      if (count > 0) {
        appStore.addToast({
          tipo: 'sync',
          mensaje: `✅ ${count} elemento${count > 1 ? 's' : ''} sincronizado${count > 1 ? 's' : ''}`
        })
      } else {
        appStore.addToast({ tipo: 'info', mensaje: 'Todo está sincronizado' })
      }
    } catch {
      appStore.addToast({ tipo: 'error', mensaje: '❌ Error de sincronización' })
    } finally {
      syncStore.setSyncing(false)
    }
  }

  return {
    syncing: syncStore.syncing,
    pendientes: syncStore.pendientes,
    ultimoSync: syncStore.ultimoSync,
    syncAhora
  }
}
