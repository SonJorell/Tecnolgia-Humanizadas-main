import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import App from './App.vue'
import { useAuthStore } from './stores/auth'
import { useAppStore } from './stores/app'
import './index.css'

import BaseButton from './components/ui/BaseButton.vue'
import BaseCard from './components/ui/BaseCard.vue'
import BaseBadge from './components/ui/BaseBadge.vue'

async function bootstrap() {
  const app = createApp(App)
  const pinia = createPinia()

  app.use(pinia)
  
  app.component('BaseButton', BaseButton)
  app.component('BaseCard', BaseCard)
  app.component('BaseBadge', BaseBadge)

  // Inicializar sesión y tema
  const authStore = useAuthStore()
  await authStore.initialize()

  const appStore = useAppStore()
  appStore.initDarkMode()

  app.use(router)
  app.mount('#app')
}

bootstrap()
