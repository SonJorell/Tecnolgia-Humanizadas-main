<script setup lang="ts">
defineProps<{ size?: number }>()
</script>

<template>
 <svg :width="size || 32" :height="size || 32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg" aria-label="EduPlataforma logo">
 <rect x="4" y="8" width="24" height="18" rx="3" fill="#1a6fa8"/>
 <rect x="15" y="8" width="1.5" height="18" fill="white" opacity="0.4"/>
 <path d="M11 5 Q16 2 21 5" stroke="#2db88a" stroke-width="2" stroke-linecap="round" fill="none"/>
 <path d="M13.5 7 Q16 5.5 18.5 7" stroke="#2db88a" stroke-width="1.5" stroke-linecap="round" fill="none"/>
 <circle cx="16" cy="8.5" r="1" fill="#2db88a"/>
 <rect x="7" y="14" width="6" height="1.5" rx="0.75" fill="white" opacity="0.7"/>
 <rect x="7" y="17" width="5" height="1.5" rx="0.75" fill="white" opacity="0.5"/>
 <rect x="19" y="14" width="6" height="1.5" rx="0.75" fill="white" opacity="0.7"/>
 <rect x="19" y="17" width="4" height="1.5" rx="0.75" fill="white" opacity="0.5"/>
 </svg>
</template>
