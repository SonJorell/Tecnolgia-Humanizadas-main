// ═══════════════════════════════════
// Cola de sincronización offline ↔ Supabase
// Portado desde repo React + ampliado con backoff
// ═══════════════════════════════════

import { supabase } from './supabase'
import { idb } from './idb'
import type { SyncQueueItem } from '@/types/app'

const MAX_RETRIES = Number(import.meta.env.VITE_SYNC_MAX_RETRIES) || 5

export async function procesarColaSync(): Promise<number> {
  let sincronizados = 0

  try {
    const items = await idb.getAll('sync_queue') as unknown as SyncQueueItem[]
    const pendientes = items
      .filter(i => i.intentos < MAX_RETRIES)
      .sort((a, b) => a.creado_en - b.creado_en) // FIFO

    for (const item of pendientes) {
      // Backoff exponencial: esperar 2^intentos segundos
      if (item.ultimo_intento && item.intentos > 0) {
        const backoffMs = Math.pow(2, item.intentos) * 1000
        const elapsed = Date.now() - item.ultimo_intento
        if (elapsed < backoffMs) continue // Aún no es tiempo de reintentar
      }

      try {
        switch (item.tipo) {
          case 'entrega': {
            const { error } = await supabase.from('entregas').upsert(item.payload as any)
            if (error) throw error
            break
          }
          case 'progreso': {
            const { error } = await supabase
              .from('inscripciones')
              .update({ progreso: item.payload.progreso })
              .eq('alumno_id', item.payload.alumno_id as string)
              .eq('curso_id', item.payload.curso_id as string)
            if (error) throw error
            break
          }
          case 'feedback': {
            const { error } = await supabase.from('feedback').insert(item.payload as any)
            if (error) throw error
            break
          }
          case 'monedas': {
            const { error } = await supabase
              .from('perfiles')
              .update({ monedas: item.payload.monedas, xp: item.payload.xp })
              .eq('id', item.payload.user_id as string)
            if (error) throw error
            break
          }
          case 'canje': {
            const { error } = await supabase.from('canjes').insert(item.payload as any)
            if (error) throw error
            break
          }
          case 'logro': {
            const { error } = await supabase.from('logros_alumno').upsert(item.payload as any)
            if (error) throw error
            break
          }
          case 'recompensa_alumno': {
            if (item.accion === 'rpc') {
              const { error } = await supabase.rpc('otorgar_recompensa', {
                p_alumno_id: item.payload.alumno_id,
                p_xp: item.payload.xp,
                p_monedas: item.payload.monedas,
                p_razon: item.payload.razon
              })
              if (error) throw error
            }
            break
          }
          case 'correccion': {
            const { error } = await supabase.from('entregas').update({
              estado: item.payload.estado,
              calificacion: item.payload.calificacion,
              feedback_docente: item.payload.feedback_docente,
              revisado_en: item.payload.revisado_en
            }).eq('id', (item.payload as any).id)
            if (error) throw error
            break
          }
          default: {
            if (item.tabla) {
              if (item.accion === 'insert') {
                const { error } = await supabase.from(item.tabla).insert(item.payload as any)
                if (error) throw error
              } else if (item.accion === 'upsert') {
                const { error } = await supabase.from(item.tabla).upsert(item.payload as any)
                if (error) throw error
              } else if (item.accion === 'update' && (item.payload as any).id) {
                const { error } = await supabase.from(item.tabla).update(item.payload as any).eq('id', (item.payload as any).id)
                if (error) throw error
              } else if (item.accion === 'delete' && (item.payload as any).id) {
                const { error } = await supabase.from(item.tabla).delete().eq('id', (item.payload as any).id)
                if (error) throw error
              } else {
                console.warn('Acción no soportada en sync.ts para el tipo:', item.tipo)
              }
            }
            break
          }
        }

        await idb.delete('sync_queue', item.id)
        sincronizados++
      } catch (err: any) {
        console.error('[Sync] Item failed completely, dropping from queue to avoid loops:', err)
        await idb.delete('sync_queue', item.id)
        
        // Show error to user reliably (Pinia might not be active here)
        setTimeout(() => alert(`Fallo al guardar en la nube: ${err.message || JSON.stringify(err)}`), 100)
      }
    }
  } catch (err) {
    console.error('[Sync] Error procesando cola:', err)
  }

  return sincronizados
}

export async function agregarACola(
  tipo: SyncQueueItem['tipo'],
  payload: Record<string, unknown>,
  tabla?: string,
  accion: SyncQueueItem['accion'] = 'upsert'
): Promise<void> {
  await idb.put('sync_queue', {
    id: crypto.randomUUID(),
    tipo,
    accion,
    tabla: tabla || tipo,
    payload,
    intentos: 0,
    creado_en: Date.now(),
    ultimo_intento: null,
    error_msg: null
  } as any)
}

export async function contarPendientes(): Promise<number> {
  const items = await idb.getAll('sync_queue') as unknown as SyncQueueItem[]
  return items.filter(i => i.intentos < MAX_RETRIES).length
}

export async function contarFallidos(): Promise<number> {
  const items = await idb.getAll('sync_queue') as unknown as SyncQueueItem[]
  return items.filter(i => i.intentos >= MAX_RETRIES).length
}

export async function limpiarFallidos(): Promise<number> {
  const items = await idb.getAll('sync_queue') as unknown as SyncQueueItem[]
  const fallidos = items.filter(i => i.intentos >= MAX_RETRIES)
  for (const item of fallidos) {
    await idb.delete('sync_queue', item.id)
  }
  return fallidos.length
}
