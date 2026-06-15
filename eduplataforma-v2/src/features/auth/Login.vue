<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useAppStore } from '@/stores/app'
import { useConnectivity } from '@/composables/useConnectivity'

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
  <div
    class="mesh-background min-h-screen flex flex-col items-center justify-center font-body-md text-on-surface p-margin-mobile md:p-gutter">
    <main class="relative z-10 w-full max-w-md sm:max-w-[460px] px-4 sm:px-0">
      <div
        class="glass-card rounded-3xl p-8 md:p-12 flex flex-col items-center transition-all duration-1000 ease-in-out opacity-100 translate-y-0 scale-100 animate-slide-up">

        <!-- Modern 3D/Brand Mark -->
        <div class="mb-10 flex flex-col items-center">
          <div class="relative group cursor-default">
            <div
              class="absolute -inset-2 bg-gradient-to-tr from-primary to-secondary opacity-20 blur-xl rounded-full group-hover:opacity-40 transition duration-1000">
            </div>
            <div
              class="relative w-20 h-20 bg-white/80 dark:bg-surface-container-low/80 rounded-2xl flex items-center justify-center shadow-2xl overflow-hidden border border-white/50 dark:border-white/10 backdrop-blur-sm">
              <div class="absolute inset-0 bg-gradient-to-br from-primary/20 via-transparent to-secondary/10"></div>
              <span class="material-symbols-outlined text-primary text-[48px] z-10 drop-shadow-sm"
                style="font-variation-settings: 'FILL' 1;">school</span>
            </div>
          </div>
          <h1 class="mt-8 font-headline-xl text-[32px] text-primary tracking-tighter font-[900]">
            EduPlataforma
          </h1>
        </div>

        <!-- Welcome Message -->
        <div class="w-full mb-8 text-center">
          <h2 class="font-headline-lg text-headline-lg text-on-background mb-3 tracking-tight font-bold">Acceso
            Institucional</h2>
          <p class="font-body-md text-on-surface-variant/80">Bienvenido de nuevo al ecosistema premium de aprendizaje.
          </p>
        </div>

        <!-- Error -->
        <div v-if="error"
          class="w-full bg-error-container text-error text-sm p-4 rounded-xl mb-6 flex items-center gap-3 animate-fade-in font-medium shadow-sm">
          <span class="material-symbols-outlined text-[20px]">error</span>
          {{ error }}
        </div>

        <!-- Login Form -->
        <form class="w-full space-y-6" @submit.prevent="handleSubmit">
          <!-- Email Field -->
          <div class="space-y-2">
            <label class="block font-label-md text-[13px] text-on-surface-variant/70 uppercase tracking-[0.1em]"
              for="email">
              Email Institucional
            </label>
            <div class="relative">
              <span
                class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant/40 text-[22px]">alternate_email</span>
              <input id="email" v-model="email" type="email" placeholder="nombre.apellido@escuela.cl" required
                class="input-field w-full pl-12 pr-4 py-4 bg-white/60 dark:bg-surface-container-lowest/60 border border-outline-variant/30 rounded-xl font-body-md text-on-surface placeholder:text-on-surface-variant/30 focus:bg-white dark:focus:bg-surface-container-lowest outline-none" />
            </div>
          </div>

          <!-- Password Field -->
          <div class="space-y-2">
            <label class="block font-label-md text-[13px] text-on-surface-variant/70 uppercase tracking-[0.1em]"
              for="password">
              Contraseña
            </label>
            <div class="relative">
              <span
                class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant/40 text-[22px]">lock</span>
              <input id="password" v-model="password" :type="showPwd ? 'text' : 'password'" placeholder="••••••••"
                required
                class="input-field w-full pl-12 pr-12 py-4 bg-white/60 dark:bg-surface-container-lowest/60 border border-outline-variant/30 rounded-xl font-body-md text-on-surface placeholder:text-on-surface-variant/30 focus:bg-white dark:focus:bg-surface-container-lowest outline-none" />
              <button type="button"
                class="absolute right-4 top-1/2 -translate-y-1/2 text-on-surface-variant/40 hover:text-primary transition-colors p-1"
                @click="showPwd = !showPwd">
                <span class="material-symbols-outlined text-[20px]">{{ showPwd ? 'visibility_off' : 'visibility'
                }}</span>
              </button>
            </div>
          </div>

          <!-- Action Button -->
          <button type="submit" :disabled="loading"
            class="btn-premium w-full text-white font-headline-md text-[17px] py-4 rounded-xl shadow-lg mt-4 flex items-center justify-center gap-3 tracking-tight group disabled:opacity-70 disabled:pointer-events-none">
            <span class="font-bold">{{ loading ? 'Verificando...' : 'Ingresar al Portal' }}</span>
            <span v-if="!loading"
              class="material-symbols-outlined text-[24px] group-hover:translate-x-1 transition-transform">arrow_forward</span>
            <span v-else class="material-symbols-outlined text-[24px] animate-spin">sync</span>
          </button>
        </form>

        <!-- Connection status -->
        <div class="flex items-center justify-center gap-2 mt-8">
          <div :class="['w-2 h-2 rounded-full shadow-sm', connColor]" />
          <span class="text-xs text-on-surface-variant/70 tracking-wide font-medium uppercase">Estado: {{ connText
          }}</span>
        </div>
      </div>

      <!-- External Footer -->
      <footer class="mt-10 flex flex-col items-center gap-5 w-full">
        <p class="font-body-sm text-on-surface-variant/50 font-medium tracking-tight text-center">© 2026 EduPlataforma
          . Experiencia de aprendizaje premium.</p>
        <div class="flex gap-8">
          <a class="font-label-sm text-on-surface-variant/50 hover:text-primary transition-colors uppercase tracking-widest text-[10px] font-bold"
            href="#">Privacidad</a>
          <a class="font-label-sm text-on-surface-variant/50 hover:text-primary transition-colors uppercase tracking-widest text-[10px] font-bold"
            href="#">Términos</a>
          <a class="font-label-sm text-on-surface-variant/50 hover:text-primary transition-colors uppercase tracking-widest text-[10px] font-bold"
            href="#">Contacto</a>
        </div>
      </footer>
    </main>
  </div>
</template>

<style scoped>
/* Sophisticated mesh gradient with deep blues and teals */
.mesh-background {
  background-color: var(--color-surface);
  background-image:
    radial-gradient(at 0% 0%, hsla(205, 100%, 50%, 0.08) 0px, transparent 50%),
    radial-gradient(at 50% 0%, hsla(185, 100%, 50%, 0.05) 0px, transparent 50%),
    radial-gradient(at 100% 0%, hsla(200, 100%, 50%, 0.08) 0px, transparent 50%),
    radial-gradient(at 0% 100%, hsla(190, 100%, 50%, 0.05) 0px, transparent 50%),
    radial-gradient(at 50% 100%, hsla(210, 100%, 50%, 0.08) 0px, transparent 50%),
    radial-gradient(at 100% 100%, hsla(170, 100%, 50%, 0.05) 0px, transparent 50%);
  animation: mesh-move 25s ease-infinite alternate;
  background-size: 200% 200%;
}

:global(.dark) .mesh-background {
  background-image:
    radial-gradient(at 0% 0%, hsla(205, 100%, 60%, 0.08) 0px, transparent 50%),
    radial-gradient(at 50% 0%, hsla(185, 100%, 60%, 0.05) 0px, transparent 50%),
    radial-gradient(at 100% 0%, hsla(200, 100%, 60%, 0.08) 0px, transparent 50%),
    radial-gradient(at 0% 100%, hsla(190, 100%, 60%, 0.05) 0px, transparent 50%),
    radial-gradient(at 50% 100%, hsla(210, 100%, 60%, 0.08) 0px, transparent 50%),
    radial-gradient(at 100% 100%, hsla(170, 100%, 60%, 0.05) 0px, transparent 50%);
}

@keyframes mesh-move {
  0% {
    background-position: 0% 0%;
  }

  100% {
    background-position: 100% 100%;
  }
}

/* Enhanced Glassmorphism Card */
.glass-card {
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(40px) saturate(200%);
  -webkit-backdrop-filter: blur(40px) saturate(200%);
  border: 1px solid rgba(150, 204, 255, 0.2);
  box-shadow: 0 40px 100px -20px rgba(0, 0, 0, 0.06), 0 10px 40px -10px rgba(0, 0, 0, 0.04);
}

:global(.dark) .glass-card {
  background: rgba(4, 14, 31, 0.6);
  border: 1px solid rgba(255, 255, 255, 0.05);
  box-shadow: 0 40px 100px -20px rgba(0, 0, 0, 0.3), 0 10px 40px -10px rgba(0, 0, 0, 0.2);
}

/* Modern 3D-ish lift for inputs with focus glow */
.input-field {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.input-field:focus {
  box-shadow: 0 0 0 4px rgba(0, 86, 135, 0.08), 0 10px 15px -3px rgba(0, 86, 135, 0.1);
  transform: translateY(-2px);
  border-color: var(--color-primary);
}

:global(.dark) .input-field:focus {
  box-shadow: 0 0 0 4px rgba(142, 213, 255, 0.08), 0 10px 15px -3px rgba(142, 213, 255, 0.1);
}

/* More prominent premium button effect */
.btn-premium {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.btn-premium:hover:not(:disabled) {
  transform: scale(1.02) translateY(-3px);
  box-shadow: 0 20px 30px -12px rgba(0, 86, 135, 0.4);
  filter: brightness(1.15);
}

:global(.dark) .btn-premium:hover:not(:disabled) {
  box-shadow: 0 20px 30px -12px rgba(142, 213, 255, 0.2);
}

.btn-premium:active:not(:disabled) {
  transform: scale(0.98);
}
</style>
