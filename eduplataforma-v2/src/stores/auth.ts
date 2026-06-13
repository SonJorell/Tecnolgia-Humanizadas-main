// ═══════════════════════════════════
// Store: Autenticación y Perfil (Pinia)
// Portado desde Zustand authStore
// ═══════════════════════════════════

import { ref } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/services/supabase'
import { idb } from '@/services/idb'
import type { Perfil } from '@/types/user'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<any | null>(null)
  const perfil = ref<Perfil | null>(null)
  const loading = ref(true)
  const error = ref<string | null>(null)

  async function signIn(email: string, password: string): Promise<void> {
    loading.value = true
    error.value = null

    try {
      const { data, error: authError } = await supabase.auth.signInWithPassword({ email, password })
      if (authError) throw authError
      user.value = data.user
      await loadPerfil()
    } catch (err: any) {
      error.value = err.message || 'Error al iniciar sesión'
      loading.value = false
      throw err
    }
  }

  async function signOut(): Promise<void> {
    await supabase.auth.signOut()
    user.value = null
    perfil.value = null
    error.value = null
  }

  async function loadPerfil(): Promise<void> {
    try {
      const { data: { user: authUser } } = await supabase.auth.getUser()
      if (!authUser) {
        // Intentar cargar de IDB si hay sesión offline
        const cachedPerfil = await idb.get('perfiles', user.value?.id || '')
        if (cachedPerfil) {
          perfil.value = cachedPerfil as unknown as Perfil
        }
        loading.value = false
        return
      }

      const { data, error: dbError } = await supabase
        .from('perfiles')
        .select('*')
        .eq('id', authUser.id)
        .single()

      if (dbError) throw dbError

      user.value = authUser
      perfil.value = data as Perfil
      loading.value = false

      // Cachear perfil en IDB para acceso offline
      if (data) {
        await idb.put('perfiles', data as any)
      }
    } catch (err) {
      console.error('[Auth] Error cargando perfil:', err)
      // Fallback a IDB
      if (user.value?.id) {
        const cachedPerfil = await idb.get('perfiles', user.value.id)
        if (cachedPerfil) {
          perfil.value = cachedPerfil as unknown as Perfil
        }
      }
      loading.value = false
    }
  }

  function clearError(): void {
    error.value = null
  }

  function updatePerfil(updates: Partial<Perfil>): void {
    if (perfil.value) {
      perfil.value = { ...perfil.value, ...updates }
      // Actualizar en IDB
      idb.put('perfiles', perfil.value as any)
    }
  }

  async function guardarPerfil(updates: Partial<Perfil>): Promise<void> {
    if (!perfil.value) return
    loading.value = true
    try {
      const { error: err } = await supabase
        .from('perfiles')
        .update(updates)
        .eq('id', perfil.value.id)
      
      if (err) throw err
      
      // Actualizar localmente
      updatePerfil(updates)
    } catch (err: any) {
      error.value = err.message || 'Error al guardar perfil'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function cambiarPassword(newPassword: string): Promise<void> {
    loading.value = true
    try {
      const { error: err } = await supabase.auth.updateUser({ password: newPassword })
      if (err) throw err
    } catch (err: any) {
      error.value = err.message || 'Error al cambiar contraseña'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function initialize(): Promise<void> {
    const { data: { session } } = await supabase.auth.getSession()
    if (session?.user) {
      user.value = session.user
      await loadPerfil()
    } else {
      user.value = null
      perfil.value = null
      loading.value = false
    }

    supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.user) {
        user.value = session.user
        loadPerfil()
      } else {
        user.value = null
        perfil.value = null
        loading.value = false
      }
    })
  }

  return {
    // State
    user,
    perfil,
    loading,
    error,
    // Actions
    signIn,
    signOut,
    loadPerfil,
    clearError,
    updatePerfil,
    guardarPerfil,
    cambiarPassword,
    initialize
  }
})
