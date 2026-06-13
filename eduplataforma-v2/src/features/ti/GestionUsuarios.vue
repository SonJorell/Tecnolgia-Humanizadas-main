<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/services/supabase'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import { Shield, Search, UserCheck, AlertTriangle } from 'lucide-vue-next'
import { useAppStore } from '@/stores/app'

const appStore = useAppStore()
const usuarios = ref<any[]>([])
const loading = ref(true)
const search = ref('')

onMounted(async () => {
 await cargarUsuarios()
})

async function cargarUsuarios() {
 loading.value = true
 const { data } = await supabase
 .from('perfiles')
 .select('*')
 .order('rol')
 
 usuarios.value = data || []
 loading.value = false
}

const getFilteredUsers = () => {
 if (!search.value) return usuarios.value
 const s = search.value.toLowerCase()
 return usuarios.value.filter(u => 
 u.nombre?.toLowerCase().includes(s) || 
 u.email?.toLowerCase().includes(s) || 
 u.rol?.toLowerCase().includes(s)
 )
}
</script>

<template>
 <div class="p-4 md:p-6 space-y-6 animate-fade-in max-w-5xl mx-auto">
 <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
 <div>
 <h1 class="font-headline-md font-extrabold text-2xl md:text-3xl text-on-surface flex items-center gap-2">
 <Shield class="text-violet" /> Gestión de Permisos
 </h1>
 <p class="text-sm text-on-surface-variant mt-1">Supervisa roles y estado del sistema de los usuarios.</p>
 </div>
 
 <div class="relative w-full md:w-64 mt-4 md:mt-0">
 <Search :size="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-on-surface-variant" />
 <input id="search" name="search" v-model="search" type="text" placeholder="Buscar usuario..." class="w-full h-10 pl-9 pr-4 bg-surface-container-low border border-border-subtle rounded-lg text-sm outline-none focus:ring-2 focus:ring-violet/50" />
 </div>
 </div>

 <BaseCard class="p-0 overflow-hidden">
 <div class="overflow-x-auto">
 <div class="overflow-x-auto w-full">
<table class="w-full text-left border-collapse">
 <thead>
 <tr class="bg-surface-container-low text-xs uppercase tracking-wider text-on-surface-variant border-b border-border-subtle">
 <th class="px-4 py-3 font-semibold">Usuario</th>
 <th class="px-4 py-3 font-semibold">Email</th>
 <th class="px-4 py-3 font-semibold text-center">Rol</th>
 <th class="px-4 py-3 font-semibold text-center">Estado de Red</th>
 </tr>
 </thead>
 <tbody class="divide-y divide-border text-sm">
 <tr v-if="loading">
 <td colspan="4" class="p-4 text-center text-on-surface-variant">Cargando...</td>
 </tr>
 <tr v-else-if="getFilteredUsers().length === 0">
 <td colspan="4" class="p-4 text-center text-on-surface-variant">No se encontraron usuarios.</td>
 </tr>
 <tr v-else v-for="user in getFilteredUsers()" :key="user.id" class="hover:bg-surface-container-low/50 transition-colors">
 <td class="px-4 py-3 font-medium text-on-surface flex items-center gap-2">
 <div class="w-8 h-8 rounded-full bg-primary/20 text-primary flex items-center justify-center font-bold overflow-hidden flex-shrink-0">
 <img v-if="user.avatar_url" :src="user.avatar_url" class="w-full h-full object-cover" />
 <span v-else>{{ user.nombre?.charAt(0) || 'U' }}</span>
 </div>
 {{ user.nombre }}
 </td>
 <td class="px-4 py-3 text-on-surface-variant">{{ user.email }}</td>
 <td class="px-4 py-3 text-center">
 <BaseBadge 
 :variant="user.rol === 'ti' ? 'danger' : user.rol === 'directivo' ? 'violet' : user.rol === 'docente' ? 'mint' : 'primary'" 
 size="sm" class="uppercase"
 >
 {{ user.rol }}
 </BaseBadge>
 </td>
 <td class="px-4 py-3 text-center">
 <span class="inline-flex items-center gap-1 text-secondary text-xs font-bold">
 <UserCheck :size="14" /> OK
 </span>
 </td>
 </tr>
 </tbody>
 </table>
</div>
 </div>
 </BaseCard>
 </div>
</template>
