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
 primary: 'bg-primary-container text-primary ',
 mint: 'bg-secondary-container text-on-secondary-container ',
 amber: 'bg-tertiary-100 text-tertiary-800 ',
 violet: 'bg-violet-bg text-violet ',
 danger: 'bg-error-container text-error ',
 neutral: 'bg-surface-container-low text-on-surface-muted ',
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
