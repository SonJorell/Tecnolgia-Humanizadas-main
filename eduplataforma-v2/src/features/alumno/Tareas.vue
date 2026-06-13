<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useTareasStore } from '@/stores/tareas'
import { useCursosStore } from '@/stores/cursos'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import { Clock, CheckCircle2, ChevronRight } from 'lucide-vue-next'

const router = useRouter()
const authStore = useAuthStore()
const tareasStore = useTareasStore()
const cursosStore = useCursosStore()

const filtro = ref<'pendientes' | 'completadas'>('pendientes')

onMounted(async () => {
 if (authStore.perfil) {
 // Aseguramos que ambas stores tengan datos locales (offline-first)
 await Promise.all([
 tareasStore.cargarEntregas(authStore.perfil.id),
 cursosStore.cargarInscripciones(authStore.perfil.id)
 ])
 }
})

// Simulación de unión de datos entre Entregas y Materiales/Cursos
// En una query real esto viene de Supabase, offline lo cruzamos con los stores
const listaTareas = computed(() => {
 const base = filtro.value === 'pendientes' ? tareasStore.pendientes : tareasStore.completadas
 return base.map(entrega => {
 // Buscar si tenemos el material descargado/cachead
 // Para el demo del blueprint, inferimos datos si no los tenemos
 return {
 ...entrega,
 titulo: 'Actividad Evaluada',
 curso_nombre: 'Asignatura Desconocida',
 curso_color: '#1a6fa8',
 vence_en: Math.floor(Math.random() * 5) + 1, // Fake countdown para el diseño
 xp: 50
 }
 })
})
</script>

<template>
 <div class="p-4 md:p-6 max-w-4xl mx-auto space-y-6 animate-fade-in">
 <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
 <div>
 <h1 class="font-headline-md font-extrabold text-2xl md:text-3xl text-on-surface">
 📝 Mis Tareas
 </h1>
 <p class="text-sm text-on-surface-variant mt-1">Organiza tu tiempo y gana experiencia.</p>
 </div>
 
 <!-- Filtros -->
 <div class="flex bg-surface-container-low p-1 rounded-xl w-full md:w-auto">
 <button type="button"
 :class="['flex-1 md:w-32 py-1.5 text-sm font-medium rounded-lg transition-all', filtro === 'pendientes' ? 'bg-surface-container-lowest shadow-sm text-on-surface ' : 'text-on-surface-variant']"
 @click="filtro = 'pendientes'"
 >
 Pendientes ({{ tareasStore.pendientes.length }})
 </button>
 <button type="button"
 :class="['flex-1 md:w-32 py-1.5 text-sm font-medium rounded-lg transition-all', filtro === 'completadas' ? 'bg-surface-container-lowest shadow-sm text-on-surface ' : 'text-on-surface-variant']"
 @click="filtro = 'completadas'"
 >
 Completadas ({{ tareasStore.completadas.length }})
 </button>
 </div>
 </div>

 <!-- Lista de Tareas -->
 <div class="space-y-3">
 <BaseCard 
 v-for="tarea in listaTareas" 
 :key="tarea.id" 
 hover
 class="border-l-4"
 :style="{ borderLeftColor: tarea.curso_color }"
 >
 <div class="flex flex-col sm:flex-row sm:items-center gap-4 justify-between">
 
 <!-- Lado Izquierdo: Info -->
 <div class="flex items-start gap-3">
 <div 
 class="mt-1 p-2 rounded-xl flex-shrink-0"
 :class="filtro === 'pendientes' ? 'bg-tertiary-container text-tertiary ' : 'bg-secondary-container text-secondary '"
 >
 <Clock v-if="filtro === 'pendientes'" :size="24" />
 <CheckCircle2 v-else :size="24" />
 </div>
 <div>
 <p class="text-[10px] font-bold uppercase tracking-wider mb-0.5" :style="{ color: tarea.curso_color }">
 {{ tarea.curso_nombre }}
 </p>
 <p class="font-semibold text-on-surface text-base leading-tight mb-1.5">
 {{ tarea.titulo }} ({{ tarea.material_id.substring(0,4) }})
 </p>
 <div class="flex flex-wrap items-center gap-2">
 <BaseBadge v-if="filtro === 'pendientes'" variant="amber" size="sm">
 ⏳ Vence en {{ tarea.vence_en }} días
 </BaseBadge>
 <BaseBadge v-else variant="mint" size="sm">
 ✅ {{ tarea.estado === 'revisado' ? 'Revisada' : 'Entregada' }}
 </BaseBadge>
 <span class="text-xs font-bold text-primary bg-primary-bg px-2 py-0.5 rounded-full">
 +{{ tarea.xp }} XP
 </span>
 </div>
 </div>
 </div>

 <!-- Lado Derecho: Acción -->
 <BaseButton 
 :variant="filtro === 'pendientes' ? 'primary' : 'secondary'"
 size="md"
 class="sm:w-auto w-full group"
 @click="router.push(`/alumno/tareas/${tarea.id}`)"
 >
 {{ filtro === 'pendientes' ? 'Resolver ahora' : 'Ver entrega' }}
 <ChevronRight :size="16" class="group-hover:translate-x-1 transition-transform" />
 </BaseButton>

 </div>
 </BaseCard>

 <div v-if="listaTareas.length === 0" class="text-center py-16 bg-surface-container-lowest shadow-sm rounded-2xl">
 <p class="text-5xl mb-4">
 {{ filtro === 'pendientes' ? '🏖️' : '📝' }}
 </p>
 <p class="font-headline-md font-bold text-xl text-on-surface mb-1">
 {{ filtro === 'pendientes' ? '¡Todo al día!' : 'Aún no has completado tareas' }}
 </p>
 <p class="text-sm text-on-surface-variant">
 {{ filtro === 'pendientes' ? 'No tienes ninguna entrega pendiente. Relájate un rato.' : 'Cuando resuelvas tus tareas, aparecerán aquí.' }}
 </p>
 </div>
 </div>
 </div>
</template>
