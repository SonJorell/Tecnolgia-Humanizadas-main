<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/services/supabase'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import { Megaphone, Send, Trash2, Edit, X } from 'lucide-vue-next'
import { useDirectivoStore } from '@/stores/directivo'
import { useAppStore } from '@/stores/app'

const authStore = useAuthStore()
const directivoStore = useDirectivoStore()
const appStore = useAppStore()

const comunicados = ref<any[]>([])
const loading = ref(true)
const enviando = ref(false)

const nuevoComunicado = ref({
  titulo: '',
  contenido: '',
  segmento: 'todos',
  curso_id: null as string | null
})

const editandoId = ref<string | null>(null)

onMounted(async () => {
  if (directivoStore.cursosExistentes.length === 0) {
    await directivoStore.cargarDatosGestion()
  }
  await cargarComunicados()
})

async function cargarComunicados() {
  loading.value = true
  const { data } = await supabase
    .from('comunicados')
    .select('*, autor:perfiles!autor_id(nombre), curso:cursos(nombre)')
    .order('creado_en', { ascending: false })
  
  if (data) comunicados.value = data
  loading.value = false
}

async function emitirComunicado() {
  if (!nuevoComunicado.value.titulo || !nuevoComunicado.value.contenido) {
    appStore.addToast({ tipo: 'error', mensaje: 'Debes completar título y contenido.' })
    return
  }

  enviando.value = true
  try {
    if (editandoId.value) {
      const { error } = await supabase.from('comunicados').update({
        titulo: nuevoComunicado.value.titulo,
        contenido: nuevoComunicado.value.contenido,
        segmento: nuevoComunicado.value.segmento,
        curso_id: nuevoComunicado.value.segmento === 'curso_especifico' ? nuevoComunicado.value.curso_id : null
      }).eq('id', editandoId.value)
      if (error) throw error
      appStore.addToast({ tipo: 'success', mensaje: 'Comunicado publicado exitosamente' })
    } else {
      const { error } = await supabase.from('comunicados').insert({
        autor_id: authStore.perfil?.id,
        titulo: nuevoComunicado.value.titulo,
        contenido: nuevoComunicado.value.contenido,
        segmento: nuevoComunicado.value.segmento,
        curso_id: nuevoComunicado.value.segmento === 'curso_especifico' ? nuevoComunicado.value.curso_id : null
      })
      if (error) throw error
      appStore.addToast({ tipo: 'exito', mensaje: 'Comunicado enviado correctamente.' })
    }
    
    cancelarEdicion()
    await cargarComunicados()
  } catch(e: any) {
    appStore.addToast({ tipo: 'error', mensaje: 'Error al guardar comunicado.' })
  } finally {
    enviando.value = false
  }
}

function editarComunicado(com: any) {
  editandoId.value = com.id
  nuevoComunicado.value = {
    titulo: com.titulo,
    contenido: com.contenido,
    segmento: com.segmento,
    curso_id: com.curso_id
  }
}

function cancelarEdicion() {
  editandoId.value = null
  nuevoComunicado.value = { titulo: '', contenido: '', segmento: 'todos', curso_id: null }
}

async function eliminarComunicado(id: string) {
  if (!confirm('¿Estás seguro de eliminar este comunicado?')) return
  try {
    const { error } = await supabase.from('comunicados').delete().eq('id', id)
    if (error) throw error
    appStore.addToast({ tipo: 'success', mensaje: 'Comunicado eliminado' })
    await cargarComunicados()
  } catch (e) {
    appStore.addToast({ tipo: 'error', mensaje: 'Error al eliminar.' })
  }
}
</script>

<template>
  <div class="p-4 md:p-6 space-y-6 animate-fade-in max-w-5xl mx-auto">
    <div class="flex items-center gap-3">
      <div class="w-12 h-12 rounded-xl bg-primary-bg dark:bg-primary/20 text-primary flex items-center justify-center">
        <Megaphone :size="24" />
      </div>
      <div>
        <h1 class="font-display font-extrabold text-2xl md:text-3xl text-text dark:text-dark-text">Centro de Comunicados</h1>
        <p class="text-sm text-text-muted mt-1">Emite anuncios para alumnos, docentes o cursos específicos.</p>
      </div>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      
      <!-- Emitir Comunicado -->
      <div class="md:col-span-1 space-y-4">
        <BaseCard class="sticky top-6">
          <div class="flex justify-between items-center mb-4 border-b border-border dark:border-white/10 pb-2">
            <h2 class="font-bold text-lg text-text dark:text-dark-text">
              {{ editandoId ? 'Editar Comunicado' : 'Nuevo Comunicado' }}
            </h2>
            <button v-if="editandoId" @click="cancelarEdicion" class="text-xs flex items-center gap-1 text-danger hover:underline">
              <X :size="14" /> Cancelar
            </button>
          </div>
          
          <form @submit.prevent="emitirComunicado" class="space-y-4">
            <div>
              <label class="block text-xs font-semibold text-text-muted mb-1">Título</label>
              <input v-model="nuevoComunicado.titulo" required type="text" class="w-full bg-surface dark:bg-dark-card border border-border dark:border-white/10 rounded-lg px-3 py-2 text-sm outline-none focus:border-primary" placeholder="Ej: Suspensión de clases..." />
            </div>

            <div>
              <label class="block text-xs font-semibold text-text-muted mb-1">Público Objetivo (Segmento)</label>
              <select v-model="nuevoComunicado.segmento" class="w-full bg-surface dark:bg-dark-card border border-border dark:border-white/10 rounded-lg px-3 py-2 text-sm outline-none focus:border-primary">
                <option value="todos">Toda la Comunidad (General)</option>
                <option value="docentes">Solo Docentes</option>
                <option value="alumnos">Todos los Alumnos</option>
                <option value="curso_especifico">Curso Específico...</option>
              </select>
            </div>

            <div v-if="nuevoComunicado.segmento === 'curso_especifico'" class="animate-fade-in">
              <label class="block text-xs font-semibold text-text-muted mb-1">Seleccionar Curso</label>
              <select v-model="nuevoComunicado.curso_id" required class="w-full bg-surface dark:bg-dark-card border border-border dark:border-white/10 rounded-lg px-3 py-2 text-sm outline-none focus:border-primary">
                <option value="" disabled>Selecciona un curso</option>
                <option v-for="c in directivoStore.cursosExistentes" :key="c.id" :value="c.id">{{ c.nombre }}</option>
              </select>
            </div>

            <div>
              <label class="block text-xs font-semibold text-text-muted mb-1">Mensaje</label>
              <textarea v-model="nuevoComunicado.contenido" required rows="4" class="w-full bg-surface dark:bg-dark-card border border-border dark:border-white/10 rounded-lg px-3 py-2 text-sm outline-none focus:border-primary resize-none" placeholder="Escribe el anuncio aquí..."></textarea>
            </div>

            <BaseButton type="submit" variant="primary" class="w-full justify-center" :loading="enviando">
              <Send v-if="!editandoId" :size="16" class="mr-2" />
              <Edit v-else :size="16" class="mr-2" />
              {{ editandoId ? 'Guardar Cambios' : 'Publicar Comunicado' }}
            </BaseButton>
          </form>
        </BaseCard>
      </div>

      <!-- Historial de Comunicados -->
      <div class="md:col-span-2 space-y-4">
        <h2 class="font-bold text-lg text-text dark:text-dark-text border-b border-border dark:border-white/10 pb-2">
          Historial de Anuncios
        </h2>
        
        <div v-if="loading" class="space-y-4">
          <div v-for="i in 3" :key="i" class="skeleton h-24 rounded-xl"></div>
        </div>

        <div v-else-if="comunicados.length === 0" class="text-center py-10">
          <div class="w-16 h-16 rounded-full bg-surface dark:bg-dark-surface mx-auto flex items-center justify-center mb-3">
            <Megaphone class="text-text-muted opacity-50" :size="32" />
          </div>
          <p class="font-medium text-text dark:text-dark-text">No hay comunicados activos</p>
          <p class="text-sm text-text-muted">Los anuncios que emitas aparecerán aquí.</p>
        </div>

        <div v-else class="space-y-4">
          <BaseCard v-for="com in comunicados" :key="com.id" class="relative group">
            <div class="flex justify-between items-start mb-2">
              <h3 class="font-bold text-lg text-primary">{{ com.titulo }}</h3>
              <span class="text-xs font-semibold px-2 py-1 rounded bg-surface dark:bg-dark-surface border border-border dark:border-white/5 uppercase">
                {{ com.segmento === 'curso_especifico' ? com.curso?.nombre : com.segmento }}
              </span>
            </div>
            
            <p class="text-sm text-text dark:text-dark-text whitespace-pre-wrap">{{ com.contenido }}</p>
            
            <div class="mt-4 pt-3 border-t border-border dark:border-white/5 flex flex-col sm:flex-row gap-3 justify-between items-start sm:items-center text-xs text-text-muted">
              <div class="flex items-center gap-4">
                <span>Emitido por: {{ com.autor?.nombre }}</span>
                <span>{{ new Date(com.creado_en).toLocaleString() }}</span>
              </div>
              <div class="flex gap-2 w-full sm:w-auto">
                <button @click="editarComunicado(com)" class="flex-1 sm:flex-none flex items-center justify-center gap-1 px-3 py-1.5 rounded-lg bg-surface dark:bg-dark-surface hover:bg-primary/10 hover:text-primary transition-colors border border-border dark:border-white/5">
                  <Edit :size="14" /> Editar
                </button>
                <button @click="eliminarComunicado(com.id)" class="flex-1 sm:flex-none flex items-center justify-center gap-1 px-3 py-1.5 rounded-lg bg-surface dark:bg-dark-surface hover:bg-danger/10 hover:text-danger transition-colors border border-border dark:border-white/5">
                  <Trash2 :size="14" /> Borrar
                </button>
              </div>
            </div>
          </BaseCard>
        </div>
      </div>
      
    </div>
  </div>
</template>
