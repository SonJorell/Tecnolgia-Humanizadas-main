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
          
          const cursoIds = dbCursos.map(c => c.id)
          let materialIds: string[] = []
          
          if (cursoIds.length > 0) {
            // Paralelizar las consultas independientes para acelerar drásticamente la carga
            const [matRes, inscRes, logRes, convRes] = await Promise.all([
              supabase.from('materiales').select('*').in('curso_id', cursoIds),
              supabase.from('inscripciones').select('*, curso:cursos(nombre), alumno:perfiles!alumno_id(*)').in('curso_id', cursoIds),
              supabase.from('logros_docente').select('*, logros_asignados(*)').eq('docente_id', docenteId),
              supabase.from('conversaciones').select('*, mensajes(*)').or(`curso_id.in.(${cursoIds.join(',')}),participante_1.eq.${docenteId},participante_2.eq.${docenteId}`)
            ])

            if (matRes.data) {
              materiales.value = matRes.data
              materialIds = matRes.data.map(m => m.id)
              
              // Cargar entregas correspondientes a esos materiales
              if (materialIds.length > 0) {
                const { data: dbEntregas } = await supabase
                  .from('entregas')
                  .select('*, material:materiales(*), alumno:perfiles!alumno_id(nombre, avatar_url)')
                  .in('material_id', materialIds)
                  
                if (dbEntregas) {
                  const entregasLimpias = dbEntregas.map((e: any) => ({
                    ...e,
                    material: undefined,
                    alumno: undefined,
                    _alumno_nombre: e.alumno?.nombre,
                    _material_titulo: e.material?.titulo,
                    _curso_id: e.material?.curso_id
                  }))
                  entregas.value = entregasLimpias as any
                  await idb.putMany('entregas', entregasLimpias as any)
                }
              }
            }

            if (inscRes.data) {
              // Deduplicar alumnos
              const uniqueAlumnos = new Map()
              inscRes.data.forEach((i: any) => {
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

            if (logRes.data) {
               logrosDocente.value = logRes.data
               let asignados: any[] = []
               logRes.data.forEach(l => {
                 if (l.logros_asignados) {
                   asignados = [...asignados, ...l.logros_asignados]
                 }
               })
               logrosAsignados.value = asignados
            }

            if (convRes.data) {
              conversaciones.value = convRes.data
            }
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
