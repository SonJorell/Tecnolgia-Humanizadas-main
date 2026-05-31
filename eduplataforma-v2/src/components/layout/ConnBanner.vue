<script setup lang="ts">
import { computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { useSyncStore } from '@/stores/sync'

const appStore = useAppStore()
const syncStore = useSyncStore()

const bgClass = computed(() => {
  if (syncStore.syncing) return 'bg-primary'
  switch (appStore.conexion) {
    case 'ONLINE_SUPABASE': return 'bg-[#2db88a]'
    case 'ONLINE_LAN_ONLY': return 'bg-[#e8a020]'
    default: return 'bg-[#e05050]'
  }
})

const statusText = computed(() => {
  if (syncStore.syncing) return '↑ Sincronizando...'
  switch (appStore.conexion) {
    case 'ONLINE_SUPABASE': return '● Conectado · LAN ✓ · Supabase ✓'
    case 'ONLINE_LAN_ONLY': return '◐ Solo LAN · Guardando offline'
    default: return '○ Sin conexión · Modo offline activo'
  }
})
</script>

<template>
  <div
    :class="['conn-banner fixed top-0 left-0 right-0 h-9 flex items-center justify-center z-50 text-white text-xs font-medium font-body', bgClass]"
  >
    <span v-if="syncStore.syncing" class="flex items-center gap-2">
      <span class="w-3 h-3 border-2 border-white border-t-transparent rounded-full animate-spin" />
      {{ statusText }}
    </span>
    <span v-else>{{ statusText }}</span>
    <span v-if="syncStore.hasPendientes && !syncStore.syncing" class="ml-3 opacity-80">
      · {{ syncStore.pendientes }} pendiente{{ syncStore.pendientes > 1 ? 's' : '' }}
    </span>
  </div>
</template>
