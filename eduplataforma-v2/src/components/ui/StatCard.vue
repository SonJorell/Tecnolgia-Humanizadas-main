<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
 icon: any
 label: string
 value: string | number
 iconBg?: string
 subtitle?: string
}>()

const displayValue = computed(() =>
 typeof props.value === 'number' ? props.value.toLocaleString('es-CL') : props.value
)
</script>

<template>
 <div class="bg-surface-container-lowest rounded-xl p-4 shadow-card card-hover">
 <div class="flex items-center gap-3">
 <div :class="['w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0', iconBg || 'bg-primary-container']">
 <component :is="icon" :size="20" />
 </div>
 <div class="min-w-0">
 <p class="font-headline-lg font-extrabold text-2xl text-on-surface leading-none">
 {{ displayValue }}
 </p>
 <p class="text-xs text-on-surface-muted mt-0.5">{{ label }}</p>
 <p v-if="subtitle" class="text-[11px] text-on-secondary-container mt-0.5">{{ subtitle }}</p>
 </div>
 </div>
 </div>
</template>
