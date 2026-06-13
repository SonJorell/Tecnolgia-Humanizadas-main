<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useGamificacionStore } from '@/stores/gamificacion'
import { useAppStore } from '@/stores/app'
import BaseButton from '@/components/ui/BaseButton.vue'
import RewardConfetti from '@/components/gamification/RewardConfetti.vue'
import { Smile, Meh, Frown, MessageSquare } from 'lucide-vue-next'

const router = useRouter()
const store = useGamificacionStore()
const appStore = useAppStore()

const rating = ref(0)
const categoria = ref('sugerencia')
const comentario = ref('')
const enviando = ref(false)
const showReward = ref(false)

async function enviarFeedback() {
 if (rating.value === 0 || comentario.value.trim().length < 10) {
 appStore.addToast({ tipo: 'error', mensaje: 'Por favor selecciona una carita y escribe al menos 10 letras' })
 return
 }
 if (!appStore.isOnline) {
 appStore.addToast({ tipo: 'error', mensaje: 'Debes estar conectado a internet para enviar feedback.' })
 return
 }

 enviando.value = true
 try {
 // 1. Guardar en IDB (Offline First) - Omitimos el detalle del código idb por brevedad del blueprint
 // 2. Dar recompensa (Solo 1 vez al día, simplificado aquí)
 await store.ganarXP(50, 'feedback_enviado')
 await store.ganarMonedas(20, 'feedback_enviado')
 
 enviando.value = true
 showReward.value = true
 } catch (err: any) {
 appStore.addToast({ tipo: 'error', mensaje: err.message || 'Error al enviar feedback' })
 } finally {
 enviando.value = false
 }
}

function onRewardComplete() {
 showReward.value = false
 router.push('/alumno')
}
</script>

<template>
 <div class="p-4 md:p-6 max-w-2xl mx-auto animate-fade-in pb-24">
 <div class="text-center mb-8">
 <div class="w-16 h-16 bg-primary-bg text-primary rounded-full flex items-center justify-center text-3xl mx-auto mb-4">
 <MessageSquare :size="32" />
 </div>
 <h1 class="font-headline-md font-extrabold text-2xl md:text-3xl text-on-surface">Danos tu Feedback</h1>
 <p class="text-sm text-on-surface-variant mt-2 max-w-md mx-auto">
 ¿Encontraste un error? ¿Tienes una sugerencia? Ayúdanos a mejorar y gana +50 XP y +20 🪙.
 </p>
 </div>

 <div class="bg-surface-container-lowest p-6 rounded-2xl shadow-sm border border-border-subtle space-y-6">
 
 <!-- Rating -->
 <div class="text-center">
 <label class="block text-sm font-semibold text-on-surface mb-3">¿Cómo te sientes usando la plataforma hoy?</label>
 <div class="flex justify-center gap-4">
 <button type="button" @click="rating = 1" :class="['p-3 rounded-full transition-transform', rating === 1 ? 'bg-error-container text-error scale-110' : 'text-on-surface-variant hover:bg-surface-container-low']">
 <Frown :size="40" />
 </button>
 <button type="button" @click="rating = 2" :class="['p-3 rounded-full transition-transform', rating === 2 ? 'bg-tertiary-container text-tertiary scale-110' : 'text-on-surface-variant hover:bg-surface-container-low']">
 <Meh :size="40" />
 </button>
 <button type="button" @click="rating = 3" :class="['p-3 rounded-full transition-transform', rating === 3 ? 'bg-secondary-container text-secondary scale-110' : 'text-on-surface-variant hover:bg-surface-container-low']">
 <Smile :size="40" />
 </button>
 </div>
 </div>

 <!-- Tipo -->
 <div>
 <label class="block text-sm font-semibold text-on-surface mb-2">¿De qué trata tu mensaje?</label>
 <select id="categoria" name="categoria" v-model="categoria" class="w-full bg-surface-container-low border border-border-subtle rounded-xl px-4 py-3 text-on-surface outline-none focus:ring-2 focus:ring-primary/50">
 <option value="sugerencia">💡 Tengo una idea o sugerencia</option>
 <option value="error">🐛 Encontré un error (Bug)</option>
 <option value="ayuda">🙋 Necesito ayuda técnica</option>
 </select>
 </div>

 <!-- Mensaje -->
 <div>
 <label class="block text-sm font-semibold text-on-surface mb-2">Tu comentario</label>
 <textarea id="comentario" name="comentario" 
 v-model="comentario"
 rows="4"
 placeholder="Escribe aquí los detalles..."
 class="w-full bg-surface-container-low border border-border-subtle rounded-xl px-4 py-3 text-on-surface outline-none focus:ring-2 focus:ring-primary/50 resize-y"
 ></textarea>
 </div>

 <BaseButton class="w-full" variant="primary" :loading="enviando" @click="enviarFeedback">
 Enviar Feedback y ganar recompensa
 </BaseButton>
 </div>

 <RewardConfetti :active="showReward" @complete="onRewardComplete" />
 </div>
</template>
