import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { idb } from '@/services/idb'
import { supabase } from '@/services/supabase'
import { useAppStore } from './app'
import type { Entrega } from '@/types/database'

export const useTareasStore = defineStore('tareas', () => {
  const appStore = useAppStore()
  const entregas = ref<Entrega[]>([])
  const loading = ref(false)

  const pendientes = computed(() => entregas.value.filter(e => e.estado === 'pendiente'))
  const completadas = computed(() => entregas.value.filter(e => ['entregada', 'revisada'].includes(e.estado)))

  async function cargarEntregas(alumnoId: string) {
    loading.value = true
    try {
      // 1. Carga local (offline-first)
      const localEntregas = (await idb.getAll('entregas')) as Entrega[]
      if (localEntregas.length > 0) {
        entregas.value = localEntregas.filter(e => e.alumno_id === alumnoId)
      }

      // 2. Actualizar desde Supabase si hay red
      if (appStore.isOnline) {
        const { data } = await supabase
          .from('entregas')
          .select('*, material:materiales(*)')
          .eq('alumno_id', alumnoId)

        if (data) {
          entregas.value = data as any
          // Al guardar entregas localmente no guardamos el material anidado entero en la misma tabla
          const entregasClean = data.map((d: any) => {
            const { material, ...rest } = d
            return rest
          })
          await idb.putMany('entregas', entregasClean as any)
          
          const materiales = data.map((d: any) => d.material).filter(Boolean)
          if (materiales.length > 0) {
             await idb.putMany('materiales', materiales as any)
          }
        }
      }
    } catch (err) {
      console.error('Error cargando entregas:', err)
    } finally {
      loading.value = false
    }
  }

  function getEntregasPorCurso(_cursoId: string) {
    return entregas.value.filter(_e => {
       // Ojo: asume que e.material_id mapea a un material que conocemos (lo ideal es traer la relación unida)
       // Esto lo resolveremos en los componentes buscando el material correspondiente
       return true
    })
  }

  return {
    entregas,
    pendientes,
    completadas,
    loading,
    cargarEntregas,
    getEntregasPorCurso
  }
})
