<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(defineProps<{
  variant?: 'primary' | 'mint' | 'amber' | 'violet' | 'danger' | 'neutral'
  size?: 'sm' | 'md'
}>(), {
  variant: 'primary',
  size: 'md'
})

const classes = computed(() => {
  const variants: Record<string, string> = {
    primary: 'bg-primary-bg text-primary dark:bg-primary/15',
    mint: 'bg-mint-bg text-mint dark:bg-mint/15',
    amber: 'bg-amber-bg text-amber dark:bg-amber/15',
    violet: 'bg-violet-bg text-violet dark:bg-violet/15',
    danger: 'bg-danger-bg text-danger dark:bg-danger/15',
    neutral: 'bg-surface dark:bg-dark-card2 text-text-muted dark:text-dark-muted',
  }

  const sizes: Record<string, string> = {
    sm: 'text-[10px] px-1.5 py-0.5',
    md: 'text-xs px-2 py-0.5',
  }

  return `inline-flex items-center font-semibold rounded-full ${variants[props.variant]} ${sizes[props.size]}`
})
</script>

<template>
  <span :class="classes">
    <slot />
  </span>
</template>
