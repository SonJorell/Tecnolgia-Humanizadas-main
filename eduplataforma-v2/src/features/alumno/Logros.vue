<script setup lang="ts">
import { useGamificacionStore } from '@/stores/gamificacion'
import BaseCard from '@/components/ui/BaseCard.vue'
import { onMounted } from 'vue'

const store = useGamificacionStore()

onMounted(async () => {
  await store.loadLogrosAsignados()
})
</script>

<template>
  <div class="p-4 md:p-6 max-w-5xl mx-auto space-y-8 animate-fade-in">
    <div class="text-center md:text-left">
      <h1 class="font-display font-extrabold text-2xl md:text-4xl text-text dark:text-dark-text">🏆 Mis Logros</h1>
      <p class="text-sm text-text-muted mt-2">Completa tareas y participa para desbloquear medallas y ganar XP.</p>
    </div>

    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
      <BaseCard 
        v-for="logro in store.logros" 
        :key="logro.id"
        :class="['text-center transition-all duration-300', logro.desbloqueado ? 'border-2 border-mint shadow-mint/20' : 'opacity-60 grayscale hover:grayscale-0']"
      >
        <div 
          class="w-16 h-16 mx-auto rounded-full flex items-center justify-center text-3xl mb-3 shadow-inner"
          :class="logro.desbloqueado ? 'bg-mint-bg dark:bg-mint/20' : 'bg-surface dark:bg-dark-card2'"
        >
          {{ logro.icono }}
        </div>
        <h3 class="font-bold text-sm text-text dark:text-dark-text leading-tight mb-1">{{ logro.nombre }}</h3>
        <p class="text-xs text-text-muted mb-3 line-clamp-2">{{ logro.descripcion }}</p>
        
        <div class="inline-block bg-surface dark:bg-dark-card2 px-3 py-1 rounded-full border border-border dark:border-white/10">
          <span class="text-[10px] font-bold" :class="logro.desbloqueado ? 'text-mint' : 'text-primary'">
            {{ logro.desbloqueado ? '¡Desbloqueado!' : `+${logro.xp_premio} XP` }}
          </span>
        </div>
      </BaseCard>
    </div>
  </div>
</template>
