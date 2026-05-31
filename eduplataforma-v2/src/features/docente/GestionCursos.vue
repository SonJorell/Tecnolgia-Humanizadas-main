<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useDocenteStore } from '@/stores/docente'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import { BookOpen, Users, Edit3, Save, X, Image as ImageIcon } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'
import { useAppStore } from '@/stores/app'

const router = useRouter()
const docenteStore = useDocenteStore()
const appStore = useAppStore()

const editingId = ref<string | null>(null)
const editForm = ref({
  descripcion: '',
  banner_url: '',
  objetivosText: ''
})

const startEdit = (curso: any) => {
  editingId.value = curso.id
  editForm.value = {
    descripcion: curso.descripcion || '',
    banner_url: curso.banner_url || '',
    objetivosText: (curso.objetivos || []).join('\n')
  }
}

const saveEdit = async (curso: any) => {
  try {
    const objetivos = editForm.value.objetivosText.split('\n').filter(o => o.trim() !== '')
    const updates = {
      descripcion: editForm.value.descripcion,
      banner_url: editForm.value.banner_url,
      objetivos
    }
    
    const { error } = await supabase.from('cursos').update(updates).eq('id', curso.id)
    if (error) throw error
    
    // Update local store
    Object.assign(curso, updates)
    editingId.value = null
    appStore.addToast({ tipo: 'success', mensaje: 'Curso actualizado correctamente' })
  } catch (err: any) {
    appStore.addToast({ tipo: 'error', mensaje: err.message || 'Error al actualizar' })
  }
}
</script>

<template>
  <div class="p-4 md:p-6 max-w-6xl mx-auto space-y-6 animate-fade-in">
    <div>
      <h1 class="font-display font-extrabold text-2xl md:text-3xl text-text dark:text-dark-text flex items-center gap-2">
        <BookOpen class="text-primary" /> Gestión de Cursos
      </h1>
      <p class="text-sm text-text-muted mt-1">Administra la información, banner y objetivos de tus clases.</p>
    </div>

    <div v-if="docenteStore.loading" class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div v-for="i in 2" :key="i" class="h-64 skeleton rounded-2xl"></div>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <BaseCard v-for="curso in docenteStore.cursos" :key="curso.id" class="overflow-hidden flex flex-col h-full group">
        <!-- Banner -->
        <div class="h-32 bg-primary/20 relative w-full flex-shrink-0">
          <img v-if="curso.banner_url" :src="curso.banner_url" class="w-full h-full object-cover" />
          <div v-else class="w-full h-full flex items-center justify-center text-primary/40">
            <ImageIcon :size="48" />
          </div>
          <div class="absolute top-2 right-2 bg-black/60 text-white text-[10px] px-2 py-1 rounded-full font-bold uppercase backdrop-blur-sm">
            {{ curso.estado || 'Activo' }}
          </div>
        </div>

        <div class="p-5 flex flex-col flex-1">
          <!-- Modo Vista -->
          <template v-if="editingId !== curso.id">
            <div class="flex items-start justify-between mb-2">
              <div>
                <h3 class="font-bold text-lg text-text dark:text-dark-text leading-tight">{{ curso.nombre }}</h3>
                <p class="text-xs font-semibold text-primary mt-1">{{ curso.nivel }}</p>
              </div>
              <span class="text-3xl">{{ curso.icono }}</span>
            </div>
            
            <p class="text-sm text-text-muted mb-4 flex-1 line-clamp-3">
              {{ curso.descripcion || 'Sin descripción. Haz clic en editar para agregar detalles sobre este curso.' }}
            </p>

            <div class="flex items-center gap-4 text-sm font-semibold text-text dark:text-dark-text mb-4 border-t border-border dark:border-white/10 pt-4">
              <span class="flex items-center gap-1.5"><Users :size="16" class="text-violet" /> {{ docenteStore.alumnos.filter(a => a.curso_id === curso.id).length }} Alumnos</span>
            </div>

            <div class="grid grid-cols-2 gap-2 mt-auto">
              <BaseButton variant="primary" class="w-full justify-center" @click="router.push(`/docente/cursos/${curso.id}`)">Ver Detalle</BaseButton>
              <BaseButton variant="ghost" class="w-full justify-center text-text-muted" @click="startEdit(curso)">
                <Edit3 :size="16" class="mr-1" /> Editar
              </BaseButton>
            </div>
          </template>

          <!-- Modo Edición -->
          <template v-else>
            <div class="space-y-4 flex-1">
              <div>
                <label class="block text-xs font-bold text-text-muted uppercase mb-1">Descripción</label>
                <textarea v-model="editForm.descripcion" class="w-full p-2 bg-surface dark:bg-dark-bg border border-border dark:border-white/10 rounded-lg text-sm outline-none" rows="3"></textarea>
              </div>
              <div>
                <label class="block text-xs font-bold text-text-muted uppercase mb-1">URL de Portada (Banner)</label>
                <input v-model="editForm.banner_url" type="text" placeholder="https://..." class="w-full p-2 bg-surface dark:bg-dark-bg border border-border dark:border-white/10 rounded-lg text-sm outline-none" />
              </div>
              <div>
                <label class="block text-xs font-bold text-text-muted uppercase mb-1">Objetivos (uno por línea)</label>
                <textarea v-model="editForm.objetivosText" class="w-full p-2 bg-surface dark:bg-dark-bg border border-border dark:border-white/10 rounded-lg text-sm outline-none" rows="3" placeholder="Aprender matemáticas..."></textarea>
              </div>
            </div>
            
            <div class="grid grid-cols-2 gap-2 mt-4 pt-4 border-t border-border dark:border-white/10">
              <BaseButton variant="ghost" class="w-full justify-center" @click="editingId = null">
                <X :size="16" class="mr-1" /> Cancelar
              </BaseButton>
              <BaseButton variant="primary" class="w-full justify-center" @click="saveEdit(curso)">
                <Save :size="16" class="mr-1" /> Guardar
              </BaseButton>
            </div>
          </template>
        </div>
      </BaseCard>

      <div v-if="docenteStore.cursos.length === 0" class="col-span-full text-center py-12 text-text-muted">
        No tienes cursos asignados.
      </div>
    </div>
  </div>
</template>
