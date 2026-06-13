<script setup lang="ts">
import { useAuthStore } from '@/stores/auth'
import { useGamificacionStore } from '@/stores/gamificacion'
import BaseButton from '@/components/ui/BaseButton.vue'

const authStore = useAuthStore()
const gamificacionStore = useGamificacionStore()

// Fake avatares para el blueprint
const avatares = ['👦', '👧', '🧑', '👨‍🚀', '🦸', '🐱', '🐶', '🦊']
</script>

<template>
 <div class="p-4 md:p-6 max-w-4xl mx-auto space-y-6 animate-fade-in">
 <!-- Header Perfil -->
 <div class="bg-surface-container-lowest rounded-3xl p-8 text-center shadow-sm border border-border-subtle relative overflow-hidden">
 <!-- Background pattern based on marco -->
 <div 
 class="absolute inset-0 opacity-10 pointer-events-none"
 :class="{
 'bg-gradient-to-br from-primary to-mint': authStore.perfil?.marco_activo_id === 'neon',
 'bg-gradient-to-br from-amber-500 to-red-500': authStore.perfil?.marco_activo_id === 'fire',
 }"
 />
 
 <div class="relative z-10">
 <div class="w-32 h-32 mx-auto rounded-full bg-surface-container-low flex items-center justify-center text-6xl shadow-inner border-4"
 :class="{
 'border-primary': authStore.perfil?.marco_activo_id === 'neon',
 'border-tertiary-500': authStore.perfil?.marco_activo_id === 'fire',
 'border-border-subtle ': !authStore.perfil?.marco_activo_id
 }">
 <img v-if="authStore.perfil?.avatar_url && (authStore.perfil.avatar_url.startsWith('http') || authStore.perfil.avatar_url.startsWith('data'))" :src="authStore.perfil.avatar_url" class="w-full h-full object-cover rounded-full" />
 <span v-else-if="authStore.perfil?.avatar_url">{{ authStore.perfil.avatar_url }}</span>
 <span v-else>🧑‍🎓</span>
 </div>
 
 <h1 class="font-headline-md font-bold text-3xl text-on-surface mt-4">
 {{ authStore.perfil?.nombre || 'Estudiante' }}
 </h1>
 <p class="text-primary font-bold tracking-wider uppercase text-sm mt-1">
 Nivel {{ authStore.perfil?.nivel || 1 }} - Explorador
 </p>
 
 <div class="max-w-xs mx-auto mt-6">
 <div class="flex justify-between text-xs font-semibold text-on-surface-variant mb-2">
 <span>Progreso XP</span>
 <span>{{ authStore.perfil?.xp || 0 }} / {{ (authStore.perfil?.nivel || 1) * 100 }}</span>
 </div>
 <div class="h-3 bg-surface-container-low rounded-full overflow-hidden">
 <div 
 class="h-full bg-primary rounded-full transition-all duration-1000"
 :style="{ width: `${gamificacionStore.progresoNivel}%` }"
 />
 </div>
 </div>
 </div>
 </div>

 <!-- Personalización -->
 <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
 <div class="bg-surface-container-lowest p-6 rounded-2xl shadow-sm border border-border-subtle">
 <h2 class="font-headline-md font-bold text-lg mb-4">Elige tu Avatar</h2>
 <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
 <button type="button" 
 v-for="(av, idx) in avatares" 
 :key="idx"
 class="w-14 h-14 rounded-xl text-3xl flex items-center justify-center bg-surface-container-low hover:bg-primary-bg transition-colors"
 >
 {{ av }}
 </button>
 </div>
 </div>
 
 <div class="bg-surface-container-lowest p-6 rounded-2xl shadow-sm border border-border-subtle">
 <h2 class="font-headline-md font-bold text-lg mb-4">Marcos Desbloqueados</h2>
 <div class="flex flex-col gap-3">
 <div class="flex items-center justify-between p-3 rounded-xl border-2 border-primary bg-primary-bg">
 <span class="font-semibold text-primary">Marco Normal</span>
 <span class="text-xs bg-primary text-white px-2 py-1 rounded">Equipado</span>
 </div>
 <div class="flex items-center justify-between p-3 rounded-xl border border-border-subtle opacity-50 grayscale">
 <span class="font-semibold">Marco Fuego</span>
 <span class="text-xs bg-surface-container-low px-2 py-1 rounded">Bloqueado</span>
 </div>
 </div>
 <BaseButton variant="ghost" class="w-full mt-4" @click="$router.push('/alumno/tienda')">
 Comprar más en Tienda
 </BaseButton>
 </div>
 </div>
 </div>
</template>
