<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useAppStore } from '@/stores/app'
import { supabase } from '@/services/supabase'
import type { Material } from '@/types/database'
import { useRouter } from 'vue-router'

const router = useRouter()
const authStore = useAuthStore()
const appStore = useAppStore()

const stats = ref({ cursos: 0, tareas: 0, logros: 0 })
const materialesNuevos = ref<Material[]>([])
const comunicados = ref<any[]>([])
const proximosEventos = ref<any[]>([])
const loading = ref(true)

onMounted(async () => {
 if (!authStore.perfil || !appStore.isOnline) {
 loading.value = false
 return
 }
 await loadStats()
})

async function loadStats() {
 try {
 const [inscRes, entregaRes, logrosRes, matRes] = await Promise.all([
 supabase.from('inscripciones').select('id, curso_id', { count: 'exact' }).eq('alumno_id', authStore.perfil!.id),
 supabase.from('entregas').select('id', { count: 'exact' }).eq('alumno_id', authStore.perfil!.id).eq('estado', 'pendiente'),
 supabase.from('logros_alumno').select('id', { count: 'exact' }).eq('alumno_id', authStore.perfil!.id),
 supabase.from('materiales').select('*').eq('publicado', true).order('creado_en', { ascending: false }).limit(3)
 ])

 stats.value = {
 cursos: inscRes.count || 0,
 tareas: entregaRes.count || 0,
 logros: logrosRes.count || 0,
 }
 materialesNuevos.value = (matRes.data as Material[]) || []

 // Fetch Comunicados
 const cursoIds = (inscRes.data || []).map(i => i.curso_id)
 let query = supabase.from('comunicados').select('*, autor:perfiles!autor_id(nombre)')
 
 if (cursoIds.length > 0) {
 query = query.or(`segmento.in.(todos,alumnos),curso_id.in.(${cursoIds.join(',')})`)
 } else {
 query = query.in('segmento', ['todos', 'alumnos'])
 }
 
 const { data: comData } = await query.order('creado_en', { ascending: false }).limit(1)
 if (comData) comunicados.value = comData

 } catch (err) {
 console.error('[Inicio] Error cargando stats:', err)
 } finally {
 loading.value = false
 }
}

function getTipoIcon(tipo: string): string {
 switch (tipo) {
 case 'guia': return 'palette'
 case 'tarea': return 'assignment'
 case 'evaluacion': return 'quiz'
 default: return 'menu_book'
 }
}

function getTipoColor(tipo: string): string {
 switch (tipo) {
 case 'guia': return 'text-primary bg-primary/10'
 case 'tarea': return 'text-amber-800 dark:text-amber-300-500 bg-amber-500/10'
 case 'evaluacion': return 'text-red-500 bg-red-500/10'
 default: return 'text-secondary bg-secondary/10'
 }
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

function parseContentWithLinks(text: string) {
 if (!text) return ''
 const urlRegex = /(https?:\/\/[^\s]+)/g
 return text.replace(urlRegex, '<a href="$1" target="_blank" class="text-primary hover:text-primary-container hover:underline underline-offset-4 decoration-primary/30 font-medium inline-flex items-center gap-1 transition-colors">$1 <span class="material-symbols-outlined text-[16px]">open_in_new</span></a>')
}
</script>

<template>
 <div v-if="authStore.perfil" class="px-margin-mobile md:px-margin-tablet lg:px-margin-desktop py-10 max-w-container-max mx-auto space-y-10 animate-fade-in font-body-md text-body-md">
 
 <!-- Welcome Section -->
 <section>
 <h2 class="font-headline-xl text-headline-xl text-on-surface mb-1 transition-colors">
 ¡Hola de nuevo, {{ authStore.perfil.nombre.split(' ')[0] }}! 👋
 </h2>
 <p class="font-body-lg text-body-lg text-on-surface-variant transition-colors">
 Hoy es un gran día para aprender algo nuevo. Revisa tus avances.
 </p>
 </section>

 <!-- Grid Layout -->
 <div class="grid grid-cols-1 lg:grid-cols-12 gap-8">
 
 <!-- Feature Banner (Anuncio Oficial) -->
 <div v-if="comunicados.length > 0" class="lg:col-span-12">
 <div class="relative overflow-hidden rounded-3xl p-8 bg-surface-container-lowest border border-border-subtle shadow-sm flex flex-col md:flex-row items-center justify-between group transition-colors">
 <!-- Decorative element -->
 <div class="absolute top-0 left-0 w-1.5 h-full bg-primary "></div>
 
 <div class="z-10 relative space-y-4 text-center md:text-left">
 <div class="inline-flex items-center gap-2 px-3 py-1 bg-primary-container/20 text-primary rounded-full text-[11px] font-bold uppercase tracking-wider">
 <span class="material-symbols-outlined text-base">campaign</span>
 Anuncio Reciente
 </div>
 <div>
 <h3 class="font-headline-md text-headline-md text-on-surface mb-2 transition-colors">
 {{ comunicados[0].titulo }}
 </h3>
 <p class="text-on-surface-variant max-w-2xl font-body-sm text-body-sm transition-colors" v-html="parseContentWithLinks(comunicados[0].contenido)">
 </p>
 </div>
 </div>
 
 <div class="hidden md:block opacity-10 group-hover:opacity-20 transition-opacity">
 <span class="material-symbols-outlined text-[100px] text-primary ">auto_awesome</span>
 </div>
 </div>
 </div>
 <div v-else class="lg:col-span-12">
 <div class="relative overflow-hidden rounded-3xl p-8 bg-surface-container-lowest border border-border-subtle shadow-sm flex flex-col md:flex-row items-center justify-between group transition-colors">
 <div class="absolute top-0 left-0 w-1.5 h-full bg-primary "></div>
 <div class="z-10 relative space-y-4 text-center md:text-left">
 <div class="inline-flex items-center gap-2 px-3 py-1 bg-primary-container/20 text-primary rounded-full text-[11px] font-bold uppercase tracking-wider">
 <span class="material-symbols-outlined text-base">campaign</span>
 Novedades
 </div>
 <div>
 <h3 class="font-headline-md text-headline-md text-on-surface mb-2 transition-colors">Grande J2n Software</h3>
 <a href="https://j2nsoftware.netlify.app/" target="_blank" class="text-primary hover:text-primary-container font-medium inline-flex items-center gap-1.5 transition-colors underline underline-offset-4 decoration-primary/30 ">
 Visitar plataforma externa
 <span class="material-symbols-outlined text-lg">open_in_new</span>
 </a>
 </div>
 </div>
 <div class="hidden md:block opacity-10 group-hover:opacity-20 transition-opacity">
 <span class="material-symbols-outlined text-[100px] text-primary ">auto_awesome</span>
 </div>
 </div>
 </div>

 <!-- Stats Row -->
 <div class="lg:col-span-12 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
 <div class="bento-card p-6 bg-surface-container-lowest rounded-3xl border border-border-subtle shadow-sm flex flex-col gap-4 cursor-pointer hover:-translate-y-1 hover:shadow-lg transition-all" @click="router.push('/alumno/cursos')">
 <div class="w-12 h-12 rounded-2xl bg-primary/10 flex items-center justify-center text-primary transition-colors">
 <span class="material-symbols-outlined text-[28px]">school</span>
 </div>
 <div>
 <span class="font-headline-md text-headline-md block leading-none mb-1 text-on-surface transition-colors">{{ loading ? '-' : stats.cursos }}</span>
 <span class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wide transition-colors">Cursos activos</span>
 </div>
 </div>
 
 <div class="bento-card p-6 bg-surface-container-lowest rounded-3xl border border-border-subtle shadow-sm flex flex-col gap-4 cursor-pointer hover:-translate-y-1 hover:shadow-lg transition-all" @click="router.push('/alumno/tareas')">
 <div class="w-12 h-12 rounded-2xl bg-tertiary/10 flex items-center justify-center text-tertiary transition-colors">
 <span class="material-symbols-outlined text-[28px]">pending_actions</span>
 </div>
 <div>
 <span class="font-headline-md text-headline-md block leading-none mb-1 text-on-surface transition-colors">{{ loading ? '-' : stats.tareas }}</span>
 <span class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wide transition-colors">Tareas pendientes</span>
 </div>
 </div>
 
 <div class="bento-card p-6 bg-surface-container-lowest rounded-3xl border border-border-subtle shadow-sm flex flex-col gap-4 cursor-pointer hover:-translate-y-1 hover:shadow-lg transition-all" @click="router.push('/alumno/logros')">
 <div class="w-12 h-12 rounded-2xl bg-secondary/10 flex items-center justify-center text-secondary transition-colors">
 <span class="material-symbols-outlined text-[28px]">emoji_events</span>
 </div>
 <div>
 <span class="font-headline-md text-headline-md block leading-none mb-1 text-on-surface transition-colors">{{ loading ? '-' : stats.logros }}</span>
 <span class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wide transition-colors">Logros ganados</span>
 </div>
 </div>
 
 <div class="bento-card p-6 bg-surface-container-lowest rounded-3xl border border-border-subtle shadow-sm flex flex-col gap-4 cursor-pointer hover:-translate-y-1 hover:shadow-lg transition-all" @click="router.push('/alumno/tienda')">
 <div class="w-12 h-12 rounded-2xl bg-surface-tint/10 flex items-center justify-center text-surface-tint transition-colors">
 <span class="material-symbols-outlined text-[28px]">currency_exchange</span>
 </div>
 <div>
 <div class="flex items-baseline gap-2 mb-1">
 <span class="font-headline-md text-headline-md leading-none text-on-surface transition-colors">{{ authStore.perfil.monedas }}</span>
 <span class="text-[11px] font-bold text-on-surface-variant uppercase tracking-tighter transition-colors">EduMonedas</span>
 </div>
 <span class="font-label-sm text-label-sm text-primary hover:underline transition-colors">Canjear en tienda</span>
 </div>
 </div>
 </div>

 <!-- Main Content (Materials) & Secondary Area -->
 <div class="lg:col-span-8 space-y-6">
 <div class="flex items-center justify-between mb-4 px-2">
 <h4 class="font-headline-md text-headline-md text-on-surface flex items-center gap-3 transition-colors">
 <span class="w-1 h-8 bg-primary rounded-full transition-colors"></span>
 Material Nuevo
 </h4>
 <button type="button" @click="router.push('/alumno/cursos')" class="font-label-md text-label-md text-primary hover:bg-primary/5 px-4 py-2 rounded-xl transition-all">
 Ver catálogo completo
 </button>
 </div>
 
 <div class="space-y-3">
 <div v-if="loading" class="text-center py-4 font-body-sm text-body-sm text-on-surface-variant/60 transition-colors">Cargando...</div>
 <div v-else-if="materialesNuevos.length === 0" class="text-center py-4 font-body-sm text-body-sm text-on-surface-variant/60 transition-colors">No hay material reciente.</div>
 
 <div 
 v-for="mat in materialesNuevos" 
 :key="mat.id"
 class="group flex items-center gap-5 p-5 bg-surface-container-lowest border border-border-subtle rounded-2xl hover:border-primary/40 hover:shadow-md transition-all cursor-pointer"
 >
 <div :class="['w-14 h-14 rounded-xl flex items-center justify-center transition-all', getTipoColor(mat.tipo)]">
 <span class="material-symbols-outlined text-[28px]">{{ getTipoIcon(mat.tipo) }}</span>
 </div>
 <div class="flex-1">
 <h5 class="font-bold text-on-surface font-body-lg text-body-lg group-hover:text-primary transition-colors">{{ mat.titulo }}</h5>
 <div class="flex items-center gap-4 mt-1.5">
 <span class="px-2.5 py-0.5 bg-primary/10 text-primary text-[10px] font-bold rounded uppercase tracking-wider transition-colors">{{ mat.tipo }}</span>
 <span v-if="mat.disponible_offline" class="flex items-center gap-1.5 font-label-sm text-label-sm text-on-surface-variant/70 transition-colors">
 <span class="material-symbols-outlined text-base">cloud_off</span>
 Acceso Offline
 </span>
 <span v-else class="flex items-center gap-1.5 font-label-sm text-label-sm text-on-surface-variant/70 transition-colors">
 <span class="material-symbols-outlined text-base">cloud_done</span>
 Solo Online
 </span>
 </div>
 </div>
 <div class="hidden sm:flex flex-col items-end gap-1">
 <span class="font-label-sm text-label-sm text-on-surface-variant/60 italic transition-colors">Publicado</span>
 <span class="text-[11px] text-on-surface-variant/80 font-bold transition-colors">{{ mat.creado_en ? new Date(mat.creado_en).toLocaleDateString() : new Date().toLocaleDateString() }}</span>
 </div>
 <span class="material-symbols-outlined text-outline-variant group-hover:text-primary group-hover:translate-x-1 transition-all">chevron_right</span>
 </div>
 </div>
 </div>

 <!-- Right Column: Sidebar content -->
 <div class="lg:col-span-4 space-y-8">
 
 <!-- Progress Illustration Card -->
 <div class="relative overflow-hidden rounded-3xl bg-primary p-8 text-on-primary shadow-xl min-h-[340px] flex flex-col justify-between transition-colors">
 <div class="absolute -right-8 -bottom-8 opacity-10 rotate-12">
 <span class="material-symbols-outlined text-[200px]">auto_stories</span>
 </div>
 <div class="relative z-10 space-y-3">
 <h4 class="font-headline-md text-headline-md leading-tight text-on-primary">Tu Ecosistema</h4>
 <p class="font-body-sm text-body-sm opacity-80 text-on-primary-container">Sigue explorando tus cursos para subir al nivel {{ (authStore.perfil.nivel || 1) + 1 }} y desbloquear nuevas recompensas exclusivas.</p>
 </div>
 <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-5 border border-white/20 relative z-10">
 <div class="flex justify-between items-center mb-3 text-on-primary">
 <span class="text-[11px] font-bold uppercase tracking-widest opacity-80">Progreso a Nivel {{ (authStore.perfil.nivel || 1) + 1 }}</span>
 <span class="text-[13px] font-bold bg-white/20 px-2 py-0.5 rounded-lg">{{ Math.round(xpProgress) }}%</span>
 </div>
 <div class="w-full h-2 bg-white/20 rounded-full overflow-hidden mb-1">
 <div class="h-full bg-secondary-container shadow-[0_0_8px_rgba(122,250,199,0.5)] transition-all duration-1000" :style="{ width: `${xpProgress}%` }"></div>
 </div>
 <p class="text-[11px] font-medium opacity-80 text-center mt-2 text-on-primary">¡Sigue así, falta poco para tu próxima recompensa!</p>
 </div>
 </div>

 <!-- Upcoming Tasks Quick View -->
 <div class="bg-surface-container-lowest rounded-3xl p-6 border border-border-subtle shadow-sm transition-colors">
 <h5 class="font-headline-md text-headline-md text-on-surface mb-4 flex items-center gap-2 transition-colors">
 <span class="material-symbols-outlined text-[20px] text-primary ">event_note</span>
 Próximos Eventos
 </h5>
 <div class="space-y-4">
 <div class="flex gap-3 items-start">
 <div class="w-2 h-2 rounded-full bg-primary mt-1.5 transition-colors"></div>
 <div class="flex-1">
 <p class="font-body-sm text-body-sm font-bold text-on-surface transition-colors">Examen de Inglés</p>
 <p class="font-label-sm text-label-sm text-on-surface-variant transition-colors">Mañana, 09:00 AM</p>
 </div>
 </div>
 <div class="flex gap-3 items-start">
 <div class="w-2 h-2 rounded-full bg-secondary mt-1.5 transition-colors"></div>
 <div class="flex-1">
 <p class="font-body-sm text-body-sm font-bold text-on-surface transition-colors">Entrega de Taller Artístico</p>
 <p class="font-label-sm text-label-sm text-on-surface-variant transition-colors">Viernes, 11:59 PM</p>
 </div>
 </div>
 </div>
 </div>
 
 </div>
 </div>
 </div>
</template>

<style scoped>
@keyframes fadeIn {
 from { opacity: 0; transform: translateY(16px); }
 to { opacity: 1; transform: translateY(0); }
}
.animate-fade-in {
 animation: fadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}
.bento-card {
 transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}
.bento-card:hover {
 transform: translateY(-4px);
 box-shadow: 0 12px 24px -8px rgba(0, 86, 135, 0.15);
}
</style>
