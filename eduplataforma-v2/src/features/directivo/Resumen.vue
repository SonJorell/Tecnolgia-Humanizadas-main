<script setup lang="ts">
import { onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useDirectivoStore } from '@/stores/directivo'
import StatCard from '@/components/ui/StatCard.vue'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import { AlertCircle, Users, Activity, CheckSquare, Bell, TrendingUp, ChevronRight, Megaphone } from 'lucide-vue-next'

const router = useRouter()
const directivoStore = useDirectivoStore()

onMounted(async () => {
  await directivoStore.cargarDatosGlobales()
})

const alertasCriticas = computed(() => directivoStore.alertas.filter(a => !a.resuelta && a.tipo === 'critica'))
</script>

<template>
  <div class="p-4 md:p-6 max-w-7xl mx-auto space-y-6 animate-fade-in">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
      <div>
        <h1 class="font-display font-extrabold text-2xl md:text-3xl text-text dark:text-dark-text">
          Estación de Mando
        </h1>
        <p class="text-sm text-text-muted mt-1">Resumen en tiempo real del ecosistema del colegio.</p>
      </div>
      <div class="flex items-center gap-3">
        <BaseBadge variant="neutral" class="px-3 py-1.5 flex items-center gap-2">
          <Activity :size="16" class="text-mint" /> Red del Colegio: Estable
        </BaseBadge>
      </div>
    </div>

    <!-- Alerta Critica Global (si existe) -->
    <div v-if="alertasCriticas.length > 0" class="bg-danger-bg dark:bg-danger/20 border border-danger/30 rounded-2xl p-4 flex items-start sm:items-center justify-between gap-4 shadow-sm animate-pulse-slow">
      <div class="flex items-start sm:items-center gap-3">
        <AlertCircle class="text-danger flex-shrink-0 mt-0.5 sm:mt-0" :size="24" />
        <div>
          <p class="font-bold text-danger text-sm sm:text-base">Requiere Atención</p>
          <p class="text-xs sm:text-sm text-danger/80">{{ alertasCriticas[0].mensaje }}</p>
        </div>
      </div>
      <button @click="router.push('/directivo/alertas')" class="text-xs font-bold text-white bg-danger hover:bg-danger-dark px-4 py-2 rounded-lg whitespace-nowrap transition-colors">
        Resolver
      </button>
    </div>

    <!-- 4 KPIs Principales -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <StatCard 
        :icon="Users" 
        label="Asistencia Digital" 
        :value="`${directivoStore.stats.alumnosConectadosSemana} activos`" 
        iconBg="bg-primary-bg dark:bg-primary/20 text-primary"
        :subtitle="`de ${directivoStore.stats.alumnosTotales} alumnos`"
      />
      <StatCard 
        :icon="TrendingUp" 
        label="Promedio General" 
        :value="directivoStore.stats.promedioColegio" 
        iconBg="bg-mint-bg dark:bg-mint/20 text-mint"
        subtitle="Basado en notas de entregas"
      />
      <StatCard 
        :icon="CheckSquare" 
        label="Correcciones Atrasadas" 
        :value="directivoStore.stats.correccionesAtrasadas" 
        iconBg="bg-amber-bg dark:bg-amber/20 text-amber"
        subtitle="Tareas esperando nota docente"
      />
      <StatCard 
        :icon="Users" 
        label="Cuerpo Docente" 
        :value="directivoStore.stats.profesoresTotales" 
        iconBg="bg-violet-bg dark:bg-violet/20 text-violet"
        subtitle="Profesores activos"
      />
    </div>

    <!-- Grillas Secundarias -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      
      <!-- Ranking de Cursos -->
      <div class="lg:col-span-2 space-y-4">
        <div class="flex items-center justify-between">
          <h2 class="font-display font-bold text-lg text-text dark:text-dark-text">Top Rendimiento por Curso</h2>
          <button @click="router.push('/directivo/rendimiento')" class="text-sm text-primary font-medium hover:underline">
            Ver detalle completo
          </button>
        </div>

        <BaseCard class="p-0 overflow-hidden">
          <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="bg-surface dark:bg-dark-card2 text-xs uppercase tracking-wider text-text-muted border-b border-border dark:border-white/10">
                  <th class="px-4 py-3 font-semibold">Curso</th>
                  <th class="px-4 py-3 font-semibold text-center">Tasa Entrega</th>
                  <th class="px-4 py-3 font-semibold text-center">Promedio</th>
                  <th class="px-4 py-3 font-semibold text-center">Estado</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-border dark:divide-white/10 text-sm">
                <tr v-for="curso in directivoStore.cursos" :key="curso.id" class="hover:bg-surface/50 dark:hover:bg-dark-card2/50 transition-colors">
                  <td class="px-4 py-3 font-medium text-text dark:text-dark-text">{{ curso.nombre }}</td>
                  <td class="px-4 py-3 text-center">
                    <span :class="curso.tasa_entrega >= 80 ? 'text-mint' : curso.tasa_entrega >= 50 ? 'text-amber' : 'text-danger'" class="font-bold">
                      {{ curso.tasa_entrega }}%
                    </span>
                  </td>
                  <td class="px-4 py-3 text-center font-bold text-text dark:text-dark-text">{{ curso.promedio.toFixed(1) }}</td>
                  <td class="px-4 py-3 text-center">
                    <BaseBadge :variant="curso.tasa_entrega >= 80 ? 'mint' : curso.tasa_entrega >= 50 ? 'amber' : 'danger'" size="sm">
                      {{ curso.tasa_entrega >= 80 ? 'Excelente' : curso.tasa_entrega >= 50 ? 'Observación' : 'Riesgo Crítico' }}
                    </BaseBadge>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </BaseCard>
      </div>

      <!-- Accesos Rápidos -->
      <div class="space-y-4">
        <h2 class="font-display font-bold text-lg text-text dark:text-dark-text">Accesos de Gestión</h2>

        <BaseCard hover class="flex items-center justify-between cursor-pointer border-l-4 border-mint" @click="router.push('/directivo/comunicados')">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-mint-bg dark:bg-mint/20 text-mint flex items-center justify-center">
              <Megaphone :size="20" />
            </div>
            <div>
              <p class="font-bold text-text dark:text-dark-text text-sm">Centro de Comunicados</p>
              <p class="text-xs text-text-muted">Emitir anuncios oficiales</p>
            </div>
          </div>
          <ChevronRight class="text-text-light" :size="16" />
        </BaseCard>

        <BaseCard hover class="flex items-center justify-between cursor-pointer border-l-4 border-amber" @click="router.push('/directivo/alertas')">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-amber-bg dark:bg-amber/20 text-amber flex items-center justify-center">
              <Bell :size="20" />
            </div>
            <div>
              <p class="font-bold text-text dark:text-dark-text text-sm">Buzón de Alertas</p>
              <p class="text-xs text-text-muted">{{ directivoStore.alertas.filter(a => !a.resuelta).length }} avisos pendientes</p>
            </div>
          </div>
          <ChevronRight class="text-text-light" :size="16" />
        </BaseCard>
      </div>

    </div>
  </div>
</template>

<style scoped>
.animate-pulse-slow {
  animation: pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.8; }
}
</style>
