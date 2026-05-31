<script setup lang="ts">
import { ref } from 'vue'
import BaseCard from '@/components/ui/BaseCard.vue'
import { BarChart3, TrendingUp, AlertTriangle } from 'lucide-vue-next'

const cursosDemo = ref([
  { id: '1', nombre: 'Matemáticas 8vo A', promedio: 6.2, entregas: 85, riesgo: 2 },
  { id: '2', nombre: 'Matemáticas 8vo B', promedio: 5.8, entregas: 70, riesgo: 5 },
])
</script>

<template>
  <div class="p-4 md:p-6 max-w-5xl mx-auto space-y-6 animate-fade-in">
    <div>
      <h1 class="font-display font-extrabold text-2xl md:text-3xl text-text dark:text-dark-text">📊 Reportes</h1>
      <p class="text-sm text-text-muted mt-1">Estadísticas de rendimiento y alertas tempranas de tus cursos.</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div class="bg-primary-bg dark:bg-primary/20 border border-primary/30 p-6 rounded-2xl flex flex-col items-center justify-center text-center">
        <TrendingUp class="text-primary mb-2" :size="32" />
        <p class="text-sm font-semibold text-text dark:text-dark-text mb-1">Promedio General</p>
        <p class="text-4xl font-extrabold text-primary">6.0</p>
      </div>
      
      <div class="bg-mint-bg dark:bg-mint/20 border border-mint/30 p-6 rounded-2xl flex flex-col items-center justify-center text-center">
        <BarChart3 class="text-mint mb-2" :size="32" />
        <p class="text-sm font-semibold text-text dark:text-dark-text mb-1">Tasa de Entregas</p>
        <p class="text-4xl font-extrabold text-mint">78%</p>
      </div>

      <div class="bg-danger-bg dark:bg-danger/20 border border-danger/30 p-6 rounded-2xl flex flex-col items-center justify-center text-center">
        <AlertTriangle class="text-danger mb-2" :size="32" />
        <p class="text-sm font-semibold text-text dark:text-dark-text mb-1">Alumnos en Riesgo</p>
        <p class="text-4xl font-extrabold text-danger">7</p>
      </div>
    </div>

    <h2 class="font-display font-bold text-lg mt-8 mb-4">Desglose por Curso</h2>
    <div class="space-y-3">
      <BaseCard v-for="c in cursosDemo" :key="c.id" class="flex flex-col sm:flex-row justify-between items-center p-5">
        <div>
          <p class="font-bold text-text dark:text-dark-text text-lg">{{ c.nombre }}</p>
          <p class="text-sm text-text-muted">Entregas a tiempo: {{ c.entregas }}%</p>
        </div>
        <div class="flex items-center gap-6 mt-4 sm:mt-0">
          <div class="text-center">
            <p class="text-xs text-text-muted uppercase font-semibold">Promedio</p>
            <p class="text-xl font-bold" :class="c.promedio >= 6.0 ? 'text-mint' : 'text-amber'">{{ c.promedio }}</p>
          </div>
          <div class="text-center">
            <p class="text-xs text-text-muted uppercase font-semibold">En Riesgo</p>
            <p class="text-xl font-bold" :class="c.riesgo > 3 ? 'text-danger' : 'text-text'">{{ c.riesgo }}</p>
          </div>
        </div>
      </BaseCard>
    </div>
  </div>
</template>
