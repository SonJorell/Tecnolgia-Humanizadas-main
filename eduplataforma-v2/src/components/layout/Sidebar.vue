<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useAppStore } from '@/stores/app'
import { useSyncStore } from '@/stores/sync'
import {
  Home, BookOpen, ClipboardList, Trophy, Search,
  MessageSquare, Store, Users, Upload, BarChart3,
  FileText, Building2, TrendingUp, Server, Bell, LogOut, GraduationCap,
  Megaphone
} from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const appStore = useAppStore()
const syncStore = useSyncStore()

interface NavLink {
  path: string
  label: string
  icon: any
  badge?: number
}

const navLinks = computed<NavLink[]>(() => {
  const rol = authStore.perfil?.rol
  if (rol === 'alumno') {
    return [
      { path: '/alumno', label: 'Inicio', icon: Home },
      { path: '/alumno/cursos', label: 'Mis Cursos', icon: BookOpen },
      { path: '/alumno/tareas', label: 'Tareas', icon: ClipboardList },
      { path: '/alumno/logros', label: 'Logros', icon: Trophy },
      { path: '/alumno/buscador', label: 'Buscador', icon: Search },
      { path: '/alumno/mensajeria', label: 'Mensajes', icon: MessageSquare },
      { path: '/alumno/tienda', label: 'Tienda', icon: Store },
    ]
  }
  if (rol === 'docente') {
    return [
      { path: '/docente', label: 'Panel', icon: Home },
      { path: '/docente/cursos', label: 'Cursos', icon: BookOpen },
      { path: '/docente/alumnos', label: 'Alumnos', icon: Users },
      { path: '/docente/materiales', label: 'Materiales', icon: Upload },
      { path: '/docente/entregas', label: 'Entregas', icon: ClipboardList },
      { path: '/docente/mensajeria', label: 'Mensajería', icon: MessageSquare },
      { path: '/docente/logros', label: 'Premios', icon: Trophy },
    ]
  }
  if (rol === 'directivo') {
    return [
      { path: '/directivo', label: 'Resumen', icon: Building2 },
      { path: '/directivo/rendimiento', label: 'Rendimiento', icon: TrendingUp },
      { path: '/directivo/infraestructura', label: 'Infraestructura', icon: Server },
      { path: '/directivo/alertas', label: 'Alertas', icon: Bell },
      { path: '/directivo/gestion', label: 'Gestión', icon: GraduationCap },
      { path: '/directivo/comunicados', label: 'Anuncios', icon: Megaphone },
    ]
  }
  if (rol === 'ti') {
    return [
      { path: '/ti', label: 'Panel Feedback', icon: MessageSquare },
      { path: '/ti/usuarios', label: 'Usuarios', icon: Users },
    ]
  }
  return []
})

const connDot = computed(() => {
  switch (appStore.conexion) {
    case 'ONLINE_SUPABASE': return 'bg-[#2db88a]'
    case 'ONLINE_LAN_ONLY': return 'bg-[#e8a020]'
    default: return 'bg-[#e05050]'
  }
})

function isActive(path: string): boolean {
  if (path === `/${authStore.perfil?.rol}`) {
    return route.path === path
  }
  return route.path.startsWith(path)
}

async function handleLogout() {
  await authStore.signOut()
  router.push('/login')
}
</script>

<template>
  <aside class="sidebar h-[calc(100dvh-96px)] sticky top-[96px] w-[240px] bg-card dark:bg-dark-card border-r border-border dark:border-white/10 flex flex-col overflow-hidden">
    <!-- Profile card -->
    <div v-if="authStore.perfil" class="p-4 bg-surface dark:bg-dark-card2 m-3 rounded-xl">
      <div class="flex items-center gap-3">
        <div class="w-11 h-11 rounded-full bg-primary flex items-center justify-center text-white font-bold text-sm flex-shrink-0 overflow-hidden cursor-pointer hover:ring-2 hover:ring-primary/50 transition-all" @click="router.push(`/${authStore.perfil.rol}/perfil`)">
          <img v-if="authStore.perfil.avatar_url && (authStore.perfil.avatar_url.startsWith('http') || authStore.perfil.avatar_url.startsWith('data'))" :src="authStore.perfil.avatar_url" class="w-full h-full object-cover" />
          <span v-else-if="authStore.perfil.avatar_url" class="text-2xl">{{ authStore.perfil.avatar_url }}</span>
          <span v-else>{{ authStore.perfil.nombre?.charAt(0).toUpperCase() || 'U' }}</span>
        </div>
        <div class="min-w-0">
          <p class="font-medium text-sm text-text dark:text-dark-text truncate">
            {{ authStore.perfil.nombre }}
          </p>
          <p class="text-xs text-text-muted dark:text-dark-muted">
            {{ authStore.perfil.rol.charAt(0).toUpperCase() + authStore.perfil.rol.slice(1) }}
            <span v-if="authStore.perfil.rol === 'alumno'"> · Nivel {{ authStore.perfil.nivel }}</span>
          </p>
        </div>
      </div>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 px-3 space-y-0.5 overflow-y-auto">
      <router-link
        v-for="link in navLinks"
        :key="link.path"
        :to="link.path"
        :class="[
          'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors',
          isActive(link.path)
            ? 'bg-primary-bg dark:bg-primary/10 text-primary'
            : 'text-text-muted dark:text-dark-muted hover:bg-surface dark:hover:bg-dark-card2 hover:text-text dark:hover:text-dark-text'
        ]"
      >
        <component :is="link.icon" :size="18" />
        <span class="flex-1">{{ link.label }}</span>
        <span
          v-if="link.badge && link.badge > 0"
          class="text-[10px] font-bold bg-amber text-white px-1.5 py-0.5 rounded-full min-w-[18px] text-center"
        >
          {{ link.badge }}
        </span>
      </router-link>
    </nav>

    <!-- XP bar (alumno only) -->
    <div v-if="authStore.perfil?.rol === 'alumno'" class="mx-3 mb-2">
      <div class="bg-gradient-to-br from-blue-600 to-blue-400 rounded-xl p-3.5">
        <p class="text-[10px] font-bold uppercase tracking-wider text-white/75">
          🌟 Nivel {{ authStore.perfil.nivel }} — {{ authStore.perfil.nivel <= 2 ? 'Novato' : authStore.perfil.nivel <= 5 ? 'Aprendiz' : 'Experto' }}
        </p>
        <p class="text-xs font-semibold text-white mt-1 mb-1.5">
          {{ authStore.perfil.xp }} / {{ authStore.perfil.nivel * 100 }} XP
        </p>
        <div class="h-1.5 bg-white/20 rounded-full overflow-hidden">
          <div
            class="h-full bg-gradient-to-r from-amber-400 to-yellow-300 rounded-full progress-fill"
            :style="{ width: `${Math.min(100, (authStore.perfil.xp / (authStore.perfil.nivel * 100)) * 100)}%` }"
          />
        </div>
        <p class="text-white font-semibold text-xs mt-1.5">🪙 {{ authStore.perfil.monedas }} monedas</p>
      </div>
    </div>

    <!-- System status -->
    <div class="p-3 border-t border-border dark:border-white/10">
      <div class="text-[10px] text-text-light dark:text-dark-muted space-y-1">
        <div class="flex items-center gap-2">
          <div :class="['w-1.5 h-1.5 rounded-full', connDot]" />
          <span>{{ appStore.conexion === 'ONLINE_SUPABASE' ? 'Supabase ✓' : appStore.conexion === 'ONLINE_LAN_ONLY' ? 'Solo LAN' : 'Offline' }}</span>
        </div>
        <div v-if="syncStore.hasPendientes" class="text-amber">
          📤 {{ syncStore.pendientes }} pendiente{{ syncStore.pendientes > 1 ? 's' : '' }}
        </div>
      </div>
      <button
        class="flex items-center gap-1.5 text-xs text-text-muted hover:text-danger mt-2 transition-colors"
        @click="handleLogout"
      >
        <LogOut :size="14" />
        Cerrar sesión
      </button>
    </div>
  </aside>
</template>
