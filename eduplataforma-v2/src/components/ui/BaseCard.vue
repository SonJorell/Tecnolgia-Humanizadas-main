<script setup lang="ts">
withDefaults(defineProps<{
 hover?: boolean
}>(), {
 hover: false
})
</script>

<template>
 <div :class="['bg-surface-container-lowest rounded-xl p-4 md:p-5 shadow-card', hover ? 'card-hover cursor-pointer' : '']">
 <slot />
 </div>
</template>
