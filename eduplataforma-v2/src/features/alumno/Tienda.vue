<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useGamificacionStore } from '@/stores/gamificacion'
import { useAuthStore } from '@/stores/auth'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import RewardConfetti from '@/components/gamification/RewardConfetti.vue'

const store = useGamificacionStore()
const authStore = useAuthStore()

const comprando = ref(false)
const showReward = ref(false)
const itemComprado = ref('')

onMounted(async () => {
  await store.loadTienda()
})

async function intentarComprar(id: string, nombre: string) {
  try {
    comprando.value = true
    await store.comprarItem(id)
    itemComprado.value = nombre
    showReward.value = true
  } catch (err: any) {
    alert(err.message)
  } finally {
    comprando.value = false
  }
}
</script>

<template>
  <div class="p-4 md:p-6 max-w-5xl mx-auto space-y-8 animate-fade-in">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
      <div>
        <h1 class="font-display font-extrabold text-2xl md:text-4xl text-text dark:text-dark-text">🛍️ Tienda de Canjes</h1>
        <p class="text-sm text-text-muted mt-2">Usa tus monedas para obtener personalizaciones y beneficios académicos.</p>
      </div>
      
      <div class="bg-amber-bg dark:bg-amber/20 border border-amber/30 rounded-2xl px-6 py-3 flex items-center gap-3">
        <span class="text-3xl">🪙</span>
        <div>
          <p class="text-xs font-bold text-amber-600 dark:text-amber-400 uppercase tracking-wider">Tu saldo</p>
          <p class="font-display font-extrabold text-2xl text-amber-700 dark:text-amber-300">{{ authStore.perfil?.monedas || 0 }}</p>
        </div>
      </div>
    </div>

    <!-- Catálogo -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
      <BaseCard v-for="item in store.tienda" :key="item.id" class="flex flex-col">
        <div class="flex-1">
          <div class="w-full h-32 bg-surface dark:bg-dark-card2 rounded-xl mb-4 flex items-center justify-center text-5xl overflow-hidden relative">
            <template v-if="item.categoria === 'banner'">
              <img :src="item.icono" class="w-full h-full object-cover" />
              <div class="absolute inset-0 bg-black/20 flex items-center justify-center"><span class="text-3xl drop-shadow-md">🖼️</span></div>
            </template>
            <template v-else-if="item.categoria === 'avatar'">
              <div class="w-16 h-16 rounded-full bg-primary/20 flex items-center justify-center text-4xl">{{ item.icono }}</div>
            </template>
            <template v-else>
              {{ item.categoria === 'marco' ? '🔲' : item.categoria === 'academico' ? '📝' : '🎁' }}
            </template>
          </div>
          <h3 class="font-bold text-text dark:text-dark-text mb-1">{{ item.nombre }}</h3>
          <p class="text-xs text-text-muted mb-4 line-clamp-2">
            {{ item.requiere_aprobacion ? 'Requiere aprobación del profesor' : 'Se equipa automáticamente en tu perfil' }}
          </p>
        </div>
        
        <div class="pt-4 border-t border-border dark:border-white/10 flex items-center justify-between">
          <p class="font-bold text-lg text-amber-600 dark:text-amber-400 flex items-center gap-1">
            {{ item.precio_monedas }} 🪙
          </p>
          <BaseButton 
            size="sm" 
            :variant="(authStore.perfil?.monedas || 0) >= item.precio_monedas ? 'primary' : 'secondary'"
            :disabled="(authStore.perfil?.monedas || 0) < item.precio_monedas || comprando"
            @click="intentarComprar(item.id, item.nombre)"
          >
            Canjear
          </BaseButton>
        </div>
      </BaseCard>
    </div>

    <RewardConfetti :active="showReward" @complete="showReward = false" />
  </div>
</template>
