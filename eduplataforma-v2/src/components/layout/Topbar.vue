<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useAppStore } from '@/stores/app'
import { useSyncStore } from '@/stores/sync'
import { useSync } from '@/composables/useSync'
import { supabase } from '@/services/supabase'
import Logo from '@/components/ui/Logo.vue'
import { Moon, Sun, RefreshCw, LogOut, Bell, X, Check } from 'lucide-vue-next'

const router = useRouter()
const authStore = useAuthStore()
const appStore = useAppStore()
const syncStore = useSyncStore()
const { syncAhora } = useSync()

const rolLabel = computed(() => {
  switch (authStore.perfil?.rol) {
    case 'alumno': return 'Alumno'
    case 'docente': return 'Docente'
    case 'directivo': return 'Directivo'
    default: return ''
  }
})

const rolBadgeClass = computed(() => {
  switch (authStore.perfil?.rol) {
    case 'alumno': return 'bg-primary-bg text-primary'
    case 'docente': return 'bg-mint-bg text-mint'
    case 'directivo': return 'bg-violet-bg text-violet'
    default: return 'bg-surface text-text-muted'
  }
})

const connDot = computed(() => {
  switch (appStore.conexion) {
    case 'ONLINE_SUPABASE': return 'bg-[#2db88a]'
    case 'ONLINE_LAN_ONLY': return 'bg-[#e8a020]'
    default: return 'bg-[#e05050]'
  }
})

async function handleLogout() {
  await authStore.signOut()
  router.push('/login')
}

// ─── NOTIFICACIONES ───
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

async function markAsRead(id: string) {
  await supabase.from('notificaciones').update({ leido: true }).eq('id', id)
  const n = notificaciones.value.find(x => x.id === id)
  if (n) n.leido = true
}

async function markAllAsRead() {
  const unreadIds = notificaciones.value.filter(n => !n.leido).map(n => n.id)
  if (unreadIds.length > 0) {
    await supabase.from('notificaciones').update({ leido: true }).in('id', unreadIds)
    notificaciones.value.forEach(n => n.leido = true)
  }
}

async function deleteNotif(id: string) {
  await supabase.from('notificaciones').delete().eq('id', id)
  notificaciones.value = notificaciones.value.filter(x => x.id !== id)
}
</script>

<template>
  <header
    class="sticky top-9 z-40 h-[60px] md:h-[60px] bg-card/95 dark:bg-dark-card/95 backdrop-blur-lg shadow-topbar flex items-center px-3 md:px-5"
  >
    <!-- Left: Logo + App name + Role badge -->
    <div class="flex items-center gap-2.5 min-w-0">
      <Logo :size="28" />
      <span class="font-display font-bold text-base text-text dark:text-dark-text hidden sm:inline">
        EduPlataforma
      </span>
      <span
        v-if="authStore.perfil"
        :class="['text-[10px] font-semibold uppercase tracking-wider px-2 py-0.5 rounded-full', rolBadgeClass]"
      >
        {{ rolLabel }}
      </span>
    </div>

    <div class="flex-1" />

    <!-- Right: controls -->
    <div class="flex items-center gap-2">
      <!-- Connection dot (mobile) -->
      <div :class="['w-2 h-2 rounded-full md:hidden', connDot]" />

      <!-- Sync button (desktop) -->
      <button
        v-if="syncStore.hasPendientes"
        class="hidden md:flex items-center gap-1.5 text-xs font-medium text-primary hover:text-primary-light px-2 py-1.5 rounded-lg hover:bg-primary-bg transition-colors"
        :disabled="syncStore.syncing"
        @click="syncAhora"
      >
        <RefreshCw :size="14" :class="{ 'animate-spin': syncStore.syncing }" />
        Sync ↑{{ syncStore.pendientes }}
      </button>

      <!-- Dark mode toggle -->
      <button
        class="p-2 rounded-lg text-text-light hover:text-text hover:bg-surface dark:hover:bg-dark-card2 transition-colors"
        @click="appStore.toggleDarkMode()"
        :title="appStore.darkMode ? 'Modo claro' : 'Modo oscuro'"
      >
        <Sun v-if="appStore.darkMode" :size="18" />
        <Moon v-else :size="18" />
      </button>

      <!-- Notificaciones -->
      <div class="relative">
        <button
          class="p-2 rounded-lg text-text-light hover:text-text hover:bg-surface dark:hover:bg-dark-card2 transition-colors relative"
          @click="showNotifs = !showNotifs"
        >
          <Bell :size="18" />
          <span v-if="unreadNotifs > 0" class="absolute top-1.5 right-1.5 w-2 h-2 bg-danger rounded-full ring-2 ring-card dark:ring-dark-card"></span>
        </button>

        <!-- Dropdown Notificaciones -->
        <div v-if="showNotifs" class="absolute right-0 mt-2 w-80 bg-card dark:bg-dark-card rounded-2xl shadow-xl border border-border dark:border-white/10 overflow-hidden z-50">
          <div class="p-3 border-b border-border dark:border-white/10 flex items-center justify-between bg-surface dark:bg-dark-card2">
            <h3 class="font-bold text-sm text-text dark:text-dark-text">Notificaciones</h3>
            <button v-if="unreadNotifs > 0" @click="markAllAsRead" class="text-[10px] font-bold text-primary hover:underline">
              Marcar todo como leído
            </button>
          </div>
          <div class="max-h-80 overflow-y-auto">
            <div v-if="notificaciones.length === 0" class="p-6 text-center text-xs text-text-muted">
              No tienes notificaciones
            </div>
            <div 
              v-for="notif in notificaciones" 
              :key="notif.id"
              class="p-3 border-b border-border dark:border-white/5 hover:bg-surface dark:hover:bg-dark-card2 transition-colors flex gap-3 group"
              :class="{'bg-primary/5 dark:bg-primary/10': !notif.leido}"
            >
              <div class="w-8 h-8 rounded-full bg-primary/20 text-primary flex items-center justify-center flex-shrink-0">
                <Bell :size="14" />
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-xs font-bold text-text dark:text-dark-text">{{ notif.titulo }}</p>
                <p class="text-xs text-text-muted mt-0.5 line-clamp-2">{{ notif.mensaje }}</p>
                <p class="text-[10px] text-text-muted/50 mt-1">{{ new Date(notif.creado_en).toLocaleDateString() }}</p>
              </div>
              <div class="flex flex-col gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                <button v-if="!notif.leido" @click="markAsRead(notif.id)" class="p-1 text-primary hover:bg-primary/10 rounded" title="Marcar como leído">
                  <Check :size="12" />
                </button>
                <button @click="deleteNotif(notif.id)" class="p-1 text-danger hover:bg-danger/10 rounded" title="Borrar">
                  <X :size="12" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Avatar -->
      <div
        v-if="authStore.perfil"
        class="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-white text-xs font-bold cursor-pointer hover:ring-2 hover:ring-primary/50 transition-all overflow-hidden"
        @click="router.push(`/${authStore.perfil.rol}/perfil`)"
      >
        <img v-if="authStore.perfil.avatar_url && (authStore.perfil.avatar_url.startsWith('http') || authStore.perfil.avatar_url.startsWith('data'))" :src="authStore.perfil.avatar_url" class="w-full h-full object-cover" />
        <span v-else-if="authStore.perfil.avatar_url" class="text-lg">{{ authStore.perfil.avatar_url }}</span>
        <span v-else>{{ authStore.perfil.nombre?.charAt(0).toUpperCase() || 'U' }}</span>
      </div>

      <!-- Logout (desktop) -->
      <button
        class="hidden md:flex items-center gap-1 text-xs text-text-muted hover:text-danger px-2 py-1.5 rounded-lg hover:bg-danger-bg transition-colors"
        @click="handleLogout"
      >
        <LogOut :size="14" />
        Salir
      </button>
    </div>
  </header>
</template>
