<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import {
  Home, BookOpen, ClipboardList, Trophy, Store,
  Users, Upload, BarChart3, Building2, TrendingUp, Server, Bell, GraduationCap,
  Megaphone, MessageSquare
} from 'lucide-vue-next'

const route = useRoute()
const authStore = useAuthStore()

interface BottomNavItem {
  path: string
  label: string
  icon: any
}

const items = computed<BottomNavItem[]>(() => {
  const rol = authStore.perfil?.rol
  if (rol === 'alumno') {
    return [
      { path: '/alumno', label: 'Inicio', icon: Home },
      { path: '/alumno/cursos', label: 'Cursos', icon: BookOpen },
      { path: '/alumno/tareas', label: 'Tareas', icon: ClipboardList },
      { path: '/alumno/mensajeria', label: 'Chat', icon: MessageSquare },
      { path: '/alumno/logros', label: 'Logros', icon: Trophy },
    ]
  }
  if (rol === 'docente') {
    return [
      { path: '/docente', label: 'Panel', icon: Home },
      { path: '/docente/alumnos', label: 'Alumnos', icon: Users },
      { path: '/docente/materiales', label: 'Material', icon: Upload },
      { path: '/docente/dashboard', label: 'Dashboard', icon: BarChart3 },
    ]
  }
  if (rol === 'ti') {
    return [
      { path: '/ti', label: 'Panel Feedback', icon: MessageSquare },
      { path: '/ti/usuarios', label: 'Usuarios', icon: Users },
    ]
  }
  if (rol === 'directivo') {
    return [
      { path: '/directivo', label: 'Resumen', icon: Building2 },
      { path: '/directivo/rendimiento', label: 'Rendim.', icon: TrendingUp },
      { path: '/directivo/infraestructura', label: 'Infra', icon: Server },
      { path: '/directivo/alertas', label: 'Alertas', icon: Bell },
      { path: '/directivo/gestion', label: 'Gestión', icon: GraduationCap },
      { path: '/directivo/comunicados', label: 'Anuncios', icon: Megaphone },
    ]
  }
  return []
})

const rolColor = computed(() => {
  switch (authStore.perfil?.rol) {
    case 'alumno': return 'text-primary'
    case 'docente': return 'text-mint'
    case 'directivo': return 'text-violet'
    case 'ti': return 'text-amber'
    default: return 'text-text-muted'
  }
})

function isActive(path: string): boolean {
  if (path === `/${authStore.perfil?.rol}`) {
    return route.path === path
  }
  return route.path.startsWith(path)
}
</script>

<template>
  <nav class="bottom-nav fixed bottom-0 left-0 right-0 z-40 bg-card dark:bg-dark-card border-t border-border dark:border-white/10 shadow-[0_-4px_20px_rgba(0,0,0,0.08)]"
    style="padding-bottom: env(safe-area-inset-bottom)"
  >
    <div class="flex items-center justify-around h-14 px-1 w-full max-w-md mx-auto">
      <router-link
        v-for="item in items"
        :key="item.path"
        :to="item.path"
        :class="[
          'flex flex-col items-center justify-center gap-0.5 flex-1 min-w-0 h-full transition-colors',
          isActive(item.path) ? rolColor : 'text-text-light dark:text-dark-muted'
        ]"
      >
        <component :is="item.icon" :size="20" class="flex-shrink-0" />
        <span class="text-[9px] sm:text-[10px] font-medium whitespace-nowrap truncate max-w-full px-0.5">{{ item.label }}</span>
      </router-link>
    </div>
  </nav>
</template>
