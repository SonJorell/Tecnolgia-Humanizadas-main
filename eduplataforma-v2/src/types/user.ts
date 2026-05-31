export interface Perfil {
  id: string
  nombre: string
  rol: 'alumno' | 'docente' | 'directivo' | 'ti'
  curso_id?: string
  avatar_url?: string
  xp: number
  monedas: number
  nivel: number
  email?: string
  telefono?: string
  ultimo_login?: string
  creado_en?: string
  actualizado?: string
  marco_activo_id?: string
  banner_activo_id?: string
  avatar_activo_id?: string
  inventario_premios?: string[]
}

export interface UserSession {
  id: string
  email: string
  role?: string
}
