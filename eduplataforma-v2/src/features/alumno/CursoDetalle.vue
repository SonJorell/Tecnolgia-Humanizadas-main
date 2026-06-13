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
import { useAppStore } from '@/stores/app'
import { 
  ChevronLeft, Send, CheckCircle2, Clock, DownloadCloud
} from 'lucide-vue-next'
import { sanitizeText, containsProfanity } from '@/utils/profanityFilter'

const route = useRoute()
const router = useRouter()
const cursosStore = useCursosStore()
const tareasStore = useTareasStore()
const authStore = useAuthStore()
const appStore = useAppStore()

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
  if (!entregaForm.value.archivo_url.trim() && !entregaForm.value.archivos.length) {
    appStore.addToast({ tipo: 'error', mensaje: 'Debes añadir un enlace o un archivo.' })
    return
  }
  entregando.value = true
  try {
    const payload = JSON.parse(JSON.stringify({
      id: crypto.randomUUID(),
      material_id: tareaActiva.value.id,
      alumno_id: authStore.user?.id,
      archivo_url: entregaForm.value.archivo_url,
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
  let msg = nuevoMensaje.value.trim()
  
  if (containsProfanity(msg)) {
    appStore.addToast({ tipo: 'error', mensaje: 'Por favor, mantén un lenguaje respetuoso. Tu mensaje ha sido filtrado.' })
    msg = sanitizeText(msg)
  }
  
  nuevoMensaje.value = ''
  
  // En lugar de inserción optimista falsa, esperamos el retorno real para evitar conflictos de ID
  const { data: insertedMsg, error } = await supabase.from('mensajes').insert({
    curso_id: cursoId,
    autor_id: authStore.perfil.id,
    contenido: msg
  }).select('id, contenido, creado_en, autor:perfiles(nombre, avatar_url, rol)').single()

  if (!error && insertedMsg) {
    if (!mensajes.value.some((m: any) => m.id === insertedMsg.id)) {
      mensajes.value.push(insertedMsg)
      setTimeout(() => {
        const container = document.querySelector('.flex-1.overflow-y-auto')
        if (container) container.scrollTop = container.scrollHeight
      }, 50)
    }
  }
}

import { watch, onUnmounted } from 'vue'

let chatSubscription: any = null

function subscribeToChat() {
  if (chatSubscription) return
  chatSubscription = supabase
    .channel(`curso_${cursoId}`)
    .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'mensajes', filter: `curso_id=eq.${cursoId}` }, async payload => {
      // Buscamos el mensaje con sus relaciones (autor)
      const { data } = await supabase
        .from('mensajes')
        .select('id, contenido, creado_en, autor:perfiles(nombre, avatar_url, rol)')
        .eq('id', payload.new.id)
        .single()
      
      // Verificamos por ID para evitar duplicados, permitiendo pruebas en varias pestañas con el mismo usuario
      if (data && !mensajes.value.some((m: any) => m.id === data.id)) {
        mensajes.value.push(data)
        // Hacer scroll al final
        setTimeout(() => {
          const container = document.querySelector('.flex-1.overflow-y-auto')
          if (container) container.scrollTop = container.scrollHeight
        }, 50)
      }
    })
    .subscribe()
}

function unsubscribeFromChat() {
  if (chatSubscription) {
    supabase.removeChannel(chatSubscription)
    chatSubscription = null
  }
}

watch(activeTab, (val) => {
  if (val === 'comunidad') {
    loadMensajes()
    subscribeToChat()
  } else {
    unsubscribeFromChat()
  }
})

onUnmounted(() => {
  unsubscribeFromChat()
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
  <div v-if="curso" class="pt-8 pb-12 px-gutter max-w-container-max mx-auto animate-fade-in">
    <!-- Breadcrumbs -->
    <nav class="flex items-center gap-2 mb-6">
      <button type="button" 
        class="flex items-center gap-1 text-primary hover:underline transition-all outline-none"
        @click="router.back()"
      >
        <span class="material-symbols-outlined text-sm">chevron_left</span>
        <span class="text-body-sm font-medium">Volver a cursos</span>
      </button>
    </nav>
    
    <!-- Course Bento Header -->
    <div class="relative w-full rounded-3xl overflow-hidden mb-8 shadow-lg group">
      <div class="absolute inset-0 bg-gradient-to-t from-black/90 via-black/40 to-transparent z-10"></div>
      <img :src="(curso as any).imagen_url || 'https://images.unsplash.com/photo-1516321497487-e288fb19713f?q=80&w=2070&auto=format&fit=crop'" alt="Course Banner" class="w-full h-48 md:h-64 object-cover transform transition-transform duration-700 group-hover:scale-105">
      <div class="absolute inset-0 z-20 flex flex-col justify-end p-8">
        <div class="inline-flex items-center gap-2 px-3 py-1 bg-black/40 backdrop-blur-md border border-white/20 rounded-full text-white text-label-sm w-fit mb-4">
          <span class="material-symbols-outlined text-sm">schedule</span>
          {{ curso.nivel }}
        </div>
        <h2 class="text-headline-lg font-headline-lg text-white mb-2 leading-tight drop-shadow-md">{{ curso.nombre }}</h2>
        <div class="flex items-center gap-3 text-white/90 drop-shadow-sm">
          <span class="material-symbols-outlined">person</span>
          <span class="text-body-md">Prof. {{ (curso as any).docente?.nombre || curso.docente_id }}</span>
        </div>
      </div>
    </div>

    <!-- Tabs Navigation -->
    <div class="flex border-b border-border-subtle mb-8 overflow-x-auto">
      <button type="button" 
        class="flex items-center gap-2 px-6 py-4 transition-colors font-semibold"
        :class="activeTab === 'tareas' ? 'border-b-2 border-primary text-primary' : 'text-on-surface-variant hover:text-primary'"
        @click="activeTab = 'tareas'"
      >
        <span class="material-symbols-outlined">assignment</span>
        Tareas
      </button>
      <button type="button" 
        class="flex items-center gap-2 px-6 py-4 transition-colors font-semibold"
        :class="activeTab === 'materiales' ? 'border-b-2 border-primary text-primary' : 'text-on-surface-variant hover:text-primary'"
        @click="activeTab = 'materiales'"
      >
        <span class="material-symbols-outlined">book</span>
        Materiales
      </button>
      <button type="button" 
        class="flex items-center gap-2 px-6 py-4 transition-colors font-semibold"
        :class="activeTab === 'comunidad' ? 'border-b-2 border-primary text-primary' : 'text-on-surface-variant hover:text-primary'"
        @click="activeTab = 'comunidad'"
      >
        <span class="material-symbols-outlined">forum</span>
        Comunidad
      </button>
    </div>

    <!-- Contenido Tareas -->
    <div v-if="activeTab === 'tareas'" class="grid grid-cols-1 gap-4">
      <div v-for="tarea in tareasDelCurso" :key="tarea.id" 
           :class="[
             'border rounded-2xl p-6 flex flex-col md:flex-row md:items-center justify-between gap-6 transition-all group relative overflow-hidden',
             tarea.estado_entrega === 'pendiente' ? 'bg-surface-container-lowest border-border-subtle hover:shadow-md' : 'bg-surface-container-low border-border-subtle/50 opacity-80 hover:opacity-100'
           ]">
        <div v-if="tarea.estado_entrega === 'pendiente'" class="absolute left-0 top-0 bottom-0 w-1 bg-primary"></div>
        <div class="flex items-center gap-6">
          <div :class="[
            'w-12 h-12 rounded-xl flex items-center justify-center',
            tarea.estado_entrega === 'pendiente' ? 'bg-primary-container/20 text-primary' : 'bg-secondary-container/30 text-on-secondary-container'
          ]">
            <span class="material-symbols-outlined text-2xl" :style="tarea.estado_entrega !== 'pendiente' ? 'font-variation-settings: \'FILL\' 1;' : ''">
              {{ tarea.estado_entrega === 'pendiente' ? 'history_toggle_off' : 'check_circle' }}
            </span>
          </div>
          <div>
            <h3 class="text-headline-md font-headline-md text-on-surface transition-colors" :class="{'group-hover:text-primary': tarea.estado_entrega === 'pendiente'}">
              {{ tarea.titulo }}
            </h3>
            <div class="flex flex-wrap items-center gap-3 mt-1">
              <span :class="[
                'px-3 py-1 rounded-full text-label-sm font-semibold uppercase tracking-wider',
                tarea.estado_entrega === 'pendiente' ? 'bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-300' : 'bg-secondary-container text-on-secondary-container'
              ]">
                {{ tarea.estado_entrega === 'pendiente' ? 'Pendiente' : 'Entregada' }}
              </span>
              <span v-if="tarea.xp_premio" :class="[
                'font-bold text-label-md flex items-center gap-1',
                tarea.estado_entrega === 'pendiente' ? 'text-primary' : 'text-on-secondary-container'
              ]">
                <span v-if="tarea.estado_entrega !== 'pendiente'" class="material-symbols-outlined text-sm">stars</span>
                {{ tarea.estado_entrega !== 'pendiente' ? 'Ganado: ' : '' }}+{{ tarea.xp_premio }} XP
              </span>
              <span v-if="tarea.estado_entrega === 'pendiente'" class="text-on-surface-variant text-body-sm flex items-center gap-1">
                <span class="material-symbols-outlined text-sm">event</span>
                {{ tarea.creado_en ? new Date(tarea.creado_en).toLocaleDateString() : new Date().toLocaleDateString() }}
              </span>
            </div>
          </div>
        </div>
        <button type="button" 
          v-if="tarea.estado_entrega === 'pendiente'"
          @click="abrirEntrega(tarea)"
          class="bg-primary text-on-primary px-8 py-3 rounded-xl font-bold hover:brightness-110 active:scale-95 transition-all shadow-sm shrink-0"
        >
          Entregar
        </button>
        <button type="button" 
          v-else
          class="border border-primary text-primary px-8 py-3 rounded-xl font-bold hover:bg-primary-fixed-dim transition-all shrink-0"
        >
          Ver Corrección
        </button>
      </div>

      <div v-if="tareasDelCurso.length === 0 && !cursosStore.loading" class="text-center py-10 bg-surface-container-low rounded-2xl border border-border-subtle">
        <p class="text-4xl mb-2">🎉</p>
        <p class="font-medium text-on-surface text-headline-md">¡Estás al día!</p>
        <p class="text-sm text-on-surface-variant">No tienes tareas asignadas en este curso.</p>
      </div>
    </div>

    <!-- Contenido Materiales -->
    <div v-if="activeTab === 'materiales'" class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div v-for="mat in materiales" :key="mat.id" class="bg-surface-container-lowest border border-border-subtle rounded-2xl p-6 flex flex-col md:flex-row gap-4 hover:shadow-md transition-shadow group">
        <div class="w-12 h-12 bg-primary-container/10 rounded-xl flex items-center justify-center text-2xl flex-shrink-0 text-primary">
          {{ getIcon(mat.tipo) }}
        </div>
        <div class="min-w-0 flex-1">
          <p class="text-headline-md font-headline-md text-on-surface truncate group-hover:text-primary transition-colors">{{ mat.titulo }}</p>
          <p class="text-body-sm text-on-surface-variant mt-1 line-clamp-2">{{ mat.descripcion || 'Sin descripción' }}</p>
          <div class="flex flex-wrap items-center gap-2 mt-3">
            <span class="px-3 py-1 bg-primary-container text-on-primary-container rounded-full text-label-sm font-semibold uppercase tracking-wider">{{ mat.tipo }}</span>
            <a v-if="mat.archivo_url" :href="mat.archivo_url" target="_blank" rel="noopener noreferrer" class="text-label-sm text-primary font-bold hover:underline bg-primary/10 px-3 py-1 rounded-full flex items-center">
              <span class="material-symbols-outlined text-[14px] mr-1">link</span> Enlace
            </a>
            <button type="button" v-for="(arch, idx) in mat.archivos" :key="idx" @click.stop="descargarArchivo(arch)" class="text-label-sm text-secondary font-bold hover:underline bg-secondary/10 px-3 py-1 rounded-full flex items-center">
              <span class="material-symbols-outlined text-[14px] mr-1">download</span> {{ arch.nombre }}
            </button>
          </div>
        </div>
      </div>
      
      <div v-if="materiales.length === 0 && !cursosStore.loading" class="col-span-full text-center py-10 bg-surface-container-low rounded-2xl border border-border-subtle">
        <p class="text-4xl mb-2">📚</p>
        <p class="font-medium text-on-surface text-headline-md">Sin material</p>
        <p class="text-sm text-on-surface-variant">El docente aún no ha subido material para este curso.</p>
      </div>
    </div>

    <!-- Contenido Comunidad (Chat) -->
    <div v-if="activeTab === 'comunidad'" class="flex flex-col h-[500px] bg-surface-container-lowest border border-border-subtle rounded-3xl overflow-hidden shadow-sm">
      <div class="flex-1 overflow-y-auto p-4 space-y-4 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] dark:bg-[radial-gradient(#3e484f_1px,transparent_1px)] [background-size:16px_16px]">
        <div v-if="loadingMensajes && mensajes.length === 0" class="text-center py-4 text-on-surface-variant">
          Cargando mensajes...
        </div>
        <div v-else-if="mensajes.length === 0" class="text-center py-10">
          <p class="text-4xl mb-2">👋</p>
          <p class="font-medium text-on-surface text-headline-md">¡Sé el primero en saludar!</p>
          <p class="text-sm text-on-surface-variant">Escribe un mensaje para tu clase.</p>
        </div>
        
        <div 
          v-for="msg in mensajes" 
          :key="msg.id" 
          :class="['flex gap-3 max-w-[85%]', msg.autor?.nombre === authStore.perfil?.nombre ? 'ml-auto flex-row-reverse' : 'mr-auto']"
        >
          <div class="w-10 h-10 rounded-full bg-primary-container flex items-center justify-center text-on-primary-container text-sm font-bold overflow-hidden flex-shrink-0 mt-1 shadow-sm border-2 border-surface-container-lowest">
            <img v-if="msg.autor?.avatar_url && (msg.autor.avatar_url.startsWith('http') || msg.autor.avatar_url.startsWith('data'))" :src="msg.autor.avatar_url" class="w-full h-full object-cover" />
            <span v-else>{{ msg.autor?.nombre?.charAt(0) || 'U' }}</span>
          </div>
          <div :class="['flex flex-col', msg.autor?.nombre === authStore.perfil?.nombre ? 'items-end' : 'items-start']">
            <div class="flex items-baseline gap-2 mb-1">
              <span class="text-label-md font-bold text-on-surface">{{ msg.autor?.nombre }}</span>
              <span v-if="msg.autor?.rol === 'docente'" class="text-[10px] bg-secondary text-on-secondary px-2 py-0.5 rounded-full uppercase font-bold tracking-wide">Docente</span>
              <span class="text-label-sm text-on-surface-variant font-normal">{{ new Date(msg.creado_en).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) }}</span>
            </div>
            <div :class="['px-5 py-3 rounded-2xl text-body-md shadow-sm', 
              msg.autor?.nombre === authStore.perfil?.nombre 
                ? 'bg-primary text-on-primary rounded-tr-sm' 
                : 'bg-surface-container-lowest text-on-surface border border-border-subtle rounded-tl-sm'
            ]">
              {{ msg.contenido }}
            </div>
          </div>
        </div>
      </div>

      <div class="p-4 bg-surface-container-lowest border-t border-border-subtle z-10">
        <form @submit.prevent="enviarMensaje" class="flex items-center gap-3 max-w-4xl mx-auto">
          <input id="nuevoMensaje" name="nuevoMensaje" 
            v-model="nuevoMensaje"
            type="text" 
            placeholder="Escribe tu mensaje..."
            class="flex-1 h-12 px-6 bg-surface-container-low border border-border-subtle rounded-full font-body-md text-sm outline-none focus:ring-2 focus:ring-primary/40 focus:border-primary transition-all shadow-sm"
          />
          <button type="submit" class="w-12 h-12 rounded-full bg-primary text-white flex items-center justify-center hover:bg-primary-container hover:text-on-primary-container shadow-md transition-all disabled:opacity-50 disabled:scale-95 active:scale-95 shrink-0">
            <span class="material-symbols-outlined text-[20px] ml-1">send</span>
          </button>
        </form>
      </div>
    </div>

    <!-- Modal Entregar Tarea -->
    <div v-if="showEntregaModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-on-surface/50 backdrop-blur-sm animate-fade-in">
      <div class="bg-surface-container-lowest rounded-3xl w-full max-w-md shadow-xl p-8 relative max-h-[90vh] overflow-y-auto">
        <h2 class="font-headline-md text-headline-md mb-3 text-on-surface">Entregar: {{ tareaActiva?.titulo }}</h2>
        <p class="text-body-sm text-on-surface-variant mb-6">Puedes pegar un enlace (Drive, YouTube) o subir un archivo directamente desde tu equipo.</p>
        
        <label class="block text-label-md font-bold mb-2 text-on-surface">Enlace del trabajo (Opcional)</label>
        <input id="entregaForm_archivo_url" name="entregaForm_archivo_url" 
          v-model="entregaForm.archivo_url" 
          type="url" 
          placeholder="https://..." 
          class="w-full bg-surface-container-low border-none rounded-xl px-4 py-3 outline-none focus:ring-2 focus:ring-primary mb-6 text-body-md transition-all" 
        />

        <label class="block text-label-md font-bold mb-2 text-on-surface">Archivos Adjuntos (Max 5MB)</label>
        <label class="flex flex-col items-center justify-center w-full h-32 border-2 border-dashed border-primary/30 rounded-2xl cursor-pointer bg-primary/5 hover:bg-primary/10 transition-colors mb-6">
          <div class="flex flex-col items-center justify-center pt-5 pb-6">
            <span class="material-symbols-outlined text-4xl mb-2 text-primary">upload_file</span>
            <p class="text-body-sm text-on-surface-variant"><span class="font-bold text-primary">Haz clic para subir</span> o arrastra aquí</p>
          </div>
          <input id="input_file_5" name="input_file_5" type="file" class="hidden" multiple @change="handleEntregaFileUpload" />
        </label>

        <div v-if="entregaForm.archivos.length > 0" class="space-y-3 mb-6">
          <div v-for="(file, idx) in entregaForm.archivos" :key="idx" class="flex items-center justify-between p-3 bg-surface-container-low rounded-xl border border-border-subtle-subtle">
            <div class="flex items-center gap-3 overflow-hidden">
              <span class="material-symbols-outlined text-primary">draft</span>
              <span class="text-label-sm truncate font-medium text-on-surface">{{ file.nombre }}</span>
            </div>
            <button type="button" @click="removeEntregaArchivo(idx)" class="text-error hover:text-error/80 px-2 font-bold text-lg">&times;</button>
          </div>
        </div>
        
        <div class="flex justify-end gap-3 mt-8">
          <button type="button" @click="showEntregaModal = false" class="px-6 py-3 rounded-xl font-bold text-on-surface-variant hover:bg-surface-container-high transition-colors">
            Cancelar
          </button>
          <button type="button" 
            @click="enviarEntrega" 
            :disabled="!entregaForm.archivo_url && entregaForm.archivos.length === 0 || entregando"
            class="bg-primary text-on-primary px-8 py-3 rounded-xl font-bold hover:brightness-110 active:scale-95 transition-all shadow-sm disabled:opacity-50 disabled:active:scale-100"
          >
            {{ entregando ? 'Enviando...' : 'Enviar Tarea' }}
          </button>
        </div>
      </div>
    </div>
  </div>
  
  <div v-else-if="cursosStore.loading" class="p-6 text-center text-on-surface-variant font-medium">
    Cargando curso...
  </div>
</template>
