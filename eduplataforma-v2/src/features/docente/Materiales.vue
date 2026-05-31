<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useDocenteStore } from '@/stores/docente'
import { useAuthStore } from '@/stores/auth'
import { idb } from '@/services/idb'
import { useAppStore } from '@/stores/app'
import { useSync } from '@/composables/useSync'
import BaseButton from '@/components/ui/BaseButton.vue'
import { FileText, Upload, Plus, DownloadCloud, FileVideo, FilePlus, Eye, Download, Search } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

const docenteStore = useDocenteStore()
const authStore = useAuthStore()
const appStore = useAppStore()
const { syncAhora } = useSync()

const search = ref('')
const filterCurso = ref('')
const showUploadModal = ref(false)
const isEditing = ref(false)

const newMaterial = ref({
  id: '',
  titulo: '',
  curso_id: '',
  tipo: 'guia',
  descripcion: '',
  archivo_url: '',
  archivos: [] as any[],
  es_tarea: false,
  xp_base: 50,
  fecha_vencimiento: ''
})
const subiendo = ref(false)


const materialesList = computed(() => {
  let list = docenteStore.materiales || []
  if (filterCurso.value) {
    list = list.filter(m => m.curso_id === filterCurso.value)
  }
  if (search.value) {
    const s = search.value.toLowerCase()
    list = list.filter(m => m.titulo?.toLowerCase().includes(s))
  }
  return list.sort((a, b) => new Date(b.creado_en).getTime() - new Date(a.creado_en).getTime())
})

// La carga ya la hace el panel general/layout de docente, así que no es estrictamente necesario, 
// pero podemos tener un botón de recarga si lo desean.

async function guardarMaterial() {
  if (!newMaterial.value.titulo || !newMaterial.value.curso_id) {
    appStore.addToast({ tipo: 'error', mensaje: 'Faltan campos obligatorios' })
    return
  }
  
  subiendo.value = true
  try {
    const { es_tarea, xp_base, fecha_vencimiento, ...rest } = newMaterial.value
    
    const payload = JSON.parse(JSON.stringify({
      ...rest,
      docente_id: authStore.user?.id,
      archivo_nombre: rest.tipo === 'enlace' ? 'Enlace Externo' : 'Documento Externo',
      publicado: true,
      xp_premio: es_tarea ? xp_base : 0,
      fecha_entrega: es_tarea && fecha_vencimiento ? new Date(fecha_vencimiento).toISOString() : null,
      creado_en: new Date().toISOString()
    }))

    if (isEditing.value) {
      payload.id = newMaterial.value.id
      
      await idb.put('sync_queue', {
        id: crypto.randomUUID(),
        tipo: 'material',
        accion: 'update',
        tabla: 'materiales',
        payload,
        intentos: 0,
        creado_en: Date.now(),
        ultimo_intento: null,
        error_msg: null
      })
      appStore.addToast({ tipo: 'info', mensaje: 'Material actualizado. Se sincronizará pronto.' })
      
      const idx = docenteStore.materiales.findIndex(m => m.id === payload.id)
      if (idx !== -1) docenteStore.materiales[idx] = { ...docenteStore.materiales[idx], ...payload }
    } else {
      payload.id = crypto.randomUUID()
      await idb.put('sync_queue', {
        id: crypto.randomUUID(),
        tipo: 'material',
        accion: 'insert',
        tabla: 'materiales',
        payload,
        intentos: 0,
        creado_en: Date.now(),
        ultimo_intento: null,
        error_msg: null
      })
      appStore.addToast({ tipo: 'info', mensaje: 'Material creado. Se sincronizará pronto.' })
      docenteStore.materiales.push({ ...payload, visualizaciones: 0, descargas: 0, curso: docenteStore.cursos.find(c => c.id === payload.curso_id) })
    }
    
    showUploadModal.value = false
    
    // Auto-sync background
    syncAhora()

    // Reset
    newMaterial.value = {
      id: '',
      titulo: '',
      curso_id: '',
      tipo: 'guia',
      descripcion: '',
      archivo_url: '',
      archivos: [],
      es_tarea: false,
      xp_base: 50,
      fecha_vencimiento: ''
    }
    isEditing.value = false
  } catch (error: any) {
    appStore.addToast({ tipo: 'error', mensaje: error.message || 'Error al guardar el material' })
  } finally {
    subiendo.value = false
  }
}

function openCreateModal() {
  isEditing.value = false
  newMaterial.value = { id: '', titulo: '', curso_id: '', tipo: 'guia', descripcion: '', archivo_url: '', archivos: [], es_tarea: false, xp_base: 50, fecha_vencimiento: '' }
  showUploadModal.value = true
}

function openEditModal(mat: any) {
  isEditing.value = true
  newMaterial.value = {
    id: mat.id,
    titulo: mat.titulo,
    curso_id: mat.curso_id,
    tipo: mat.tipo,
    descripcion: mat.descripcion || '',
    archivo_url: mat.archivo_url || '',
    archivos: mat.archivos || [],
    es_tarea: mat.xp_premio > 0,
    xp_base: mat.xp_premio || 50,
    fecha_vencimiento: mat.fecha_entrega ? new Date(mat.fecha_entrega).toISOString().slice(0, 16) : ''
  }
  showUploadModal.value = true
}

async function eliminarMaterial(id: string) {
  if (!confirm('¿Seguro que deseas eliminar este material?')) return
  try {
    await idb.put('sync_queue', {
      id: crypto.randomUUID(),
      tipo: 'material',
      accion: 'delete',
      tabla: 'materiales',
      payload: { id },
      intentos: 0,
      creado_en: Date.now(),
      ultimo_intento: null,
      error_msg: null
    })
    docenteStore.materiales = docenteStore.materiales.filter(m => m.id !== id)
    appStore.addToast({ tipo: 'success', mensaje: 'Material eliminado. Se sincronizará pronto.' })
    syncAhora()
  } catch (error: any) {
    alert('Error crítico al eliminar material: ' + error.message)
    appStore.addToast({ tipo: 'error', mensaje: 'Error al eliminar material' })
  }
}

async function handleFileUpload(event: Event) {
  const target = event.target as HTMLInputElement
  if (!target.files?.length) return

  const MAX_SIZE_MB = 5
  for (let i = 0; i < target.files.length; i++) {
    const file = target.files[i]
    if (file.size > MAX_SIZE_MB * 1024 * 1024) {
      appStore.addToast({ tipo: 'error', mensaje: `El archivo ${file.name} supera el límite de ${MAX_SIZE_MB}MB` })
      continue
    }

    const reader = new FileReader()
    reader.onload = (e) => {
      newMaterial.value.archivos.push({
        nombre: file.name,
        tipo: file.type,
        data: e.target?.result as string
      })
    }
    reader.readAsDataURL(file)
  }
}

function removeArchivo(index: number) {
  newMaterial.value.archivos.splice(index, 1)
}
</script>

<template>
  <div class="p-4 md:p-6 space-y-6 animate-fade-in max-w-6xl mx-auto">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
      <div>
        <h1 class="font-display font-extrabold text-2xl md:text-3xl text-text dark:text-dark-text">📚 Materiales</h1>
        <p class="text-sm text-text-muted mt-1">Sube archivos, guías y crea tareas para tus alumnos.</p>
      </div>
      <BaseButton @click="openCreateModal" class="flex-shrink-0">
        <Plus :size="18" />
        Subir Material
      </BaseButton>
    </div>

    <!-- Lista -->
    <div class="bg-card dark:bg-dark-card border border-border dark:border-white/10 rounded-2xl shadow-sm overflow-hidden">
      <div class="p-4 border-b border-border dark:border-white/10 bg-surface dark:bg-dark-card2 flex flex-col sm:flex-row items-center gap-3">
        <div class="relative w-full sm:w-64">
          <Search :size="18" class="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted" />
          <input 
            v-model="search"
            type="text" 
            placeholder="Buscar material..." 
            class="w-full h-9 pl-9 pr-4 bg-card dark:bg-dark-bg border border-border dark:border-white/10 rounded-lg text-sm outline-none focus:ring-2 focus:ring-primary/50"
          />
        </div>
        <select v-model="filterCurso" class="w-full sm:w-48 h-9 px-3 bg-card dark:bg-dark-bg border border-border dark:border-white/10 rounded-lg text-sm outline-none">
          <option value="">Todos los cursos</option>
          <option v-for="c in docenteStore.cursos" :key="c.id" :value="c.id">{{ c.nombre }}</option>
        </select>
      </div>
      
      <div class="divide-y divide-border dark:divide-white/10">
        <div v-if="docenteStore.loading" class="p-8 text-center text-text-muted">Cargando materiales...</div>
        <div v-else-if="materialesList.length === 0" class="p-8 text-center text-text-muted">No has subido ningún material aún.</div>
        
        <div v-else v-for="mat in materialesList" :key="mat.id" class="p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-4 hover:bg-surface dark:hover:bg-dark-card2 transition-colors">
          <div class="flex items-start sm:items-center gap-4 min-w-0">
            <div class="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0" :class="mat.tipo === 'video' ? 'bg-amber-bg text-amber' : mat.tipo === 'enlace' ? 'bg-violet-bg text-violet' : 'bg-primary-bg text-primary'">
              <FileVideo v-if="mat.tipo === 'video'" :size="20" />
              <FilePlus v-else-if="mat.tipo === 'enlace'" :size="20" />
              <FileText v-else :size="20" />
            </div>
            <div>
              <p class="font-semibold text-text dark:text-dark-text text-sm sm:text-base">{{ mat.titulo }}</p>
              <div class="flex flex-wrap items-center gap-2 text-xs mt-1">
                <span class="text-text-muted font-medium">{{ docenteStore.cursos.find(c => c.id === mat.curso_id)?.nombre || 'Curso' }}</span>
                <span class="text-text-light">&bull;</span>
                <span class="text-text-muted">{{ new Date(mat.creado_en).toLocaleDateString() }}</span>
                <span v-if="mat.es_tarea" class="text-mint font-bold uppercase text-[10px] px-1.5 py-0.5 rounded bg-mint-bg">Tarea</span>
              </div>
            </div>
          </div>
          
          <div class="flex items-center gap-6 sm:ml-auto">
            <div class="flex items-center gap-4 text-xs text-text-muted font-medium">
              <span class="flex items-center gap-1" title="Vistas"><Eye :size="14" /> {{ mat.visualizaciones || 0 }}</span>
              <span v-if="mat.tipo !== 'video' && mat.tipo !== 'enlace'" class="flex items-center gap-1" title="Descargas"><Download :size="14" /> {{ mat.descargas || 0 }}</span>
            </div>
            <div class="flex gap-2">
              <BaseButton variant="ghost" size="sm" @click="openEditModal(mat)">Editar</BaseButton>
              <BaseButton variant="ghost" size="sm" class="text-danger hover:bg-danger/10" @click="eliminarMaterial(mat.id)">Eliminar</BaseButton>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Subida -->
    <div v-if="showUploadModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-text/50 dark:bg-dark-bg/80 backdrop-blur-sm animate-fade-in">
      <div class="bg-card dark:bg-dark-card rounded-2xl w-full max-w-lg shadow-modal overflow-hidden flex flex-col max-h-[90vh]">
        <div class="p-4 border-b border-border dark:border-white/10 bg-surface dark:bg-dark-card2 flex justify-between items-center">
          <h2 class="font-bold text-text dark:text-dark-text">{{ isEditing ? 'Editar Material' : 'Subir Nuevo Material' }}</h2>
        </div>
        
        <div class="p-6 overflow-y-auto space-y-4">
          <div>
            <label class="block text-sm font-semibold mb-1">Título</label>
            <input v-model="newMaterial.titulo" type="text" class="w-full bg-surface dark:bg-dark-card2 border border-border dark:border-white/10 rounded-xl px-4 py-2.5 outline-none focus:ring-2 focus:ring-primary/50" />
          </div>
          
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-semibold mb-1">Curso</label>
              <select v-model="newMaterial.curso_id" class="w-full bg-surface dark:bg-dark-card2 border border-border dark:border-white/10 rounded-xl px-4 py-2.5 outline-none">
                <option value="" disabled>Selecciona...</option>
                <option v-for="c in docenteStore.cursos" :key="c.id" :value="c.id">{{ c.nombre }}</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-semibold mb-1">Tipo</label>
              <select v-model="newMaterial.tipo" class="w-full bg-surface dark:bg-dark-card2 border border-border dark:border-white/10 rounded-xl px-4 py-2.5 outline-none">
                <option value="guia">PDF / Word (Google Drive)</option>
                <option value="video">Video (YouTube/Drive)</option>
                <option value="enlace">Enlace Web General</option>
              </select>
            </div>
          </div>

          <div>
            <label class="block text-sm font-semibold mb-1">URL / Enlace del Material</label>
            <input v-model="newMaterial.archivo_url" type="url" placeholder="https://..." class="w-full bg-surface dark:bg-dark-card2 border border-border dark:border-white/10 rounded-xl px-4 py-2.5 outline-none focus:ring-2 focus:ring-primary/50" />
            <p class="text-xs text-text-muted mt-1">Opcional. Pega aquí el enlace de Google Drive, YouTube u otra plataforma pública.</p>
          </div>

          <div>
            <label class="block text-sm font-semibold mb-1">Archivos Adjuntos (Max 5MB)</label>
            <label class="flex flex-col items-center justify-center w-full h-24 border-2 border-dashed border-primary/30 rounded-xl cursor-pointer bg-primary/5 hover:bg-primary/10 transition-colors">
              <div class="flex flex-col items-center justify-center pt-5 pb-6">
                <Upload :size="24" class="text-primary mb-2" />
                <p class="text-sm text-text-muted"><span class="font-bold text-primary">Haz clic para subir</span> o arrastra y suelta</p>
              </div>
              <input type="file" class="hidden" multiple @change="handleFileUpload" />
            </label>

            <!-- Lista de Archivos -->
            <div v-if="newMaterial.archivos.length > 0" class="mt-3 space-y-2">
              <div v-for="(file, idx) in newMaterial.archivos" :key="idx" class="flex items-center justify-between p-2 bg-surface dark:bg-dark-card2 rounded-lg border border-border dark:border-white/10">
                <div class="flex items-center gap-2 overflow-hidden">
                  <FileText :size="16" class="text-primary flex-shrink-0" />
                  <span class="text-xs truncate font-medium text-text dark:text-dark-text">{{ file.nombre }}</span>
                </div>
                <button @click="removeArchivo(idx)" class="text-danger hover:text-danger/80 px-2 font-bold">&times;</button>
              </div>
            </div>
          </div>

          <label class="flex items-center gap-2 p-3 bg-primary-bg dark:bg-primary/10 border border-primary/20 rounded-xl cursor-pointer hover:bg-primary/20 transition-colors">
            <input v-model="newMaterial.es_tarea" type="checkbox" class="w-4 h-4 text-primary rounded focus:ring-primary" />
            <div>
              <span class="font-bold text-sm text-primary dark:text-primary-light">Activar Buzón de Entrega (Es Tarea)</span>
              <p class="text-xs text-primary/70">Permite que el alumno suba su archivo resuelto y reciba calificación/XP.</p>
            </div>
          </label>

          <div v-if="newMaterial.es_tarea" class="grid grid-cols-2 gap-4 animate-fade-in">
            <div>
              <label class="block text-sm font-semibold mb-1">XP al Entregar</label>
              <input v-model="newMaterial.xp_base" type="number" step="10" class="w-full bg-surface dark:bg-dark-card2 border border-border dark:border-white/10 rounded-xl px-4 py-2.5 outline-none" />
            </div>
            <div>
              <label class="block text-sm font-semibold mb-1">Vencimiento</label>
              <input v-model="newMaterial.fecha_vencimiento" type="datetime-local" class="w-full bg-surface dark:bg-dark-card2 border border-border dark:border-white/10 rounded-xl px-4 py-2.5 outline-none" />
            </div>
          </div>


        </div>

        <div class="p-4 border-t border-border dark:border-white/10 bg-surface dark:bg-dark-card2 flex justify-end gap-3">
          <BaseButton variant="ghost" @click="showUploadModal = false">Cancelar</BaseButton>
          <BaseButton variant="primary" :loading="subiendo" @click="guardarMaterial">Guardar Material</BaseButton>
        </div>
      </div>
    </div>
  </div>
</template>
