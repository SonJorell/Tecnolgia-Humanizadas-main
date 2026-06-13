<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/services/supabase'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import { MessageSquare, CheckCircle, Trophy, User } from 'lucide-vue-next'

const feedbacks = ref<any[]>([])
const loading = ref(true)
const processing = ref(false)

const monedasPremio = ref(100)
const xpPremio = ref(50)

onMounted(async () => {
 await cargarFeedbacks()
})

async function cargarFeedbacks() {
 loading.value = true
 const { data } = await supabase
 .from('feedback')
 .select('*, autor:perfiles(nombre, rol, avatar_url)')
 .order('creado_en', { ascending: false })
 
 feedbacks.value = data || []
 loading.value = false
}

async function resolverFeedback(id: string, util: boolean) {
 try {
 processing.value = true
 const monedas = util ? monedasPremio.value : 0
 const xp = util ? xpPremio.value : 0
 
 const { error } = await supabase.rpc('evaluar_feedback', {
 p_feedback_id: id,
 p_estado: true,
 p_monedas_premio: monedas,
 p_xp_premio: xp
 })

 if (error) throw error

 // Actualizar vista
 const index = feedbacks.value.findIndex(f => f.id === id)
 if (index !== -1) {
 feedbacks.value[index].resuelto = true
 }
 } catch (err: any) {
 alert(err.message || 'Error al evaluar feedback')
 } finally {
 processing.value = false
 }
}
</script>

<template>
 <div class="p-4 md:p-6 max-w-5xl mx-auto space-y-6 animate-fade-in">
 <div>
 <h1 class="font-headline-md font-extrabold text-2xl md:text-3xl text-on-surface flex items-center gap-2">
 <MessageSquare class="text-primary" /> Panel TI: Feedback
 </h1>
 <p class="text-sm text-on-surface-variant mt-1">Revisa sugerencias, marca problemas resueltos y otorga recompensas.</p>
 </div>

 <div v-if="loading" class="space-y-4">
 <div v-for="i in 3" :key="i" class="h-32 skeleton rounded-xl"></div>
 </div>

 <div v-else class="space-y-4">
 <BaseCard v-for="fb in feedbacks" :key="fb.id" class="p-5 flex flex-col md:flex-row gap-4">
 <div class="flex items-center gap-3 md:w-1/4 flex-shrink-0">
 <div class="w-10 h-10 rounded-full bg-primary/20 text-primary flex items-center justify-center font-bold overflow-hidden">
 <img v-if="fb.autor?.avatar_url" :src="fb.autor.avatar_url" class="w-full h-full object-cover" />
 <User v-else :size="20" />
 </div>
 <div>
 <p class="font-bold text-on-surface text-sm">{{ fb.autor?.nombre || 'Usuario' }}</p>
 <p class="text-[10px] text-on-surface-variant uppercase font-semibold">{{ fb.autor?.rol }}</p>
 <p class="text-[10px] text-on-surface-light mt-0.5">{{ new Date(fb.creado_en).toLocaleDateString() }}</p>
 </div>
 </div>

 <div class="flex-1">
 <div class="flex flex-wrap gap-1 mb-2">
 <BaseBadge v-for="(cat, i) in (fb.categorias || [])" :key="i" variant="neutral" size="sm">
 {{ cat }}
 </BaseBadge>
 <BaseBadge :variant="fb.rating >= 4 ? 'mint' : fb.rating === 3 ? 'amber' : 'danger'" size="sm">
 Rating: {{ fb.rating }}/5
 </BaseBadge>
 </div>
 <p class="text-sm text-on-surface">{{ fb.comentario || '(Sin comentario adicional)' }}</p>
 </div>

 <div class="md:w-1/4 flex flex-col justify-center gap-2 border-t md:border-t-0 md:border-l border-border-subtle pt-4 md:pt-0 md:pl-4">
 <div v-if="fb.resuelto" class="flex flex-col items-center text-secondary bg-secondary-container rounded-lg p-3">
 <CheckCircle :size="24" class="mb-1" />
 <span class="text-xs font-bold uppercase">Resuelto</span>
 </div>
 <template v-else>
 <div class="flex flex-col gap-1 mb-2">
 <label class="text-[10px] text-on-surface-variant font-semibold uppercase">Recompensa (Útil)</label>
 <div class="flex items-center gap-2 text-xs font-bold text-on-surface">
 🪙 <input id="monedasPremio" name="monedasPremio" v-model.number="monedasPremio" type="number" class="w-16 h-6 px-1 rounded bg-surface-container-low border border-border-subtle" />
 ⭐ <input id="xpPremio" name="xpPremio" v-model.number="xpPremio" type="number" class="w-16 h-6 px-1 rounded bg-surface-container-low border border-border-subtle" />
 </div>
 </div>
 <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
 <BaseButton variant="primary" size="sm" :disabled="processing" class="w-full justify-center px-0 text-xs" @click="resolverFeedback(fb.id, true)">
 <Trophy :size="12" class="mr-1" /> Útil
 </BaseButton>
 <BaseButton variant="secondary" size="sm" :disabled="processing" class="w-full justify-center px-0 text-xs text-on-surface-variant" @click="resolverFeedback(fb.id, false)">
 Cerrar
 </BaseButton>
 </div>
 </template>
 </div>
 </BaseCard>

 <div v-if="feedbacks.length === 0" class="text-center py-10 bg-surface-container-low rounded-xl">
 <p class="text-on-surface-variant">No hay feedback registrado.</p>
 </div>
 </div>
 </div>
</template>
