<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useCursosStore } from '@/stores/cursos'
import { useTareasStore } from '@/stores/tareas'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import { supabase } from '@/services/supabase'
import { useAuthStore } from '@/stores/auth'
import { 
  ChevronLeft, Send, CheckCircle2, Clock, DownloadCloud
} from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()
const cursosStore = useCursosStore()
const tareasStore = useTareasStore()
const authStore = useAuthStore()

const cursoId = route.params.id as string
const activeTab = ref<'tareas' | 'materiales' | 'comunidad'>('tareas')
const mensajes = ref<any[]>([])
const nuevoMensaje = ref('')
const loadingMensajes = ref(false)

const showEntregaModal = ref(false)
const tareaActiva = ref<any>(null)
const entregaForm = ref({ archivo_url: '', archivos: [] as any[] })
const entregando = ref(false)

function abrirEntrega(tarea: any) {
  tareaActiva.value = tarea
  entregaForm.value = { archivo_url: '', archivos: [] }
  showEntregaModal.value = true
}

async function handleEntregaFileUpload(event: Event) {
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
      entregaForm.value.archivos.push({
        nombre: file.name,
        tipo: file.type,
        data: e.target?.result as string
      })
    }
    reader.readAsDataURL(file)
  }
}

function removeEntregaArchivo(index: number) {
  entregaForm.value.archivos.splice(index, 1)
}

async function enviarEntrega() {
  if (!newUrl.value.trim() && !fileInput.value?.files?.length) {
    appStore.addToast({ tipo: 'error', mensaje: 'Debes añadir un enlace o un archivo.' })
    return
  }
  entregando.value = true
  try {
    const payload = JSON.parse(JSON.stringify({
      id: crypto.randomUUID(),
      material_id: tareaActiva.value.id,
      alumno_id: authStore.user?.id,
      archivo_url: newUrl.value,
      archivos: entregaForm.value.archivos,
      estado: 'entregado',
      sincronizado: false,
      entregado_en: new Date().toISOString()
    }))
    
    // Add to sync queue for offline support
    await import('@/services/idb').then(m => m.idb.put('sync_queue', {
      id: crypto.randomUUID(),
      tipo: 'entrega',
      accion: 'insert',
      tabla: 'entregas',
      payload,
      intentos: 0,
      creado_en: Date.now(),
      ultimo_intento: null,
      error_msg: null
    }))
    
    // Update local store immediately for optimistic UI
    tareasStore.entregas.push(payload)
    showEntregaModal.value = false
    appStore.addToast({ tipo: 'success', mensaje: '¡Tarea entregada! Se subirá a la nube.' })
    uploading.value = false
    entregando.value = false
  } catch (e) {
    entregando.value = false
  }
}

onMounted(async () => {
  // Asegurar que haya cargado el curso
  if (!cursosStore.getCurso(cursoId)) {
    // Aquí podríamos forzar la carga si venimos por URL directa
  }
  await cursosStore.cargarMateriales(cursoId)
})

const curso = computed(() => cursosStore.getCurso(cursoId))
const materiales = computed(() => cursosStore.materiales[cursoId] || [])

// Todas las tareas de este curso (materiales con tipo = 'tarea' o xp_premio > 0)
const tareasDelCurso = computed(() => {
  return materiales.value.filter(m => m.tipo === 'tarea' || (m as any).xp_premio > 0).map(mat => {
    // Buscar si el alumno ya entregó
    const entrega = tareasStore.entregas.find(e => e.material_id === mat.id)
    return {
      ...mat,
      estado_entrega: entrega?.estado || 'pendiente',
      entrega_id: entrega?.id
    }
  })
})

function getIcon(tipo: string) {
  switch (tipo) {
    case 'guia': return '📄'
    case 'video': return '🎥'
    case 'enlace': return '🔗'
    default: return '📁'
  }
}

async function loadMensajes() {
  loadingMensajes.value = true
  const { data } = await supabase
    .from('mensajes')
    .select('id, contenido, creado_en, autor:perfiles(nombre, avatar_url, rol)')
    .eq('curso_id', cursoId)
    .order('creado_en', { ascending: true })
  mensajes.value = data || []
  loadingMensajes.value = false
}

async function enviarMensaje() {
  if (!nuevoMensaje.value.trim() || !authStore.perfil) return
  const msg = nuevoMensaje.value.trim()
  nuevoMensaje.value = ''
  
  mensajes.value.push({
    id: Math.random().toString(),
    contenido: msg,
    creado_en: new Date().toISOString(),
    autor: {
      nombre: authStore.perfil.nombre,
      avatar_url: authStore.perfil.avatar_url,
      rol: authStore.perfil.rol
    }
  })

  await supabase.from('mensajes').insert({
    curso_id: cursoId,
    autor_id: authStore.perfil.id,
    contenido: msg
  })
  
  loadMensajes()
}

import { watch } from 'vue'
watch(activeTab, (val) => {
  if (val === 'comunidad') {
    loadMensajes()
  }
})

function descargarArchivo(archivo: any) {
  try {
    const a = document.createElement('a')
    a.href = archivo.data
    a.download = archivo.nombre
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
  } catch (error) {
    console.error('Error al descargar:', error)
    appStore.addToast({ tipo: 'error', mensaje: 'No se pudo descargar el archivo' })
  }
}
</script>

<template>
  <div v-if="curso" class="p-4 md:p-6 animate-fade-in max-w-4xl mx-auto">
    <!-- Breadcrumb & Cabecera -->
    <button 
      class="flex items-center gap-1 text-sm text-text-muted hover:text-text mb-4 transition-colors"
      @click="router.back()"
    >
      <ChevronLeft :size="16" /> Volver a cursos
    </button>
    
    <div 
      class="rounded-2xl p-6 md:p-8 text-white relative overflow-hidden shadow-card mb-6"
      :style="{ backgroundColor: curso.color || '#1a6fa8' }"
    >
      <div class="relative z-10 flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div>
          <BaseBadge variant="neutral" class="mb-3 bg-white/20 text-white dark:bg-white/20 dark:text-white border-0">{{ curso.nivel }}</BaseBadge>
          <h1 class="font-display font-extrabold text-3xl md:text-4xl">
            {{ curso.icono }} {{ curso.nombre }}
          </h1>
          <p v-if="curso.docente_id" class="text-white/80 text-sm mt-2 font-medium">
            👨‍🏫 Prof. {{ (curso as any).docente?.nombre || curso.docente_id }}
          </p>
        </div>
      </div>
      <!-- Decorative circle -->
      <div class="absolute -top-20 -right-20 w-64 h-64 bg-white/10 rounded-full blur-2xl pointer-events-none" />
    </div>

    <!-- Tabs Navigation -->
    <div class="flex items-center gap-2 border-b border-border dark:border-white/10 mb-6 overflow-x-auto">
      <button 
        v-for="tab in [{ id: 'tareas', label: '📝 Tareas' }, { id: 'materiales', label: '📚 Materiales' }, { id: 'comunidad', label: '💬 Comunidad' }]"
        :key="tab.id"
        :class="[
          'px-4 py-3 text-sm font-semibold border-b-2 transition-colors',
          activeTab === tab.id 
            ? 'border-primary text-primary dark:text-primary-light' 
            : 'border-transparent text-text-muted hover:text-text dark:text-dark-muted dark:hover:text-dark-text'
        ]"
        @click="activeTab = tab.id as any"
      >
        {{ tab.label }}
      </button>
    </div>

    <!-- Contenido Tareas -->
    <div v-if="activeTab === 'tareas'" class="space-y-3">
      <BaseCard v-for="tarea in tareasDelCurso" :key="tarea.id" hover class="border-l-4" :style="{ borderLeftColor: curso.color || '#1a6fa8' }">
        <div class="flex items-start justify-between">
          <div class="flex items-start gap-3">
            <div class="mt-0.5 p-2 rounded-lg" :class="tarea.estado_entrega === 'pendiente' ? 'bg-amber-bg text-amber' : 'bg-mint-bg text-mint'">
              <Clock v-if="tarea.estado_entrega === 'pendiente'" :size="20" />
              <CheckCircle2 v-else :size="20" />
            </div>
            <div>
              <p class="font-medium text-text dark:text-dark-text text-base">{{ tarea.titulo }}</p>
              <div class="flex items-center gap-2 mt-1.5">
                <BaseBadge :variant="tarea.estado_entrega === 'pendiente' ? 'amber' : 'mint'">
                  {{ tarea.estado_entrega.toUpperCase() }}
                </BaseBadge>
                <span class="text-xs font-semibold text-primary" v-if="tarea.xp_premio">+{{ tarea.xp_premio }} XP</span>
              </div>
            </div>
          </div>
          <BaseButton size="sm" :variant="tarea.estado_entrega === 'pendiente' ? 'primary' : tarea.estado_entrega === 'revisado' ? 'ghost' : 'secondary'" @click="abrirEntrega(tarea)">
            {{ tarea.estado_entrega === 'pendiente' ? 'Entregar' : tarea.estado_entrega === 'revisado' ? 'Ver Corrección' : 'Actualizar' }}
          </BaseButton>
        </div>
      </BaseCard>
      
      <div v-if="tareasDelCurso.length === 0 && !cursosStore.loading" class="text-center py-10 bg-surface dark:bg-dark-card2 rounded-xl">
        <p class="text-4xl mb-2">🎉</p>
        <p class="font-medium text-text dark:text-dark-text">¡Estás al día!</p>
        <p class="text-sm text-text-muted">No tienes tareas asignadas en este curso.</p>
      </div>
    </div>

    <!-- Contenido Materiales -->
    <div v-if="activeTab === 'materiales'" class="grid grid-cols-1 md:grid-cols-2 gap-3">
      <div v-for="mat in materiales" :key="mat.id" class="block outline-none">
        <BaseCard class="h-full">
        <div class="flex items-start gap-3">
          <div class="w-12 h-12 bg-primary-bg dark:bg-primary/10 rounded-xl flex items-center justify-center text-2xl flex-shrink-0">
            {{ getIcon(mat.tipo) }}
          </div>
          <div class="min-w-0 flex-1">
            <p class="font-semibold text-text dark:text-dark-text truncate">{{ mat.titulo }}</p>
            <p class="text-xs text-text-muted mt-0.5 line-clamp-1">{{ mat.descripcion || 'Sin descripción' }}</p>
            <div class="flex flex-wrap items-center gap-2 mt-2">
              <BaseBadge size="sm" variant="primary">{{ mat.tipo }}</BaseBadge>
              <a v-if="mat.archivo_url" :href="mat.archivo_url" target="_blank" rel="noopener noreferrer" class="text-[10px] text-primary font-bold hover:underline bg-primary/10 px-2 py-0.5 rounded-lg flex items-center">
                🔗 Enlace
              </a>
              <button v-for="(arch, idx) in mat.archivos" :key="idx" @click.stop="descargarArchivo(arch)" class="text-[10px] text-mint font-bold hover:underline bg-mint/10 px-2 py-0.5 rounded-lg flex items-center">
                <DownloadCloud :size="12" class="mr-1 inline" /> {{ arch.nombre }}
              </button>
            </div>
          </div>
        </div>
      </BaseCard>
      </div>
      
      <div v-if="materiales.length === 0 && !cursosStore.loading" class="col-span-full text-center py-10 bg-surface dark:bg-dark-card2 rounded-xl">
        <p class="text-4xl mb-2">📚</p>
        <p class="font-medium text-text dark:text-dark-text">Sin material</p>
        <p class="text-sm text-text-muted">El docente aún no ha subido material para este curso.</p>
      </div>
    </div>

    <!-- Contenido Comunidad (Chat) -->
    <div v-if="activeTab === 'comunidad'" class="flex flex-col h-[500px] bg-card dark:bg-dark-card border border-border dark:border-white/10 rounded-2xl overflow-hidden">
      <!-- Lista de Mensajes -->
      <div class="flex-1 overflow-y-auto p-4 space-y-4 bg-surface/50 dark:bg-dark-card2/50">
        <div v-if="loadingMensajes && mensajes.length === 0" class="text-center py-4 text-text-muted">
          Cargando mensajes...
        </div>
        <div v-else-if="mensajes.length === 0" class="text-center py-10">
          <p class="text-4xl mb-2">👋</p>
          <p class="font-medium text-text dark:text-dark-text">¡Sé el primero en saludar!</p>
          <p class="text-sm text-text-muted">Escribe un mensaje para tu clase.</p>
        </div>
        
        <div 
          v-for="msg in mensajes" 
          :key="msg.id" 
          :class="['flex gap-3 max-w-[85%]', msg.autor?.nombre === authStore.perfil?.nombre ? 'ml-auto flex-row-reverse' : 'mr-auto']"
        >
          <div class="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-white text-xs font-bold overflow-hidden flex-shrink-0 mt-1">
            <img v-if="msg.autor?.avatar_url && (msg.autor.avatar_url.startsWith('http') || msg.autor.avatar_url.startsWith('data'))" :src="msg.autor.avatar_url" class="w-full h-full object-cover" />
            <span v-else-if="msg.autor?.avatar_url" class="text-sm">{{ msg.autor.avatar_url }}</span>
            <span v-else>{{ msg.autor?.nombre?.charAt(0) || 'U' }}</span>
          </div>
          <div :class="['flex flex-col', msg.autor?.nombre === authStore.perfil?.nombre ? 'items-end' : 'items-start']">
            <div class="flex items-baseline gap-2 mb-1">
              <span class="text-xs font-bold text-text dark:text-dark-text">{{ msg.autor?.nombre }}</span>
              <span v-if="msg.autor?.rol === 'docente'" class="text-[9px] bg-mint text-white px-1.5 py-0.5 rounded uppercase font-bold">Docente</span>
              <span class="text-[10px] text-text-muted">{{ new Date(msg.creado_en).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) }}</span>
            </div>
            <div :class="['px-4 py-2 rounded-2xl text-sm shadow-sm', 
              msg.autor?.nombre === authStore.perfil?.nombre 
                ? 'bg-primary text-white rounded-tr-none' 
                : 'bg-white dark:bg-dark-card text-text dark:text-dark-text border border-border dark:border-white/10 rounded-tl-none'
            ]">
              {{ msg.contenido }}
            </div>
          </div>
        </div>
      </div>

      <!-- Input Área -->
      <div class="p-4 bg-surface dark:bg-dark-card2 border-t border-border dark:border-white/10">
        <form @submit.prevent="enviarMensaje" class="flex gap-2">
          <input 
            v-model="nuevoMensaje"
            type="text" 
            placeholder="Escribe tu mensaje..."
            class="flex-1 bg-card dark:bg-dark-bg border border-border dark:border-white/10 rounded-xl px-4 py-2 outline-none focus:ring-2 focus:ring-primary/50 text-sm"
          />
          <BaseButton type="submit" variant="primary" size="sm" class="px-4 shrink-0 rounded-xl">
            <Send :size="16" />
          </BaseButton>
        </form>
      </div>
    </div>

    <!-- Modal Entregar Tarea -->
    <div v-if="showEntregaModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-text/50 dark:bg-dark-bg/80 backdrop-blur-sm animate-fade-in">
      <div class="bg-card dark:bg-dark-card rounded-2xl w-full max-w-md shadow-modal p-6 relative max-h-[90vh] overflow-y-auto">
        <h2 class="font-bold text-xl mb-3 text-text dark:text-dark-text">Entregar: {{ tareaActiva?.titulo }}</h2>
        <p class="text-sm text-text-muted mb-5">Puedes pegar un enlace (Drive, YouTube) o subir un archivo directamente desde tu equipo.</p>
        
        <label class="block text-sm font-semibold mb-1.5">Enlace del trabajo (Opcional)</label>
        <input 
          v-model="entregaForm.archivo_url" 
          type="url" 
          placeholder="https://..." 
          class="w-full bg-surface dark:bg-dark-card2 border border-border dark:border-white/10 rounded-xl px-4 py-3 outline-none focus:ring-2 focus:ring-primary/50 mb-4 text-sm" 
        />

        <label class="block text-sm font-semibold mb-1">Archivos Adjuntos (Max 5MB)</label>
        <label class="flex flex-col items-center justify-center w-full h-24 border-2 border-dashed border-primary/30 rounded-xl cursor-pointer bg-primary/5 hover:bg-primary/10 transition-colors">
          <div class="flex flex-col items-center justify-center pt-5 pb-6">
            <span class="text-2xl mb-1 text-primary">📤</span>
            <p class="text-sm text-text-muted"><span class="font-bold text-primary">Haz clic para subir</span> o arrastra aquí</p>
          </div>
          <input type="file" class="hidden" multiple @change="handleEntregaFileUpload" />
        </label>

        <!-- Lista de Archivos -->
        <div v-if="entregaForm.archivos.length > 0" class="mt-3 space-y-2 mb-6">
          <div v-for="(file, idx) in entregaForm.archivos" :key="idx" class="flex items-center justify-between p-2 bg-surface dark:bg-dark-card2 rounded-lg border border-border dark:border-white/10">
            <div class="flex items-center gap-2 overflow-hidden">
              <span class="text-lg">📄</span>
              <span class="text-xs truncate font-medium text-text dark:text-dark-text">{{ file.nombre }}</span>
            </div>
            <button @click="removeEntregaArchivo(idx)" class="text-danger hover:text-danger/80 px-2 font-bold">&times;</button>
          </div>
        </div>
        
        <div class="flex justify-end gap-3 mt-6">
          <BaseButton variant="ghost" @click="showEntregaModal = false">Cancelar</BaseButton>
          <BaseButton variant="primary" :loading="entregando" @click="enviarEntrega" :disabled="!entregaForm.archivo_url && entregaForm.archivos.length === 0">
            Enviar Tarea
          </BaseButton>
        </div>
      </div>
    </div>
  </div>
  
  <div v-else-if="cursosStore.loading" class="p-6 text-center text-text-muted">
    Cargando curso...
  </div>
</template>
