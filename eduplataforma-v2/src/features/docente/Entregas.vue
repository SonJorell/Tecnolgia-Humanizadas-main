<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useDocenteStore } from '@/stores/docente'
import { useAppStore } from '@/stores/app'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import { useSync } from '@/composables/useSync'
import BaseButton from '@/components/ui/BaseButton.vue'
import { CheckCircle2, AlertCircle, Search, FileText, Download, X } from 'lucide-vue-next'

const authStore = useAuthStore()
const docenteStore = useDocenteStore()
const appStore = useAppStore()

const filtro = ref<'pendientes' | 'revisadas'>('pendientes')
const search = ref('')
const selectedEntrega = ref<any | null>(null)

// Formulario de Corrección
const nota = ref<number | ''>('')
const feedback = ref('')
const xpOtorgado = ref<number>(50)
const guardando = ref(false)
const { syncAhora } = useSync()

onMounted(async () => {
 if (authStore.perfil) {
 await docenteStore.cargarDatos(authStore.perfil.id)
 }
})

const entregasFiltradas = computed(() => {
 const base = filtro.value === 'pendientes' ? docenteStore.pendientesCorreccion : docenteStore.revisadas
 if (!search.value) return base
 
 const s = search.value.toLowerCase()
 return base.filter(e => 
 (e as any)._alumno_nombre?.toLowerCase().includes(s) || 
 (e as any)._material_titulo?.toLowerCase().includes(s)
 )
})

function abrirCorreccion(entrega: any) {
 selectedEntrega.value = entrega
 // Resetear el formulario al abrir
 nota.value = entrega.calificacion || ''
 feedback.value = entrega.feedback_docente || ''
 xpOtorgado.value = 50 // Por defecto
}

async function guardarCorreccion() {
 if (!selectedEntrega.value) return
 if (nota.value === '' || nota.value < 1.0 || nota.value > 7.0) {
 appStore.addToast({ tipo: 'error', mensaje: 'Por favor ingresa una nota válida entre 1.0 y 7.0' })
 return
 }

 guardando.value = true
 try {
 await docenteStore.calificarEntrega(
 selectedEntrega.value.id, 
 Number(nota.value), 
 feedback.value, 
 xpOtorgado.value
 )
 
 appStore.addToast({ tipo: 'info', mensaje: 'Calificación guardada y sincronizada' })
 if (appStore.isOnline) {
 await syncAhora()
 }
 selectedEntrega.value = null // Cerrar modal
 } catch (err) {
 appStore.addToast({ tipo: 'error', mensaje: 'Faltan datos de la entrega' })
 } finally {
 guardando.value = false
 }
}

function descargarArchivo(file: any) {
 if (!file.data) return
 const a = document.createElement('a')
 a.href = file.data
 a.download = file.nombre || 'documento'
 document.body.appendChild(a)
 a.click()
 document.body.removeChild(a)
}
</script>

<template>
 <div class="p-4 md:p-6 max-w-6xl mx-auto space-y-6 animate-fade-in relative">
 
 <!-- Header y Filtros -->
 <div class="flex flex-col lg:flex-row lg:items-end justify-between gap-4">
 <div>
 <h1 class="font-headline-md font-extrabold text-2xl md:text-3xl text-on-surface">📝 Buzón de Correcciones</h1>
 <p class="text-sm text-on-surface-variant mt-1">Revisa las tareas entregadas por tus alumnos de todos tus cursos.</p>
 </div>

 <div class="flex flex-col sm:flex-row gap-3">
 <div class="relative shadow-sm w-full sm:w-64">
 <Search :size="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-on-surface-variant" />
 <input id="search" name="search"
 v-model="search"
 type="text"
 placeholder="Buscar alumno o tarea..."
 class="w-full h-10 pl-9 pr-4 bg-surface-container-lowest border border-border rounded-lg text-sm text-on-surface outline-none focus:ring-2 focus:ring-primary/50"
 />
 </div>
 
 <div class="flex bg-surface-container-low p-1 rounded-lg">
 <button type="button"
 :class="['px-4 py-1.5 text-sm font-medium rounded-md transition-all', filtro === 'pendientes' ? 'bg-surface-container-lowest shadow-sm text-on-surface ' : 'text-on-surface-variant']"
 @click="filtro = 'pendientes'"
 >
 Pendientes ({{ docenteStore.pendientesCorreccion.length }})
 </button>
 <button type="button"
 :class="['px-4 py-1.5 text-sm font-medium rounded-md transition-all', filtro === 'revisadas' ? 'bg-surface-container-lowest shadow-sm text-on-surface ' : 'text-on-surface-variant']"
 @click="filtro = 'revisadas'"
 >
 Revisadas ({{ docenteStore.revisadas.length }})
 </button>
 </div>
 </div>
 </div>

 <!-- Lista de Entregas -->
 <div class="space-y-3">
 <BaseCard 
 v-for="entrega in entregasFiltradas" 
 :key="entrega.id" 
 hover
 class="cursor-pointer"
 @click="abrirCorreccion(entrega)"
 >
 <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
 <div class="flex items-center gap-4 min-w-0">
 <div class="w-12 h-12 rounded-full bg-primary-bg text-primary flex items-center justify-center font-bold text-xl flex-shrink-0">
 {{ (entrega as any)._alumno_nombre?.charAt(0) || 'A' }}
 </div>
 <div class="min-w-0">
 <div v-if="entrega.estado === 'revisado'" class="text-sm">
 <span class="font-medium text-on-surface">Calificación:</span> {{ entrega.calificacion }}
 </div>
 <div v-else-if="entrega.estado === 'tardio'" class="text-sm text-error">Entrega tardía</div>
 <p class="font-bold text-on-surface truncate">
 {{ (entrega as any)._alumno_nombre || 'Alumno' }}
 </p>
 <p class="text-sm text-on-surface-variant truncate">
 Tarea: {{ (entrega as any)._material_titulo || 'Sin título' }}
 </p>
 <div class="flex gap-2 mt-1.5">
 <BaseBadge :variant="filtro === 'pendientes' ? 'amber' : 'mint'" size="sm">
 {{ filtro === 'pendientes' ? 'Por revisar' : 'Revisada' }}
 </BaseBadge>
 <BaseBadge v-if="entrega.calificacion" variant="primary" size="sm">Nota: {{ entrega.calificacion }}</BaseBadge>
 </div>
 </div>
 </div>

 <BaseButton :variant="filtro === 'pendientes' ? 'primary' : 'secondary'" size="sm">
 {{ filtro === 'pendientes' ? 'Corregir' : 'Ver detalle' }}
 </BaseButton>
 </div>
 </BaseCard>

 <!-- Empty State -->
 <div v-if="entregasFiltradas.length === 0" class="text-center py-16 bg-surface-container-lowest shadow-sm rounded-2xl border border-border">
 <CheckCircle2 v-if="filtro === 'pendientes'" class="mx-auto text-secondary mb-4" :size="48" />
 <AlertCircle v-else class="mx-auto text-on-surface-variant mb-4" :size="48" />
 <h3 class="font-headline-md font-bold text-xl text-on-surface mb-2">
 {{ filtro === 'pendientes' ? 'Bandeja limpia' : 'Aún no has corregido tareas' }}
 </h3>
 <p class="text-sm text-on-surface-variant max-w-sm mx-auto">
 {{ filtro === 'pendientes' ? '¡Excelente! No tienes tareas urgentes por calificar en este momento. Tómate un descanso.' : 'Las tareas que califiques y envíes a tus alumnos aparecerán aquí.' }}
 </p>
 </div>
 </div>

 <!-- Modal de Corrección (Simplificado sin dialogs complejos por blueprint) -->
 <div v-if="selectedEntrega" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-text/50 backdrop-blur-sm animate-fade-in">
 <div class="bg-surface-container-lowest rounded-2xl w-full max-w-3xl shadow-modal overflow-hidden flex flex-col max-h-[90vh]">
 
 <!-- Header Modal -->
 <div class="p-4 border-b border-border flex items-center justify-between bg-surface-container-low">
 <div>
 <h2 class="font-bold text-on-surface">Corrección: {{ selectedEntrega._material_titulo }}</h2>
 <p class="text-xs text-on-surface-variant">Alumno: {{ selectedEntrega._alumno_nombre }}</p>
 </div>
 <button type="button" @click="selectedEntrega = null" class="p-2 text-on-surface-variant hover:bg-surface-container-lowest rounded-lg transition-colors">
 <X :size="20" />
 </button>
 </div>

 <!-- Body Modal -->
 <div class="p-6 overflow-y-auto flex-1 grid grid-cols-1 md:grid-cols-2 gap-6">
 
 <!-- Lado Izquierdo: Trabajo del Alumno -->
 <div class="space-y-4">
 <h3 class="font-semibold text-sm text-on-surface uppercase tracking-wider">Respuesta del Alumno</h3>
 <div class="p-4 bg-surface-container-low rounded-xl text-sm text-on-surface border border-border min-h-[150px] whitespace-pre-wrap">
 {{ selectedEntrega.contenido || 'No escribió texto.' }}
 </div>

 <div v-if="selectedEntrega.archivos && selectedEntrega.archivos.length > 0">
 <h3 class="font-semibold text-sm text-on-surface uppercase tracking-wider mb-2">Adjuntos</h3>
 <div class="space-y-2">
 <div v-for="(file, idx) in selectedEntrega.archivos" :key="idx" class="flex items-center justify-between p-3 bg-surface-container-low rounded-lg border border-border">
 <div class="flex items-center gap-2 overflow-hidden">
 <FileText :size="16" class="text-primary flex-shrink-0" />
 <span class="text-xs truncate font-medium text-on-surface">{{ file.nombre || 'Archivo.pdf' }}</span>
 </div>
 <button type="button" @click="descargarArchivo(file)" class="text-primary hover:text-primary-light p-1">
 <Download :size="16" />
 </button>
 </div>
 </div>
 </div>
 </div>

 <!-- Lado Derecho: Rúbrica y Corrección -->
 <div class="space-y-4 border-t md:border-t-0 md:border-l border-border md:pl-6 pt-4 md:pt-0">
 <div>
 <label class="block text-sm font-semibold text-on-surface mb-1">Nota (1.0 a 7.0)</label>
 <input id="nota" name="nota" 
 v-model="nota" 
 type="number" 
 min="1.0" 
 max="7.0" 
 step="0.1" 
 class="w-full bg-surface-container-low border border-border rounded-xl px-4 py-2.5 text-on-surface outline-none focus:ring-2 focus:ring-primary/50 text-xl font-bold"
 />
 </div>

 <div>
 <label class="block text-sm font-semibold text-on-surface mb-1">XP a otorgar (Gamificación)</label>
 <div class="flex items-center gap-2">
 <input id="xpOtorgado" name="xpOtorgado" 
 v-model="xpOtorgado" 
 type="number" 
 step="10" 
 class="flex-1 bg-surface-container-low border border-border rounded-xl px-4 py-2.5 text-on-surface outline-none focus:ring-2 focus:ring-primary/50 font-bold"
 />
 <span class="text-primary font-bold">XP</span>
 </div>
 <p class="text-xs text-on-surface-variant mt-1">El alumno recibirá el 40% del XP en monedas de regalo 🪙.</p>
 </div>

 <div>
 <label class="block text-sm font-semibold text-on-surface mb-1">Feedback Privado (Opcional)</label>
 <textarea id="feedback" name="feedback" 
 v-model="feedback" 
 rows="4" 
 placeholder="Escribe comentarios constructivos sobre su trabajo..."
 class="w-full bg-surface-container-low border border-border rounded-xl px-4 py-3 text-sm text-on-surface outline-none focus:ring-2 focus:ring-primary/50 resize-none"
 ></textarea>
 </div>
 </div>

 </div>

 <!-- Footer Modal -->
 <div class="p-4 border-t border-border bg-surface-container-low flex justify-end gap-3">
 <BaseButton variant="ghost" @click="selectedEntrega = null">Cancelar</BaseButton>
 <BaseButton variant="primary" :loading="guardando" @click="guardarCorreccion">
 <CheckCircle2 :size="16" class="mr-2" /> Guardar y Sincronizar
 </BaseButton>
 </div>

 </div>
 </div>
 </div>
</template>
