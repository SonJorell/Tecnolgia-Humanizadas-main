<script setup lang="ts">
import { useAccessibilityStore } from '@/stores/accessibility'
// Inicializar la tienda de accesibilidad
useAccessibilityStore()
</script>

<template>
  <router-view />
</template>
