<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useDocenteStore } from '@/stores/docente'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import { ArrowLeft, Users, FileText, Target, Activity } from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()
const docenteStore = useDocenteStore()

const cursoId = computed(() => route.params.id as string)
const curso = computed(() => docenteStore.cursos.find(c => c.id === cursoId.value))
const alumnos = computed(() => docenteStore.alumnos.filter(a => a.curso_id === cursoId.value))
const materiales = computed(() => docenteStore.materiales.filter(m => m.curso_id === cursoId.value))
const tareas = computed(() => materiales.value.filter(m => m.es_tarea))

onMounted(() => {
  if (!curso.value && !docenteStore.loading) {
    router.replace('/docente/cursos')
  }
})
</script>

<template>
  <div class="p-4 md:p-6 max-w-6xl mx-auto space-y-6 animate-fade-in">
    <button @click="router.back()" class="flex items-center gap-2 text-sm text-text-muted hover:text-primary transition-colors mb-2">
      <ArrowLeft :size="16" /> Volver a cursos
    </button>

    <div v-if="!curso" class="py-12 text-center text-text-muted">Cargando curso...</div>
    
    <template v-else>
      <!-- Hero Header -->
      <div class="relative w-full h-48 md:h-64 rounded-2xl overflow-hidden bg-primary shadow-sm">
        <img v-if="curso.banner_url" :src="curso.banner_url" class="absolute inset-0 w-full h-full object-cover opacity-60 mix-blend-overlay" />
        <div class="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent"></div>
        <div class="absolute bottom-0 left-0 p-6 md:p-8 w-full flex items-end justify-between">
          <div class="text-white">
            <h1 class="font-display font-extrabold text-3xl md:text-4xl">{{ curso.nombre }}</h1>
            <p class="opacity-80 text-sm md:text-base mt-2 max-w-2xl">{{ curso.descripcion || 'Sin descripción' }}</p>
          </div>
          <span class="text-6xl hidden sm:block">{{ curso.icono }}</span>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Sidebar -->
        <div class="space-y-6">
          <BaseCard class="p-5">
            <h3 class="font-bold flex items-center gap-2 mb-4 text-text dark:text-dark-text"><Target :size="18" class="text-primary"/> Objetivos</h3>
            <ul v-if="(curso.objetivos?.length || 0) > 0" class="space-y-2 text-sm text-text-muted">
              <li v-for="(obj, i) in curso.objetivos" :key="i" class="flex items-start gap-2">
                <div class="w-1.5 h-1.5 rounded-full bg-primary mt-1.5 flex-shrink-0"></div>
                <span>{{ obj }}</span>
              </li>
            </ul>
            <p v-else class="text-sm text-text-light italic">No hay objetivos definidos.</p>
          </BaseCard>

          <BaseCard class="p-5">
            <h3 class="font-bold flex items-center gap-2 mb-4 text-text dark:text-dark-text"><Activity :size="18" class="text-violet"/> Resumen</h3>
            <div class="space-y-3">
              <div class="flex justify-between items-center text-sm">
                <span class="text-text-muted">Alumnos</span>
                <span class="font-bold text-text dark:text-dark-text bg-surface dark:bg-dark-bg px-2 py-1 rounded">{{ alumnos.length }}</span>
              </div>
              <div class="flex justify-between items-center text-sm">
                <span class="text-text-muted">Materiales</span>
                <span class="font-bold text-text dark:text-dark-text bg-surface dark:bg-dark-bg px-2 py-1 rounded">{{ materiales.length }}</span>
              </div>
              <div class="flex justify-between items-center text-sm">
                <span class="text-text-muted">Tareas Activas</span>
                <span class="font-bold text-text dark:text-dark-text bg-surface dark:bg-dark-bg px-2 py-1 rounded">{{ tareas.length }}</span>
              </div>
            </div>
            <BaseButton variant="primary" class="w-full justify-center mt-4" @click="router.push('/docente/materiales')">Añadir Material</BaseButton>
          </BaseCard>
        </div>

        <!-- Main Content -->
        <div class="lg:col-span-2 space-y-6">
          <BaseCard>
            <div class="p-4 border-b border-border dark:border-white/10 flex justify-between items-center">
              <h3 class="font-bold flex items-center gap-2 text-text dark:text-dark-text"><Users :size="18" class="text-blue-500"/> Alumnos Inscritos</h3>
              <BaseButton variant="ghost" size="sm" @click="router.push('/docente/alumnos')">Ver todos</BaseButton>
            </div>
            <div class="divide-y divide-border dark:divide-white/10 max-h-80 overflow-y-auto">
              <div v-for="alumno in alumnos" :key="alumno.id" class="p-3 flex items-center justify-between hover:bg-surface dark:hover:bg-dark-card2 cursor-pointer" @click="router.push(`/docente/alumnos/${alumno.id}`)">
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 rounded-full bg-primary/20 text-primary flex items-center justify-center font-bold text-xs overflow-hidden">
                    <img v-if="alumno.avatar_url && (alumno.avatar_url.startsWith('http') || alumno.avatar_url.startsWith('data'))" :src="alumno.avatar_url" class="w-full h-full object-cover" />
                    <span v-else-if="alumno.avatar_url" class="text-lg">{{ alumno.avatar_url }}</span>
                    <span v-else>{{ alumno.nombre.charAt(0) }}</span>
                  </div>
                  <span class="font-medium text-sm text-text dark:text-dark-text">{{ alumno.nombre }}</span>
                </div>
                <div class="flex items-center gap-3">
                  <span class="text-xs font-bold text-amber-500 bg-amber-500/10 px-2 py-1 rounded-full">⭐ {{ alumno.xp }}</span>
                </div>
              </div>
              <div v-if="alumnos.length === 0" class="p-8 text-center text-sm text-text-muted">No hay alumnos en este curso.</div>
            </div>
          </BaseCard>

          <BaseCard>
            <div class="p-4 border-b border-border dark:border-white/10">
              <h3 class="font-bold flex items-center gap-2 text-text dark:text-dark-text"><FileText :size="18" class="text-mint"/> Últimos Materiales</h3>
            </div>
            <div class="divide-y divide-border dark:divide-white/10">
              <div v-for="mat in materiales.slice(0, 5)" :key="mat.id" class="p-4 flex items-center justify-between">
                <div>
                  <p class="font-medium text-sm text-text dark:text-dark-text">{{ mat.titulo }}</p>
                  <p class="text-xs text-text-muted mt-0.5">{{ new Date(mat.creado_en).toLocaleDateString() }}</p>
                </div>
                <div class="flex gap-2">
                  <span v-if="mat.es_tarea" class="text-[10px] uppercase font-bold text-primary bg-primary/10 px-2 py-1 rounded">Tarea</span>
                  <span class="text-[10px] text-text-muted bg-surface dark:bg-dark-bg px-2 py-1 rounded">{{ mat.visualizaciones || 0 }} views</span>
                </div>
              </div>
              <div v-if="materiales.length === 0" class="p-8 text-center text-sm text-text-muted">No has subido materiales a este curso.</div>
            </div>
          </BaseCard>
        </div>
      </div>
    </template>
  </div>
</template>
