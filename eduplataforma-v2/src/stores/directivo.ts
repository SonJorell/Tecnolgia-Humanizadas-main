import { defineStore } from 'pinia'
import { ref } from 'vue'
import { supabase } from '@/services/supabase'
export interface Alerta {
  id: string
  tipo: 'critica' | 'advertencia' | 'info'
  mensaje: string
  fecha: string
  resuelta: boolean
}

export interface CursoRendimiento {
  id: string
  nombre: string
  promedio: number
  tasa_entrega: number // 0 a 100
  alumnos_riesgo: number
  profesor_id: string
}

export const useDirectivoStore = defineStore('directivo', () => {
  const loading = ref(false)
  const successMsg = ref('')
  const errorMsg = ref('')

  // Listas para la Gestión Académica
  const profesoresDisponibles = ref<any[]>([])
  const alumnosDisponibles = ref<any[]>([])
  const cursosExistentes = ref<any[]>([])
  
  // KPIs Globales (Reales)
  const stats = ref({
    alumnosTotales: 0,
    alumnosConectadosSemana: 0,
    promedioColegio: 0,
    correccionesAtrasadas: 0,
    profesoresTotales: 0
  })

  // Alertas Prioritarias
  const alertas = ref<Alerta[]>([
    { id: '1', tipo: 'info', mensaje: 'Sistema preparado. Mostrando datos en tiempo real.', fecha: new Date().toISOString(), resuelta: false },
  ])

  // Rendimiento por Cursos
  const cursos = ref<CursoRendimiento[]>([])

  async function cargarDatosGlobales() {
    loading.value = true
    try {
      // 1. Alumnos Totales
      const { count: alumnosTotales } = await supabase.from('perfiles').select('*', { count: 'exact', head: true }).eq('rol', 'alumno')
      
      // 2. Profesores Totales
      const { count: profesoresTotales } = await supabase.from('perfiles').select('*', { count: 'exact', head: true }).eq('rol', 'docente')

      // 3. Promedio del colegio (promedio de todas las entregas con nota)
      const { data: entregasConNota } = await supabase.from('entregas').select('nota').not('nota', 'is', null)
      let promedio = 0
      if (entregasConNota && entregasConNota.length > 0) {
        const total = entregasConNota.reduce((sum, e) => sum + (e.nota || 0), 0)
        promedio = Number((total / entregasConNota.length).toFixed(1))
      }

      // 4. Correcciones atrasadas (estado pendiente)
      const { count: correccionesAtrasadas } = await supabase.from('entregas').select('*', { count: 'exact', head: true }).eq('estado', 'pendiente')

      // 5. Asistencia digital (Alumnos que han enviado alguna tarea en los últimos 7 días)
      const sieteDiasAtras = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()
      const { data: entregasRecientes } = await supabase.from('entregas').select('alumno_id').gte('creado_en', sieteDiasAtras)
      
      const alumnosUnicosRecientes = new Set(entregasRecientes?.map(e => e.alumno_id))

      stats.value = {
        alumnosTotales: alumnosTotales || 0,
        profesoresTotales: profesoresTotales || 0,
        promedioColegio: promedio,
        correccionesAtrasadas: correccionesAtrasadas || 0,
        alumnosConectadosSemana: alumnosUnicosRecientes.size
      }

      // 6. Rendimiento por Cursos
      const { data: cursosData } = await supabase.from('cursos').select('id, nombre, docente_id')
      if (cursosData) {
        const { data: entregasAll } = await supabase.from('entregas').select('nota, material_id, material:materiales(curso_id)')
        
        cursos.value = cursosData.map(curso => {
          const entregasCurso = entregasAll?.filter((e: any) => e.material && e.material.curso_id === curso.id) || []
          const entregasConNota = entregasCurso.filter(e => e.nota !== null)
          
          let promCurso = 0
          if (entregasConNota.length > 0) {
            const sum = entregasConNota.reduce((acc, e) => acc + (e.nota || 0), 0)
            promCurso = sum / entregasConNota.length
          }

          // Asumimos tasa_entrega como % de entregas que ya tienen nota o están entregadas (simplificación)
          const tasa_entrega = entregasCurso.length > 0 ? Math.round((entregasConNota.length / entregasCurso.length) * 100) : 0

          return {
            id: curso.id,
            nombre: curso.nombre,
            promedio: Number(promCurso.toFixed(1)),
            tasa_entrega,
            alumnos_riesgo: 0, // placeholder
            profesor_id: curso.docente_id
          }
        })
      }

    } catch (err) {
      console.error('Error cargando métricas directivas:', err)
    } finally {
      loading.value = false
    }
  }

  function marcarAlertaComoResuelta(id: string) {
    const alerta = alertas.value.find(a => a.id === id)
    if (alerta) alerta.resuelta = true
  }

  // ── Funciones de Gestión Académica ──

  async function cargarDatosGestion() {
    loading.value = true
    try {
      const [resProfes, resAlumnos, resCursos] = await Promise.all([
        supabase.from('perfiles').select('*').eq('rol', 'docente'),
        supabase.from('perfiles').select('*').eq('rol', 'alumno'),
        supabase.from('cursos').select('*, docente:perfiles!docente_id(nombre)')
      ])
      if (resProfes.data) profesoresDisponibles.value = resProfes.data
      if (resAlumnos.data) alumnosDisponibles.value = resAlumnos.data
      if (resCursos.data) cursosExistentes.value = resCursos.data
    } catch (err) {
      console.error(err)
    } finally {
      loading.value = false
    }
  }

  async function crearCurso(nombre: string, nivel: string, docente_id: string, color: string, icono: string) {
    loading.value = true
    try {
      const { error } = await supabase.from('cursos').insert({
        nombre, nivel, docente_id, color, icono
      })
      if (error) throw error
      successMsg.value = 'Curso creado exitosamente.'
      await cargarDatosGestion()
    } catch (e: any) {
      errorMsg.value = e.message
    } finally {
      loading.value = false
    }
  }

  async function inscribirAlumnos(curso_id: string, alumno_ids: string[]) {
    loading.value = true
    try {
      const inscripciones = alumno_ids.map(id => ({
        curso_id, alumno_id: id, progreso: 0
      }))
      const { error } = await supabase.from('inscripciones').insert(inscripciones)
      if (error) throw error
      successMsg.value = 'Alumnos inscritos exitosamente.'
    } catch (e: any) {
      errorMsg.value = e.message
    } finally {
      loading.value = false
    }
  }

  async function crearUsuarioPrueba(email: string, nombre: string, rol: string) {
    loading.value = true
    try {
      const { error } = await supabase.rpc('crear_usuario_admin', {
        p_email: email,
        p_password: 'prueba123',
        p_nombre: nombre,
        p_rol: rol
      })
      if (error) throw error
      successMsg.value = `Usuario ${rol} creado exitosamente con clave: prueba123.`
      await cargarDatosGestion()
    } catch (e: any) {
      errorMsg.value = e.message
      console.error(e)
    } finally {
      loading.value = false
    }
  }

  return {
    stats,
    alertas,
    cursos,
    loading,
    successMsg,
    errorMsg,
    profesoresDisponibles,
    alumnosDisponibles,
    cursosExistentes,
    cargarDatosGlobales,
    marcarAlertaComoResuelta,
    cargarDatosGestion,
    crearCurso,
    inscribirAlumnos,
    crearUsuarioPrueba
  }
})
