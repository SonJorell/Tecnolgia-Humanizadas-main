<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useAppStore } from '@/stores/app'
import { idb } from '@/services/idb'
import { useSync } from '@/composables/useSync'
import BaseButton from '@/components/ui/BaseButton.vue'
import RewardConfetti from '@/components/gamification/RewardConfetti.vue'
import { ChevronLeft, Paperclip, X, CloudOff, Info, CheckCircle2, Star, MessageSquare } from 'lucide-vue-next'

import { useCursosStore } from '@/stores/cursos'
import { useTareasStore } from '@/stores/tareas'
import { computed } from 'vue'

const route = useRoute()
const router = useRouter()
const appStore = useAppStore()
const authStore = useAuthStore()
const cursosStore = useCursosStore()
const tareasStore = useTareasStore()
const { syncAhora } = useSync()

const id = route.params.id as string

const contenido = ref('')
const archivos = ref<File[]>([])
const dragging = ref(false)
const subiendo = ref(false)
const showReward = ref(false)

const tarea = computed<any>(() => route.params.id === 'demo' ? {
 titulo: 'Evaluación Formativa 1',
 descripcion: 'Lee el capítulo 4 del texto guía escolar...',
 vence_en: null,
 xp_premio: 50
} : Object.values(cursosStore.materiales).flat().find((m: any) => m.id === route.params.id) || {})

const entrega = computed(() => {
 return tareasStore.entregas.find(e => e.material_id === id)
})

function handleFileDrop(e: DragEvent) {
 dragging.value = false
 if (e.dataTransfer?.files) {
 archivos.value.push(...Array.from(e.dataTransfer.files))
 }
}

function handleFileSelect(e: Event) {
 const target = e.target as HTMLInputElement
 if (target.files) {
 archivos.value.push(...Array.from(target.files))
 }
}

function removerArchivo(index: number) {
 archivos.value.splice(index, 1)
}

async function fileToBase64(file: File): Promise<string> {
 return new Promise((resolve, reject) => {
 const reader = new FileReader()
 reader.readAsDataURL(file)
 reader.onload = () => resolve(reader.result as string)
 reader.onerror = error => reject(error)
 })
}

async function entregarTarea() {
 if (!contenido.value && archivos.value.length === 0) {
 appStore.addToast({ tipo: 'error', mensaje: 'Por favor escribe algo o adjunta un archivo' })
 return
 }

 subiendo.value = true
 try {
 // 1. Convertir archivos a Base64 para guardado local
 const adjuntosBase64 = await Promise.all(
 archivos.value.map(async f => ({
 nombre: f.name,
 tipo: f.type,
 data: await fileToBase64(f)
 }))
 )

 const payload = JSON.parse(JSON.stringify({
 material_id: id,
 alumno_id: authStore.user?.id,
 contenido: contenido.value,
 archivos: adjuntosBase64,
 estado: 'entregado',
 entregado_en: new Date().toISOString()
 }))

 // 2. Guardar en Cola de Sincronización (Offline-First)
 await idb.put('sync_queue', {
 id: crypto.randomUUID(),
 tipo: 'entrega',
 accion: 'insert',
 tabla: 'entregas',
 payload,
 intentos: 0,
 creado_en: Date.now(),
 ultimo_intento: null,
 error_msg: null
 })

 // 3. Recompensa visual (Gamificación Inmediata)
 subiendo.value = false
 showReward.value = true
 
 // Auto-sync background
 syncAhora()
 
 // Opcional: Sumar XP/Monedas al store local inmediatamente
 } catch (err) {
 console.error(err)
 appStore.addToast({ tipo: 'error', mensaje: 'Ocurrió un error al guardar la tarea' })
 subiendo.value = false
 }
}

function onRewardComplete() {
 showReward.value = false
 router.push('/alumno/tareas')
}
</script>

<template>
 <div class="p-4 md:p-6 max-w-3xl mx-auto animate-fade-in pb-24">
 <!-- Breadcrumb -->
 <button type="button" 
 class="flex items-center gap-1 text-sm text-on-surface-variant hover:text-on-surface mb-6 transition-colors"
 @click="router.back()"
 >
 <ChevronLeft :size="16" /> Volver a tareas
 </button>

 <!-- Header Tarea -->
 <div class="bg-surface-container-lowest rounded-2xl p-6 shadow-sm border border-border-subtle mb-6">
 <div class="flex items-center gap-2 mb-2">
 <span class="text-xs font-bold text-primary bg-primary-bg px-2 py-0.5 rounded-full uppercase tracking-wider">
 {{ tarea.curso }}
 </span>
 <span class="text-xs font-bold text-tertiary bg-tertiary-container px-2 py-0.5 rounded-full flex items-center gap-1">
 ⏳ Vence: {{ tarea.vence_en }}
 </span>
 </div>
 <h1 class="font-headline-md font-bold text-2xl text-on-surface mb-3">
 {{ tarea.titulo }}
 </h1>
 <p class="text-on-surface-variant text-sm leading-relaxed">
 {{ tarea.descripcion }}
 </p>
 </div>

 <!-- Zona de Entrega o Corrección -->
 <div v-if="entrega?.estado === 'revisado'" class="bg-surface-container-lowest rounded-2xl p-6 shadow-sm border-2 border-secondary">
 <div class="flex items-center gap-3 mb-6 border-b border-border-subtle pb-4">
 <div class="w-10 h-10 rounded-full bg-secondary-container text-secondary flex items-center justify-center">
 <CheckCircle2 :size="24" />
 </div>
 <div>
 <h2 class="font-headline-md font-bold text-xl text-on-surface">Tarea Revisada</h2>
 <p class="text-sm text-on-surface-variant">El profesor ha corregido tu entrega</p>
 </div>
 </div>
 
 <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
 <div class="bg-surface-container-low p-4 rounded-xl border border-border-subtle text-center">
 <p class="text-on-surface-variant text-xs font-bold uppercase mb-1">Calificación</p>
 <p class="text-3xl font-headline-md font-bold" :class="entrega.calificacion && entrega.calificacion >= 60 ? 'text-secondary' : 'text-error'">
 {{ entrega.calificacion || 0 }} / 100
 </p>
 </div>
 <div class="bg-surface-container-low p-4 rounded-xl border border-border-subtle text-center">
 <p class="text-on-surface-variant text-xs font-bold uppercase mb-1">XP Obtenidos</p>
 <div class="flex items-center justify-center gap-2 text-2xl font-headline-md font-bold text-primary">
 <Star :size="24" class="fill-primary text-primary" />
 +{{ tarea.xp_premio || 0 }}
 </div>
 </div>
 </div>
 
 <div class="bg-primary-bg border border-primary/20 rounded-xl p-4">
 <div class="flex items-center gap-2 mb-2">
 <MessageSquare :size="18" class="text-primary" />
 <p class="font-bold text-sm text-primary">Feedback del Docente</p>
 </div>
 <p class="text-sm text-on-surface whitespace-pre-wrap">
 {{ entrega.feedback_docente || 'Sin comentarios adicionales.' }}
 </p>
 </div>
 
 <div class="mt-6 flex justify-end">
 <BaseButton variant="secondary" @click="router.back()">Volver a Tareas</BaseButton>
 </div>
 </div>
 
 <div v-else class="bg-surface-container-lowest rounded-2xl p-6 shadow-sm border border-border-subtle">
 <h2 class="font-headline-md font-bold text-lg text-on-surface mb-4">Tu Respuesta</h2>
 
 <!-- Input Texto -->
 <textarea id="contenido" name="contenido"
 v-model="contenido"
 rows="4"
 placeholder="Escribe tu respuesta o comentarios para el profesor aquí..."
 class="w-full bg-surface-container-low rounded-xl p-4 text-sm text-on-surface border border-border-subtle focus:ring-2 focus:ring-primary/30 focus:border-primary outline-none transition-all resize-y mb-4"
 ></textarea>

 <!-- Zona Archivos Drag & Drop -->
 <div 
 :class="['border-2 border-dashed rounded-xl p-6 text-center transition-colors mb-4 relative', dragging ? 'border-primary bg-primary-bg ' : 'border-border-subtle hover:bg-surface-container-low ']"
 @dragover.prevent="dragging = true"
 @dragleave.prevent="dragging = false"
 @drop.prevent="handleFileDrop"
 >
 <input id="input_file_7" name="input_file_7" 
 type="file" 
 multiple 
 class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
 @change="handleFileSelect"
 />
 <Paperclip :size="24" class="mx-auto text-on-surface-light mb-2" />
 <p class="text-sm font-medium text-on-surface">Arrastra archivos aquí o haz clic para subir</p>
 <p class="text-xs text-on-surface-variant mt-1">PDF, Imágenes o Documentos (Máx 10MB)</p>
 </div>

 <!-- Lista de Adjuntos -->
 <ul v-if="archivos.length > 0" class="space-y-2 mb-6">
 <li v-for="(file, idx) in archivos" :key="idx" class="flex items-center justify-between bg-surface-container-low p-3 rounded-lg border border-border-subtle">
 <div class="flex items-center gap-3 min-w-0">
 <div class="w-8 h-8 bg-primary-bg text-primary rounded flex items-center justify-center flex-shrink-0">
 <Paperclip :size="14" />
 </div>
 <p class="text-sm font-medium text-on-surface truncate">{{ file.name }}</p>
 </div>
 <button type="button" @click="removerArchivo(idx)" class="text-on-surface-light hover:text-error p-1">
 <X :size="16" />
 </button>
 </li>
 </ul>

 <!-- Advertencia Offline Crítica -->
 <div v-if="!appStore.isOnline" class="flex gap-3 bg-surface-container-low border border-border-subtle p-4 rounded-xl mb-6">
 <CloudOff :size="20" class="text-on-surface-variant flex-shrink-0" />
 <div>
 <p class="text-sm font-semibold text-on-surface">Estás sin conexión a internet</p>
 <p class="text-xs text-on-surface-variant mt-0.5">Al presionar"Entregar", la tarea se guardará segura en este dispositivo y se enviará automáticamente cuando recuperes la red. ¡No perderás tu trabajo!</p>
 </div>
 </div>
 
 <!-- Mensaje Online -->
 <div v-else class="flex gap-3 bg-secondary-container text-secondary p-4 rounded-xl mb-6">
 <Info :size="20" class="flex-shrink-0" />
 <p class="text-xs font-medium pt-0.5">La conexión es estable. Tu tarea se enviará al profesor inmediatamente.</p>
 </div>

 <div class="flex justify-end gap-3">
 <BaseButton variant="ghost" @click="router.back()">Cancelar</BaseButton>
 <BaseButton variant="primary" :loading="subiendo" @click="entregarTarea">
 {{ entrega?.estado === 'entregado' ? '🔄 Actualizar Entrega' : '🚀 Entregar Tarea' }}
 </BaseButton>
 </div>
 </div>

 <!-- Animación de Recompensa (Se dispara al guardar en IDB) -->
 <RewardConfetti :active="showReward" @complete="onRewardComplete" />
 </div>
</template>
