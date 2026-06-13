<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const authStore = useAuthStore()

interface NavLink {
 path: string
 label: string
 icon: string
 iconFilled?: boolean
}

const navLinks = computed<NavLink[]>(() => {
 const rol = authStore.perfil?.rol
 if (rol === 'alumno') {
 return [
 { path: '/alumno', label: 'Inicio', icon: 'home', iconFilled: true },
 { path: '/alumno/cursos', label: 'Cursos', icon: 'school' },
 { path: '/alumno/tareas', label: 'Tareas', icon: 'assignment' },
 { path: '/alumno/mensajeria', label: 'Mensajes', icon: 'mail' },
 { path: '/alumno/perfil', label: 'Perfil', icon: 'person' },
 ]
 }
 if (rol === 'docente') {
 return [
 { path: '/docente', label: 'Panel', icon: 'home', iconFilled: true },
 { path: '/docente/cursos', label: 'Cursos', icon: 'school' },
 { path: '/docente/entregas', label: 'Entregas', icon: 'assignment' },
 { path: '/docente/mensajeria', label: 'Mensajes', icon: 'mail' },
 { path: '/docente/perfil', label: 'Perfil', icon: 'person' },
 ]
 }
  if (rol === 'directivo') {
  return [
  { path: '/directivo', label: 'Resumen', icon: 'domain', iconFilled: true },
  { path: '/directivo/rendimiento', label: 'Rendim.', icon: 'trending_up' },
  { path: '/directivo/alertas', label: 'Alertas', icon: 'notifications_active' },
  { path: '/directivo/comunicados', label: 'Anuncios', icon: 'campaign' },
  { path: '/directivo/perfil', label: 'Perfil', icon: 'person' },
  ]
  }
  if (rol === 'ti') {
  return [
  { path: '/ti', label: 'Panel', icon: 'bug_report', iconFilled: true },
  { path: '/ti/infraestructura', label: 'Infra.', icon: 'dns' },
  { path: '/ti/usuarios', label: 'Usuarios', icon: 'group' },
  { path: '/ti/perfil', label: 'Perfil', icon: 'person' },
  ]
  }
 return []
})

function isActive(path: string): boolean {
 if (path === `/${authStore.perfil?.rol}`) {
 return route.path === path
 }
 return route.path.startsWith(path)
}
</script>

<template>
 <nav class="md:hidden fixed bottom-0 left-0 w-full bg-surface-container-lowest border-t border-outline-variant/50 flex justify-around py-3 z-50 px-4 shadow-[0_-4px_12px_rgba(0,0,0,0.05)] (0,0,0,0.2)] transition-colors duration-300">
 <router-link
 v-for="link in navLinks"
 :key="link.path"
 :to="link.path"
 :class="[
 'flex flex-col items-center gap-1 transition-colors',
 isActive(link.path) ? 'text-primary ' : 'text-on-surface-variant hover:text-primary/70 :text-[#96ccff]/70'
 ]"
 >
 <span class="material-symbols-outlined" :style="isActive(link.path) || link.iconFilled ? 'font-variation-settings: \'FILL\' 1;' : ''">
 {{ link.icon }}
 </span>
 <span :class="['font-[\'Inter\'] text-[10px]', isActive(link.path) ? 'font-bold' : '']">{{ link.label }}</span>
 </router-link>
 </nav>
</template>
