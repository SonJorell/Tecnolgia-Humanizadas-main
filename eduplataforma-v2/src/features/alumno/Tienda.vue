<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useGamificacionStore } from '@/stores/gamificacion'
import { useAuthStore } from '@/stores/auth'
import RewardConfetti from '@/components/gamification/RewardConfetti.vue'

const store = useGamificacionStore()
const authStore = useAuthStore()

const comprando = ref(false)
const showReward = ref(false)
const itemComprado = ref('')
const currentFilter = ref('Todos')
const searchQuery = ref('')
const showHistory = ref(false)

onMounted(async () => {
  await store.loadTienda()
})

const filteredTienda = computed(() => {
  return store.tienda.filter(item => {
    const matchSearch = item.nombre.toLowerCase().includes(searchQuery.value.toLowerCase()) || item.categoria.toLowerCase().includes(searchQuery.value.toLowerCase())
    return matchSearch
  })
})

const academicos = computed(() => filteredTienda.value.filter(i => i.categoria === 'academico'))
const digitales = computed(() => filteredTienda.value.filter(i => ['banner', 'avatar', 'marco'].includes(i.categoria)))
const fisicos = computed(() => filteredTienda.value.filter(i => i.categoria === 'fisico'))

async function intentarComprar(id: string, nombre: string) {
  try {
    comprando.value = true
    await store.comprarItem(id)
    itemComprado.value = nombre
    showReward.value = true
  } catch (err: any) {
    alert(err.message)
  } finally {
    comprando.value = false
  }
}

function getIconForCategoria(cat: string) {
  switch(cat) {
    case 'academico': return 'school'
    case 'banner': return 'wallpaper'
    case 'avatar': return 'face'
    case 'marco': return 'crop_square'
    case 'fisico': return 'inventory_2'
    default: return 'star'
  }
}

const historial = computed(() => {
  // Mock history derived from inventario
  const inventario = authStore.perfil?.inventario_premios || []
  return inventario.map((inv: string) => {
    const item = store.tienda.find(i => i.icono === inv || i.id === inv)
    return {
      nombre: item ? item.nombre : inv,
      fecha: new Date().toLocaleDateString(),
      categoria: item ? item.categoria : 'digital'
    }
  })
})
</script>

<template>
  <div class="px-margin-mobile md:px-margin-desktop max-w-container-max mx-auto w-full space-y-12 pb-20 animate-fade-in">
    
    <!-- Hero Section & Balance -->
    <section class="relative rounded-3xl overflow-hidden bg-primary h-[320px] shadow-xl flex items-center mt-6">
      <div class="absolute inset-0 bg-primary opacity-80"></div>
      <div class="absolute inset-0 opacity-10 bg-[radial-gradient(circle_at_top_right,_var(--tw-gradient-stops))] from-white via-transparent to-transparent"></div>
      <div class="absolute -right-20 -bottom-20 opacity-10">
        <span class="material-symbols-outlined text-[300px] text-white">storefront</span>
      </div>

      <div class="relative z-10 px-6 md:px-12 w-full flex flex-col md:flex-row justify-between items-center gap-8">
        <div class="text-on-primary text-center md:text-left">
          <span class="bg-secondary-container text-on-secondary-container px-4 py-1 rounded-full font-label-md text-label-md mb-4 inline-block shadow-sm tracking-widest uppercase">Tienda Oficial</span>
          <h2 class="font-headline-xl text-headline-xl mb-2 text-on-primary">Tienda de Canjes</h2>
          <p class="font-body-lg text-body-lg text-on-primary/90 max-w-md">Transforma tu esfuerzo en recompensas exclusivas. Canjea tus EduMonedas aquí.</p>
        </div>
        
        <div class="bg-white/10 backdrop-blur-md border border-white/20 p-8 rounded-3xl flex flex-col items-center w-full max-w-sm shadow-lg">
          <p class="text-white/80 font-label-sm text-label-sm mb-1 uppercase tracking-widest">Tu Balance Actual</p>
          <div class="flex items-center gap-3">
            <span class="material-symbols-outlined text-4xl text-secondary-container" style="font-variation-settings: 'FILL' 1;">monetization_on</span>
            <span class="font-headline-xl text-headline-xl text-white">{{ authStore.perfil?.monedas || 0 }} <span class="font-headline-md text-headline-md font-medium text-secondary-container">EDM</span></span>
          </div>
          <button type="button" @click="showHistory = true" class="mt-4 w-full bg-white text-primary py-2.5 rounded-xl font-bold hover:bg-surface-container-low transition-colors active:scale-95 duration-200">Ver Historial</button>
        </div>
      </div>
    </section>

    <!-- Filters & Search -->
    <div class="flex flex-col md:flex-row justify-between gap-4 sticky top-20 z-30 py-4 bg-surface/80 backdrop-blur-md border-b border-border-subtle/50">
      <div class="flex flex-wrap gap-3">
        <button type="button" 
          v-for="filter in ['Todos', 'Digitales', 'Académicos', 'Físicos']" 
          :key="filter"
          @click="currentFilter = filter"
          :class="[
            'px-5 py-2 rounded-full font-label-md text-label-md transition-all shadow-sm border',
            currentFilter === filter 
              ? 'bg-primary text-on-primary border-primary' 
              : 'bg-surface-container-lowest border-border-subtle text-on-surface-variant hover:border-primary/50 hover:text-primary'
          ]"
        >
          {{ filter }}
        </button>
      </div>
      <div class="relative w-full md:w-72">
        <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
        <input id="searchQuery" name="searchQuery" 
          v-model="searchQuery"
          type="text" 
          placeholder="Buscar recompensas o tags..." 
          class="w-full pl-10 pr-4 py-2 bg-surface-container-lowest border border-border-subtle rounded-full text-sm font-body-sm text-on-surface outline-none focus:ring-2 focus:ring-primary focus:border-primary transition-all shadow-sm"
        />
      </div>
    </div>

    <div v-if="store.loading" class="text-center py-20 text-on-surface-variant">
      <span class="material-symbols-outlined animate-spin text-4xl mb-4">sync</span>
      <p class="font-body-md text-body-md">Cargando inventario...</p>
    </div>

    <template v-else>
      <!-- Beneficios Académicos Section -->
      <section v-if="(currentFilter === 'Todos' || currentFilter === 'Académicos') && academicos.length > 0">
        <div class="flex items-center gap-4 mb-8">
          <div class="p-3 bg-primary/10 rounded-2xl">
            <span class="material-symbols-outlined text-primary text-[28px]">school</span>
          </div>
          <div>
            <h3 class="font-headline-md text-headline-md text-on-surface">Beneficios Académicos</h3>
            <p class="font-body-sm text-body-sm text-on-surface-variant">Mejora tu rendimiento con ventajas exclusivas.</p>
          </div>
        </div>
        
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-for="item in academicos" :key="item.id" class="bg-surface-container-lowest border border-border-subtle rounded-3xl p-6 hover:shadow-lg hover:border-primary/30 transition-all group flex flex-col h-full">
            <div class="flex justify-between items-start mb-6">
              <div class="w-16 h-16 bg-surface-container rounded-2xl flex items-center justify-center text-primary group-hover:scale-110 transition-transform">
                <span class="material-symbols-outlined text-[32px]">{{ getIconForCategoria(item.categoria) }}</span>
              </div>
              <span class="bg-surface-container-high text-on-surface-variant px-2.5 py-1 rounded-md text-[10px] uppercase font-bold tracking-wider">ACADÉMICO</span>
            </div>
            <h4 class="font-headline-md text-xl mb-2 text-on-surface">{{ item.nombre }}</h4>
            <p class="font-body-sm text-body-sm text-on-surface-variant flex-grow">{{ item.requiere_aprobacion ? 'Requiere aprobación de tu profesor.' : 'Beneficio de uso inmediato.' }}</p>
            
            <div class="mt-8 flex items-center justify-between border-t border-border-subtle pt-4">
              <span class="flex items-center gap-1 font-bold text-primary">
                <span class="material-symbols-outlined text-sm" style="font-variation-settings: 'FILL' 1;">monetization_on</span>
                {{ item.precio_monedas }} EDM
              </span>
              <button type="button" 
                @click="intentarComprar(item.id, item.nombre)"
                :disabled="(authStore.perfil?.monedas || 0) < item.precio_monedas || comprando"
                class="bg-primary text-on-primary px-6 py-2 rounded-xl font-label-md text-label-md hover:bg-primary-container hover:text-on-primary-container disabled:opacity-50 disabled:pointer-events-none transition-colors"
              >
                Canjear
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- Personalizaciones Digitales Section -->
      <section v-if="(currentFilter === 'Todos' || currentFilter === 'Digitales') && digitales.length > 0">
        <div class="flex items-center gap-4 mb-8">
          <div class="p-3 bg-secondary/10 rounded-2xl">
            <span class="material-symbols-outlined text-secondary text-[28px]">palette</span>
          </div>
          <div>
            <h3 class="font-headline-md text-headline-md text-on-surface">Personalizaciones Digitales</h3>
            <p class="font-body-sm text-body-sm text-on-surface-variant">Haz que tu perfil destaque en la red EduPlataforma.</p>
          </div>
        </div>
        
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-for="item in digitales" :key="item.id" class="bg-surface-container-lowest border border-border-subtle rounded-3xl p-6 flex flex-col hover:shadow-lg hover:border-secondary/30 transition-all group">
            <div class="flex-grow">
              <div class="relative rounded-2xl overflow-hidden h-40 mb-6 bg-surface-container flex items-center justify-center">
                <template v-if="item.categoria === 'banner'">
                  <img v-if="item.icono && item.icono.length > 5" :src="item.icono" class="w-full h-full object-cover group-hover:scale-105 transition-transform" />
                  <span v-else class="material-symbols-outlined text-6xl text-on-surface-variant/30">wallpaper</span>
                </template>
                <template v-else-if="item.categoria === 'avatar'">
                  <div class="text-6xl group-hover:scale-110 transition-transform">{{ item.icono || '😎' }}</div>
                </template>
                <template v-else>
                  <span class="material-symbols-outlined text-6xl text-on-surface-variant/30 group-hover:scale-110 transition-transform">{{ getIconForCategoria(item.categoria) }}</span>
                </template>
              </div>
              <div class="flex justify-between items-start mb-2 gap-2">
                <h4 class="font-headline-md text-xl text-on-surface line-clamp-2">{{ item.nombre }}</h4>
                <span class="bg-surface-container-high text-on-surface-variant px-2.5 py-1 rounded-md text-[10px] uppercase font-bold tracking-wider shrink-0">{{ item.categoria }}</span>
              </div>
            </div>
            
            <div class="mt-6 flex flex-col gap-4 border-t border-border-subtle pt-4">
              <div class="flex items-center justify-between">
                <span class="flex items-center gap-1 font-bold text-secondary">
                  <span class="material-symbols-outlined text-sm" style="font-variation-settings: 'FILL' 1;">monetization_on</span>
                  {{ item.precio_monedas }} EDM
                </span>
                <span class="text-xs font-bold text-on-surface-variant opacity-60 uppercase">Inmediato</span>
              </div>
              <button type="button" 
                @click="intentarComprar(item.id, item.nombre)"
                :disabled="(authStore.perfil?.monedas || 0) < item.precio_monedas || comprando"
                class="w-full bg-surface-container text-on-surface py-2.5 rounded-xl font-label-md text-label-md hover:bg-surface-container-highest disabled:opacity-50 disabled:pointer-events-none transition-colors"
              >
                Canjear
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- Artículos Físicos Section -->
      <section v-if="(currentFilter === 'Todos' || currentFilter === 'Físicos') && fisicos.length > 0">
        <div class="flex items-center gap-4 mb-8">
          <div class="p-3 bg-tertiary/10 rounded-2xl">
            <span class="material-symbols-outlined text-tertiary text-[28px]">shopping_bag</span>
          </div>
          <div>
            <h3 class="font-headline-md text-headline-md text-on-surface">Artículos Físicos</h3>
            <p class="font-body-sm text-body-sm text-on-surface-variant">Recompensas tangibles enviadas directamente a tu institución o domicilio.</p>
          </div>
        </div>
        
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          <div v-for="item in fisicos" :key="item.id" class="bg-surface-container-lowest border border-border-subtle rounded-3xl overflow-hidden group shadow-sm hover:shadow-xl transition-all relative">
            <span class="absolute top-3 left-3 bg-surface-container-high/80 backdrop-blur text-on-surface-variant px-2.5 py-1 rounded-md text-[10px] uppercase font-bold tracking-wider z-10">FÍSICO</span>
            <div class="h-48 bg-surface-container-low relative flex items-center justify-center">
              <img v-if="item.icono && item.icono.length > 5" :src="item.icono" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
              <span v-else class="material-symbols-outlined text-[64px] text-tertiary/40">inventory_2</span>
            </div>
            <div class="p-5">
              <h4 class="font-bold text-on-surface font-body-lg mb-1">{{ item.nombre }}</h4>
              <p class="text-[12px] text-on-surface-variant mb-4">Artículo físico con entrega programada.</p>
              
              <div class="flex items-center justify-between border-t border-border-subtle pt-3">
                <span class="text-tertiary font-bold flex items-center gap-1">
                  <span class="material-symbols-outlined text-sm" style="font-variation-settings: 'FILL' 1;">monetization_on</span>
                  {{ item.precio_monedas }}
                </span>
                <button type="button" 
                  @click="intentarComprar(item.id, item.nombre)"
                  :disabled="(authStore.perfil?.monedas || 0) < item.precio_monedas || comprando"
                  class="bg-tertiary/10 text-tertiary hover:bg-tertiary hover:text-on-tertiary px-4 py-2 rounded-xl text-label-sm font-bold transition-all disabled:opacity-50 disabled:pointer-events-none"
                >
                  Solicitar
                </button>
              </div>
            </div>
          </div>
        </div>
      </section>
      
      <div v-if="filteredTienda.length === 0" class="text-center py-20 bg-surface-container-lowest rounded-3xl border border-border-subtle shadow-sm">
        <span class="material-symbols-outlined text-[64px] text-on-surface-variant/50 mb-4">search_off</span>
        <h3 class="font-headline-md text-headline-md text-on-surface">No hay resultados</h3>
        <p class="font-body-md text-body-md text-on-surface-variant mt-2">No pudimos encontrar recompensas con ese criterio.</p>
      </div>
    </template>

    <RewardConfetti :active="showReward" @complete="showReward = false" />

    <!-- History Modal -->
    <div v-if="showHistory" class="fixed inset-0 z-50 flex items-center justify-center px-4 bg-black/50 backdrop-blur-sm animate-fade-in">
      <div class="bg-surface-container-lowest w-full max-w-lg rounded-3xl shadow-xl overflow-hidden flex flex-col max-h-[80vh]">
        <div class="p-6 border-b border-border-subtle flex items-center justify-between">
          <h3 class="font-headline-md text-xl font-bold text-on-surface">Historial de Canjes</h3>
          <button type="button" @click="showHistory = false" class="p-2 text-on-surface-variant hover:text-primary transition-colors hover:bg-surface-variant rounded-full">
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>
        <div class="p-6 overflow-y-auto flex-1 bg-surface-container-lowest">
          <div v-if="historial.length === 0" class="text-center py-8 text-on-surface-variant">
            <span class="material-symbols-outlined text-4xl mb-2 opacity-50">receipt_long</span>
            <p class="font-body-sm">No has realizado canjes aún.</p>
          </div>
          <div v-else class="space-y-4">
            <div v-for="(hist, idx) in historial" :key="idx" class="flex items-center justify-between p-4 bg-surface-container-low rounded-2xl border border-border-subtle">
              <div class="flex items-center gap-4">
                <div class="w-10 h-10 rounded-full bg-primary/10 text-primary flex items-center justify-center">
                  <span class="material-symbols-outlined">{{ getIconForCategoria(hist.categoria) }}</span>
                </div>
                <div>
                  <p class="font-label-md text-on-surface">{{ hist.nombre }}</p>
                  <p class="text-xs text-on-surface-variant mt-0.5">{{ hist.fecha }}</p>
                </div>
              </div>
              <span class="bg-secondary-container text-on-secondary-container text-[10px] font-bold px-2 py-1 rounded-md uppercase tracking-wider">Entregado</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(16px); }
  to { opacity: 1; transform: translateY(0); }
}
.animate-fade-in {
  animation: fadeIn 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}
</style>
