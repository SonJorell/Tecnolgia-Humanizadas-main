<script setup lang="ts">
import { useConnectivity } from '@/composables/useConnectivity'
import ConnBanner from './ConnBanner.vue'
import Topbar from './Topbar.vue'
import Sidebar from './Sidebar.vue'
import BottomNav from './BottomNav.vue'
import ToastContainer from '@/components/ui/ToastContainer.vue'

useConnectivity()
</script>

<template>
  <div class="min-h-screen bg-surface dark:bg-dark-surface">
    <ConnBanner />
    <div style="padding-top: 36px">
      <Topbar />
      <div class="app-layout">
        <Sidebar />
        <main class="main-content flex-1 min-h-[calc(100dvh-96px)]">
          <router-view />
        </main>
      </div>
    </div>
    <BottomNav />
    <ToastContainer />
  </div>
</template>
