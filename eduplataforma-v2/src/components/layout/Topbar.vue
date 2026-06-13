<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useAppStore } from '@/stores/app'
import { supabase } from '@/services/supabase'

const router = useRouter()
const authStore = useAuthStore()
const appStore = useAppStore()

async function handleLogout() {
 await authStore.signOut()
 router.push('/login')
}

const showNotifs = ref(false)
const notificaciones = ref<any[]>([])
const unreadNotifs = computed(() => notificaciones.value.filter(n => !n.leido).length)

onMounted(async () => {
 if (authStore.user) {
 const { data } = await supabase
 .from('notificaciones')
 .select('*')
 .eq('usuario_id', authStore.user.id)
 .order('creado_en', { ascending: false })
 .limit(10)
 
 if (data) {
 notificaciones.value = data
 }
 }
})

async function markAllAsRead() {
 const unreadIds = notificaciones.value.filter(n => !n.leido).map(n => n.id)
 if (unreadIds.length > 0) {
 await supabase.from('notificaciones').update({ leido: true }).in('id', unreadIds)
 notificaciones.value.forEach(n => n.leido = true)
 }
}
</script>

<template>
 <header class="flex justify-between items-center w-full px-6 md:px-12 py-4 sticky top-8 z-30 bg-surface-container-low/80 backdrop-blur-xl border-b border-outline-variant/50 transition-colors duration-300">
 <div class="flex items-center gap-6 flex-1">
 
 <!-- Search -->
 <div class="relative hidden sm:block w-full max-w-sm">
 <span class="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-on-surface-variant/40 text-[20px]">search</span>
 <input id="input_text_1" name="input_text_1" 
 type="text" 
 class="pl-11 pr-4 py-2.5 bg-surface-container-low border border-outline-variant/50 rounded-2xl font-['Inter'] text-[14px] leading-[20px] w-full text-on-surface focus:ring-2 focus:ring-primary/20 :ring-[#96ccff]/20 focus:border-primary/40 :border-[#96ccff]/40 outline-none transition-all placeholder:text-on-surface-variant/40 :text-[#9ea8b3]/50" 
 placeholder="¿Qué quieres aprender hoy?" 
 />
 </div>
 </div>
 
 <div class="flex items-center gap-2 md:gap-4">
 <button type="button" 
 class="w-10 h-10 flex items-center justify-center rounded-xl hover:bg-surface-container-low :bg-[#1a2129] transition-colors text-on-surface-variant"
 @click="appStore.toggleDarkMode()"
 :title="appStore.darkMode ? 'Modo claro' : 'Modo oscuro'"
 >
 <span class="material-symbols-outlined">{{ appStore.darkMode ? 'light_mode' : 'dark_mode' }}</span>
 </button>
 
 <div class="relative">
 <button type="button" 
 class="w-10 h-10 flex items-center justify-center rounded-xl hover:bg-surface-container-low :bg-[#1a2129] transition-colors text-on-surface-variant"
 @click="showNotifs = !showNotifs"
 >
 <span class="material-symbols-outlined">notifications</span>
 </button>
 <span v-if="unreadNotifs > 0" class="absolute top-2.5 right-2.5 w-2 h-2 bg-[#ba1a1a] rounded-full ring-2 ring-white"></span>

 <!-- Dropdown Notificaciones -->
 <div v-if="showNotifs" class="absolute right-0 mt-2 w-80 bg-surface-container-lowest rounded-2xl shadow-xl border border-outline-variant/50 overflow-hidden z-50">
 <div class="p-3 border-b border-outline-variant/50 flex items-center justify-between bg-surface-container-low">
 <h3 class="font-bold text-sm text-on-surface">Notificaciones</h3>
 <button type="button" v-if="unreadNotifs > 0" @click="markAllAsRead" class="text-[10px] font-bold text-primary hover:underline">
 Marcar todo como leído
 </button>
 </div>
 <div class="max-h-80 overflow-y-auto">
 <div v-if="notificaciones.length === 0" class="p-6 text-center text-xs text-on-surface-variant/60">
 No tienes notificaciones
 </div>
 <div 
 v-for="notif in notificaciones" 
 :key="notif.id"
 class="p-3 border-b border-outline-variant/30 hover:bg-surface-container :bg-[#222b35] transition-colors flex gap-3"
 :class="{'bg-primary/5 ': !notif.leido}"
 >
 <div class="w-8 h-8 rounded-full bg-primary/10 text-primary flex items-center justify-center flex-shrink-0">
 <span class="material-symbols-outlined text-[16px]">notifications</span>
 </div>
 <div class="flex-1 min-w-0">
 <p class="text-xs font-bold text-on-surface">{{ notif.titulo }}</p>
 <p class="text-xs text-on-surface-variant/80 mt-0.5 line-clamp-2">{{ notif.mensaje }}</p>
 <p class="text-[10px] text-on-surface-variant/50 mt-1">{{ new Date(notif.creado_en).toLocaleDateString() }}</p>
 </div>
 </div>
 </div>
 </div>
 </div>
 
 <div class="h-6 w-[1px] bg-outline-variant/40 mx-2"></div>
 
 <button type="button" 
 class="flex items-center gap-2 py-2 px-4 rounded-xl border border-primary/20 hover:bg-primary/5 :bg-[#96ccff]/10 transition-all"
 @click="handleLogout"
 >
 <span class="font-['Inter'] text-[14px] font-bold text-primary hidden sm:inline">Salir</span>
 <span class="material-symbols-outlined text-primary text-[20px]">login</span>
 </button>
 </div>
 </header>
</template>
