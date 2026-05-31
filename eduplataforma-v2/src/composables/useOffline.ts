// ═══════════════════════════════════
// Composable: Operaciones offline
// Portado desde React useOffline hook
// ═══════════════════════════════════

import { agregarACola, procesarColaSync } from '@/services/sync'
import { idb } from '@/services/idb'
import { useAppStore } from '@/stores/app'
import { useAuthStore } from '@/stores/auth'

export function useOffline() {
  const appStore = useAppStore()
  const authStore = useAuthStore()

  async function guardarEntregaOffline(entrega: any): Promise<void> {
    // Guardar en IDB primero (respuesta instantánea)
    await idb.put('entregas', entrega)

    // Agregar a cola de sync
    await agregarACola('entrega', entrega, 'entregas', 'upsert')

    appStore.addToast({
      tipo: 'info',
      mensaje: appStore.isOnline
        ? '✅ Entrega guardada y sincronizada'
        : '📱 Entrega guardada offline · Se sincronizará al reconectar'
    })

    // Si online, sincronizar de inmediato
    if (appStore.isOnline) {
      await procesarColaSync()
    }
  }

  async function guardarFeedbackOffline(feedback: any): Promise<void> {
    await agregarACola('feedback', feedback, 'feedback', 'insert')

    // Otorgar +5 monedas
    const perfil = authStore.perfil
    if (perfil) {
      const newMonedas = perfil.monedas + 5
      authStore.updatePerfil({ monedas: newMonedas })
      await agregarACola('monedas', {
        user_id: perfil.id,
        monedas: newMonedas,
        xp: perfil.xp
      })
    }

    appStore.addToast({ tipo: 'xp', mensaje: '🪙 +5 monedas por tu feedback' })

    if (appStore.isOnline) {
      await procesarColaSync()
    }
  }

  return {
    isOffline: appStore.isOffline,
    isLanOnly: appStore.isLanOnly,
    isOnline: appStore.isOnline,
    guardarEntregaOffline,
    guardarFeedbackOffline
  }
}
