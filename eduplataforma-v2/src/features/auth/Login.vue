<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useAppStore } from '@/stores/app'
import { useConnectivity } from '@/composables/useConnectivity'
import Logo from '@/components/ui/Logo.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import { Mail, Lock, Eye, EyeOff } from 'lucide-vue-next'

const router = useRouter()
const authStore = useAuthStore()
const appStore = useAppStore()
useConnectivity()

const email = ref('')
const password = ref('')
const showPwd = ref(false)
const loading = ref(false)
const error = ref('')

const connColor = computed(() =>
  appStore.conexion === 'ONLINE_SUPABASE' ? 'bg-[#2db88a]' :
  appStore.conexion === 'ONLINE_LAN_ONLY' ? 'bg-[#e8a020]' : 'bg-[#e05050]'
)

const connText = computed(() =>
  appStore.conexion === 'ONLINE_SUPABASE' ? 'Conectado a Supabase' :
  appStore.conexion === 'ONLINE_LAN_ONLY' ? 'Solo LAN' : 'Modo offline'
)

async function handleSubmit() {
  error.value = ''
  loading.value = true

  try {
    await authStore.signIn(email.value, password.value)
    if (authStore.perfil) {
      router.push(`/${authStore.perfil.rol}`)
    }
  } catch (err: any) {
    error.value = err.message || 'Credenciales incorrectas'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-surface to-primary-bg dark:from-dark-surface dark:to-dark-card flex items-center justify-center p-4">
    <div class="max-w-sm w-full">
      <form
        @submit.prevent="handleSubmit"
        class="bg-card dark:bg-dark-card rounded-2xl shadow-modal p-8 animate-slide-up"
      >
        <!-- Logo -->
        <div class="flex flex-col items-center mb-6">
          <Logo :size="48" />
          <h1 class="font-display text-2xl font-extrabold text-text dark:text-dark-text mt-3">
            EduPlataforma v2.0
          </h1>
          <p class="text-sm text-text-muted dark:text-dark-muted mt-1">
            Tu escuela, sin límites
          </p>
        </div>

        <!-- Error -->
        <div
          v-if="error"
          class="bg-danger-bg dark:bg-danger/20 text-danger text-sm p-3 rounded-lg mb-4 animate-slide-up"
        >
          {{ error }}
        </div>

        <!-- Email -->
        <div class="mb-4">
          <label class="block text-xs font-medium text-text-muted dark:text-dark-muted mb-1.5">
            Correo electrónico
          </label>
          <div class="relative">
            <Mail :size="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-text-light" />
            <input
              id="email-input"
              v-model="email"
              type="email"
              placeholder="usuario@escuela.cl"
              required
              class="w-full h-11 pl-10 pr-4 rounded-lg bg-surface dark:bg-dark-card2 border border-border dark:border-white/10 text-sm text-text dark:text-dark-text placeholder:text-text-light focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all font-body"
            />
          </div>
        </div>

        <!-- Password -->
        <div class="mb-6">
          <label class="block text-xs font-medium text-text-muted dark:text-dark-muted mb-1.5">
            Contraseña
          </label>
          <div class="relative">
            <Lock :size="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-text-light" />
            <input
              id="password-input"
              v-model="password"
              :type="showPwd ? 'text' : 'password'"
              placeholder="••••••••"
              required
              class="w-full h-11 pl-10 pr-10 rounded-lg bg-surface dark:bg-dark-card2 border border-border dark:border-white/10 text-sm text-text dark:text-dark-text placeholder:text-text-light focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all font-body"
            />
            <button
              type="button"
              class="absolute right-3 top-1/2 -translate-y-1/2 text-text-light hover:text-text-muted transition-colors"
              @click="showPwd = !showPwd"
            >
              <EyeOff v-if="showPwd" :size="16" />
              <Eye v-else :size="16" />
            </button>
          </div>
        </div>

        <!-- Submit -->
        <BaseButton
          id="login-button"
          type="submit"
          full-width
          size="lg"
          :loading="loading"
        >
          Ingresar
        </BaseButton>

        <!-- Connection status -->
        <div class="flex items-center justify-center gap-2 mt-4">
          <div :class="['w-2 h-2 rounded-full', connColor]" />
          <span class="text-xs text-text-muted dark:text-dark-muted">Estado: {{ connText }}</span>
        </div>
      </form>

      <!-- Footer -->
      <p class="text-center text-xs text-text-light mt-6">
        J2N Software · Santo Tomás Arica 2026
      </p>
    </div>
  </div>
</template>
