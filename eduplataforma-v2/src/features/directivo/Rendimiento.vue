<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useDirectivoStore } from '@/stores/directivo'
import StatCard from '@/components/ui/StatCard.vue'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import {
 TrendingUp, Users, BookOpen,
 AlertTriangle, BarChart3, ArrowUpRight, ArrowDownRight,
 ChevronDown, ChevronUp, Filter, Search
} from 'lucide-vue-next'

const directivoStore = useDirectivoStore()

// ── Filters ──
const filtroAsignatura = ref('Todas')
const filtroNivel = ref('Todos')
const busqueda = ref('')
const ordenarPor = ref<'promedio' | 'tasa_entrega' | 'alumnos_riesgo'>('tasa_entrega')
const ordenAsc = ref(false)

const asignaturas = ['Todas', 'Matemáticas', 'Lenguaje', 'Ciencias', 'Historia']
const niveles = ['Todos', '7mo Básico', '8vo Básico', '1ro Medio', '2do Medio']

// ── Datos de rendimiento detallado (mock data ampliado) ──
const cursosDetalle = ref([
 { id: 'c1', nombre: '8vo Básico A', asignatura: 'Matemáticas', nivel: '8vo Básico', profesor: 'Prof. María López', promedio: 6.2, promedioAnterior: 5.9, tasa_entrega: 92, alumnos_riesgo: 1, alumnos_total: 35, entregas_mes: 180, mejor_alumno: 'Juan Pérez', mejor_nota: 7.0 },
 { id: 'c2', nombre: '8vo Básico B', asignatura: 'Matemáticas', nivel: '8vo Básico', profesor: 'Prof. Carlos Díaz', promedio: 4.8, promedioAnterior: 5.1, tasa_entrega: 45, alumnos_riesgo: 8, alumnos_total: 32, entregas_mes: 95, mejor_alumno: 'Sofía Reyes', mejor_nota: 6.5 },
 { id: 'c3', nombre: '1ro Medio A', asignatura: 'Ciencias', nivel: '1ro Medio', profesor: 'Prof. Ana Vargas', promedio: 5.5, promedioAnterior: 5.3, tasa_entrega: 78, alumnos_riesgo: 3, alumnos_total: 38, entregas_mes: 145, mejor_alumno: 'Pedro Soto', mejor_nota: 6.8 },
 { id: 'c4', nombre: '1ro Medio B', asignatura: 'Lenguaje', nivel: '1ro Medio', profesor: 'Prof. Laura Muñoz', promedio: 6.0, promedioAnterior: 5.8, tasa_entrega: 88, alumnos_riesgo: 2, alumnos_total: 36, entregas_mes: 160, mejor_alumno: 'Valentina Rojas', mejor_nota: 7.0 },
 { id: 'c5', nombre: '7mo Básico A', asignatura: 'Historia', nivel: '7mo Básico', profesor: 'Prof. Roberto Pinto', promedio: 5.8, promedioAnterior: 5.6, tasa_entrega: 83, alumnos_riesgo: 2, alumnos_total: 34, entregas_mes: 138, mejor_alumno: 'Martín Flores', mejor_nota: 6.9 },
 { id: 'c6', nombre: '2do Medio A', asignatura: 'Ciencias', nivel: '2do Medio', profesor: 'Prof. Ana Vargas', promedio: 5.2, promedioAnterior: 5.4, tasa_entrega: 65, alumnos_riesgo: 5, alumnos_total: 37, entregas_mes: 110, mejor_alumno: 'Diego Campos', mejor_nota: 6.3 },
])

// ── Distribución de notas ──
const distribucionNotas = ref([
 { rango: '1.0 - 2.9', cantidad: 12, color: 'bg-error' },
 { rango: '3.0 - 3.9', cantidad: 28, color: 'bg-error-container' },
 { rango: '4.0 - 4.9', cantidad: 45, color: 'bg-tertiary' },
 { rango: '5.0 - 5.9', cantidad: 85, color: 'bg-primary' },
 { rango: '6.0 - 6.9', cantidad: 110, color: 'bg-secondary' },
 { rango: '7.0', cantidad: 35, color: 'bg-secondary' },
])

const maxDistribucion = computed(() => Math.max(...distribucionNotas.value.map(d => d.cantidad)))

// ── Filtered and sorted data ──
const cursosFiltrados = computed(() => {
 let result = [...cursosDetalle.value]

 if (filtroAsignatura.value !== 'Todas') {
 result = result.filter(c => c.asignatura === filtroAsignatura.value)
 }
 if (filtroNivel.value !== 'Todos') {
 result = result.filter(c => c.nivel === filtroNivel.value)
 }
 if (busqueda.value.trim()) {
 const q = busqueda.value.toLowerCase()
 result = result.filter(c =>
 c.nombre.toLowerCase().includes(q) ||
 c.profesor.toLowerCase().includes(q) ||
 c.asignatura.toLowerCase().includes(q)
 )
 }

 result.sort((a, b) => {
 const diff = a[ordenarPor.value] - b[ordenarPor.value]
 return ordenAsc.value ? diff : -diff
 })

 return result
})

// ── Aggregate stats ──
const statsGlobales = computed(() => {
 const cursos = cursosDetalle.value
 const promedioGlobal = cursos.reduce((s, c) => s + c.promedio, 0) / cursos.length
 const tasaGlobal = cursos.reduce((s, c) => s + c.tasa_entrega, 0) / cursos.length
 const totalRiesgo = cursos.reduce((s, c) => s + c.alumnos_riesgo, 0)
 const totalAlumnos = cursos.reduce((s, c) => s + c.alumnos_total, 0)
 const totalEntregasMes = cursos.reduce((s, c) => s + c.entregas_mes, 0)
 return { promedioGlobal, tasaGlobal, totalRiesgo, totalAlumnos, totalEntregasMes }
})

function toggleOrden(campo: 'promedio' | 'tasa_entrega' | 'alumnos_riesgo') {
 if (ordenarPor.value === campo) {
 ordenAsc.value = !ordenAsc.value
 } else {
 ordenarPor.value = campo
 ordenAsc.value = false
 }
}

function getColorForPromedio(promedio: number): string {
 if (promedio >= 6.0) return 'text-secondary'
 if (promedio >= 5.0) return 'text-tertiary'
 return 'text-error'
}

function getTendenciaColor(actual: number, anterior: number): string {
 if (actual > anterior) return 'text-secondary'
 if (actual < anterior) return 'text-error'
 return 'text-on-surface-variant'
}

onMounted(async () => {
 await directivoStore.cargarDatosGlobales()
})
</script>

<template>
 <div class="p-4 md:p-6 max-w-7xl mx-auto space-y-6 animate-fade-in">
 <!-- Header -->
 <div>
 <h1 class="font-headline-md font-extrabold text-2xl md:text-3xl text-on-surface">
 📊 Rendimiento Académico
 </h1>
 <p class="text-sm text-on-surface-variant mt-1">Análisis profundo del rendimiento por cursos, asignaturas y docentes.</p>
 </div>

 <!-- Global KPIs -->
 <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
 <StatCard
 :icon="TrendingUp"
 label="Promedio Global"
 :value="statsGlobales.promedioGlobal.toFixed(1)"
 iconBg="bg-secondary-container text-secondary"
 />
 <StatCard
 :icon="BarChart3"
 label="Tasa de Entregas"
 :value="`${Math.round(statsGlobales.tasaGlobal)}%`"
 iconBg="bg-primary-bg text-primary"
 />
 <StatCard
 :icon="AlertTriangle"
 label="En Riesgo"
 :value="statsGlobales.totalRiesgo"
 iconBg="bg-error-container text-error"
 />
 <StatCard
 :icon="Users"
 label="Alumnos Totales"
 :value="statsGlobales.totalAlumnos"
 iconBg="bg-violet-bg text-violet"
 />
 <StatCard
 :icon="BookOpen"
 label="Entregas/Mes"
 :value="statsGlobales.totalEntregasMes"
 iconBg="bg-tertiary-container text-tertiary"
 />
 </div>

 <!-- Distribution Chart + Top/Bottom -->
 <div class="grid grid-cols-1 lg:grid-cols-5 gap-6">
 <!-- Distribución de Notas -->
 <BaseCard class="lg:col-span-3">
 <h3 class="font-headline-md font-bold text-base text-on-surface mb-5 flex items-center gap-2">
 <BarChart3 :size="18" class="text-primary" /> Distribución de Notas (Colegio)
 </h3>
 <div class="space-y-3">
 <div
 v-for="d in distribucionNotas" :key="d.rango"
 class="flex items-center gap-3"
 >
 <span class="text-xs font-mono text-on-surface-variant w-20 text-right flex-shrink-0">{{ d.rango }}</span>
 <div class="flex-1 h-7 bg-surface-container-low rounded-lg overflow-hidden relative">
 <div
 :class="['h-full rounded-lg transition-all duration-1000 ease-out', d.color]"
 :style="{ width: `${(d.cantidad / maxDistribucion) * 100}%` }"
 ></div>
 <span class="absolute right-2 top-1/2 -translate-y-1/2 text-[11px] font-bold text-on-surface">
 {{ d.cantidad }}
 </span>
 </div>
 </div>
 </div>
 </BaseCard>

 <!-- Top & Bottom Performers -->
 <div class="lg:col-span-2 space-y-4">
 <!-- Mejor curso -->
 <BaseCard class="border-l-4 border-secondary">
 <div class="flex items-center gap-2 mb-3">
 <span class="text-xl">🏆</span>
 <h3 class="font-bold text-sm text-on-surface">Mejor Rendimiento</h3>
 </div>
 <p class="font-headline-md font-extrabold text-lg text-secondary">
 {{ cursosDetalle.reduce((best, c) => c.promedio > best.promedio ? c : best).nombre }}
 </p>
 <div class="flex items-center gap-4 mt-2 text-xs text-on-surface-variant">
 <span>Promedio <strong class="text-secondary">{{ cursosDetalle.reduce((best, c) => c.promedio > best.promedio ? c : best).promedio.toFixed(1) }}</strong></span>
 <span>Entregas <strong class="text-secondary">{{ cursosDetalle.reduce((best, c) => c.promedio > best.promedio ? c : best).tasa_entrega }}%</strong></span>
 </div>
 </BaseCard>

 <!-- Peor curso -->
 <BaseCard class="border-l-4 border-error">
 <div class="flex items-center gap-2 mb-3">
 <span class="text-xl">⚠️</span>
 <h3 class="font-bold text-sm text-on-surface">Requiere Atención</h3>
 </div>
 <p class="font-headline-md font-extrabold text-lg text-error">
 {{ cursosDetalle.reduce((worst, c) => c.promedio < worst.promedio ? c : worst).nombre }}
 </p>
 <div class="flex items-center gap-4 mt-2 text-xs text-on-surface-variant">
 <span>Promedio <strong class="text-error">{{ cursosDetalle.reduce((worst, c) => c.promedio < worst.promedio ? c : worst).promedio.toFixed(1) }}</strong></span>
 <span>{{ cursosDetalle.reduce((worst, c) => c.promedio < worst.promedio ? c : worst).alumnos_riesgo }} en riesgo</span>
 </div>
 </BaseCard>

 <!-- Comparativa rápida -->
 <BaseCard class="bg-gradient-to-br from-violet-bg to-primary-bg border-0">
 <div class="text-center">
 <p class="text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-1">Meta Institucional</p>
 <p class="font-headline-md font-extrabold text-3xl text-primary">6.0</p>
 <p class="text-xs text-on-surface-variant mt-1">
 {{ statsGlobales.promedioGlobal >= 6.0 ? '✅ Meta alcanzada' : `📉 Faltan ${(6.0 - statsGlobales.promedioGlobal).toFixed(1)} puntos` }}
 </p>
 </div>
 </BaseCard>
 </div>
 </div>

 <!-- Filter Bar -->
 <div class="flex flex-col md:flex-row items-stretch md:items-center gap-3 bg-surface-container-low rounded-xl p-3">
 <div class="flex items-center gap-2 text-on-surface-variant">
 <Filter :size="16" />
 <span class="text-xs font-semibold uppercase tracking-wider">Filtros</span>
 </div>
 <div class="flex flex-wrap gap-2 flex-1">
 <select id="filtroAsignatura" name="filtroAsignatura"
 v-model="filtroAsignatura"
 class="h-8 px-3 text-xs bg-surface-container-lowest border border-border-subtle rounded-lg outline-none focus:ring-2 focus:ring-primary/50 text-on-surface"
 >
 <option v-for="a in asignaturas" :key="a">{{ a }}</option>
 </select>
 <select id="filtroNivel" name="filtroNivel"
 v-model="filtroNivel"
 class="h-8 px-3 text-xs bg-surface-container-lowest border border-border-subtle rounded-lg outline-none focus:ring-2 focus:ring-primary/50 text-on-surface"
 >
 <option v-for="n in niveles" :key="n">{{ n }}</option>
 </select>
 </div>
 <div class="relative w-full md:w-56">
 <Search :size="14" class="absolute left-2.5 top-1/2 -translate-y-1/2 text-on-surface-variant" />
 <input id="busqueda" name="busqueda"
 v-model="busqueda"
 type="text"
 placeholder="Buscar curso o profesor..."
 class="w-full h-8 pl-8 pr-3 text-xs bg-surface-container-lowest border border-border-subtle rounded-lg outline-none focus:ring-2 focus:ring-primary/50 text-on-surface"
 />
 </div>
 </div>

 <!-- Detailed Course Table -->
 <BaseCard class="p-0 overflow-hidden">
 <div class="overflow-x-auto">
 <div class="overflow-x-auto w-full">
<table class="w-full text-left border-collapse min-w-[700px]">
 <thead>
 <tr class="bg-surface-container-low text-xs uppercase tracking-wider text-on-surface-variant border-b border-border-subtle">
 <th class="px-4 py-3 font-semibold">Curso</th>
 <th class="px-4 py-3 font-semibold">Docente</th>
 <th class="px-4 py-3 font-semibold text-center cursor-pointer select-none hover:text-primary transition-colors" @click="toggleOrden('promedio')">
 <span class="inline-flex items-center gap-1">
 Promedio
 <component :is="ordenarPor === 'promedio' ? (ordenAsc ? ChevronUp : ChevronDown) : ChevronDown" :size="12" :class="ordenarPor === 'promedio' ? 'text-primary' : 'opacity-30'" />
 </span>
 </th>
 <th class="px-4 py-3 font-semibold text-center">Tendencia</th>
 <th class="px-4 py-3 font-semibold text-center cursor-pointer select-none hover:text-primary transition-colors" @click="toggleOrden('tasa_entrega')">
 <span class="inline-flex items-center gap-1">
 Tasa Entrega
 <component :is="ordenarPor === 'tasa_entrega' ? (ordenAsc ? ChevronUp : ChevronDown) : ChevronDown" :size="12" :class="ordenarPor === 'tasa_entrega' ? 'text-primary' : 'opacity-30'" />
 </span>
 </th>
 <th class="px-4 py-3 font-semibold text-center cursor-pointer select-none hover:text-primary transition-colors" @click="toggleOrden('alumnos_riesgo')">
 <span class="inline-flex items-center gap-1">
 En Riesgo
 <component :is="ordenarPor === 'alumnos_riesgo' ? (ordenAsc ? ChevronUp : ChevronDown) : ChevronDown" :size="12" :class="ordenarPor === 'alumnos_riesgo' ? 'text-primary' : 'opacity-30'" />
 </span>
 </th>
 <th class="px-4 py-3 font-semibold text-center">Top Alumno</th>
 </tr>
 </thead>
 <tbody class="divide-y divide-border text-sm">
 <tr
 v-for="curso in cursosFiltrados" :key="curso.id"
 class="hover:bg-surface-container-low/50 transition-colors"
 >
 <td class="px-4 py-3">
 <div>
 <p class="font-bold text-on-surface">{{ curso.nombre }}</p>
 <p class="text-[11px] text-on-surface-variant">{{ curso.asignatura }}</p>
 </div>
 </td>
 <td class="px-4 py-3 text-on-surface-variant text-xs">{{ curso.profesor }}</td>
 <td class="px-4 py-3 text-center">
 <span class="font-extrabold text-lg" :class="getColorForPromedio(curso.promedio)">
 {{ curso.promedio.toFixed(1) }}
 </span>
 </td>
 <td class="px-4 py-3 text-center">
 <span class="inline-flex items-center gap-0.5 text-xs font-semibold" :class="getTendenciaColor(curso.promedio, curso.promedioAnterior)">
 <component :is="curso.promedio > curso.promedioAnterior ? ArrowUpRight : curso.promedio < curso.promedioAnterior ? ArrowDownRight : TrendingUp" :size="14" />
 {{ curso.promedio > curso.promedioAnterior ? '+' : '' }}{{ (curso.promedio - curso.promedioAnterior).toFixed(1) }}
 </span>
 </td>
 <td class="px-4 py-3">
 <div class="flex items-center gap-2 justify-center">
 <div class="w-20 h-2 bg-surface-container-low rounded-full overflow-hidden">
 <div
 class="h-full rounded-full transition-all duration-700"
 :class="curso.tasa_entrega >= 80 ? 'bg-secondary' : curso.tasa_entrega >= 50 ? 'bg-tertiary' : 'bg-error'"
 :style="{ width: `${curso.tasa_entrega}%` }"
 ></div>
 </div>
 <span class="text-xs font-bold" :class="curso.tasa_entrega >= 80 ? 'text-secondary' : curso.tasa_entrega >= 50 ? 'text-tertiary' : 'text-error'">
 {{ curso.tasa_entrega }}%
 </span>
 </div>
 </td>
 <td class="px-4 py-3 text-center">
 <BaseBadge
 :variant="curso.alumnos_riesgo === 0 ? 'mint' : curso.alumnos_riesgo <= 3 ? 'amber' : 'danger'"
 size="sm"
 >
 {{ curso.alumnos_riesgo }} / {{ curso.alumnos_total }}
 </BaseBadge>
 </td>
 <td class="px-4 py-3 text-center">
 <div class="text-xs">
 <p class="font-medium text-on-surface">{{ curso.mejor_alumno }}</p>
 <p class="text-secondary font-bold">{{ curso.mejor_nota.toFixed(1) }}</p>
 </div>
 </td>
 </tr>
 </tbody>
 </table>
</div>
 </div>

 <div v-if="cursosFiltrados.length === 0" class="p-12 text-center">
 <Search :size="48" class="mx-auto text-on-surface-light mb-3" />
 <p class="font-medium text-on-surface">Sin resultados</p>
 <p class="text-sm text-on-surface-variant">Prueba cambiando los filtros de búsqueda.</p>
 </div>
 </BaseCard>
 </div>
</template>
