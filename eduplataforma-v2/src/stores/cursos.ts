import { defineStore } from 'pinia'
import { ref } from 'vue'
import { idb } from '@/services/idb'
import { supabase } from '@/services/supabase'
import { useAppStore } from './app'
import type { Curso, Inscripcion, Material } from '@/types/database'

export const useCursosStore = defineStore('cursos', () => {
  const appStore = useAppStore()
  const inscripciones = ref<(Inscripcion & { curso: Curso })[]>([])
  const materiales = ref<Record<string, Material[]>>({})
  const loading = ref(false)

  async function cargarInscripciones(alumnoId: string) {
    loading.value = true
    try {
      // 1. Carga rápida desde caché local (Offline-first)
      try {
        const localInscs = (await idb.getAll('inscripciones')) as Inscripcion[]
        const localCursos = (await idb.getAll('cursos')) as Curso[]
        
        if (localInscs.length > 0) {
          const mix = localInscs
            .filter(i => i.alumno_id === alumnoId)
            .map(i => ({
              ...i,
              curso: localCursos.find(c => c.id === i.curso_id)
            }))
          inscripciones.value = mix as any
        }
      } catch (err) {
        console.warn('No se pudo cargar desde IDB:', err)
      }

      // 2. Si hay conexión, actualizar desde Supabase
      if (appStore.isOnline) {
        const { data, error } = await supabase
          .from('inscripciones')
          .select('*, curso:cursos(*)')
          .eq('alumno_id', alumnoId)

        if (error) {
          console.error('[cursosStore] Error fetching inscripciones:', error)
        } else if (data) {
          // Fetch teachers manually to avoid PostgREST ambiguity PGRST201
          const docenteIds = [...new Set(data.map(d => d.curso?.docente_id).filter(Boolean))]
          if (docenteIds.length > 0) {
            const { data: profes } = await supabase.from('perfiles').select('id, nombre').in('id', docenteIds)
            data.forEach(d => {
              if (d.curso && profes) {
                d.curso.docente = profes.find(p => p.id === d.curso.docente_id)
              }
            })
          }
          inscripciones.value = data as any
          // Guardar en caché para próximo inicio offline
          await idb.putMany('inscripciones', data.map((d: any) => ({ ...d, curso: undefined })))
          await idb.putMany('cursos', data.map((d: any) => d.curso).filter(Boolean))
        }
      }
    } catch (err) {
      console.error('[cursosStore] Exception cargando cursos:', err)
    } finally {
      loading.value = false
    }
  }

  async function cargarMateriales(cursoId: string) {
    try {
      // 1. Carga local
      try {
        const localMat = (await idb.getAll('materiales')) as unknown as Material[]
        materiales.value[cursoId] = localMat.filter(m => m.curso_id === cursoId)
      } catch (err) {
        console.warn('No se pudo cargar materiales locales:', err)
      }

      if (appStore.isOnline) {
        const { data, error } = await supabase
          .from('materiales')
          .select('*')
          .eq('curso_id', cursoId)
          .eq('publicado', true)
          .order('creado_en', { ascending: false })

        if (error) {
          console.error('[cursosStore] Error fetching materiales:', error)
        } else if (data) {
          materiales.value[cursoId] = data as any
          await idb.putMany('materiales', data as any)
        }
      }
    } catch (err) {
      console.error('[cursosStore] Exception cargando materiales:', err)
    }
  }

  function getCurso(cursoId: string): Curso | undefined {
    return inscripciones.value.find(i => i.curso_id === cursoId)?.curso
  }

  return {
    inscripciones,
    materiales,
    loading,
    cargarInscripciones,
    cargarMateriales,
    getCurso
  }
})
