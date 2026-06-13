<script setup lang="ts">
import { ref } from 'vue'
import { Search, ChevronRight, FileText, BookOpen, Clock } from 'lucide-vue-next'

const query = ref('')
const buscando = ref(false)

// Fake results para UI interactiva offline
const resultados = ref<any[]>([])

function buscar() {
 buscando.value = true
 setTimeout(() => {
 buscando.value = false
 if (query.value.trim().length > 2) {
 resultados.value = [
 { id: '1', tipo: 'tarea', titulo: 'Guía Ecuaciones', desc: 'Matemáticas', icono: FileText },
 { id: '2', tipo: 'material', titulo: 'PDF Revolución Francesa', desc: 'Historia', icono: BookOpen }
 ]
 } else {
 resultados.value = []
 }
 }, 300)
}
</script>

<template>
 <div class="p-4 md:p-6 max-w-3xl mx-auto space-y-6 animate-fade-in">
 <div>
 <h1 class="font-headline-md font-extrabold text-2xl text-on-surface">🔍 Buscador Offline</h1>
 <p class="text-sm text-on-surface-variant mt-1">Busca materiales y tareas guardados en tu dispositivo.</p>
 </div>

 <!-- Search Input -->
 <div class="relative shadow-sm">
 <Search :size="20" class="absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant" />
 <input id="query" name="query"
 v-model="query"
 type="text"
 placeholder="Ej: Matemáticas, Ecuaciones, Guía 3..."
 class="w-full h-14 pl-12 pr-4 bg-surface-container-lowest border border-border-subtle rounded-2xl text-on-surface focus:ring-2 focus:ring-primary/50 focus:border-primary outline-none transition-all font-medium"
 @input="buscar"
 />
 <div v-if="buscando" class="absolute right-4 top-1/2 -translate-y-1/2">
 <span class="w-4 h-4 border-2 border-primary border-t-transparent rounded-full animate-spin block"></span>
 </div>
 </div>

 <!-- Resultados -->
 <div v-if="resultados.length > 0" class="space-y-3">
 <h3 class="text-xs font-bold text-on-surface-variant uppercase tracking-wider mb-2">Resultados locales</h3>
 <div 
 v-for="res in resultados" 
 :key="res.id"
 class="flex items-center justify-between bg-surface-container-lowest p-4 rounded-xl border border-border-subtle hover:shadow-hover cursor-pointer transition-all group"
 >
 <div class="flex items-center gap-4">
 <div class="w-10 h-10 rounded-lg bg-surface-container-low flex items-center justify-center text-primary group-hover:bg-primary group-hover:text-white transition-colors">
 <component :is="res.icono" :size="20" />
 </div>
 <div>
 <p class="font-semibold text-on-surface">{{ res.titulo }}</p>
 <p class="text-xs text-on-surface-variant">{{ res.desc }}</p>
 </div>
 </div>
 <ChevronRight :size="16" class="text-on-surface-light group-hover:text-primary transition-colors" />
 </div>
 </div>

 <!-- Historial de Búsqueda vacío -->
 <div v-if="query.length === 0" class="mt-8">
 <h3 class="text-xs font-bold text-on-surface-variant uppercase tracking-wider mb-4 flex items-center gap-2">
 <Clock :size="14" /> Búsquedas recientes
 </h3>
 <div class="flex flex-wrap gap-2">
 <span class="px-3 py-1.5 bg-surface-container-low text-on-surface-variant rounded-lg text-sm cursor-pointer hover:text-on-surface transition-colors">
 ciencias
 </span>
 <span class="px-3 py-1.5 bg-surface-container-low text-on-surface-variant rounded-lg text-sm cursor-pointer hover:text-on-surface transition-colors">
 evaluación
 </span>
 </div>
 </div>
 </div>
</template>
