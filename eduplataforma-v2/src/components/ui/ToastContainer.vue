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
  info: 'bg-primary-bg dark:bg-primary/15 border-primary/20',
  xp: 'bg-amber-bg dark:bg-amber/15 border-amber/20',
  sync: 'bg-mint-bg dark:bg-mint/15 border-mint/20',
  error: 'bg-danger-bg dark:bg-danger/15 border-danger/20',
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
          <p class="text-sm font-medium text-text dark:text-dark-text flex-1">{{ toast.mensaje }}</p>
          <button
            class="text-text-light hover:text-text-muted transition-colors flex-shrink-0"
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
