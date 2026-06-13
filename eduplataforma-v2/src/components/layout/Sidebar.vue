<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useAccessibilityStore } from '@/stores/accessibility'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const a11y = useAccessibilityStore()

interface NavLink {
 path: string
 label: string
 icon: string
 iconFilled?: boolean
 badge?: number
}

const navLinks = computed<NavLink[]>(() => {
 const rol = authStore.perfil?.rol
 if (rol === 'alumno') {
 return [
 { path: '/alumno', label: 'Inicio', icon: 'home', iconFilled: true },
 { path: '/alumno/cursos', label: 'Mis Cursos', icon: 'school' },
 { path: '/alumno/tareas', label: 'Tareas', icon: 'assignment' },
 { path: '/alumno/logros', label: 'Logros', icon: 'emoji_events' },
 { path: '/alumno/buscador', label: 'Buscador', icon: 'search' },
 { path: '/alumno/mensajeria', label: 'Mensajes', icon: 'mail' },
 { path: '/alumno/tienda', label: 'Tienda', icon: 'shopping_cart' },
 ]
 }
 if (rol === 'docente') {
 return [
 { path: '/docente', label: 'Panel', icon: 'home', iconFilled: true },
 { path: '/docente/cursos', label: 'Cursos', icon: 'school' },
 { path: '/docente/alumnos', label: 'Alumnos', icon: 'group' },
 { path: '/docente/materiales', label: 'Materiales', icon: 'upload_file' },
 { path: '/docente/entregas', label: 'Entregas', icon: 'assignment' },
 { path: '/docente/mensajeria', label: 'Mensajería', icon: 'mail' },
 { path: '/docente/logros', label: 'Premios', icon: 'emoji_events' },
 ]
 }
 if (rol === 'directivo') {
 return [
 { path: '/directivo', label: 'Resumen', icon: 'domain', iconFilled: true },
 { path: '/directivo/rendimiento', label: 'Rendimiento', icon: 'trending_up' },
 { path: '/directivo/alertas', label: 'Alertas', icon: 'notifications_active' },
 { path: '/directivo/gestion', label: 'Gestión', icon: 'school' },
 { path: '/directivo/comunicados', label: 'Anuncios', icon: 'campaign' },
 ]
 }
 if (rol === 'ti') {
 return [
 { path: '/ti', label: 'Panel Feedback', icon: 'bug_report', iconFilled: true },
 { path: '/ti/infraestructura', label: 'Infraestructura', icon: 'dns' },
 { path: '/ti/usuarios', label: 'Usuarios', icon: 'group' },
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

async function handleLogout() {
 await authStore.signOut()
 router.push('/login')
}

const levelName = computed(() => {
 const lvl = authStore.perfil?.nivel || 1
 if (lvl <= 2) return 'Novato'
 if (lvl <= 5) return 'Aprendiz'
 return 'Experto'
})

const xpProgress = computed(() => {
 if (!authStore.perfil) return 0
 const max = authStore.perfil.nivel * 100
 return Math.min(100, (authStore.perfil.xp / max) * 100)
})
</script>

<template>
 <aside class="hidden md:flex flex-col h-[calc(100vh-32px)] w-72 fixed left-0 top-8 bg-surface-container-lowest/80 backdrop-blur-xl border-r border-border-subtle shadow-[0px_4px_20px_rgba(0,0,0,0.04)] z-40 py-6 px-6 gap-6 pt-6 transition-colors duration-300">
 <!-- Brand Header -->
 <div class="flex flex-col gap-1 mb-2">
 <h1 class="font-headline-md text-headline-md font-extrabold text-primary tracking-tight transition-colors">EduPlataforma</h1>
 <p class="font-label-sm text-label-sm text-on-surface-variant opacity-80 uppercase tracking-widest transition-colors">Ecosistema Educativo</p>
 </div>

 <!-- Profile Section -->
 <div v-if="authStore.perfil" class="p-4 bg-surface-container-low/50 backdrop-blur-md rounded-2xl flex items-center gap-4 border border-border-subtle cursor-pointer hover:border-primary/50 hover:shadow-[0px_4px_20px_rgba(0,0,0,0.04)] transition-all" @click="router.push(`/${authStore.perfil.rol}/perfil`)">
 <div class="w-12 h-12 rounded-full bg-primary-container overflow-hidden ring-2 ring-white flex-shrink-0 shadow-sm flex items-center justify-center text-primary font-bold text-xl transition-colors">
 <img 
 v-if="authStore.perfil.avatar_url && (authStore.perfil.avatar_url.startsWith('http') || authStore.perfil.avatar_url.startsWith('data'))" 
 :src="authStore.perfil.avatar_url" 
 class="w-full h-full object-cover" 
 alt="Avatar"
 />
 <span v-else-if="authStore.perfil.avatar_url" class="text-2xl">{{ authStore.perfil.avatar_url }}</span>
 <span v-else>{{ authStore.perfil.nombre?.charAt(0).toUpperCase() || 'U' }}</span>
 </div>
 <div class="overflow-hidden">
 <p class="font-body-md text-body-md font-bold text-on-surface truncate transition-colors">{{ authStore.perfil.nombre }}</p>
 <p class="font-label-sm text-[10px] text-on-surface-variant uppercase tracking-wider opacity-90 transition-colors">
 {{ authStore.perfil.rol }} <span v-if="authStore.perfil.rol === 'alumno'">• Nivel {{ authStore.perfil.nivel }}</span>
 </p>
 </div>
 </div>

 <!-- Navigation Links -->
 <nav class="flex-1 space-y-1">
 <router-link
 v-for="link in navLinks"
 :key="link.path"
 :to="link.path"
 :class="[
 'flex items-center gap-3 px-4 py-3 rounded-xl transition-all',
 isActive(link.path)
 ? 'nav-item-active bg-primary/10 text-primary font-bold'
 : 'text-on-surface-variant hover:bg-surface-container hover:text-primary font-medium'
 ]"
 >
 <span class="material-symbols-outlined" :style="isActive(link.path) || link.iconFilled ? 'font-variation-settings: \'FILL\' 1;' : ''">
 {{ link.icon }}
 </span>
 <span class="font-body-sm text-body-sm">{{ link.label }}</span>
 <span
 v-if="link.badge && link.badge > 0"
 class="ml-auto text-[10px] font-bold bg-error text-on-error px-1.5 py-0.5 rounded-full min-w-[18px] text-center"
 >
 {{ link.badge }}
 </span>
 </router-link>
 </nav>

 <!-- Sidebar Bottom -->
 <div class="mt-auto space-y-4 pt-6 border-t border-border-subtle">
 
 <!-- XP Bar (Alumnos) -->
 <div v-if="authStore.perfil?.rol === 'alumno'" class="bg-primary/5 p-4 rounded-2xl border border-primary/10">
 <div class="flex justify-between items-center mb-2">
 <span class="text-[10px] font-bold text-primary uppercase flex items-center gap-1 tracking-wider">
 <span class="material-symbols-outlined text-[14px]" style="font-variation-settings: 'FILL' 1;">stars</span>
 Nivel {{ authStore.perfil.nivel }} — {{ levelName }}
 </span>
 </div>
 <div class="w-full h-1.5 bg-surface-container rounded-full overflow-hidden">
 <div class="h-full bg-primary rounded-full shadow-[0_0_8px_currentColor] transition-all duration-1000" :style="{ width: `${xpProgress}%`, color: 'rgba(0,86,135,0.5)' }"></div>
 </div>
 <div class="flex justify-between items-center mt-2.5">
 <span class="text-[11px] font-medium text-on-surface-variant">{{ authStore.perfil.xp }} / {{ authStore.perfil.nivel * 100 }} XP</span>
 <span class="text-[11px] font-bold text-secondary flex items-center gap-0.5" title="EduMonedas">
 <span class="material-symbols-outlined text-[14px]">monetization_on</span>
 {{ authStore.perfil.monedas }}
 </span>
 </div>
 </div>

 <!-- Accesibilidad -->
 <div class="flex items-center justify-between bg-surface-container-low/50 p-2 rounded-xl border border-border-subtle">
 <span class="text-xs font-bold text-on-surface-variant ml-2 uppercase tracking-widest">Texto</span>
 <div class="flex gap-1">
 <button type="button" @click="a11y.decreaseFontSize()" class="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-surface-container text-on-surface-variant transition-colors" title="Reducir tamaño de letra">A-</button>
 <button type="button" @click="a11y.increaseFontSize()" class="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-surface-container text-on-surface-variant transition-colors" title="Aumentar tamaño de letra">A+</button>
 </div>
 </div>

 <button type="button" 
 @click="handleLogout"
 class="w-full py-2.5 flex items-center justify-center gap-2 text-on-surface-variant hover:text-error transition-colors font-label-md text-label-md hover:bg-error/10 rounded-xl"
 >
 <span class="material-symbols-outlined text-[20px]">logout</span>
 Cerrar sesión
 </button>
 </div>
 </aside>
</template>

<style scoped>
.nav-item-active {
 position: relative;
}
.nav-item-active::before {
 content: '';
 position: absolute;
 left: -1rem;
 top: 50%;
 transform: translateY(-50%);
 width: 4px;
 height: 24px;
 background-color: var(--color-primary);
 border-radius: 0 4px 4px 0;
}
</style>
