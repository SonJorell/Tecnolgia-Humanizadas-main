<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useDocenteStore } from '@/stores/docente'
import { useAuthStore } from '@/stores/auth'
import StatCard from '@/components/ui/StatCard.vue'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import {
  BarChart3, TrendingUp, TrendingDown, Clock,
  AlertTriangle, Target,
  ArrowUpRight, ArrowDownRight, ChevronRight, Megaphone
} from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

const router = useRouter()
const docenteStore = useDocenteStore()
const authStore = useAuthStore()

// ── Período seleccionado ──
const periodos = ['Esta semana', 'Este mes', 'Último trimestre'] as const
const periodoActivo = ref<typeof periodos[number]>('Esta semana')

// ── Mock data (representativo del schema real) ──
const tendenciaSemanal = ref([
  { dia: 'Lun', entregas: 12, promedio: 5.8 },
  { dia: 'Mar', entregas: 18, promedio: 6.1 },
  { dia: 'Mié', entregas: 15, promedio: 5.5 },
  { dia: 'Jue', entregas: 22, promedio: 6.3 },
  { dia: 'Vie', entregas: 8, promedio: 6.0 },
])

const cursosRendimiento = ref([
  { id: '1', nombre: 'Matemáticas 8vo A', promedio: 6.2, entregas: 92, riesgo: 1, tendencia: 'up' as const },
  { id: '2', nombre: 'Matemáticas 8vo B', promedio: 4.8, entregas: 45, riesgo: 8, tendencia: 'down' as const },
  { id: '3', nombre: 'Ciencias 1ro Medio', promedio: 5.5, entregas: 78, riesgo: 3, tendencia: 'up' as const },
])

const alumnosRiesgo = ref([
  { id: 'a1', nombre: 'Ana Gómez', curso: '8vo B', entregas: 2, total: 10, promedio: 3.8, razon: 'Baja entrega' },
  { id: 'a2', nombre: 'Pedro Díaz', curso: '8vo B', entregas: 4, total: 10, promedio: 4.1, razon: 'Promedio bajo' },
  { id: 'a3', nombre: 'Luis Morales', curso: '1ro Medio', entregas: 3, total: 10, promedio: 4.3, razon: 'Baja entrega' },
])

const actividadReciente = ref([
  { tipo: 'entrega', texto: 'Juan Pérez entregó "Ecuaciones Cuadráticas"', tiempo: 'hace 15 min', icono: '📄' },
  { tipo: 'logro', texto: 'María López desbloqueó "Entregador Serial" 🔥', tiempo: 'hace 1 hora', icono: '🏆' },
  { tipo: 'feedback', texto: 'Nuevo feedback anónimo de 8vo A', tiempo: 'hace 2 horas', icono: '💬' },
  { tipo: 'entrega', texto: 'Carlos Ruiz entregó "Laboratorio de Biología"', tiempo: 'hace 3 horas', icono: '📄' },
])

// ── Computed KPIs ──
const kpis = computed(() => ({
  promedioGeneral: 5.7,
  cambioPromedio: +0.3,
  tasaEntrega: 72,
  cambioEntrega: -5,
  correccionesHoy: docenteStore.pendientesCorreccion.length || 14,
  alumnosEnRiesgo: alumnosRiesgo.value.length,
  xpOtorgadoSemana: 2450,
}))

// Bar chart max value for normalization
const maxEntregas = computed(() => Math.max(...tendenciaSemanal.value.map(d => d.entregas)))

const comunicados = ref<any[]>([])

onMounted(async () => {
  if (authStore.perfil) {
    await docenteStore.cargarDatos(authStore.perfil.id)
    
    // Cargar comunicados para docentes
    const { data: comData } = await supabase
      .from('comunicados')
      .select('*, autor:perfiles!autor_id(nombre)')
      .in('segmento', ['todos', 'docentes'])
      .order('creado_en', { ascending: false })
      .limit(2)
      
    if (comData) comunicados.value = comData
  }
})
</script>

<template>
  <div class="p-4 md:p-6 max-w-7xl mx-auto space-y-6 animate-fade-in">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
      <div>
        <h1 class="font-display font-extrabold text-2xl md:text-3xl text-text dark:text-dark-text">
          📈 Dashboard Analítico
        </h1>
        <p class="text-sm text-text-muted mt-1">Métricas de rendimiento de tus cursos en tiempo real.</p>
      </div>
      <div class="flex items-center gap-2 bg-surface dark:bg-dark-card2 rounded-xl p-1">
        <button
          v-for="p in periodos" :key="p"
          @click="periodoActivo = p"
          :class="[
            'px-3 py-1.5 text-xs font-semibold rounded-lg transition-all duration-200',
            periodoActivo === p
              ? 'bg-primary text-white shadow-sm'
              : 'text-text-muted dark:text-dark-muted hover:text-text dark:hover:text-dark-text'
          ]"
        >
          {{ p }}
        </button>
      </div>
    </div>

    <!-- Comunicados (Anuncios Oficiales) -->
    <div v-if="comunicados.length > 0" class="space-y-3">
      <div v-for="com in comunicados" :key="com.id" class="flex items-start gap-3 bg-mint-bg dark:bg-mint/10 border border-mint/20 text-text dark:text-dark-text px-4 py-3 rounded-xl shadow-sm">
        <Megaphone class="text-mint flex-shrink-0 mt-0.5" :size="20" />
        <div>
          <div class="flex items-center gap-2 mb-1">
            <h3 class="font-bold text-mint">{{ com.titulo }}</h3>
            <span class="text-[10px] uppercase bg-mint/20 text-mint px-1.5 py-0.5 rounded font-bold">Dirección</span>
          </div>
          <p class="text-sm opacity-90">{{ com.contenido }}</p>
        </div>
      </div>
    </div>

    <!-- KPI Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <div class="bg-card dark:bg-dark-card rounded-xl p-4 shadow-card card-hover">
        <div class="flex items-center justify-between mb-3">
          <div class="w-10 h-10 rounded-lg bg-mint-bg dark:bg-mint/20 flex items-center justify-center">
            <TrendingUp :size="20" class="text-mint" />
          </div>
          <span :class="[
            'flex items-center gap-0.5 text-xs font-bold px-2 py-0.5 rounded-full',
            kpis.cambioPromedio >= 0 ? 'bg-mint-bg text-mint' : 'bg-danger-bg text-danger'
          ]">
            <component :is="kpis.cambioPromedio >= 0 ? ArrowUpRight : ArrowDownRight" :size="12" />
            {{ kpis.cambioPromedio >= 0 ? '+' : '' }}{{ kpis.cambioPromedio }}
          </span>
        </div>
        <p class="font-display font-extrabold text-3xl text-text dark:text-dark-text">{{ kpis.promedioGeneral }}</p>
        <p class="text-xs text-text-muted mt-0.5">Promedio General</p>
      </div>

      <div class="bg-card dark:bg-dark-card rounded-xl p-4 shadow-card card-hover">
        <div class="flex items-center justify-between mb-3">
          <div class="w-10 h-10 rounded-lg bg-primary-bg dark:bg-primary/20 flex items-center justify-center">
            <Target :size="20" class="text-primary" />
          </div>
          <span :class="[
            'flex items-center gap-0.5 text-xs font-bold px-2 py-0.5 rounded-full',
            kpis.cambioEntrega >= 0 ? 'bg-mint-bg text-mint' : 'bg-danger-bg text-danger'
          ]">
            <component :is="kpis.cambioEntrega >= 0 ? ArrowUpRight : ArrowDownRight" :size="12" />
            {{ kpis.cambioEntrega >= 0 ? '+' : '' }}{{ kpis.cambioEntrega }}%
          </span>
        </div>
        <p class="font-display font-extrabold text-3xl text-text dark:text-dark-text">{{ kpis.tasaEntrega }}%</p>
        <p class="text-xs text-text-muted mt-0.5">Tasa de Entregas</p>
      </div>

      <StatCard
        :icon="Clock"
        label="Por Corregir Hoy"
        :value="kpis.correccionesHoy"
        iconBg="bg-amber-bg dark:bg-amber/20 text-amber"
        subtitle="Tareas esperando revisión"
      />

      <div class="bg-card dark:bg-dark-card rounded-xl p-4 shadow-card card-hover relative overflow-hidden">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-lg bg-danger-bg dark:bg-danger/20 flex items-center justify-center flex-shrink-0">
            <AlertTriangle :size="20" class="text-danger" />
          </div>
          <div class="min-w-0">
            <p class="font-display font-extrabold text-2xl text-danger leading-none">{{ kpis.alumnosEnRiesgo }}</p>
            <p class="text-xs text-text-muted dark:text-dark-muted mt-0.5">Alumnos en Riesgo</p>
          </div>
        </div>
        <!-- pulse indicator -->
        <div v-if="kpis.alumnosEnRiesgo > 0" class="absolute top-3 right-3 w-2.5 h-2.5 rounded-full bg-danger animate-pulse"></div>
      </div>
    </div>

    <!-- Main Content Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

      <!-- Tendencia Semanal (visual bar chart) -->
      <div class="lg:col-span-2 space-y-4">
        <div class="flex items-center justify-between">
          <h2 class="font-display font-bold text-lg text-text dark:text-dark-text flex items-center gap-2">
            <BarChart3 :size="20" class="text-primary" /> Entregas Diarias
          </h2>
          <span class="text-xs text-text-muted">{{ periodoActivo }}</span>
        </div>

        <BaseCard class="p-6">
          <div class="flex items-end justify-between gap-3 h-44">
            <div
              v-for="d in tendenciaSemanal" :key="d.dia"
              class="flex-1 flex flex-col items-center gap-2"
            >
              <!-- Bar -->
              <div class="w-full flex justify-center">
                <div
                  class="w-10 md:w-12 rounded-t-lg transition-all duration-700 ease-out relative group cursor-pointer"
                  :class="d.entregas === Math.max(...tendenciaSemanal.map(t => t.entregas)) ? 'bg-primary' : 'bg-primary/30 dark:bg-primary/20'"
                  :style="{ height: `${(d.entregas / maxEntregas) * 140}px` }"
                >
                  <!-- Tooltip -->
                  <div class="absolute -top-10 left-1/2 -translate-x-1/2 bg-text dark:bg-dark-card text-white text-[10px] px-2 py-1 rounded-md opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none shadow-md z-10">
                    {{ d.entregas }} entregas · Prom {{ d.promedio }}
                  </div>
                  <!-- Value on bar -->
                  <span class="absolute -top-5 left-1/2 -translate-x-1/2 text-[11px] font-bold text-primary">
                    {{ d.entregas }}
                  </span>
                </div>
              </div>
              <!-- Day label -->
              <span class="text-xs font-medium text-text-muted">{{ d.dia }}</span>
            </div>
          </div>
        </BaseCard>
      </div>

      <!-- Activity Feed -->
      <div class="space-y-4">
        <h2 class="font-display font-bold text-lg text-text dark:text-dark-text">Actividad Reciente</h2>
        <BaseCard class="p-0 divide-y divide-border dark:divide-white/10">
          <div
            v-for="(act, i) in actividadReciente" :key="i"
            class="flex items-start gap-3 p-4 hover:bg-surface/50 dark:hover:bg-dark-card2/50 transition-colors"
          >
            <span class="text-xl mt-0.5 flex-shrink-0">{{ act.icono }}</span>
            <div class="min-w-0 flex-1">
              <p class="text-sm text-text dark:text-dark-text leading-snug">{{ act.texto }}</p>
              <p class="text-[11px] text-text-muted mt-1">{{ act.tiempo }}</p>
            </div>
          </div>
        </BaseCard>
      </div>
    </div>

    <!-- Rendimiento por Curso -->
    <div class="space-y-4">
      <div class="flex items-center justify-between">
        <h2 class="font-display font-bold text-lg text-text dark:text-dark-text">Rendimiento por Curso</h2>
        <button @click="router.push('/docente/reportes')" class="text-sm text-primary font-medium hover:underline">
          Reportes completos
        </button>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <BaseCard
          v-for="curso in cursosRendimiento" :key="curso.id"
          class="relative overflow-hidden"
        >
          <!-- Colored top accent -->
          <div class="absolute top-0 left-0 right-0 h-1 rounded-t-xl"
            :class="curso.promedio >= 6 ? 'bg-mint' : curso.promedio >= 5 ? 'bg-amber' : 'bg-danger'"
          ></div>

          <div class="pt-2">
            <div class="flex items-center justify-between mb-4">
              <h3 class="font-bold text-text dark:text-dark-text text-sm">{{ curso.nombre }}</h3>
              <component
                :is="curso.tendencia === 'up' ? TrendingUp : TrendingDown"
                :size="16"
                :class="curso.tendencia === 'up' ? 'text-mint' : 'text-danger'"
              />
            </div>

            <!-- Mini bars -->
            <div class="space-y-3">
              <div>
                <div class="flex justify-between text-xs mb-1">
                  <span class="text-text-muted">Promedio</span>
                  <span class="font-bold" :class="curso.promedio >= 6 ? 'text-mint' : curso.promedio >= 5 ? 'text-amber' : 'text-danger'">
                    {{ curso.promedio.toFixed(1) }}
                  </span>
                </div>
                <div class="w-full h-2 bg-surface dark:bg-dark-card2 rounded-full overflow-hidden">
                  <div
                    class="h-full rounded-full transition-all duration-1000 ease-out"
                    :class="curso.promedio >= 6 ? 'bg-mint' : curso.promedio >= 5 ? 'bg-amber' : 'bg-danger'"
                    :style="{ width: `${(curso.promedio / 7) * 100}%` }"
                  ></div>
                </div>
              </div>

              <div>
                <div class="flex justify-between text-xs mb-1">
                  <span class="text-text-muted">Tasa Entrega</span>
                  <span class="font-bold" :class="curso.entregas >= 80 ? 'text-mint' : curso.entregas >= 50 ? 'text-amber' : 'text-danger'">
                    {{ curso.entregas }}%
                  </span>
                </div>
                <div class="w-full h-2 bg-surface dark:bg-dark-card2 rounded-full overflow-hidden">
                  <div
                    class="h-full rounded-full transition-all duration-1000 ease-out"
                    :class="curso.entregas >= 80 ? 'bg-primary' : curso.entregas >= 50 ? 'bg-amber' : 'bg-danger'"
                    :style="{ width: `${curso.entregas}%` }"
                  ></div>
                </div>
              </div>
            </div>

            <div class="flex items-center justify-between mt-4 pt-3 border-t border-border dark:border-white/10">
              <BaseBadge
                :variant="curso.riesgo === 0 ? 'mint' : curso.riesgo <= 3 ? 'amber' : 'danger'"
                size="sm"
              >
                {{ curso.riesgo }} en riesgo
              </BaseBadge>
              <button class="text-xs text-primary font-semibold hover:underline">Detalle</button>
            </div>
          </div>
        </BaseCard>
      </div>
    </div>

    <!-- Alumnos en Riesgo -->
    <div class="space-y-4">
      <div class="flex items-center justify-between">
        <h2 class="font-display font-bold text-lg text-text dark:text-dark-text flex items-center gap-2">
          <AlertTriangle :size="20" class="text-danger" /> Alumnos que Necesitan Atención
        </h2>
        <button @click="router.push('/docente/alumnos')" class="text-sm text-primary font-medium hover:underline">
          Ver todos
        </button>
      </div>

      <BaseCard class="p-0 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-surface dark:bg-dark-card2 text-xs uppercase tracking-wider text-text-muted border-b border-border dark:border-white/10">
                <th class="px-4 py-3 font-semibold">Alumno</th>
                <th class="px-4 py-3 font-semibold">Curso</th>
                <th class="px-4 py-3 font-semibold text-center">Entregas</th>
                <th class="px-4 py-3 font-semibold text-center">Promedio</th>
                <th class="px-4 py-3 font-semibold">Motivo</th>
                <th class="px-4 py-3 font-semibold text-center">Acción</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-border dark:divide-white/10 text-sm">
              <tr
                v-for="alumno in alumnosRiesgo" :key="alumno.id"
                class="hover:bg-danger-bg/30 dark:hover:bg-danger/5 transition-colors"
              >
                <td class="px-4 py-3">
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-8 rounded-full bg-danger-bg dark:bg-danger/20 text-danger flex items-center justify-center font-bold text-xs flex-shrink-0">
                      {{ alumno.nombre.charAt(0) }}
                    </div>
                    <span class="font-medium text-text dark:text-dark-text">{{ alumno.nombre }}</span>
                  </div>
                </td>
                <td class="px-4 py-3 text-text-muted">{{ alumno.curso }}</td>
                <td class="px-4 py-3 text-center">
                  <span class="font-bold" :class="alumno.entregas / alumno.total < 0.5 ? 'text-danger' : 'text-amber'">
                    {{ alumno.entregas }}/{{ alumno.total }}
                  </span>
                </td>
                <td class="px-4 py-3 text-center">
                  <span class="font-bold text-danger">{{ alumno.promedio }}</span>
                </td>
                <td class="px-4 py-3">
                  <BaseBadge variant="danger" size="sm">{{ alumno.razon }}</BaseBadge>
                </td>
                <td class="px-4 py-3 text-center">
                  <BaseButton variant="ghost" size="sm" @click="router.push('/docente/alumnos')">
                    <ChevronRight :size="14" />
                  </BaseButton>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </BaseCard>
    </div>

    <!-- Quick Gamification Overview -->
    <BaseCard class="bg-gradient-to-r from-violet-bg to-primary-bg dark:from-violet/10 dark:to-primary/10 border-0">
      <div class="flex flex-col sm:flex-row items-center justify-between gap-4">
        <div class="flex items-center gap-4">
          <div class="w-14 h-14 rounded-2xl bg-white/80 dark:bg-dark-card flex items-center justify-center text-3xl shadow-sm">
            ⚡
          </div>
          <div>
            <p class="font-display font-bold text-text dark:text-dark-text text-lg">{{ kpis.xpOtorgadoSemana.toLocaleString('es-CL') }} XP</p>
            <p class="text-sm text-text-muted">Otorgados esta semana a tus alumnos · El compromiso sube 📈</p>
          </div>
        </div>
        <BaseButton variant="primary" @click="router.push('/docente/entregas')">
          Seguir Corrigiendo
        </BaseButton>
      </div>
    </BaseCard>
  </div>
</template>
