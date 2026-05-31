import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { idb } from '@/services/idb'
import { supabase } from '@/services/supabase'
import { useAppStore } from './app'
import { useAuthStore } from './auth'
import type { Entrega, Curso } from '@/types/database'

export const useDocenteStore = defineStore('docente', () => {
  const appStore = useAppStore()
  const authStore = useAuthStore()
  
  const cursos = ref<Curso[]>([])
  const alumnos = ref<any[]>([]) 
  const entregas = ref<Entrega[]>([])
  const materiales = ref<any[]>([])
  const conversaciones = ref<any[]>([])
  const logrosDocente = ref<any[]>([])
  const logrosAsignados = ref<any[]>([])
  const loading = ref(false)

  // KPIs
  // KPIs
  const pendientesCorreccion = computed(() => entregas.value.filter(e => e.estado === 'entregado'))
  const revisadas = computed(() => entregas.value.filter(e => e.estado === 'revisado'))
  const totalAlumnos = computed(() => alumnos.value.length)
  const totalCursos = computed(() => cursos.value.length)
  const totalMateriales = computed(() => materiales.value.length)
  const totalTareas = computed(() => materiales.value.filter(m => m.es_tarea).length)
  const totalLogrosOtorgados = computed(() => logrosAsignados.value.length)
  const mensajesNoLeidos = computed(() => 
    conversaciones.value.reduce((acc, c) => acc + (c.mensajes?.filter((m: any) => !m.leido && m.autor_id !== authStore.user?.id).length || 0), 0)
  )

  async function cargarDatos(docenteId: string) {
    loading.value = true
    try {
      // 1. Carga Rápida Local (Offline-first)
      const localCursos = (await idb.getAll('cursos')) as Curso[]
      const localEntregas = await idb.getAll('entregas')
      
      cursos.value = localCursos.filter(c => c.docente_id === docenteId)
      // Inferir alumnos inscritos y entregas
      // Offline, simplemente mostramos todo lo que el docente ya descargó de sus cursos
      entregas.value = localEntregas as any

      // 2. Sincronización Online
      if (appStore.isOnline) {
        // Cargar cursos del docente
        const { data: dbCursos } = await supabase
          .from('cursos')
          .select('*')
          .eq('docente_id', docenteId)
        
        if (dbCursos) {
          cursos.value = dbCursos as any
          await idb.putMany('cursos', dbCursos as any)
          
          // Cargar todas las entregas que correspondan a los materiales de sus cursos
          const { data: dbEntregas } = await supabase
            .from('entregas')
            .select('*, material:materiales(*), alumno:perfiles(nombre, avatar_url)')
            
          if (dbEntregas) {
            // Filtrar las que pertenecen a sus cursos (basado en material.curso_id)
            const entregasPropias = dbEntregas.filter(e => cursos.value.some(c => c.id === (e.material as any)?.curso_id))
            // Limpiar datos para la store y para IDB
            const entregasLimpias = entregasPropias.map((e: any) => ({
              ...e,
              material: undefined,
              alumno: undefined,
              _alumno_nombre: e.alumno?.nombre,
              _material_titulo: e.material?.titulo,
              _curso_id: e.material?.curso_id
            }))
            entregas.value = entregasLimpias as any
            
            // Guardar limpias en IDB
            await idb.putMany('entregas', entregasLimpias as any)
          }

          // Cargar alumnos inscritos en sus cursos
          const cursoIds = dbCursos.map(c => c.id)
          if (cursoIds.length > 0) {
            const { data: dbInscripciones } = await supabase
              .from('inscripciones')
              .select('*, curso:cursos(nombre), alumno:perfiles(*)')
              .in('curso_id', cursoIds)
            
            if (dbInscripciones) {
              // Deduplicar alumnos
              const uniqueAlumnos = new Map()
              dbInscripciones.forEach((i: any) => {
                if (i.alumno) {
                  uniqueAlumnos.set(i.alumno.id, {
                    id: i.alumno.id,
                    nombre: i.alumno.nombre,
                    rol: i.alumno.rol,
                    nivel: i.alumno.nivel,
                    xp: i.alumno.xp,
                    avatar_url: i.alumno.avatar_url,
                    progreso_curso: i.progreso,
                    curso_id: i.curso_id,
                    curso_nombre: i.curso?.nombre
                  })
                }
              })
              alumnos.value = Array.from(uniqueAlumnos.values())
            }

            // Cargar materiales
            const { data: matData } = await supabase
              .from('materiales')
              .select('*')
              .in('curso_id', cursoIds)
            if (matData) materiales.value = matData

            // Cargar logros asignados (los que otorgó este docente)
            const { data: logData } = await supabase
              .from('logros_docente')
              .select('*, logros_asignados(*)')
              .eq('docente_id', docenteId)
            if (logData) {
               logrosDocente.value = logData
               let asignados: any[] = []
               logData.forEach(l => {
                 if (l.logros_asignados) {
                   asignados = [...asignados, ...l.logros_asignados]
                 }
               })
               logrosAsignados.value = asignados
            }

            // Cargar conversaciones
            const { data: convData } = await supabase
              .from('conversaciones')
              .select('*, mensajes(*)')
              .or(`curso_id.in.(${cursoIds.join(',')}),participante_1.eq.${docenteId},participante_2.eq.${docenteId}`)
            if (convData) conversaciones.value = convData
          }
        }
      }
    } catch (err) {
      console.error('Error cargando datos del docente', err)
    } finally {
      loading.value = false
    }
  }

  async function calificarEntrega(entregaId: string, nota: number, feedback: string, xpOtorgado: number) {
    const idx = entregas.value.findIndex(e => e.id === entregaId)
    if (idx === -1) return

    // Actualización Optimista
    entregas.value[idx].estado = 'revisado'
    
    // Guardar offline en la cola de sync
    const payload = {
      id: entregaId,
      estado: 'revisado',
      calificacion: nota,
      feedback_docente: feedback,
      revisado_en: new Date().toISOString()
    }
    
    // Queue para actualizar la tabla entregas
    await idb.put('sync_queue', {
      id: crypto.randomUUID(),
      tipo: 'correccion',
      accion: 'update',
      tabla: 'entregas',
      payload,
      intentos: 0,
      creado_en: Date.now(),
      ultimo_intento: null,
      error_msg: null
    })
    
    // Queue para otorgar XP y Monedas al alumno (Gamificación)
    // Se despacha un evento virtual que el backend o triggers resolverán
    await idb.put('sync_queue', {
      id: crypto.randomUUID(),
      tipo: 'recompensa_alumno',
      accion: 'rpc', // Indica que esto debe llamar a un stored procedure
      tabla: 'gamificacion',
      payload: {
        alumno_id: (entregas.value[idx] as any).alumno_id,
        xp: xpOtorgado,
        monedas: Math.floor(xpOtorgado * 0.4), // 40% del XP en monedas
        razon: `Tarea corregida: ${(entregas.value[idx] as any)._material_titulo}`
      },
      intentos: 0,
      creado_en: Date.now(),
      ultimo_intento: null,
      error_msg: null
    })
  }

  return {
    cursos,
    alumnos,
    entregas,
    materiales,
    conversaciones,
    logrosDocente,
    logrosAsignados,
    pendientesCorreccion,
    revisadas,
    totalAlumnos,
    totalCursos,
    totalMateriales,
    totalTareas,
    totalLogrosOtorgados,
    mensajesNoLeidos,
    loading,
    cargarDatos,
    calificarEntrega
  }
})
