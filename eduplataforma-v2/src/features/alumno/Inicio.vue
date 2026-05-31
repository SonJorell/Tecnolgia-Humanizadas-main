<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useAppStore } from '@/stores/app'
import { useSyncStore } from '@/stores/sync'
import { supabase } from '@/services/supabase'
import StatCard from '@/components/ui/StatCard.vue'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import { BookOpen, ClipboardList, Trophy, Coins, AlertTriangle, Clock, Megaphone } from 'lucide-vue-next'
import type { Material } from '@/types/database'

const authStore = useAuthStore()
const appStore = useAppStore()
const syncStore = useSyncStore()

const stats = ref({ cursos: 0, tareas: 0, logros: 0 })
const materialesNuevos = ref<Material[]>([])
const comunicados = ref<any[]>([])
const loading = ref(true)

onMounted(async () => {
  if (!authStore.perfil || !appStore.isOnline) {
    loading.value = false
    return
  }
  await loadStats()
})

async function loadStats() {
  try {
    const [inscRes, entregaRes, logrosRes, matRes] = await Promise.all([
      supabase.from('inscripciones').select('id, curso_id', { count: 'exact' }).eq('alumno_id', authStore.perfil!.id),
      supabase.from('entregas').select('id', { count: 'exact' }).eq('alumno_id', authStore.perfil!.id).eq('estado', 'pendiente'),
      supabase.from('logros_alumno').select('id', { count: 'exact' }).eq('alumno_id', authStore.perfil!.id),
      supabase.from('materiales').select('*').eq('publicado', true).order('creado_en', { ascending: false }).limit(3)
    ])

    stats.value = {
      cursos: inscRes.count || 0,
      tareas: entregaRes.count || 0,
      logros: logrosRes.count || 0,
    }
    materialesNuevos.value = (matRes.data as Material[]) || []

    // Fetch Comunicados
    const cursoIds = (inscRes.data || []).map(i => i.curso_id)
    let query = supabase.from('comunicados').select('*, autor:perfiles!autor_id(nombre)')
    
    if (cursoIds.length > 0) {
      query = query.or(`segmento.in.(todos,alumnos),curso_id.in.(${cursoIds.join(',')})`)
    } else {
      query = query.in('segmento', ['todos', 'alumnos'])
    }
    
    const { data: comData } = await query.order('creado_en', { ascending: false }).limit(2)
    if (comData) comunicados.value = comData

  } catch (err) {
    console.error('[Inicio] Error cargando stats:', err)
  } finally {
    loading.value = false
  }
}

function getTipoIcon(tipo: string): string {
  switch (tipo) {
    case 'guia': return '📖'
    case 'tarea': return '📝'
    case 'evaluacion': return '📋'
    default: return '📁'
  }
}
</script>

<template>
  <div v-if="authStore.perfil" class="p-4 md:p-6 space-y-6 animate-fade-in">
    <!-- Welcome -->
    <div>
      <h1 class="font-display font-extrabold text-2xl text-text dark:text-dark-text">
        ¡Hola, {{ authStore.perfil.nombre.split(' ')[0] }}! 👋
      </h1>
      <p class="text-sm text-text-muted dark:text-dark-muted mt-1">
        Revisa tu progreso y tareas pendientes
      </p>
    </div>

    <!-- Sync warning -->
    <div
      v-if="syncStore.hasPendientes"
      class="flex items-center gap-3 bg-amber-bg dark:bg-amber/10 text-amber px-4 py-3 rounded-xl animate-slide-up"
    >
      <AlertTriangle :size="18" />
      <span class="text-sm font-medium">
        {{ syncStore.pendientes }} elemento{{ syncStore.pendientes > 1 ? 's' : '' }} pendiente{{ syncStore.pendientes > 1 ? 's' : '' }} de sincronizar
      </span>
    </div>

    <!-- Comunicados (Anuncios Oficiales) -->
    <div v-if="comunicados.length > 0" class="space-y-3">
      <div v-for="com in comunicados" :key="com.id" class="flex items-start gap-3 bg-mint-bg dark:bg-mint/10 border border-mint/20 text-text dark:text-dark-text px-4 py-3 rounded-xl animate-slide-up shadow-sm">
        <Megaphone class="text-mint flex-shrink-0 mt-0.5" :size="20" />
        <div>
          <div class="flex items-center gap-2 mb-1">
            <h3 class="font-bold text-mint">{{ com.titulo }}</h3>
            <span class="text-[10px] uppercase bg-mint/20 text-mint px-1.5 py-0.5 rounded font-bold">Dirección</span>
          </div>
          <p class="text-sm opacity-90">{{ com.contenido }}</p>
        </div>
      </div>
    </div>

    <!-- Stats -->
    <div class="stats-row grid grid-cols-1 gap-4">
      <StatCard
        :icon="BookOpen"
        icon-bg="bg-primary-bg"
        label="Cursos activos"
        :value="loading ? '—' : stats.cursos"
      />
      <StatCard
        :icon="ClipboardList"
        icon-bg="bg-amber-bg"
        label="Tareas pendientes"
        :value="loading ? '—' : stats.tareas"
        :subtitle="stats.tareas > 0 ? 'Revísalas' : undefined"
      />
      <StatCard
        :icon="Trophy"
        icon-bg="bg-mint-bg"
        label="Logros ganados"
        :value="loading ? '—' : stats.logros"
      />
      <StatCard
        :icon="Coins"
        icon-bg="bg-amber-bg"
        label="Monedas"
        :value="authStore.perfil.monedas"
        subtitle="Canjea en la tienda"
      />
    </div>

    <!-- New materials -->
    <div v-if="materialesNuevos.length > 0">
      <h2 class="font-display font-bold text-lg text-text dark:text-dark-text mb-3">
        📚 Material nuevo
      </h2>
      <div class="space-y-2">
        <BaseCard v-for="mat in materialesNuevos" :key="mat.id" hover class="flex items-center gap-3">
          <div class="w-10 h-10 bg-primary-bg rounded-lg flex items-center justify-center text-lg flex-shrink-0">
            {{ getTipoIcon(mat.tipo) }}
          </div>
          <div class="min-w-0 flex-1">
            <p class="font-medium text-sm text-text dark:text-dark-text truncate">{{ mat.titulo }}</p>
            <div class="flex items-center gap-2 mt-0.5">
              <BaseBadge :variant="mat.tipo === 'tarea' ? 'amber' : 'primary'" size="sm">{{ mat.tipo }}</BaseBadge>
              <BaseBadge v-if="mat.disponible_offline" variant="neutral" size="sm">📶 Offline</BaseBadge>
            </div>
          </div>
          <div v-if="mat.fecha_entrega" class="flex items-center gap-1 text-xs text-text-muted flex-shrink-0">
            <Clock :size="12" />
            {{ new Date(mat.fecha_entrega).toLocaleDateString('es-CL') }}
          </div>
        </BaseCard>
      </div>
    </div>
  </div>
</template>
