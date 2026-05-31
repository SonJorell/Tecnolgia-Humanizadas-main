<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useDirectivoStore, type Alerta } from '@/stores/directivo'
import { useAppStore } from '@/stores/app'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import {
  AlertCircle, AlertTriangle, Info, CheckCircle2,
  Search, Clock, Eye
} from 'lucide-vue-next'

const directivoStore = useDirectivoStore()
const appStore = useAppStore()

// ── Extend alerts with more mock data ──
const alertasExtendidas = ref<(Alerta & { categoria?: string; origen?: string })[]>([
  {
    id: '1',
    tipo: 'critica',
    mensaje: 'Prof. Juan Pérez tiene 45 correcciones atrasadas de hace 2 semanas en Matemáticas.',
    fecha: new Date().toISOString(),
    resuelta: false,
    categoria: 'Docencia',
    origen: 'Sistema Automático'
  },
  {
    id: '2',
    tipo: 'critica',
    mensaje: 'El curso 8vo Básico B ha bajado su tasa de entrega al 40% — situación de riesgo académico.',
    fecha: new Date(Date.now() - 3600000).toISOString(),
    resuelta: false,
    categoria: 'Rendimiento',
    origen: 'Análisis Semanal'
  },
  {
    id: '3',
    tipo: 'advertencia',
    mensaje: '12 alumnos no han ingresado a la plataforma en los últimos 7 días.',
    fecha: new Date(Date.now() - 86400000).toISOString(),
    resuelta: false,
    categoria: 'Asistencia',
    origen: 'Monitor de Actividad'
  },
  {
    id: '4',
    tipo: 'advertencia',
    mensaje: 'El almacenamiento local del servidor está al 78% de capacidad.',
    fecha: new Date(Date.now() - 86400000 * 2).toISOString(),
    resuelta: false,
    categoria: 'Infraestructura',
    origen: 'Servidor Local'
  },
  {
    id: '5',
    tipo: 'info',
    mensaje: 'Se sincronizaron 500 entregas locales hacia el servidor exitosamente.',
    fecha: new Date(Date.now() - 172800000).toISOString(),
    resuelta: false,
    categoria: 'Sincronización',
    origen: 'Sync Engine'
  },
  {
    id: '6',
    tipo: 'info',
    mensaje: 'Backup semanal completado — 2.4 GB respaldados en almacenamiento externo.',
    fecha: new Date(Date.now() - 172800000).toISOString(),
    resuelta: true,
    categoria: 'Infraestructura',
    origen: 'Sistema de Backups'
  },
  {
    id: '7',
    tipo: 'advertencia',
    mensaje: 'Prof. Laura Muñoz reportó problemas de conexión en la sala de informática.',
    fecha: new Date(Date.now() - 259200000).toISOString(),
    resuelta: true,
    categoria: 'Infraestructura',
    origen: 'Reporte Manual'
  },
])

// ── Filters ──
const filtroTipo = ref<'todos' | 'critica' | 'advertencia' | 'info'>('todos')
const filtroEstado = ref<'pendientes' | 'resueltas' | 'todas'>('pendientes')
const busqueda = ref('')

// ── Computed ──
const alertasFiltradas = computed(() => {
  let result = [...alertasExtendidas.value]

  // Filtro por tipo
  if (filtroTipo.value !== 'todos') {
    result = result.filter(a => a.tipo === filtroTipo.value)
  }

  // Filtro por estado
  if (filtroEstado.value === 'pendientes') {
    result = result.filter(a => !a.resuelta)
  } else if (filtroEstado.value === 'resueltas') {
    result = result.filter(a => a.resuelta)
  }

  // Búsqueda
  if (busqueda.value.trim()) {
    const q = busqueda.value.toLowerCase()
    result = result.filter(a =>
      a.mensaje.toLowerCase().includes(q) ||
      a.categoria?.toLowerCase().includes(q) ||
      a.origen?.toLowerCase().includes(q)
    )
  }

  // Ordenar: críticas primero, luego por fecha
  result.sort((a, b) => {
    const prioridad: Record<string, number> = { critica: 0, advertencia: 1, info: 2 }
    const pDiff = (prioridad[a.tipo] || 2) - (prioridad[b.tipo] || 2)
    if (pDiff !== 0) return pDiff
    return new Date(b.fecha).getTime() - new Date(a.fecha).getTime()
  })

  return result
})

const countByType = computed(() => ({
  criticas: alertasExtendidas.value.filter(a => a.tipo === 'critica' && !a.resuelta).length,
  advertencias: alertasExtendidas.value.filter(a => a.tipo === 'advertencia' && !a.resuelta).length,
  info: alertasExtendidas.value.filter(a => a.tipo === 'info' && !a.resuelta).length,
  total: alertasExtendidas.value.filter(a => !a.resuelta).length,
  resueltas: alertasExtendidas.value.filter(a => a.resuelta).length,
}))

// ── Actions ──
function resolverAlerta(id: string) {
  const alerta = alertasExtendidas.value.find(a => a.id === id)
  if (alerta) {
    alerta.resuelta = true
    appStore.addToast({ tipo: 'info', mensaje: '✅ Alerta resuelta — marcada como gestionada.' })
  }
}

function reabrirAlerta(id: string) {
  const alerta = alertasExtendidas.value.find(a => a.id === id)
  if (alerta) {
    alerta.resuelta = false
  }
}

function resolverTodas() {
  alertasExtendidas.value.forEach(a => { a.resuelta = true })
  appStore.addToast({ tipo: 'info', mensaje: '✅ Todas las alertas han sido marcadas como gestionadas.' })
}

function formatFechaRelativa(iso: string): string {
  const diff = Date.now() - new Date(iso).getTime()
  const mins = Math.floor(diff / 60000)
  if (mins < 60) return `hace ${mins} min`
  const hrs = Math.floor(mins / 60)
  if (hrs < 24) return `hace ${hrs} hora${hrs > 1 ? 's' : ''}`
  const dias = Math.floor(hrs / 24)
  return `hace ${dias} día${dias > 1 ? 's' : ''}`
}

function getIconForTipo(tipo: string) {
  switch (tipo) {
    case 'critica': return AlertCircle
    case 'advertencia': return AlertTriangle
    default: return Info
  }
}

function getColorForTipo(tipo: string): string {
  switch (tipo) {
    case 'critica': return 'danger'
    case 'advertencia': return 'amber'
    default: return 'primary'
  }
}

function getBgForTipo(tipo: string): string {
  switch (tipo) {
    case 'critica': return 'bg-danger-bg dark:bg-danger/10 border-danger/20'
    case 'advertencia': return 'bg-amber-bg dark:bg-amber/10 border-amber/20'
    default: return 'bg-primary-bg dark:bg-primary/10 border-primary/20'
  }
}

onMounted(async () => {
  await directivoStore.cargarDatosGlobales()
})
</script>

<template>
  <div class="p-4 md:p-6 max-w-5xl mx-auto space-y-6 animate-fade-in">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
      <div>
        <h1 class="font-display font-extrabold text-2xl md:text-3xl text-text dark:text-dark-text">
          🔔 Centro de Alertas
        </h1>
        <p class="text-sm text-text-muted mt-1">Monitoreo de incidencias críticas, advertencias y notificaciones del sistema.</p>
      </div>
      <BaseButton
        v-if="countByType.total > 0"
        variant="secondary"
        size="sm"
        @click="resolverTodas"
      >
        <CheckCircle2 :size="14" /> Resolver Todas
      </BaseButton>
    </div>

    <!-- Summary Cards -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
      <button
        @click="filtroTipo = filtroTipo === 'critica' ? 'todos' : 'critica'"
        :class="[
          'rounded-xl p-4 text-left transition-all duration-200 border-2',
          filtroTipo === 'critica'
            ? 'border-danger bg-danger-bg dark:bg-danger/15 shadow-md scale-[1.02]'
            : 'border-transparent bg-card dark:bg-dark-card shadow-card hover:shadow-hover'
        ]"
      >
        <div class="flex items-center gap-2 mb-2">
          <AlertCircle :size="18" class="text-danger" />
          <span class="text-xs font-bold text-danger uppercase tracking-wider">Críticas</span>
        </div>
        <p class="font-display font-extrabold text-3xl text-danger">{{ countByType.criticas }}</p>
      </button>

      <button
        @click="filtroTipo = filtroTipo === 'advertencia' ? 'todos' : 'advertencia'"
        :class="[
          'rounded-xl p-4 text-left transition-all duration-200 border-2',
          filtroTipo === 'advertencia'
            ? 'border-amber bg-amber-bg dark:bg-amber/15 shadow-md scale-[1.02]'
            : 'border-transparent bg-card dark:bg-dark-card shadow-card hover:shadow-hover'
        ]"
      >
        <div class="flex items-center gap-2 mb-2">
          <AlertTriangle :size="18" class="text-amber" />
          <span class="text-xs font-bold text-amber uppercase tracking-wider">Advertencias</span>
        </div>
        <p class="font-display font-extrabold text-3xl text-amber">{{ countByType.advertencias }}</p>
      </button>

      <button
        @click="filtroTipo = filtroTipo === 'info' ? 'todos' : 'info'"
        :class="[
          'rounded-xl p-4 text-left transition-all duration-200 border-2',
          filtroTipo === 'info'
            ? 'border-primary bg-primary-bg dark:bg-primary/15 shadow-md scale-[1.02]'
            : 'border-transparent bg-card dark:bg-dark-card shadow-card hover:shadow-hover'
        ]"
      >
        <div class="flex items-center gap-2 mb-2">
          <Info :size="18" class="text-primary" />
          <span class="text-xs font-bold text-primary uppercase tracking-wider">Info</span>
        </div>
        <p class="font-display font-extrabold text-3xl text-primary">{{ countByType.info }}</p>
      </button>

      <div class="bg-card dark:bg-dark-card rounded-xl p-4 shadow-card">
        <div class="flex items-center gap-2 mb-2">
          <CheckCircle2 :size="18" class="text-mint" />
          <span class="text-xs font-bold text-mint uppercase tracking-wider">Resueltas</span>
        </div>
        <p class="font-display font-extrabold text-3xl text-mint">{{ countByType.resueltas }}</p>
      </div>
    </div>

    <!-- Filter Bar -->
    <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
      <!-- Status Tabs -->
      <div class="flex bg-surface dark:bg-dark-card2 rounded-xl p-1 flex-shrink-0">
        <button
          v-for="estado in (['pendientes', 'resueltas', 'todas'] as const)"
          :key="estado"
          @click="filtroEstado = estado"
          :class="[
            'px-3 py-1.5 text-xs font-semibold rounded-lg transition-all duration-200 capitalize',
            filtroEstado === estado
              ? 'bg-primary text-white shadow-sm'
              : 'text-text-muted hover:text-text dark:hover:text-dark-text'
          ]"
        >
          {{ estado }}
        </button>
      </div>

      <!-- Search -->
      <div class="relative flex-1">
        <Search :size="14" class="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted" />
        <input
          v-model="busqueda"
          type="text"
          placeholder="Buscar en alertas..."
          class="w-full h-9 pl-9 pr-3 text-xs bg-card dark:bg-dark-card border border-border dark:border-white/10 rounded-lg outline-none focus:ring-2 focus:ring-primary/50 text-text dark:text-dark-text"
        />
      </div>
    </div>

    <!-- Alert List -->
    <div class="space-y-3">
      <TransitionGroup name="list" tag="div" class="space-y-3">
        <div
          v-for="alerta in alertasFiltradas"
          :key="alerta.id"
          :class="[
            'rounded-2xl border p-4 transition-all duration-300',
            alerta.resuelta
              ? 'bg-surface dark:bg-dark-card2 border-border dark:border-white/10 opacity-60'
              : getBgForTipo(alerta.tipo)
          ]"
        >
          <div class="flex items-start gap-3">
            <!-- Icon -->
            <div :class="[
              'w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 mt-0.5',
              alerta.resuelta ? 'bg-mint-bg dark:bg-mint/20' : 
                alerta.tipo === 'critica' ? 'bg-danger/20' :
                alerta.tipo === 'advertencia' ? 'bg-amber/20' : 'bg-primary/20'
            ]">
              <CheckCircle2 v-if="alerta.resuelta" :size="20" class="text-mint" />
              <component v-else :is="getIconForTipo(alerta.tipo)" :size="20" :class="`text-${getColorForTipo(alerta.tipo)}`" />
            </div>

            <!-- Content -->
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 mb-1">
                <BaseBadge
                  :variant="alerta.resuelta ? 'mint' : (getColorForTipo(alerta.tipo) as any)"
                  size="sm"
                >
                  {{ alerta.resuelta ? 'Resuelta' : alerta.tipo === 'critica' ? 'Crítica' : alerta.tipo === 'advertencia' ? 'Advertencia' : 'Informativa' }}
                </BaseBadge>
                <BaseBadge v-if="alerta.categoria" variant="neutral" size="sm">
                  {{ alerta.categoria }}
                </BaseBadge>
              </div>

              <p :class="[
                'text-sm leading-relaxed mb-2',
                alerta.resuelta ? 'text-text-muted line-through' : 'text-text dark:text-dark-text'
              ]">
                {{ alerta.mensaje }}
              </p>

              <div class="flex items-center gap-4 text-[11px] text-text-muted">
                <span class="flex items-center gap-1">
                  <Clock :size="11" /> {{ formatFechaRelativa(alerta.fecha) }}
                </span>
                <span v-if="alerta.origen">
                  Origen: <strong>{{ alerta.origen }}</strong>
                </span>
              </div>
            </div>

            <!-- Actions -->
            <div class="flex items-center gap-1 flex-shrink-0">
              <button
                v-if="!alerta.resuelta"
                @click="resolverAlerta(alerta.id)"
                class="w-8 h-8 rounded-lg bg-white/80 dark:bg-dark-card hover:bg-mint-bg dark:hover:bg-mint/20 flex items-center justify-center transition-colors group"
                title="Marcar como resuelta"
              >
                <CheckCircle2 :size="16" class="text-text-muted group-hover:text-mint transition-colors" />
              </button>
              <button
                v-else
                @click="reabrirAlerta(alerta.id)"
                class="w-8 h-8 rounded-lg bg-white/80 dark:bg-dark-card hover:bg-amber-bg dark:hover:bg-amber/20 flex items-center justify-center transition-colors group"
                title="Reabrir alerta"
              >
                <Eye :size="16" class="text-text-muted group-hover:text-amber transition-colors" />
              </button>
            </div>
          </div>
        </div>
      </TransitionGroup>

      <!-- Empty State -->
      <div v-if="alertasFiltradas.length === 0" class="bg-card dark:bg-dark-card rounded-2xl p-12 text-center shadow-card">
        <div class="w-16 h-16 mx-auto rounded-2xl bg-mint-bg dark:bg-mint/20 flex items-center justify-center text-3xl mb-4">
          🎉
        </div>
        <h3 class="font-display font-bold text-lg text-text dark:text-dark-text mb-2">
          {{ filtroEstado === 'pendientes' ? '¡Todo bajo control!' : 'Sin resultados' }}
        </h3>
        <p class="text-sm text-text-muted max-w-sm mx-auto">
          {{ filtroEstado === 'pendientes'
            ? 'No hay alertas pendientes por gestionar. El sistema funciona correctamente.'
            : 'Prueba cambiando los filtros o términos de búsqueda.' }}
        </p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.list-enter-active,
.list-leave-active {
  transition: all 0.4s ease;
}
.list-enter-from {
  opacity: 0;
  transform: translateX(-20px);
}
.list-leave-to {
  opacity: 0;
  transform: translateX(20px);
}
.list-move {
  transition: transform 0.4s ease;
}
</style>
