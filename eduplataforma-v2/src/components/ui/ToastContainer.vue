<script setup lang="ts">
import { computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { X } from 'lucide-vue-next'

const appStore = useAppStore()

const iconMap: Record<string, string> = {
 info: 'ℹ️',
 xp: '🌟',
 sync: '🔄',
 error: '❌',
}

const bgMap: Record<string, string> = {
 info: 'bg-primary-container border-primary/20',
 xp: 'bg-tertiary-100 border-tertiary/20',
 sync: 'bg-secondary-container border-secondary/20',
 error: 'bg-error-container border-error/20',
}

const visibleToasts = computed(() => appStore.toasts)
</script>

<template>
 <Teleport to="body">
 <div class="fixed bottom-24 right-4 md:bottom-6 md:right-6 z-[60] space-y-2 max-w-sm w-full pointer-events-none">
 <TransitionGroup name="toast">
 <div
 v-for="toast in visibleToasts"
 :key="toast.id"
 :class="['pointer-events-auto flex items-center gap-3 px-4 py-3 rounded-xl shadow-hover border backdrop-blur-sm', bgMap[toast.tipo] || bgMap.info]"
 >
 <span class="text-base flex-shrink-0">{{ iconMap[toast.tipo] || 'ℹ️' }}</span>
 <p class="text-sm font-medium text-on-surface flex-1">{{ toast.mensaje }}</p>
 <button type="button"
 class="text-on-surface-light hover:text-on-surface-muted transition-colors flex-shrink-0"
 @click="appStore.removeToast(toast.id)"
 >
 <X :size="14" />
 </button>
 </div>
 </TransitionGroup>
 </div>
 </Teleport>
</template>

<style scoped>
.toast-enter-active {
 animation: slideUpFade 200ms ease-out;
}
.toast-leave-active {
 animation: slideUpFade 150ms ease-in reverse;
}
</style>
