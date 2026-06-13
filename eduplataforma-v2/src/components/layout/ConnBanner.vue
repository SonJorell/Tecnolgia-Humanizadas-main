<script setup lang="ts">
import { computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { useSyncStore } from '@/stores/sync'

const appStore = useAppStore()
const syncStore = useSyncStore()

const isSupabase = computed(() => appStore.conexion === 'ONLINE_SUPABASE')
const isLan = computed(() => appStore.conexion === 'ONLINE_LAN_ONLY')
</script>

<template>
 <div class="fixed top-0 left-0 right-0 h-8 bg-secondary px-4 flex justify-center items-center gap-4 text-white font-['Inter'] text-[11px] font-medium uppercase tracking-wider z-50">
 <div class="flex items-center gap-1.5">
 <span class="w-1.5 h-1.5 rounded-full" :class="syncStore.syncing ? 'bg-tertiary-400 animate-pulse' : 'bg-[#7afac7] animate-pulse'"></span>
 {{ syncStore.syncing ? 'Sincronizando...' : 'Conectado' }}
 </div>
 
 <span class="opacity-30">|</span>
 
 <div class="flex items-center gap-1" :class="{'opacity-50': !isLan && !isSupabase}">
 LAN 
 <span class="material-symbols-outlined text-[14px]">{{ isLan || isSupabase ? 'check_circle' : 'cancel' }}</span>
 </div>
 
 <span class="opacity-30">|</span>
 
 <div class="flex items-center gap-1" :class="{'opacity-50': !isSupabase}">
 Supabase 
 <span class="material-symbols-outlined text-[14px]">{{ isSupabase ? 'check_circle' : 'cancel' }}</span>
 </div>

 <div v-if="syncStore.hasPendientes && !syncStore.syncing" class="ml-4 flex items-center gap-1 text-tertiary-800">
 <span class="material-symbols-outlined text-[14px]">sync_problem</span>
 {{ syncStore.pendientes }} pendiente(s)
 </div>
 </div>
</template>
