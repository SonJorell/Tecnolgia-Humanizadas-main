<script setup lang="ts">
import { ref, computed } from 'vue'
import { supabase } from '@/services/supabase'
import { useDocenteStore } from '@/stores/docente'
import { useAuthStore } from '@/stores/auth'
import { useAppStore } from '@/stores/app'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import { Award, Plus, Trophy, Trash2, Users } from 'lucide-vue-next'

const docenteStore = useDocenteStore()
const authStore = useAuthStore()
const appStore = useAppStore()

const showCreateModal = ref(false)
const isSubmitting = ref(false)

const newLogro = ref({
 nombre: '',
 descripcion: '',
 icono: '🌟',
 recompensa_xp: 50,
 recompensa_monedas: 0
})

const emojis = ['🌟', '🏆', '🔥', '🧠', '🚀', '🎯', '🎨', '💻', '🧪', '📚', '⭐', '⚡']

async function crearLogro() {
 if (!newLogro.value.nombre || !newLogro.value.descripcion) {
 appStore.addToast({ tipo: 'error', mensaje: 'Faltan campos obligatorios' })
 return
 }

 isSubmitting.value = true
 try {
 const { data, error } = await supabase.from('logros_docente').insert({
 docente_id: authStore.user?.id,
 nombre: newLogro.value.nombre,
 descripcion: newLogro.value.descripcion,
 icono: newLogro.value.icono,
 recompensa_xp: newLogro.value.recompensa_xp,
 recompensa_monedas: newLogro.value.recompensa_monedas
 }).select().single()

 if (error) throw error

 docenteStore.logrosDocente.push(data)
 appStore.addToast({ tipo: 'success', mensaje: 'Premio creado exitosamente' })
 
 // Reset form
 showCreateModal.value = false
 newLogro.value = {
 nombre: '',
 descripcion: '',
 icono: '🌟',
 recompensa_xp: 50,
 recompensa_monedas: 0
 }
 } catch (err) {
 console.error(err)
 appStore.addToast({ tipo: 'error', mensaje: 'Error al crear el premio' })
 } finally {
 isSubmitting.value = false
 }
}

async function eliminarLogro(id: string) {
 if (!confirm('¿Estás seguro de eliminar este premio? Los alumnos que ya lo recibieron no lo perderán, pero no podrás asignarlo de nuevo.')) return

 try {
 const { error } = await supabase.from('logros_docente').delete().eq('id', id)
 if (error) throw error
 
 docenteStore.logrosDocente = docenteStore.logrosDocente.filter(l => l.id !== id)
 appStore.addToast({ tipo: 'success', mensaje: 'Premio eliminado' })
 } catch(e) {
 appStore.addToast({ tipo: 'error', mensaje: 'Error al eliminar' })
 }
}
</script>

<template>
 <div class="p-4 md:p-6 max-w-5xl mx-auto space-y-6 animate-fade-in">
 <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
 <div>
 <h1 class="font-headline-md font-extrabold text-2xl md:text-3xl text-on-surface flex items-center gap-2">
 <Award class="text-yellow-500" /> Premios Personalizados
 </h1>
 <p class="text-sm text-on-surface-variant mt-1">Crea medallas únicas para recompensar el esfuerzo y habilidades de tus alumnos.</p>
 </div>
 <BaseButton variant="primary" @click="showCreateModal = true">
 <Plus :size="18" class="mr-1" /> Nuevo Premio
 </BaseButton>
 </div>

 <!-- Lista de Logros -->
 <div v-if="docenteStore.loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
 <div v-for="i in 3" :key="i" class="h-40 skeleton rounded-2xl"></div>
 </div>
 
 <div v-else-if="docenteStore.logrosDocente.length === 0" class="text-center py-16 bg-surface-container-low rounded-3xl border border-dashed border-border">
 <Trophy :size="48" class="mx-auto text-yellow-500/50 mb-4" />
 <h3 class="font-bold text-lg text-on-surface">Sin premios creados</h3>
 <p class="text-sm text-on-surface-variant mt-2 max-w-md mx-auto">No has diseñado ninguna medalla aún. Crea premios creativos como"El rey de las matemáticas" o"Ayudante del día".</p>
 <BaseButton variant="primary" class="mt-6" @click="showCreateModal = true">Crear mi primer premio</BaseButton>
 </div>

 <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
 <BaseCard v-for="logro in docenteStore.logrosDocente" :key="logro.id" class="flex flex-col relative group overflow-hidden">
 <div class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
 <button type="button" @click="eliminarLogro(logro.id)" class="w-8 h-8 rounded-full bg-error-container text-error flex items-center justify-center hover:bg-error hover:text-white transition-colors" title="Eliminar premio">
 <Trash2 :size="14" />
 </button>
 </div>
 
 <div class="p-6 flex flex-col items-center text-center flex-1">
 <span class="text-6xl mb-4 drop-shadow-md transform group-hover:scale-110 transition-transform">{{ logro.icono }}</span>
 <h3 class="font-bold text-lg text-on-surface">{{ logro.nombre }}</h3>
 <p class="text-sm text-on-surface-variant mt-2">{{ logro.descripcion }}</p>
 </div>
 
 <div class="border-t border-border p-4 bg-surface-container-low/50 flex items-center justify-between mt-auto">
 <div class="flex items-center gap-3">
 <span class="text-xs font-bold text-tertiary-500 bg-tertiary-500/10 px-2 py-1 rounded-full">+{{ logro.recompensa_xp }} XP</span>
 <span v-if="logro.recompensa_monedas > 0" class="text-xs font-bold text-yellow-500 bg-yellow-500/10 px-2 py-1 rounded-full">+{{ logro.recompensa_monedas }} 🪙</span>
 </div>
 <div class="flex items-center gap-1 text-on-surface-variant text-xs font-medium" title="Veces otorgado">
 <Users :size="12" /> {{ docenteStore.logrosAsignados.filter(la => la.logro_docente_id === logro.id).length }}
 </div>
 </div>
 </BaseCard>
 </div>

 <!-- Modal Crear -->
 <div v-if="showCreateModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-text/50 backdrop-blur-sm animate-fade-in">
 <div class="bg-surface-container-lowest rounded-2xl w-full max-w-md shadow-modal overflow-hidden">
 <div class="p-4 border-b border-border bg-surface-container-low">
 <h2 class="font-bold text-on-surface">Diseñar Nuevo Premio</h2>
 </div>
 
 <div class="p-5 space-y-4">
 <div>
 <label class="block text-xs font-bold text-on-surface-variant uppercase mb-1">Nombre de la Medalla</label>
 <input id="newLogro_nombre" name="newLogro_nombre" v-model="newLogro.nombre" type="text" placeholder="Ej: Maestro del Debate" class="w-full h-10 px-3 bg-surface-container-low border border-border rounded-lg text-sm outline-none focus:ring-2 focus:ring-primary/50" />
 </div>
 
 <div>
 <label class="block text-xs font-bold text-on-surface-variant uppercase mb-1">Descripción</label>
 <textarea id="newLogro_descripcion" name="newLogro_descripcion" v-model="newLogro.descripcion" placeholder="Por debatir con respeto y argumentos sólidos." rows="2" class="w-full p-3 bg-surface-container-low border border-border rounded-lg text-sm outline-none focus:ring-2 focus:ring-primary/50"></textarea>
 </div>

 <div>
 <label class="block text-xs font-bold text-on-surface-variant uppercase mb-2">Ícono representativo</label>
 <div class="flex flex-wrap gap-2">
 <button type="button" 
 v-for="emoji in emojis" 
 :key="emoji"
 @click="newLogro.icono = emoji"
 class="w-10 h-10 rounded-lg text-xl flex items-center justify-center transition-transform hover:scale-110"
 :class="newLogro.icono === emoji ? 'bg-primary/20 border-2 border-primary' : 'bg-surface-container-low border border-border '"
 >
 {{ emoji }}
 </button>
 </div>
 </div>

 <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
 <div>
 <label class="block text-xs font-bold text-on-surface-variant uppercase mb-1">XP al ganar</label>
 <input id="newLogro_recompensa_xp" name="newLogro_recompensa_xp" v-model.number="newLogro.recompensa_xp" type="number" min="0" class="w-full h-10 px-3 bg-surface-container-low border border-border rounded-lg text-sm outline-none focus:ring-2 focus:ring-primary/50" />
 </div>
 <div>
 <label class="block text-xs font-bold text-on-surface-variant uppercase mb-1">Monedas al ganar</label>
 <input id="newLogro_recompensa_monedas" name="newLogro_recompensa_monedas" v-model.number="newLogro.recompensa_monedas" type="number" min="0" class="w-full h-10 px-3 bg-surface-container-low border border-border rounded-lg text-sm outline-none focus:ring-2 focus:ring-primary/50" />
 </div>
 </div>
 </div>

 <div class="p-4 border-t border-border flex justify-end gap-2 bg-surface-container-low">
 <BaseButton variant="ghost" @click="showCreateModal = false" :disabled="isSubmitting">Cancelar</BaseButton>
 <BaseButton variant="primary" @click="crearLogro" :disabled="isSubmitting || !newLogro.nombre || !newLogro.descripcion">
 {{ isSubmitting ? 'Creando...' : 'Crear Premio' }}
 </BaseButton>
 </div>
 </div>
 </div>
 </div>
</template>
