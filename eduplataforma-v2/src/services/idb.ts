// ═══════════════════════════════════
// IndexedDB wrapper — almacenamiento offline
// Portado desde repo React + ampliado
// ═══════════════════════════════════

import { openDB, type DBSchema, type IDBPDatabase } from 'idb'

interface EduDB extends DBSchema {
  perfiles: {
    key: string
    value: {
      id: string
      nombre: string
      rol: string
      xp: number
      monedas: number
      nivel: number
      avatar_url?: string
      curso_id?: string
      email?: string
      [key: string]: unknown
    }
  }
  cursos: {
    key: string
    value: {
      id: string
      nombre: string
      descripcion?: string
      docente_id?: string
      nivel?: string
      icono?: string
      color?: string
      [key: string]: unknown
    }
  }
  inscripciones: {
    key: string
    value: {
      id: string
      alumno_id: string
      curso_id: string
      progreso: number
      [key: string]: unknown
    }
  }
  materiales: {
    key: string
    value: {
      id: string
      curso_id: string
      titulo: string
      descripcion?: string
      tipo: string
      archivo_url?: string
      archivo_nombre?: string
      disponible_offline: boolean
      [key: string]: unknown
    }
    indexes: { 'by_curso': string }
  }
  entregas: {
    key: string
    value: {
      id: string
      material_id: string
      alumno_id: string
      contenido?: string
      estado: string
      sincronizado?: boolean
      [key: string]: unknown
    }
    indexes: { 'by_alumno': string }
  }
  logros: {
    key: string
    value: {
      id: string
      nombre: string
      descripcion?: string
      icono?: string
      xp_premio: number
      categoria?: string
    }
  }
  logros_desbloqueados: {
    key: string
    value: {
      id: string
      alumno_id: string
      logro_id: string
      desbloqueado?: string
    }
    indexes: { 'by_alumno': string }
  }
  premios: {
    key: string
    value: {
      id: string
      nombre: string
      descripcion?: string
      icono?: string
      categoria?: string
      precio_monedas: number
      stock: number
      activo: boolean
    }
  }
  sync_queue: {
    key: string
    value: {
      id: string
      tipo: string
      accion: string
      tabla: string
      payload: Record<string, unknown>
      intentos: number
      creado_en: number
      ultimo_intento: number | null
      error_msg: string | null
    }
    indexes: { 'by_tipo': string; 'by_creado': number }
  }
  meta: {
    key: string
    value: {
      key: string
      value: unknown
      updated_at: number
    }
  }
}

export type StoreName = keyof EduDB

let dbInstance: IDBPDatabase<EduDB> | null = null

async function getDB(): Promise<IDBPDatabase<EduDB>> {
  if (dbInstance) return dbInstance
  dbInstance = await openDB<EduDB>('eduplataforma', 3, {
    upgrade(db, oldVersion, newVersion, transaction) {
      // v1: stores originales
      if (oldVersion < 1) {
        db.createObjectStore('perfiles', { keyPath: 'id' })
        db.createObjectStore('entregas', { keyPath: 'id' })
        const sq = db.createObjectStore('sync_queue', { keyPath: 'id' })
        sq.createIndex('by_tipo', 'tipo')
      }
      // v2: stores adicionales
      if (oldVersion < 2) {
        if (!db.objectStoreNames.contains('cursos')) {
          db.createObjectStore('cursos', { keyPath: 'id' })
        }
        if (!db.objectStoreNames.contains('inscripciones')) {
          db.createObjectStore('inscripciones', { keyPath: 'id' })
        }
        if (!db.objectStoreNames.contains('materiales')) {
          db.createObjectStore('materiales', { keyPath: 'id' })
        }
      }
      // v3: stores nuevos para Vue 3
      if (oldVersion < 3) {
        if (!db.objectStoreNames.contains('logros')) {
          db.createObjectStore('logros', { keyPath: 'id' })
        }
        if (!db.objectStoreNames.contains('logros_desbloqueados')) {
          db.createObjectStore('logros_desbloqueados', { keyPath: 'id' })
        }
        if (!db.objectStoreNames.contains('premios')) {
          db.createObjectStore('premios', { keyPath: 'id' })
        }
        if (!db.objectStoreNames.contains('meta')) {
          db.createObjectStore('meta', { keyPath: 'key' })
        }
        // Agregar índices si los stores ya existen sin ellos
        if (db.objectStoreNames.contains('materiales')) {
          const matStore = transaction.objectStore('materiales')
          if (!matStore.indexNames.contains('by_curso')) {
            try { matStore.createIndex('by_curso', 'curso_id') } catch { /* ya existe */ }
          }
        }
        if (db.objectStoreNames.contains('entregas')) {
          const entStore = transaction.objectStore('entregas')
          if (!entStore.indexNames.contains('by_alumno')) {
            try { entStore.createIndex('by_alumno', 'alumno_id') } catch { /* ya existe */ }
          }
        }
        if (db.objectStoreNames.contains('sync_queue')) {
          const sqStore = transaction.objectStore('sync_queue')
          if (!sqStore.indexNames.contains('by_creado')) {
            try { sqStore.createIndex('by_creado', 'creado_en') } catch { /* ya existe */ }
          }
        }
      }
    }
  })
  return dbInstance
}

export const idb = {
  get: async <T extends StoreName>(store: T, key: string): Promise<EduDB[T]['value'] | undefined> => {
    const db = await getDB()
    return db.get(store as any, key)
  },

  put: async <T extends StoreName>(store: T, val: EduDB[T]['value']) => {
    const db = await getDB()
    const safeVal = JSON.parse(JSON.stringify(val))
    return db.put(store as any, safeVal)
  },

  getAll: async <T extends StoreName>(store: T): Promise<EduDB[T]['value'][]> => {
    const db = await getDB()
    return db.getAll(store as any)
  },

  delete: async <T extends StoreName>(store: T, key: string) => {
    const db = await getDB()
    return db.delete(store as any, key)
  },

  clear: async <T extends StoreName>(store: T) => {
    const db = await getDB()
    return db.clear(store as any)
  },

  update: async <T extends StoreName>(
    store: T,
    key: string,
    fn: (val: EduDB[T]['value']) => EduDB[T]['value']
  ) => {
    const db = await getDB()
    const tx = db.transaction(store as any, 'readwrite')
    const val = await tx.store.get(key)
    if (val) {
      await tx.store.put(fn(val as EduDB[T]['value']))
    }
    await tx.done
  },

  count: async <T extends StoreName>(store: T) => {
    const db = await getDB()
    return db.count(store as any)
  },

  putMany: async <T extends StoreName>(store: T, items: EduDB[T]['value'][]) => {
    const db = await getDB()
    const tx = db.transaction(store as any, 'readwrite')
    for (const item of items) {
      const safeItem = JSON.parse(JSON.stringify(item))
      await tx.store.put(safeItem)
    }
    await tx.done
  },

  getMeta: async (key: string): Promise<unknown | undefined> => {
    const db = await getDB()
    const entry = await db.get('meta', key)
    return entry?.value
  },

  setMeta: async (key: string, value: unknown) => {
    const db = await getDB()
    await db.put('meta', { key, value, updated_at: Date.now() })
  }
}
