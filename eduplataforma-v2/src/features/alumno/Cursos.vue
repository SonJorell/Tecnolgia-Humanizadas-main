<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useCursosStore } from '@/stores/cursos'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'

const router = useRouter()
const authStore = useAuthStore()
const cursosStore = useCursosStore()

onMounted(async () => {
 if (authStore.perfil) {
 await cursosStore.cargarInscripciones(authStore.perfil.id)
 }
})
</script>

<template>
 <div class="p-4 md:p-6 space-y-6 animate-fade-in">
 <h1 class="font-headline-md font-extrabold text-2xl text-on-surface">📚 Mis Cursos</h1>
 
 <div v-if="cursosStore.loading && cursosStore.inscripciones.length === 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
 <div v-for="i in 4" :key="i" class="bg-surface-container-low h-32 rounded-xl animate-pulse" />
 </div>
 
 <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
 <BaseCard
 v-for="insc in cursosStore.inscripciones"
 :key="insc.id"
 hover
 class="border-l-4 cursor-pointer relative overflow-hidden"
 :style="{ borderLeftColor: insc.curso?.color || '#1a6fa8' }"
 @click="router.push(`/alumno/cursos/${insc.curso_id}`)"
 >
 <!-- Background subtle glow based on course color -->
 <div 
 class="absolute -top-10 -right-10 w-32 h-32 rounded-full opacity-[0.03] pointer-events-none"
 :style="{ backgroundColor: insc.curso?.color || '#1a6fa8' }"
 />
 
 <div class="flex items-start justify-between mb-2">
 <div>
 <p class="font-headline-md font-bold text-base text-on-surface flex items-center gap-2">
 <span class="text-xl">{{ insc.curso?.icono }}</span>
 {{ insc.curso?.nombre }}
 </p>
 <p class="text-xs text-on-surface-variant mt-0.5">{{ insc.curso?.nivel }}</p>
 </div>
 <BaseBadge v-if="(insc.curso as any)?.disponible_offline" variant="neutral" size="sm">📶 Offline</BaseBadge>
 </div>
 
 <div class="mt-4">
 <div class="flex items-center justify-between text-xs text-on-surface-variant mb-1.5">
 <span>Progreso</span>
 <span class="font-semibold" :style="{ color: insc.curso?.color || '#1a6fa8' }">{{ insc.progreso }}%</span>
 </div>
 <div class="h-2 bg-surface-container-low rounded-full overflow-hidden">
 <div
 class="h-full rounded-full transition-all duration-500"
 :style="{ width: `${insc.progreso}%`, backgroundColor: insc.curso?.color || '#1a6fa8' }"
 />
 </div>
 </div>
 </BaseCard>
 </div>
 
 <div v-if="!cursosStore.loading && cursosStore.inscripciones.length === 0" class="flex flex-col items-center justify-center py-12 text-center">
 <div class="w-16 h-16 bg-surface-container-low rounded-full flex items-center justify-center text-3xl mb-3">
 🎒
 </div>
 <h3 class="font-headline-md font-bold text-lg text-on-surface">Aún no tienes cursos</h3>
 <p class="text-sm text-on-surface-variant mt-1 max-w-xs">
 Tus profesores pronto te asignarán a tus materias correspondientes.
 </p>
 </div>
 </div>
</template>
