<script setup lang="ts">
import { computed } from 'vue'
import { Loader2 } from 'lucide-vue-next'

const props = withDefaults(defineProps<{
 variant?: 'primary' | 'secondary' | 'danger' | 'ghost'
 size?: 'sm' | 'md' | 'lg'
 fullWidth?: boolean
 loading?: boolean
 disabled?: boolean
}>(), {
 variant: 'primary',
 size: 'md',
 fullWidth: false,
 loading: false,
 disabled: false
})

const classes = computed(() => {
 const base = 'inline-flex items-center justify-center gap-2 font-label-md rounded-lg transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed'

 const variants: Record<string, string> = {
 primary: 'bg-primary hover:bg-on-primary-fixed-variant text-white focus:ring-primary/40 shadow-sm hover:shadow-md',
 secondary: 'bg-transparent border border-primary text-primary hover:bg-primary/5 focus:ring-primary/30',
 danger: 'bg-error hover:bg-[#93000a] text-white focus:ring-error/40',
 ghost: 'bg-transparent hover:bg-surface-container-low text-on-surface-variant focus:ring-primary/20',
 }

 const sizes: Record<string, string> = {
 sm: 'h-8 px-3 text-xs',
 md: 'h-10 px-4 text-sm',
 lg: 'h-12 px-6 text-base',
 }

 return [
 base,
 variants[props.variant],
 sizes[props.size],
 props.fullWidth ? 'w-full' : '',
 ].join(' ')
})
</script>

<template>
 <button type="button"
 :class="classes"
 :disabled="disabled || loading"
 >
 <Loader2 v-if="loading" :size="16" class="animate-spin" />
 <slot />
 </button>
</template>
