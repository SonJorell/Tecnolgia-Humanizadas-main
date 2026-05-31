import type { Router } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

export function setupGuards(router: Router): void {
  router.beforeEach((to, _from) => {
    const authStore = useAuthStore()

    // Rutas públicas (login)
    if (to.meta.public) {
      // Si ya está logueado, redirigir a su dashboard
      if (authStore.perfil) {
        return `/${authStore.perfil.rol}`
      }
      return true
    }

    // Sin sesión → login
    if (!authStore.perfil) {
      return '/login'
    }

    // Verificar rol
    const roles = to.meta.roles as string[] | undefined
    if (roles && !roles.includes(authStore.perfil.rol)) {
      return `/${authStore.perfil.rol}`
    }

    return true
  })
}
