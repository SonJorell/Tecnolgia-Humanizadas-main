<script setup lang="ts">
import { useConnectivity } from '@/composables/useConnectivity'
import ConnBanner from './ConnBanner.vue'
import Topbar from './Topbar.vue'
import Sidebar from './Sidebar.vue'
import BottomNav from './BottomNav.vue'
import ToastContainer from '@/components/ui/ToastContainer.vue'
import { onMounted, ref } from 'vue'

useConnectivity()

const isLoaded = ref(false)
onMounted(() => {
 setTimeout(() => {
 isLoaded.value = true
 }, 100)
})
</script>

<template>
 <div class="min-h-screen bg-background text-on-background relative pt-8 transition-colors duration-300">
 <ConnBanner />
 
 <Sidebar />
 
 <main 
 class="md:ml-72 pb-20 md:pb-0 min-h-[calc(100vh-32px)] transition-opacity duration-700 ease-out flex flex-col" 
 :class="isLoaded ? 'opacity-100' : 'opacity-0'"
 >
 <Topbar />
 
 <div class="flex-grow">
 <router-view />
 </div>
 </main>

 <BottomNav />
 
 <ToastContainer />
 </div>
</template>
