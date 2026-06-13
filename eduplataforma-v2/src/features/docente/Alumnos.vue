<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/services/supabase'
import { useDocenteStore } from '@/stores/docente'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import RewardConfetti from '@/components/gamification/RewardConfetti.vue'
import { Trophy, Search, Mail, Filter, CheckSquare } from 'lucide-vue-next'
import { useAppStore } from '@/stores/app'

const router = useRouter()
const docenteStore = useDocenteStore()
const appStore = useAppStore()

const search = ref('')
const filterCurso = ref('')
const showReward = ref(false)
const selectedAlumnos = ref<Set<string>>(new Set())

const alumnosFiltrados = computed(() => {
 let all = docenteStore.alumnos || []
 if (filterCurso.value) {
 all = all.filter(a => a.curso_id === filterCurso.value)
 }
 if (!search.value) return all
 const s = search.value.toLowerCase()
 return all.filter(a => a.nombre?.toLowerCase().includes(s) || (a.curso_nombre || '').toLowerCase().includes(s))
})

const allSelected = computed(() => {
 return alumnosFiltrados.value.length > 0 && selectedAlumnos.value.size === alumnosFiltrados.value.length
})

function toggleSelectAll() {
 if (allSelected.value) {
 selectedAlumnos.value.clear()
 } else {
 alumnosFiltrados.value.forEach(a => selectedAlumnos.value.add(a.id))
 }
}

function toggleSelect(id: string) {
 if (selectedAlumnos.value.has(id)) selectedAlumnos.value.delete(id)
 else selectedAlumnos.value.add(id)
}

onMounted(async () => {
 if (docenteStore.alumnos.length === 0 && !docenteStore.loading) {
 // Si no están cargados, podríamos forzar recarga, pero asumimos que el layout ya lo hizo
 }
})

async function darPuntosMasivo() {
 if (selectedAlumnos.value.size === 0) return
 try {
 // Aquí iría la lógica de dar puntos masivos, por ahora simulado
 showReward.value = true
 appStore.addToast({ tipo: 'success', mensaje: `Recompensa otorgada a ${selectedAlumnos.value.size} alumnos` })
 selectedAlumnos.value.clear()
 } catch(e) {
 appStore.addToast({ tipo: 'error', mensaje: 'Error al otorgar recompensas' })
 }
}

function irAMensaje(alumnoId: string) {
 router.push(`/docente/mensajeria?user=${alumnoId}`)
}
</script>

<template>
 <div class="p-4 md:p-6 max-w-6xl mx-auto space-y-6 animate-fade-in">
 <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
 <div>
 <h1 class="font-headline-md font-extrabold text-2xl md:text-3xl text-on-surface">🧑‍🎓 Tus Alumnos</h1>
 <p class="text-sm text-on-surface-variant mt-1">Revisa el rendimiento y otorga recompensas manuales por participación.</p>
 </div>
 </div>
 
 <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-4">
 <div class="flex flex-col md:flex-row gap-3 w-full md:w-auto">
 <div class="relative shadow-sm w-full md:w-64">
 <Search :size="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-on-surface-variant" />
 <input id="search" name="search" v-model="search" type="text" placeholder="Buscar alumno..." class="w-full h-10 pl-9 pr-4 bg-surface-container-lowest border border-border rounded-lg text-sm outline-none focus:ring-2 focus:ring-primary/50" />
 </div>
 
 <div class="relative shadow-sm w-full md:w-48">
 <Filter :size="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-on-surface-variant" />
 <select id="filterCurso" name="filterCurso" v-model="filterCurso" class="w-full h-10 pl-9 pr-4 bg-surface-container-lowest border border-border rounded-lg text-sm outline-none appearance-none focus:ring-2 focus:ring-primary/50">
 <option value="">Todos los cursos</option>
 <option v-for="c in docenteStore.cursos" :key="c.id" :value="c.id">{{ c.nombre }}</option>
 </select>
 </div>
 </div>

 <div v-if="selectedAlumnos.size > 0" class="flex gap-2 animate-fade-in">
 <BaseButton variant="primary" @click="darPuntosMasivo">
 <Trophy :size="16" class="mr-1.5" /> Premiar Seleccionados ({{ selectedAlumnos.size }})
 </BaseButton>
 <BaseButton variant="secondary" @click="router.push('/docente/mensajeria')">
 <Mail :size="16" class="mr-1.5" /> Mensaje
 </BaseButton>
 </div>
 </div>

 <div v-if="docenteStore.loading" class="h-64 skeleton rounded-2xl"></div>
 
 <BaseCard v-else class="overflow-hidden">
 <div class="overflow-x-auto">
 <div class="overflow-x-auto w-full">
<table class="w-full text-left border-collapse">
 <thead>
 <tr class="bg-surface-container-low border-b border-border text-xs uppercase font-bold text-on-surface-variant">
 <th class="p-4 w-12">
 <input id="input_checkbox_34" name="input_checkbox_34" type="checkbox" :checked="allSelected" @change="toggleSelectAll" class="rounded text-primary focus:ring-primary w-4 h-4 cursor-pointer" />
 </th>
 <th class="p-4">Alumno</th>
 <th class="p-4">Curso</th>
 <th class="p-4 text-center">Nivel</th>
 <th class="p-4 text-center">Progreso</th>
 <th class="p-4 text-right">Acciones</th>
 </tr>
 </thead>
 <tbody class="divide-y divide-border">
 <tr v-for="alumno in alumnosFiltrados" :key="alumno.id" class="hover:bg-surface-container-low transition-colors group">
 <td class="p-4">
 <input id="input_checkbox_35" name="input_checkbox_35" type="checkbox" :checked="selectedAlumnos.has(alumno.id)" @change="toggleSelect(alumno.id)" class="rounded text-primary focus:ring-primary w-4 h-4 cursor-pointer" />
 </td>
 <td class="p-4">
 <div class="flex items-center gap-3">
 <div class="w-8 h-8 rounded-full bg-primary-bg text-primary flex items-center justify-center font-bold text-xs flex-shrink-0 overflow-hidden">
 <img v-if="alumno.avatar_url && (alumno.avatar_url.startsWith('http') || alumno.avatar_url.startsWith('data'))" :src="alumno.avatar_url" class="w-full h-full object-cover" />
 <span v-else-if="alumno.avatar_url" class="text-lg">{{ alumno.avatar_url }}</span>
 <span v-else>{{ alumno.nombre?.charAt(0) || 'A' }}</span>
 </div>
 <div>
 <p class="font-bold text-on-surface text-sm cursor-pointer hover:text-primary transition-colors" @click="router.push('/docente/alumnos/' + alumno.id)">{{ alumno.nombre }}</p>
 </div>
 </div>
 </td>
 <td class="p-4 text-sm text-on-surface-variant">{{ alumno.curso_nombre || 'Sin curso' }}</td>
 <td class="p-4 text-center">
 <BaseBadge variant="primary" size="sm">Nvl {{ alumno.nivel }}</BaseBadge>
 </td>
 <td class="p-4 text-center">
 <div class="w-full bg-border rounded-full h-2 max-w-[100px] mx-auto">
 <div class="bg-tertiary-500 h-2 rounded-full" :style="{ width: `${Math.min(100, (alumno.xp || 0) / 10)}%` }"></div>
 </div>
 <p class="text-[10px] text-tertiary-600 font-bold mt-1">{{ alumno.xp || 0 }} XP</p>
 </td>
 <td class="p-4 text-right opacity-0 group-hover:opacity-100 transition-opacity">
 <div class="flex items-center justify-end gap-2">
 <BaseButton variant="ghost" size="sm" class="px-2" @click="irAMensaje(alumno.id)" title="Enviar Mensaje">
 <Mail :size="16" class="text-on-surface-variant hover:text-primary" />
 </BaseButton>
 <BaseButton variant="ghost" size="sm" class="px-2" @click="router.push('/docente/alumnos/' + alumno.id)" title="Ver Perfil">
 Ver
 </BaseButton>
 </div>
 </td>
 </tr>
 <tr v-if="alumnosFiltrados.length === 0">
 <td colspan="6" class="p-8 text-center text-on-surface-variant">No se encontraron alumnos.</td>
 </tr>
 </tbody>
 </table>
</div>
 </div>
 </BaseCard>

 <RewardConfetti :active="showReward" @complete="showReward = false" />
 </div>
</template>
