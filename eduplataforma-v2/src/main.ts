import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import App from './App.vue'
import { useAuthStore } from './stores/auth'
import { useAppStore } from './stores/app'
import './index.css'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

// Inicializar sesión y tema
const authStore = useAuthStore()
authStore.initSession()

const appStore = useAppStore()
appStore.initDarkMode()

app.mount('#app')
