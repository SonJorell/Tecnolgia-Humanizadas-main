<script setup lang="ts">
import { ref, computed } from 'vue'
import { useAppStore } from '@/stores/app'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import StatCard from '@/components/ui/StatCard.vue'
import {
  HardDrive, Wifi, WifiOff, RefreshCw, Database,
  Server, Clock, CheckCircle2, AlertTriangle, XCircle,
  Activity, Upload, Trash2, Shield
} from 'lucide-vue-next'

const appStore = useAppStore()

// ── Infrastructure Mock Data ──
const loading = ref(false)

const almacenamiento = ref({
  idbUsado: 12.4, // MB
  idbTotal: 50,   // MB (quota estimada)
  cacheArchivos: 8.2, // MB de archivos descargados offline
  ultimaLimpieza: new Date(Date.now() - 86400000 * 3).toISOString(),
})

const syncStatus = ref({
  pendientes: 12,
  fallidos: 2,
  exitosos: 345,
  ultimoSync: new Date(Date.now() - 300000).toISOString(), // hace 5 min
  promedioMs: 1200,
})

const servidorLocal = ref({
  ip: '192.168.1.100',
  puerto: 3001,
  estado: 'activo' as 'activo' | 'inactivo' | 'error',
  latencia: 45, // ms
  clientesConectados: 28,
  ultimoHeartbeat: new Date(Date.now() - 15000).toISOString(),
})

const dispositivos = ref([
  { id: 'd1', nombre: 'Sala Computación - PC-01', tipo: 'desktop', ultimaConexion: 'hace 2 min', estado: 'online', almacenamientoLocal: '15.2 MB' },
  { id: 'd2', nombre: 'Sala Computación - PC-02', tipo: 'desktop', ultimaConexion: 'hace 5 min', estado: 'online', almacenamientoLocal: '12.8 MB' },
  { id: 'd3', nombre: 'Tablet Profesor - María López', tipo: 'tablet', ultimaConexion: 'hace 1 hora', estado: 'offline', almacenamientoLocal: '8.4 MB' },
  { id: 'd4', nombre: 'Sala Computación - PC-03', tipo: 'desktop', ultimaConexion: 'hace 10 min', estado: 'online', almacenamientoLocal: '14.1 MB' },
  { id: 'd5', nombre: 'Tablet Profesor - Carlos Díaz', tipo: 'tablet', ultimaConexion: 'hace 3 días', estado: 'offline', almacenamientoLocal: '5.2 MB' },
])

const logsRecientes = ref([
  { id: 1, tipo: 'success' as const, mensaje: 'Sincronización batch completada: 45 entregas subidas', tiempo: 'hace 5 min' },
  { id: 2, tipo: 'warning' as const, mensaje: 'Servidor local: alta latencia detectada (380ms)', tiempo: 'hace 15 min' },
  { id: 3, tipo: 'success' as const, mensaje: 'Backup automático de IndexedDB completado', tiempo: 'hace 30 min' },
  { id: 4, tipo: 'error' as const, mensaje: 'Fallo al sincronizar 2 calificaciones — reintentando', tiempo: 'hace 1 hora' },
  { id: 5, tipo: 'info' as const, mensaje: 'Cache de materiales actualizado: 8 archivos nuevos', tiempo: 'hace 2 horas' },
])

// ── Computed ──
const idbPorcentaje = computed(() => Math.round((almacenamiento.value.idbUsado / almacenamiento.value.idbTotal) * 100))
const dispositivosOnline = computed(() => dispositivos.value.filter(d => d.estado === 'online').length)

const estadoConexionLabel = computed(() => {
  switch (appStore.conexion) {
    case 'ONLINE_SUPABASE': return { label: 'Internet + Supabase', color: 'text-mint', bg: 'bg-mint-bg dark:bg-mint/20', icon: Wifi }
    case 'ONLINE_LAN_ONLY': return { label: 'Solo Red Local', color: 'text-amber', bg: 'bg-amber-bg dark:bg-amber/20', icon: Wifi }
    case 'OFFLINE_TOTAL': return { label: 'Sin Conexión', color: 'text-danger', bg: 'bg-danger-bg dark:bg-danger/20', icon: WifiOff }
    default: return { label: 'Desconocido', color: 'text-text-muted', bg: 'bg-surface', icon: WifiOff }
  }
})

// ── Actions ──
async function forzarSync() {
  loading.value = true
  // Simular una sincronización
  await new Promise(r => setTimeout(r, 2000))
  syncStatus.value.pendientes = 0
  syncStatus.value.ultimoSync = new Date().toISOString()
  syncStatus.value.exitosos += 12
  logsRecientes.value.unshift({
    id: Date.now(),
    tipo: 'success',
    mensaje: `Sincronización forzada completada: ${syncStatus.value.pendientes} operaciones procesadas`,
    tiempo: 'ahora'
  })
  loading.value = false
  appStore.addToast({ tipo: 'sync', mensaje: '✅ Sincronización forzada completada — todos los datos al día.' })
}

async function limpiarCache() {
  loading.value = true
  await new Promise(r => setTimeout(r, 1500))
  almacenamiento.value.cacheArchivos = 0
  almacenamiento.value.idbUsado = Math.max(2, almacenamiento.value.idbUsado - 5)
  almacenamiento.value.ultimaLimpieza = new Date().toISOString()
  loading.value = false
  appStore.addToast({ tipo: 'info', mensaje: '🧹 Caché limpiado — se liberaron archivos temporales.' })
}

function formatFecha(iso: string): string {
  return new Date(iso).toLocaleString('es-CL', { dateStyle: 'short', timeStyle: 'short' })
}
</script>

<template>
  <div class="p-4 md:p-6 max-w-7xl mx-auto space-y-6 animate-fade-in">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
      <div>
        <h1 class="font-display font-extrabold text-2xl md:text-3xl text-text dark:text-dark-text">
          🖥️ Infraestructura y Red
        </h1>
        <p class="text-sm text-text-muted mt-1">Estado del sistema offline-first, sincronización y almacenamiento local.</p>
      </div>
      <div class="flex gap-2">
        <BaseButton variant="secondary" size="sm" @click="limpiarCache" :loading="loading">
          <Trash2 :size="14" /> Limpiar Caché
        </BaseButton>
        <BaseButton variant="primary" size="sm" @click="forzarSync" :loading="loading">
          <RefreshCw :size="14" /> Forzar Sync
        </BaseButton>
      </div>
    </div>

    <!-- Estado de Conexión Banner -->
    <div :class="['rounded-2xl p-4 flex items-center justify-between border', estadoConexionLabel.bg, 
                    appStore.conexion === 'ONLINE_SUPABASE' ? 'border-mint/30' : 
                    appStore.conexion === 'ONLINE_LAN_ONLY' ? 'border-amber/30' : 'border-danger/30']">
      <div class="flex items-center gap-3">
        <component :is="estadoConexionLabel.icon" :size="24" :class="estadoConexionLabel.color" />
        <div>
          <p class="font-bold text-sm" :class="estadoConexionLabel.color">{{ estadoConexionLabel.label }}</p>
          <p class="text-xs text-text-muted">Los datos locales siempre están disponibles, independiente de la red.</p>
        </div>
      </div>
      <BaseBadge
        :variant="appStore.conexion === 'ONLINE_SUPABASE' ? 'mint' : appStore.conexion === 'ONLINE_LAN_ONLY' ? 'amber' : 'danger'"
      >
        {{ appStore.conexion === 'ONLINE_SUPABASE' ? 'Conectado' : appStore.conexion === 'ONLINE_LAN_ONLY' ? 'LAN' : 'Offline' }}
      </BaseBadge>
    </div>

    <!-- KPI Row -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
      <StatCard
        :icon="Database"
        label="IndexedDB"
        :value="`${almacenamiento.idbUsado} MB`"
        iconBg="bg-primary-bg dark:bg-primary/20 text-primary"
        :subtitle="`${idbPorcentaje}% de ${almacenamiento.idbTotal} MB`"
      />
      <StatCard
        :icon="Upload"
        label="Pendientes Sync"
        :value="syncStatus.pendientes"
        iconBg="bg-amber-bg dark:bg-amber/20 text-amber"
        :subtitle="`${syncStatus.fallidos} fallidos`"
      />
      <StatCard
        :icon="CheckCircle2"
        label="Sync Exitosos"
        :value="syncStatus.exitosos"
        iconBg="bg-mint-bg dark:bg-mint/20 text-mint"
        subtitle="Total acumulado"
      />
      <StatCard
        :icon="Activity"
        label="Dispositivos"
        :value="`${dispositivosOnline}/${dispositivos.length}`"
        iconBg="bg-violet-bg dark:bg-violet/20 text-violet"
        subtitle="Conectados ahora"
      />
    </div>

    <!-- Main Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

      <!-- Almacenamiento Local -->
      <BaseCard class="lg:col-span-1">
        <h3 class="font-display font-bold text-base text-text dark:text-dark-text mb-4 flex items-center gap-2">
          <HardDrive :size="18" class="text-primary" /> Almacenamiento Local
        </h3>

        <!-- IDB Usage Bar -->
        <div class="space-y-4">
          <div>
            <div class="flex justify-between text-xs mb-1.5">
              <span class="text-text-muted">IndexedDB</span>
              <span class="font-bold" :class="idbPorcentaje > 80 ? 'text-danger' : idbPorcentaje > 60 ? 'text-amber' : 'text-primary'">
                {{ almacenamiento.idbUsado }} / {{ almacenamiento.idbTotal }} MB
              </span>
            </div>
            <div class="w-full h-3 bg-surface dark:bg-dark-card2 rounded-full overflow-hidden">
              <div
                class="h-full rounded-full transition-all duration-700"
                :class="idbPorcentaje > 80 ? 'bg-danger' : idbPorcentaje > 60 ? 'bg-amber' : 'bg-primary'"
                :style="{ width: `${idbPorcentaje}%` }"
              ></div>
            </div>
          </div>

          <div class="space-y-2">
            <div class="flex items-center justify-between p-3 bg-surface dark:bg-dark-card2 rounded-xl">
              <div class="flex items-center gap-2">
                <div class="w-3 h-3 rounded-full bg-primary"></div>
                <span class="text-xs text-text dark:text-dark-text">Base de datos local</span>
              </div>
              <span class="text-xs font-bold text-text dark:text-dark-text">{{ (almacenamiento.idbUsado - almacenamiento.cacheArchivos).toFixed(1) }} MB</span>
            </div>
            <div class="flex items-center justify-between p-3 bg-surface dark:bg-dark-card2 rounded-xl">
              <div class="flex items-center gap-2">
                <div class="w-3 h-3 rounded-full bg-amber"></div>
                <span class="text-xs text-text dark:text-dark-text">Caché de archivos</span>
              </div>
              <span class="text-xs font-bold text-text dark:text-dark-text">{{ almacenamiento.cacheArchivos }} MB</span>
            </div>
          </div>

          <div class="pt-3 border-t border-border dark:border-white/10">
            <p class="text-[11px] text-text-muted">
              Última limpieza: {{ formatFecha(almacenamiento.ultimaLimpieza) }}
            </p>
          </div>
        </div>
      </BaseCard>

      <!-- Servidor Local (LAN) -->
      <BaseCard class="lg:col-span-1">
        <h3 class="font-display font-bold text-base text-text dark:text-dark-text mb-4 flex items-center gap-2">
          <Server :size="18" class="text-violet" /> Servidor Local (LAN)
        </h3>

        <div class="space-y-4">
          <!-- Estado -->
          <div class="flex items-center justify-between p-3 rounded-xl" :class="servidorLocal.estado === 'activo' ? 'bg-mint-bg dark:bg-mint/10' : 'bg-danger-bg dark:bg-danger/10'">
            <div class="flex items-center gap-2">
              <div class="w-2.5 h-2.5 rounded-full" :class="servidorLocal.estado === 'activo' ? 'bg-mint animate-pulse' : 'bg-danger'"></div>
              <span class="text-sm font-semibold" :class="servidorLocal.estado === 'activo' ? 'text-mint' : 'text-danger'">
                {{ servidorLocal.estado === 'activo' ? 'Activo' : 'Inactivo' }}
              </span>
            </div>
            <span class="text-xs text-text-muted font-mono">{{ servidorLocal.ip }}:{{ servidorLocal.puerto }}</span>
          </div>

          <!-- Metrics -->
          <div class="grid grid-cols-2 gap-3">
            <div class="bg-surface dark:bg-dark-card2 rounded-xl p-3 text-center">
              <p class="text-xs text-text-muted mb-1">Latencia</p>
              <p class="font-display font-extrabold text-xl" :class="servidorLocal.latencia < 100 ? 'text-mint' : servidorLocal.latencia < 300 ? 'text-amber' : 'text-danger'">
                {{ servidorLocal.latencia }}ms
              </p>
            </div>
            <div class="bg-surface dark:bg-dark-card2 rounded-xl p-3 text-center">
              <p class="text-xs text-text-muted mb-1">Clientes</p>
              <p class="font-display font-extrabold text-xl text-primary">{{ servidorLocal.clientesConectados }}</p>
            </div>
          </div>

          <!-- Sync Speed -->
          <div>
            <div class="flex justify-between text-xs mb-1.5">
              <span class="text-text-muted">Velocidad de sync promedio</span>
              <span class="font-bold text-text dark:text-dark-text">{{ syncStatus.promedioMs }}ms</span>
            </div>
            <div class="w-full h-2 bg-surface dark:bg-dark-card2 rounded-full overflow-hidden">
              <div
                class="h-full rounded-full bg-violet transition-all duration-700"
                :style="{ width: `${Math.min(100, 100 - (syncStatus.promedioMs / 50))}%` }"
              ></div>
            </div>
          </div>

          <p class="text-[11px] text-text-muted pt-2 border-t border-border dark:border-white/10">
            Último heartbeat: {{ formatFecha(servidorLocal.ultimoHeartbeat) }}
          </p>
        </div>
      </BaseCard>

      <!-- Cola de Sincronización -->
      <BaseCard class="lg:col-span-1">
        <h3 class="font-display font-bold text-base text-text dark:text-dark-text mb-4 flex items-center gap-2">
          <RefreshCw :size="18" class="text-amber" /> Cola de Sincronización
        </h3>

        <div class="space-y-3">
          <!-- Visual Sync Pipeline -->
          <div class="flex items-center gap-2 p-3 bg-surface dark:bg-dark-card2 rounded-xl">
            <div class="flex-1 text-center">
              <p class="text-[10px] text-text-muted uppercase font-semibold mb-1">Local</p>
              <div class="w-8 h-8 mx-auto rounded-full bg-primary-bg dark:bg-primary/20 flex items-center justify-center">
                <Database :size="14" class="text-primary" />
              </div>
            </div>
            <div class="flex-shrink-0 flex flex-col items-center gap-0.5">
              <div class="flex gap-0.5">
                <div class="w-1.5 h-1.5 rounded-full bg-primary animate-ping"></div>
                <div class="w-1.5 h-1.5 rounded-full bg-primary/60"></div>
                <div class="w-1.5 h-1.5 rounded-full bg-primary/30"></div>
              </div>
              <span class="text-[9px] font-bold text-primary">{{ syncStatus.pendientes }}</span>
            </div>
            <div class="flex-1 text-center">
              <p class="text-[10px] text-text-muted uppercase font-semibold mb-1">Nube</p>
              <div class="w-8 h-8 mx-auto rounded-full bg-mint-bg dark:bg-mint/20 flex items-center justify-center">
                <Shield :size="14" class="text-mint" />
              </div>
            </div>
          </div>

          <!-- Stats breakdown -->
          <div class="space-y-2">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2">
                <Clock :size="14" class="text-amber" />
                <span class="text-xs text-text dark:text-dark-text">Pendientes</span>
              </div>
              <span class="text-xs font-bold text-amber">{{ syncStatus.pendientes }}</span>
            </div>
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2">
                <XCircle :size="14" class="text-danger" />
                <span class="text-xs text-text dark:text-dark-text">Fallidos</span>
              </div>
              <span class="text-xs font-bold text-danger">{{ syncStatus.fallidos }}</span>
            </div>
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2">
                <CheckCircle2 :size="14" class="text-mint" />
                <span class="text-xs text-text dark:text-dark-text">Exitosos</span>
              </div>
              <span class="text-xs font-bold text-mint">{{ syncStatus.exitosos }}</span>
            </div>
          </div>

          <p class="text-[11px] text-text-muted pt-2 border-t border-border dark:border-white/10">
            Último sync: {{ formatFecha(syncStatus.ultimoSync) }}
          </p>
        </div>
      </BaseCard>
    </div>

    <!-- Dispositivos Conectados -->
    <div class="space-y-4">
      <h2 class="font-display font-bold text-lg text-text dark:text-dark-text flex items-center gap-2">
        <Activity :size="20" class="text-violet" /> Dispositivos Registrados
      </h2>

      <BaseCard class="p-0 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-surface dark:bg-dark-card2 text-xs uppercase tracking-wider text-text-muted border-b border-border dark:border-white/10">
                <th class="px-4 py-3 font-semibold">Dispositivo</th>
                <th class="px-4 py-3 font-semibold">Tipo</th>
                <th class="px-4 py-3 font-semibold text-center">Estado</th>
                <th class="px-4 py-3 font-semibold text-center">Última Conexión</th>
                <th class="px-4 py-3 font-semibold text-center">Almacenamiento</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-border dark:divide-white/10 text-sm">
              <tr
                v-for="d in dispositivos" :key="d.id"
                class="hover:bg-surface/50 dark:hover:bg-dark-card2/50 transition-colors"
              >
                <td class="px-4 py-3">
                  <div class="flex items-center gap-3">
                    <span class="text-lg">{{ d.tipo === 'desktop' ? '🖥️' : '📱' }}</span>
                    <span class="font-medium text-text dark:text-dark-text text-sm">{{ d.nombre }}</span>
                  </div>
                </td>
                <td class="px-4 py-3">
                  <BaseBadge variant="neutral" size="sm">{{ d.tipo === 'desktop' ? 'Escritorio' : 'Tablet' }}</BaseBadge>
                </td>
                <td class="px-4 py-3 text-center">
                  <div class="inline-flex items-center gap-1.5">
                    <div class="w-2 h-2 rounded-full" :class="d.estado === 'online' ? 'bg-mint animate-pulse' : 'bg-text-light'"></div>
                    <span class="text-xs font-semibold" :class="d.estado === 'online' ? 'text-mint' : 'text-text-muted'">
                      {{ d.estado === 'online' ? 'Online' : 'Offline' }}
                    </span>
                  </div>
                </td>
                <td class="px-4 py-3 text-center text-xs text-text-muted">{{ d.ultimaConexion }}</td>
                <td class="px-4 py-3 text-center text-xs font-bold text-text dark:text-dark-text">{{ d.almacenamientoLocal }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </BaseCard>
    </div>

    <!-- Logs de Sistema -->
    <div class="space-y-4">
      <h2 class="font-display font-bold text-lg text-text dark:text-dark-text">📋 Registro del Sistema</h2>
      <BaseCard class="p-0 divide-y divide-border dark:divide-white/10">
        <div
          v-for="log in logsRecientes" :key="log.id"
          class="flex items-start gap-3 p-4 hover:bg-surface/50 dark:hover:bg-dark-card2/50 transition-colors"
        >
          <div class="mt-0.5 flex-shrink-0">
            <CheckCircle2 v-if="log.tipo === 'success'" :size="16" class="text-mint" />
            <AlertTriangle v-else-if="log.tipo === 'warning'" :size="16" class="text-amber" />
            <XCircle v-else-if="log.tipo === 'error'" :size="16" class="text-danger" />
            <Activity v-else :size="16" class="text-primary" />
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm text-text dark:text-dark-text leading-snug">{{ log.mensaje }}</p>
            <p class="text-[11px] text-text-muted mt-0.5">{{ log.tiempo }}</p>
          </div>
        </div>
      </BaseCard>
    </div>
  </div>
</template>
