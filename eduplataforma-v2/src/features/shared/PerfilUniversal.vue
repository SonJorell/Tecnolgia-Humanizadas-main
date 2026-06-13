<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useGamificacionStore } from '@/stores/gamificacion'
import { supabase } from '@/services/supabase'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import { Camera, Save, Key, User, Image as ImageIcon, AlertTriangle, CheckCircle, X, Box } from 'lucide-vue-next'

const authStore = useAuthStore()
const gamificacionStore = useGamificacionStore()

// Mensajes globales
const successMsg = ref('')
const errorMsg = ref('')

// --- Perfil Info ---
const perfilForm = ref({
 nombre: '',
 telefono: '',
 avatar_url: ''
})

const presetAvatars = [
 'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
 'https://api.dicebear.com/7.x/avataaars/svg?seed=Aneka',
 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jude',
 'https://api.dicebear.com/7.x/avataaars/svg?seed=Aidan',
 'https://api.dicebear.com/7.x/avataaars/svg?seed=Liliana'
]

onMounted(() => {
 if (authStore.perfil) {
 perfilForm.value.nombre = authStore.perfil.nombre || ''
 perfilForm.value.telefono = authStore.perfil.telefono || ''
 perfilForm.value.avatar_url = authStore.perfil.avatar_url || ''
 }
})

const fileInput = ref<HTMLInputElement | null>(null)

const triggerFileUpload = () => {
 fileInput.value?.click()
}

const handleFileUpload = (event: Event) => {
 const file = (event.target as HTMLInputElement).files?.[0]
 if (!file) return

 // Validar tamaño (< 2MB)
 if (file.size > 2 * 1024 * 1024) {
 errorMsg.value = 'La imagen debe pesar menos de 2MB.'
 return
 }

 const reader = new FileReader()
 reader.onload = (e) => {
 if (e.target?.result) {
 perfilForm.value.avatar_url = e.target.result as string
 }
 }
 reader.readAsDataURL(file)
}

const selectPreset = (url: string) => {
 perfilForm.value.avatar_url = url
}

const savePerfil = async () => {
 successMsg.value = ''
 errorMsg.value = ''
 try {
 await authStore.guardarPerfil({
 nombre: perfilForm.value.nombre,
 telefono: perfilForm.value.telefono,
 avatar_url: perfilForm.value.avatar_url
 })
 successMsg.value = 'Perfil actualizado exitosamente.'
 } catch (e: any) {
 errorMsg.value = e.message || 'Error al guardar.'
 }
}

const equiparItem = async (item: string) => {
 if (!authStore.perfil) return
 let categoria = ''
 if (item.startsWith('/banners/')) categoria = 'banner_activo_id'
 else if (item === 'gold' || item === 'diamond') categoria = 'marco_activo_id'
 else {
 categoria = 'avatar_url'
 perfilForm.value.avatar_url = item
 }

 const updates: any = { [categoria]: item }
 Object.assign(authStore.perfil, updates)
 
 try {
 await supabase.from('perfiles').update(updates).eq('id', authStore.perfil.id)
 successMsg.value = 'Item equipado correctamente.'
 } catch(e) {
 errorMsg.value = 'Error al equipar el item.'
 }
}

// --- Contraseña ---
const pwForm = ref({
 nueva: '',
 confirmar: ''
})

const savePassword = async () => {
 successMsg.value = ''
 errorMsg.value = ''
 if (pwForm.value.nueva !== pwForm.value.confirmar) {
 errorMsg.value = 'Las contraseñas no coinciden.'
 return
 }
 if (pwForm.value.nueva.length < 6) {
 errorMsg.value = 'La contraseña debe tener al menos 6 caracteres.'
 return
 }
 try {
 await authStore.cambiarPassword(pwForm.value.nueva)
 successMsg.value = 'Contraseña actualizada. Usala en tu próximo inicio de sesión.'
 pwForm.value.nueva = ''
 pwForm.value.confirmar = ''
 } catch (e: any) {
 errorMsg.value = e.message || 'Error al cambiar contraseña.'
 }
}

const dismissMsg = () => {
 successMsg.value = ''
 errorMsg.value = ''
}
</script>

<template>
 <div class="p-4 md:p-6 max-w-4xl mx-auto space-y-6 animate-fade-in pb-20">
 <div class="flex items-center gap-3">
 <User :size="32" class="text-primary" />
 <div>
 <h1 class="font-headline-md font-extrabold text-2xl md:text-3xl text-on-surface">Mi Perfil</h1>
 <p class="text-sm text-on-surface-variant mt-1">Personaliza tu cuenta y gestiona tu seguridad.</p>
 </div>
 </div>

 <!-- Mensajes de Feedback -->
 <div v-if="successMsg || errorMsg" class="flex items-start gap-3 p-4 rounded-xl border" :class="errorMsg ? 'bg-error-container/50 border-error/30' : 'bg-secondary-container/50 border-secondary/30'">
 <AlertTriangle v-if="errorMsg" class="text-error flex-shrink-0" />
 <CheckCircle v-else class="text-secondary flex-shrink-0" />
 <div class="flex-1">
 <p class="font-medium text-sm" :class="errorMsg ? 'text-error' : 'text-secondary'">
 {{ errorMsg || successMsg }}
 </p>
 </div>
 <button type="button" @click="dismissMsg" class="text-on-surface-variant hover:text-on-surface transition-colors">
 <X :size="18" />
 </button>
 </div>

 <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
 
 <!-- Columna Izquierda: Avatar y Datos -->
 <div class="md:col-span-2 space-y-6">
 
 <!-- Tarjeta de Edición de Perfil -->
 <BaseCard>
 <h3 class="font-bold text-lg mb-4 text-on-surface border-b border-border-subtle pb-2">Información Personal</h3>
 
 <div class="relative w-full rounded-t-xl h-32 bg-primary/20 mb-16 flex justify-center bg-cover bg-center" :style="{ backgroundImage: authStore.perfil?.banner_activo_id ? `url(${authStore.perfil.banner_activo_id})` : '' }">
 <!-- Avatar Previo -->
 <div class="absolute -bottom-12 flex flex-col items-center gap-3">
 <div class="w-24 h-24 rounded-full bg-surface-container-low border-4 border-surface overflow-hidden flex items-center justify-center flex-shrink-0 shadow-lg relative" :class="{ 'ring-4 ring-amber-400': authStore.perfil?.marco_activo_id === 'gold', 'ring-4 ring-cyan-400': authStore.perfil?.marco_activo_id === 'diamond' }">
 <template v-if="perfilForm.avatar_url && perfilForm.avatar_url.startsWith('http') || perfilForm.avatar_url.startsWith('data')">
 <img :src="perfilForm.avatar_url" class="w-full h-full object-cover" />
 </template>
 <template v-else-if="perfilForm.avatar_url">
 <span class="text-4xl">{{ perfilForm.avatar_url }}</span>
 </template>
 <template v-else>
 <span class="text-3xl font-bold text-primary">{{ perfilForm.nombre?.charAt(0)?.toUpperCase() || 'U' }}</span>
 </template>
 </div>
 </div>
 </div>
 
 <div class="flex flex-col sm:flex-row gap-8 sm:gap-6 mb-6 px-4 sm:px-6 mt-4 sm:mt-0">
 <div class="flex flex-col items-center gap-3 justify-center w-full sm:w-1/3">
 <input id="input_file_59" name="input_file_59" type="file" ref="fileInput" accept="image/*" class="hidden" @change="handleFileUpload" />
 <button type="button" @click="triggerFileUpload" class="text-xs font-semibold text-primary bg-primary/10 hover:bg-primary/20 px-3 py-1.5 rounded-full transition-colors flex items-center gap-1.5">
 <Camera :size="14" /> Subir Foto
 </button>
 </div>

 <!-- Datos Básicos -->
 <form @submit.prevent="savePerfil" class="flex-1 space-y-4">
 <div class="space-y-1">
 <label class="text-xs font-semibold text-on-surface-variant">Nombre Completo</label>
 <input id="perfilForm_nombre" name="perfilForm_nombre" v-model="perfilForm.nombre" required type="text" class="w-full px-3 py-2 bg-surface-container-low border border-border-subtle rounded-lg text-sm" />
 </div>
 <div class="space-y-1">
 <label class="text-xs font-semibold text-on-surface-variant">Teléfono</label>
 <input id="perfilForm_telefono" name="perfilForm_telefono" v-model="perfilForm.telefono" type="text" placeholder="+569..." class="w-full px-3 py-2 bg-surface-container-low border border-border-subtle rounded-lg text-sm" />
 </div>
 <div class="space-y-1">
 <label class="text-xs font-semibold text-on-surface-variant">Correo (Solo lectura)</label>
 <input id="input_email_62" name="input_email_62" :value="authStore.perfil?.email" disabled type="email" class="w-full px-3 py-2 bg-surface-container-low/50 border border-border-subtle rounded-lg text-sm text-on-surface-variant cursor-not-allowed" />
 </div>

 <div class="pt-2 flex justify-end">
 <BaseButton type="submit" variant="primary" :disabled="authStore.loading">
 <Save :size="16" class="mr-2 inline" />
 {{ authStore.loading ? 'Guardando...' : 'Guardar Cambios' }}
 </BaseButton>
 </div>
 </form>
 </div>
 </BaseCard>

 <!-- Tarjeta de Avatares Predefinidos -->
 <BaseCard>
 <h3 class="font-bold text-sm mb-4 text-on-surface flex items-center gap-2">
 <ImageIcon :size="16" class="text-on-surface-variant" /> Avatares Predefinidos
 </h3>
 <div class="flex flex-wrap gap-4">
 <button type="button" 
 v-for="(url, idx) in presetAvatars" 
 :key="idx"
 @click="selectPreset(url)"
 class="w-12 h-12 rounded-full overflow-hidden border-2 transition-transform hover:scale-110"
 :class="perfilForm.avatar_url === url ? 'border-primary' : 'border-transparent bg-surface-container-low '"
 >
 <img :src="url" class="w-full h-full object-cover" />
 </button>
 </div>
 </BaseCard>

 <!-- Inventario de Recompensas -->
 <BaseCard v-if="gamificacionStore.inventarioPremios.length > 0" class="animate-slide-up">
 <h3 class="font-bold text-sm mb-4 text-on-surface flex items-center gap-2">
 <Box :size="16" class="text-primary" /> Mi Inventario de Recompensas
 </h3>
 <p class="text-xs text-on-surface-variant mb-4">Haz clic en un ítem para equiparlo en tu perfil.</p>
 <div class="flex flex-wrap gap-4">
 <button type="button" 
 v-for="(item, idx) in gamificacionStore.inventarioPremios" 
 :key="idx"
 @click="equiparItem(item)"
 class="relative rounded-lg overflow-hidden border-2 border-transparent hover:border-primary transition-all p-1 bg-surface-container-low"
 >
 <img v-if="item.startsWith('/banners/')" :src="item" class="w-24 h-12 object-cover rounded" />
 <div v-else-if="item === 'gold' || item === 'diamond'" class="w-12 h-12 rounded-full mx-auto" :class="item === 'gold' ? 'ring-4 ring-amber-400' : 'ring-4 ring-cyan-400'"></div>
 <div v-else class="w-12 h-12 flex items-center justify-center text-3xl mx-auto">{{ item }}</div>
 </button>
 </div>
 </BaseCard>

 </div>

 <!-- Columna Derecha: Seguridad -->
 <div class="space-y-6">
 <BaseCard class="border-l-4 border-l-amber">
 <h3 class="font-bold text-lg mb-4 text-on-surface border-b border-border-subtle pb-2 flex items-center gap-2">
 <Key :size="18" class="text-tertiary" /> Seguridad
 </h3>
 <form @submit.prevent="savePassword" class="space-y-4">
 <div class="space-y-1">
 <label class="text-xs font-semibold text-on-surface-variant">Nueva Contraseña</label>
 <input id="pwForm_nueva" name="pwForm_nueva" v-model="pwForm.nueva" required type="password" class="w-full px-3 py-2 bg-surface-container-low border border-border-subtle rounded-lg text-sm" placeholder="Mínimo 6 caracteres" />
 </div>
 <div class="space-y-1">
 <label class="text-xs font-semibold text-on-surface-variant">Confirmar Contraseña</label>
 <input id="pwForm_confirmar" name="pwForm_confirmar" v-model="pwForm.confirmar" required type="password" class="w-full px-3 py-2 bg-surface-container-low border border-border-subtle rounded-lg text-sm" placeholder="Repite la contraseña" />
 </div>
 
 <div class="pt-2">
 <BaseButton type="submit" variant="secondary" class="w-full" :disabled="authStore.loading">
 Cambiar Contraseña
 </BaseButton>
 </div>
 </form>
 </BaseCard>
 </div>

 </div>
 </div>
</template>
