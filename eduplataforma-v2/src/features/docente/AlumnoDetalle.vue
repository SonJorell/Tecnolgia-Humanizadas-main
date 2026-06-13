<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/services/supabase'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import { ArrowLeft, Trophy, CheckCircle, Clock, Mail, Award, AlertTriangle } from 'lucide-vue-next'
import { useDocenteStore } from '@/stores/docente'

const route = useRoute()
const router = useRouter()
const docenteStore = useDocenteStore()
const loading = ref(true)
const showAssignModal = ref(false)
const alumno = ref<any>(null)
const entregas = ref<any[]>([])

onMounted(async () => {
 const id = route.params.id as string
 if (!id) return router.back()
 
 // 1. Cargar perfil
 const { data: perfilData } = await supabase
 .from('perfiles')
 .select('*')
 .eq('id', id)
 .single()
 
 if (perfilData) {
 // Buscar curso via inscripciones
 const { data: insc } = await supabase
 .from('inscripciones')
 .select('curso:cursos(nombre)')
 .eq('alumno_id', id)
 .limit(1)
 .single()

 alumno.value = {
 ...perfilData,
 curso: insc?.curso || null
 }
 }

 // 2. Cargar entregas del alumno
 const { data: entregasData } = await supabase
 .from('entregas')
 .select('*, material:materiales(titulo)')
 .eq('alumno_id', id)
 .order('entregado_en', { ascending: false })
 .limit(10)

 entregas.value = entregasData || []
 loading.value = false
})

async function asignarLogro(logro: any) {
 if (!alumno.value) return
 try {
 const { error } = await supabase.from('logros_asignados').insert({
 alumno_id: alumno.value.id,
 logro_docente_id: logro.id
 })
 if (error) throw error
 
 if (logro.recompensa_xp > 0 || logro.recompensa_monedas > 0) {
 await supabase.rpc('otorgar_recompensa', {
 p_alumno_id: alumno.value.id,
 p_xp: logro.recompensa_xp || 0,
 p_monedas: logro.recompensa_monedas || 0,
 p_razon: 'Logro asignado: ' + logro.nombre
 })
 
 alumno.value.xp += (logro.recompensa_xp || 0)
 alumno.value.monedas += (logro.recompensa_monedas || 0)
 alumno.value.nivel = Math.floor(Math.sqrt(alumno.value.xp / 100)) + 1
 }

 alert('Logro asignado con éxito')
 showAssignModal.value = false
 } catch(e) {
 console.error(e)
 alert('Error al asignar logro')
 }
}
</script>

<template>
 <div class="p-4 md:p-6 max-w-4xl mx-auto space-y-6 animate-fade-in">
 <button type="button" @click="router.back()" class="flex items-center gap-2 text-sm text-on-surface-variant hover:text-primary transition-colors mb-4">
 <ArrowLeft :size="16" /> Volver a lista
 </button>

 <div v-if="loading" class="h-64 skeleton"></div>

 <template v-else-if="alumno">
 <!-- Header Perfil -->
 <BaseCard class="flex flex-col md:flex-row items-center gap-6 p-6">
 <div class="w-24 h-24 rounded-full bg-primary flex items-center justify-center text-white text-3xl font-bold shadow-xl overflow-hidden flex-shrink-0">
 <img v-if="alumno.avatar_url && (alumno.avatar_url.startsWith('http') || alumno.avatar_url.startsWith('data'))" :src="alumno.avatar_url" class="w-full h-full object-cover" />
 <span v-else-if="alumno.avatar_url" class="text-4xl">{{ alumno.avatar_url }}</span>
 <span v-else>{{ alumno.nombre?.charAt(0)?.toUpperCase() || 'U' }}</span>
 </div>
 <div class="text-center md:text-left flex-1">
 <h1 class="text-2xl font-extrabold font-headline-md text-on-surface">{{ alumno.nombre || 'Usuario Desconocido' }}</h1>
 <p class="text-on-surface-variant mt-1 text-sm">{{ alumno.curso?.nombre || 'Sin curso asignado' }}</p>
 <div class="flex items-center justify-center md:justify-start gap-4 mt-3">
 <span class="px-3 py-1 bg-primary/10 text-primary rounded-full text-xs font-bold uppercase">
 Nivel {{ alumno.nivel }}
 </span>
 <span class="text-tertiary-500 font-bold text-sm flex items-center gap-1">
 ⭐ {{ alumno.xp }} XP
 </span>
 <span class="text-yellow-500 font-bold text-sm flex items-center gap-1">
 🪙 {{ alumno.monedas }} Monedas
 </span>
 </div>
 </div>
 </BaseCard>

 <!-- Resumen Actividad -->
 <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
 <BaseCard class="p-5">
 <h3 class="font-bold mb-4 flex items-center gap-2 text-on-surface"><CheckCircle :size="18" class="text-secondary"/> Últimas Entregas</h3>
 <div v-if="entregas.length === 0" class="text-sm text-on-surface-variant">No hay entregas recientes.</div>
 <ul class="space-y-3">
 <li v-for="ent in entregas" :key="ent.id" class="flex justify-between items-center text-sm p-2 rounded-md hover:bg-surface-container-low">
 <span class="truncate pr-2">{{ ent.material?.titulo || 'Tarea eliminada' }}</span>
 <span :class="['px-2 py-0.5 rounded text-[10px] font-bold uppercase', 
 ent.estado === 'revisado' ? 'bg-secondary-container text-secondary' : 'bg-tertiary-100 text-tertiary-700'
 ]">{{ ent.estado }}</span>
 </li>
 </ul>
 </BaseCard>

 <BaseCard class="p-5">
 <h3 class="font-bold mb-4 flex items-center gap-2 text-on-surface"><Trophy :size="18" class="text-primary"/> Acciones Rápidas</h3>
 <div class="space-y-3">
 <BaseButton variant="primary" class="w-full justify-center" @click="showAssignModal = true">
 <Award :size="16" class="mr-1.5"/> Otorgar Premio Especial
 </BaseButton>
 <BaseButton variant="secondary" class="w-full justify-center" @click="router.push(`/docente/mensajeria?user=${alumno.id}`)">
 <Mail :size="16" class="mr-1.5"/> Enviar Mensaje Directo
 </BaseButton>
 </div>
 </BaseCard>
 </div>

 <!-- Modal Asignar Logro -->
 <div v-if="showAssignModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-text/50 backdrop-blur-sm animate-fade-in">
 <div class="bg-surface-container-lowest rounded-2xl w-full max-w-md shadow-modal overflow-hidden flex flex-col">
 <div class="p-4 border-b border-border bg-surface-container-low flex justify-between items-center">
 <h2 class="font-bold text-on-surface">Otorgar Premio Especial</h2>
 </div>
 <div class="p-4 max-h-96 overflow-y-auto space-y-3">
 <div v-for="logro in docenteStore.logrosDocente" :key="logro.id" class="p-3 border border-border rounded-xl flex items-center justify-between hover:bg-surface-container-low cursor-pointer transition-colors" @click="asignarLogro(logro)">
 <div class="flex items-center gap-3">
 <span class="text-3xl">{{ logro.icono }}</span>
 <div>
 <p class="font-bold text-on-surface text-sm">{{ logro.nombre }}</p>
 <div class="flex gap-2 mt-1">
 <span class="text-[10px] bg-tertiary-500/10 text-tertiary-500 px-1.5 py-0.5 rounded font-bold">+{{ logro.recompensa_xp }} XP</span>
 </div>
 </div>
 </div>
 <BaseButton variant="ghost" size="sm">Dar</BaseButton>
 </div>
 <div v-if="docenteStore.logrosDocente.length === 0" class="text-center py-6 text-on-surface-variant text-sm flex flex-col items-center">
 <AlertTriangle class="text-tertiary-500 mb-2" :size="24"/>
 No has creado premios personalizados aún.
 <BaseButton variant="primary" size="sm" class="mt-4" @click="router.push('/docente/logros')">Crear un premio</BaseButton>
 </div>
 </div>
 <div class="p-4 border-t border-border flex justify-end">
 <BaseButton variant="ghost" @click="showAssignModal = false">Cancelar</BaseButton>
 </div>
 </div>
 </div>
 </template>
 <div v-else class="text-center py-10 text-on-surface-variant">
 Alumno no encontrado o sin permisos.
 </div>
 </div>
</template>
