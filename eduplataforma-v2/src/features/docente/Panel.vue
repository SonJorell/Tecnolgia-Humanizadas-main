<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useDocenteStore } from '@/stores/docente'
import BaseCard from '@/components/ui/BaseCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import { CheckCircle2, Clock, Users, BookOpen, AlertCircle, ChevronRight, MessageSquare, Award, FileText } from 'lucide-vue-next'

const router = useRouter()
const authStore = useAuthStore()
const docenteStore = useDocenteStore()

onMounted(async () => {
  if (authStore.perfil) {
    await docenteStore.cargarDatos(authStore.perfil.id)
  }
})
</script>

<template>
  <div class="p-4 md:p-6 space-y-6 animate-fade-in">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
      <div>
        <h1 class="font-display font-extrabold text-2xl md:text-3xl text-text dark:text-dark-text">
          👋 Hola, Prof. {{ authStore.perfil?.nombre || 'Docente' }}
        </h1>
        <p class="text-sm text-text-muted mt-1">Aquí está el resumen de tus clases hoy.</p>
      </div>
      <div class="flex gap-2">
        <BaseButton variant="secondary" @click="router.push('/docente/materiales')">Subir Material</BaseButton>
        <BaseButton variant="primary" @click="router.push('/docente/entregas')">Corregir Tareas</BaseButton>
      </div>
    </div>

    <!-- KPIs -->
    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
      <StatCard 
        :icon="Clock" 
        label="Por corregir" 
        :value="docenteStore.pendientesCorreccion.length" 
        iconBg="bg-amber-bg dark:bg-amber/20 text-amber"
      />
      <StatCard 
        :icon="CheckCircle2" 
        label="Corregidas" 
        :value="docenteStore.revisadas.length" 
        iconBg="bg-mint-bg dark:bg-mint/20 text-mint"
      />
      <StatCard 
        :icon="BookOpen" 
        label="Cursos" 
        :value="docenteStore.totalCursos" 
        iconBg="bg-primary-bg dark:bg-primary/20 text-primary"
      />
      <StatCard 
        :icon="Users" 
        label="Alumnos" 
        :value="docenteStore.totalAlumnos" 
        iconBg="bg-violet-bg dark:bg-violet/20 text-violet"
      />
      <StatCard 
        :icon="MessageSquare" 
        label="Mensajes" 
        :value="docenteStore.mensajesNoLeidos" 
        iconBg="bg-blue-100 dark:bg-blue-900/30 text-blue-500"
      />
      <StatCard 
        :icon="Award" 
        label="Premios dados" 
        :value="docenteStore.totalLogrosOtorgados" 
        iconBg="bg-yellow-100 dark:bg-yellow-900/30 text-yellow-500"
      />
    </div>

    <!-- Main Content Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      
      <!-- Bandeja Prioritaria (Inbox) -->
      <div class="lg:col-span-2 space-y-4">
        <div class="flex items-center justify-between">
          <h2 class="font-display font-bold text-lg text-text dark:text-dark-text flex items-center gap-2">
            <AlertCircle class="text-danger" :size="20" /> Urgentes por corregir
          </h2>
          <button @click="router.push('/docente/entregas')" class="text-sm text-primary font-medium hover:underline">
            Ver todas
          </button>
        </div>
        
        <div class="bg-card dark:bg-dark-card border border-border dark:border-white/10 rounded-2xl p-2 shadow-sm">
          <div v-if="docenteStore.pendientesCorreccion.length === 0" class="text-center py-10">
            <CheckCircle2 class="mx-auto text-mint mb-2" :size="48" />
            <p class="font-medium text-text dark:text-dark-text">¡Todo calificado!</p>
            <p class="text-sm text-text-muted">Bandeja limpia, buen trabajo.</p>
          </div>

          <div v-else class="divide-y divide-border dark:divide-white/10">
            <div 
              v-for="entrega in docenteStore.pendientesCorreccion.slice(0, 4)" 
              :key="entrega.id"
              class="flex items-center justify-between p-3 sm:p-4 hover:bg-surface dark:hover:bg-dark-card2 transition-colors group cursor-pointer"
              @click="router.push('/docente/entregas')"
            >
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-full bg-primary-bg dark:bg-primary/20 text-primary flex items-center justify-center font-bold">
                  {{ (entrega as any)._alumno_nombre?.charAt(0) || 'A' }}
                </div>
                <div>
                  <p class="font-semibold text-text dark:text-dark-text text-sm sm:text-base">
                    {{ (entrega as any)._alumno_nombre || 'Alumno Desconocido' }}
                  </p>
                  <p class="text-xs text-text-muted">
                    Entregó: <span class="font-medium">{{ (entrega as any)._material_titulo || 'Tarea' }}</span>
                  </p>
                </div>
              </div>
              <ChevronRight class="text-text-light group-hover:text-primary" :size="18" />
            </div>
          </div>
        </div>
      </div>

      <!-- Tus Cursos Rápidos -->
      <div class="space-y-4">
        <h2 class="font-display font-bold text-lg text-text dark:text-dark-text">Tus Cursos</h2>
        
        <BaseCard 
          v-for="curso in docenteStore.cursos" 
          :key="curso.id"
          class="border-l-4"
          :style="{ borderLeftColor: curso.color || '#1a6fa8' }"
        >
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <span class="text-2xl">{{ curso.icono || '📚' }}</span>
              <div>
                <p class="font-bold text-text dark:text-dark-text leading-tight">{{ curso.nombre }}</p>
                <div class="flex items-center gap-2 mt-1">
                  <span class="text-[10px] text-text-muted bg-surface dark:bg-dark-bg px-1.5 py-0.5 rounded">{{ curso.nivel }}</span>
                  <span class="text-[10px] text-primary/80 font-medium bg-primary/10 px-1.5 py-0.5 rounded flex items-center gap-1">
                    <Users :size="10" /> {{ docenteStore.alumnos.filter(a => a.curso_id === curso.id).length }}
                  </span>
                </div>
              </div>
            </div>
            <BaseButton variant="ghost" size="sm" @click="router.push(`/docente/cursos/${curso.id}`)" class="text-xs">Ver</BaseButton>
          </div>
        </BaseCard>
        
        <div v-if="docenteStore.cursos.length === 0 && !docenteStore.loading" class="text-center p-6 bg-surface dark:bg-dark-card2 rounded-xl text-text-muted text-sm">
          Aún no tienes cursos asignados.
        </div>
      </div>
    </div>
  </div>
</template>
