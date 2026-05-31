import { defineStore } from 'pinia'
import { ref, computed, toRaw } from 'vue'
import { idb } from '@/services/idb'
import { useAuthStore } from './auth'
import { supabase } from '@/services/supabase'

export interface Logro {
  id: string
  nombre: string
  descripcion: string
  icono: string
  xp_premio: number
  categoria: string
  desbloqueado?: boolean
}

export interface ItemTienda {
  id: string
  categoria: 'marco' | 'tema' | 'academico' | 'fisico' | 'banner' | 'avatar'
  nombre: string
  costo: number
  stock: number
  requiere_aprobacion: boolean
  url_asset?: string
}

export const useGamificacionStore = defineStore('gamificacion', () => {
  const authStore = useAuthStore()

  // Estado Local (Offline First)
  const logros = ref<Logro[]>([
    { id: '1', nombre: 'Primer Paso', descripcion: 'Entra a la plataforma por primera vez', icono: '🚀', xp_premio: 50, categoria: 'constancia', desbloqueado: true },
    { id: '2', nombre: 'Entregador Serial', descripcion: 'Entrega 5 tareas seguidas a tiempo', icono: '🔥', xp_premio: 200, categoria: 'academico' },
    { id: '3', nombre: 'Búho Nocturno', descripcion: 'Entrega una tarea después de las 22:00', icono: '🦉', xp_premio: 100, categoria: 'constancia' },
    { id: '4', nombre: 'La Voz del Pueblo', descripcion: 'Envía tu primer feedback', icono: '🗣️', xp_premio: 50, categoria: 'participacion' },
  ])

  const tienda = ref<any[]>([])

  async function loadTienda() {
    try {
      const { data } = await supabase.from('premios').select('*').eq('activo', true)
      if (data) tienda.value = data
    } catch (err) {
      console.error('Error loading tienda', err)
    }
  }

  async function loadLogrosAsignados() {
    if (!authStore.user?.id) return
    try {
      const { data } = await supabase
        .from('logros_asignados')
        .select('*, logro:logros_docente(*)')
        .eq('alumno_id', authStore.user.id)
      
      if (data) {
        logros.value = logros.value.filter(l => l.categoria !== 'docente')
        data.forEach((item: any) => {
          if (item.logro) {
            logros.value.push({
              id: `docente_${item.id}`,
              nombre: item.logro.nombre,
              descripcion: item.logro.descripcion,
              icono: item.logro.icono || '🏆',
              xp_premio: item.logro.recompensa_xp || 0,
              categoria: 'docente',
              desbloqueado: true
            })
          }
        })
      }
    } catch (err) {
      console.error('Error loading logros_asignados', err)
    }
  }

  // Getters
  const progresoNivel = computed(() => {
    const xp = authStore.perfil?.xp || 0
    const nivel = authStore.perfil?.nivel || 1
    const xpMeta = nivel * 100
    const xpBase = (nivel - 1) * 100
    const xpActualEnNivel = xp - xpBase
    return Math.min(100, Math.max(0, (xpActualEnNivel / (xpMeta - xpBase)) * 100))
  })

  const inventarioPremios = computed(() => {
    return authStore.perfil?.inventario_premios || []
  })

  // Actions
  async function ganarXP(cantidad: number, _razon?: string) {
    if (!authStore.perfil) return
    const nuevoXp = authStore.perfil.xp + cantidad
    const nuevoNivel = Math.floor(Math.sqrt(nuevoXp / 100)) + 1 // formula simple
    
    authStore.perfil.xp = nuevoXp
    if (nuevoNivel > authStore.perfil.nivel) {
      authStore.perfil.nivel = nuevoNivel
    }
    
    // Guardar offline
    await idb.put('perfiles', toRaw(authStore.perfil) as any)
    
    // Cola de sync para el backend
    await idb.put('sync_queue', {
      id: crypto.randomUUID(),
      tipo: 'gamificacion',
      accion: 'update',
      tabla: 'perfiles',
      payload: { id: authStore.perfil.id, xp: authStore.perfil.xp, nivel: authStore.perfil.nivel },
      intentos: 0,
      creado_en: Date.now(),
      ultimo_intento: null,
      error_msg: null
    })
  }

  async function ganarMonedas(cantidad: number, _razon?: string) {
    if (!authStore.perfil) return
    authStore.perfil.monedas += cantidad
    await idb.put('perfiles', toRaw(authStore.perfil) as any)
    // Se enviaría en la misma sync de perfiles
  }

  async function comprarItem(itemId: string) {
    const item = tienda.value.find(i => i.id === itemId)
    if (!item || !authStore.perfil) throw new Error('Item no encontrado')
    if (authStore.perfil.monedas < item.precio_monedas) throw new Error('Monedas insuficientes')

    try {
      // Llamada RPC a Supabase para transacción segura
      const { data, error } = await supabase.rpc('realizar_canje', { p_premio_id: itemId })
      if (error) throw error

      // Actualizar monedas localmente usando el valor devuelto o restando manualmente
      authStore.perfil.monedas = data?.nuevo_saldo ?? (authStore.perfil.monedas - item.precio_monedas)
      
      // Aplicar de inmediato (Optimistic UI + Persistencia)
      const updates: any = {}
      if (!authStore.perfil.inventario_premios) {
        authStore.perfil.inventario_premios = []
      }
      
      if (item.categoria === 'marco') {
        updates.marco_activo_id = item.icono
        if (!authStore.perfil.inventario_premios.includes(item.icono)) {
          authStore.perfil.inventario_premios.push(item.icono)
          updates.inventario_premios = authStore.perfil.inventario_premios
        }
      }
      else if (item.categoria === 'banner') {
        updates.banner_activo_id = item.icono
        if (!authStore.perfil.inventario_premios.includes(item.icono)) {
          authStore.perfil.inventario_premios.push(item.icono)
          updates.inventario_premios = authStore.perfil.inventario_premios
        }
      }
      else if (item.categoria === 'avatar') {
        updates.avatar_activo_id = item.icono
        if (!authStore.perfil.inventario_premios.includes(item.icono)) {
          authStore.perfil.inventario_premios.push(item.icono)
          updates.inventario_premios = authStore.perfil.inventario_premios
        }
      }

      if (Object.keys(updates).length > 0) {
        Object.assign(authStore.perfil, updates)
        await supabase.from('perfiles').update(updates).eq('id', authStore.perfil.id)
      }

      await idb.put('perfiles', toRaw(authStore.perfil) as any)

    } catch (err: any) {
      console.error(err)
      throw new Error(err.message || 'Error al procesar el canje en el servidor')
    }
  }

  return {
    logros,
    tienda,
    inventarioPremios,
    progresoNivel,
    ganarXP,
    ganarMonedas,
    comprarItem,
    loadTienda,
    loadLogrosAsignados
  }
})
