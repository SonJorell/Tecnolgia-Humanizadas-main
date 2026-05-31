export type EstadoConexion = 'ONLINE_SUPABASE' | 'ONLINE_LAN_ONLY' | 'OFFLINE_TOTAL'

export interface Toast {
  id: string
  tipo: 'info' | 'xp' | 'sync' | 'error'
  mensaje: string
  duracion?: number
}

export interface Alerta {
  id: string
  tipo: 'info' | 'warning' | 'success' | 'error'
  titulo: string
  mensaje: string
  leida: boolean
  creado_en: string
}

export interface NavItem {
  path: string
  label: string
  icon: string
  badge?: number
}

export interface SyncQueueItem {
  id: string
  tipo: 'entrega' | 'progreso' | 'feedback' | 'monedas' | 'canje' | 'logro'
  accion: 'insert' | 'update' | 'upsert'
  tabla: string
  payload: Record<string, unknown>
  intentos: number
  creado_en: number
  ultimo_intento: number | null
  error_msg: string | null
}
