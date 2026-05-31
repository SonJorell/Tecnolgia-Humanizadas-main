<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { supabase } from '@/services/supabase'
import { useAuthStore } from '@/stores/auth'
import { useAppStore } from '@/stores/app'
import { useCursosStore } from '@/stores/cursos'
import BaseCard from '@/components/ui/BaseCard.vue'
import { MessageSquare, Send, ArrowLeft, Check, CheckCheck } from 'lucide-vue-next'

const authStore = useAuthStore()
const appStore = useAppStore()
const cursosStore = useCursosStore()

const conversaciones = ref<any[]>([])
const selectedChat = ref<any>(null)
const chatMessages = ref<any[]>([])
const loadingChat = ref(false)
const newMessage = ref('')

const chats = computed(() => {
  let list = conversaciones.value.map(c => {
    let otherId = c.participante_1 === authStore.user?.id ? c.participante_2 : c.participante_1
    let otherUser = c.participante1_perfil?.id === otherId ? c.participante1_perfil : c.participante2_perfil
    
    const unread = c.mensajes?.filter((m: any) => !m.leido && m.autor_id !== authStore.user?.id).length || 0
    const lastMsg = c.mensajes?.slice(-1)[0]

    return {
      id: c.id,
      otherId,
      name: otherUser?.nombre || 'Docente',
      avatar: otherUser?.avatar_url || null,
      rol: otherUser?.rol || 'docente',
      unread,
      lastMessage: lastMsg?.contenido || 'Sin mensajes',
      lastDate: lastMsg?.creado_en || c.creado_en,
      isNew: false
    }
  })

  // Añadir profesores con los que no hay conversación
  const uniqueTeachers = new Map()
  cursosStore.inscripciones.forEach((i: any) => {
    if (i.curso?.docente) {
      uniqueTeachers.set(i.curso.docente.id, i.curso.docente)
    }
  })

  Array.from(uniqueTeachers.values()).forEach(t => {
    if (!list.some(c => c.otherId === t.id)) {
      list.push({
        id: 'temp-' + t.id,
        otherId: t.id,
        name: t.nombre,
        avatar: t.avatar_url || null,
        rol: 'docente',
        unread: 0,
        lastMessage: 'Iniciar chat',
        lastDate: new Date().toISOString(),
        isNew: true
      })
    }
  })

  return list.sort((a, b) => new Date(b.lastDate).getTime() - new Date(a.lastDate).getTime())
})

onMounted(async () => {
  await cursosStore.cargarInscripciones(authStore.user?.id || '')
  await loadConversaciones()
})

async function loadConversaciones() {
  if (!authStore.user) return
  const { data, error } = await supabase
    .from('conversaciones')
    .select(`
      *, 
      mensajes(*),
      participante1_perfil:perfiles!participante_1(id, nombre, avatar_url, rol),
      participante2_perfil:perfiles!participante_2(id, nombre, avatar_url, rol)
    `)
    .or(`participante_1.eq.${authStore.user.id},participante_2.eq.${authStore.user.id}`)
    .eq('tipo', 'individual')

  if (data) {
    conversaciones.value = data
  }
}

async function selectChat(chatId: string) {
  if (chatId.startsWith('temp-')) {
    const chatInfo = chats.value.find(c => c.id === chatId)
    selectedChat.value = chatInfo
    chatMessages.value = []
    return
  }

  const chatInfo = chats.value.find(c => c.id === chatId)
  if (!chatInfo) return

  selectedChat.value = chatInfo
  loadingChat.value = true

  const { data, error } = await supabase
    .from('mensajes')
    .select('*')
    .eq('conversacion_id', chatId)
    .order('creado_en', { ascending: true })

  if (data) {
    chatMessages.value = data
    // Mark as read
    const unreadIds = data.filter(m => !m.leido && m.autor_id !== authStore.user?.id).map(m => m.id)
    if (unreadIds.length > 0) {
      await supabase.from('mensajes').update({ leido: true }).in('id', unreadIds)
      const conv = conversaciones.value.find(c => c.id === chatId)
      if (conv && conv.mensajes) {
        conv.mensajes.forEach((m: any) => { if (unreadIds.includes(m.id)) m.leido = true })
      }
    }
  }
  loadingChat.value = false
  
  setTimeout(() => {
    const container = document.getElementById('chat-container')
    if (container) container.scrollTop = container.scrollHeight
  }, 100)
}

async function sendMessage() {
  if (!newMessage.value.trim() || !selectedChat.value) return

  const content = newMessage.value.trim()
  newMessage.value = ''

  try {
    let convId = selectedChat.value.id

    if (selectedChat.value.isNew) {
      const { data: newConv, error: convErr } = await supabase.from('conversaciones').insert({
        participante_1: authStore.user?.id,
        participante_2: selectedChat.value.otherId,
        tipo: 'individual'
      }).select(`
        *, 
        participante1_perfil:perfiles!participante_1(id, nombre, avatar_url, rol),
        participante2_perfil:perfiles!participante_2(id, nombre, avatar_url, rol)
      `).single()

      if (convErr) throw convErr
      convId = newConv.id
      conversaciones.value.push({ ...newConv, mensajes: [] })
      selectedChat.value.id = convId
      selectedChat.value.isNew = false
    }

    const { data: msgData, error } = await supabase.from('mensajes').insert({
      conversacion_id: convId,
      autor_id: authStore.user?.id,
      contenido: content
    }).select().single()

    if (error) throw error

    chatMessages.value.push(msgData)
    
    // Actualizar ultimo mensaje localmente
    const conv = conversaciones.value.find(c => c.id === selectedChat.value.id)
    if (conv) {
      if (!conv.mensajes) conv.mensajes = []
      conv.mensajes.push(msgData)
    }

    setTimeout(() => {
      const container = document.getElementById('chat-container')
      if (container) container.scrollTop = container.scrollHeight
    }, 100)
  } catch(e) {
    console.error(e)
    appStore.addToast({ tipo: 'error', mensaje: 'No se pudo enviar el mensaje' })
    newMessage.value = content
  }
}
</script>

<template>
  <div class="p-4 md:p-6 max-w-6xl mx-auto h-[calc(100vh-80px)] flex flex-col animate-fade-in">
    <div class="mb-4">
      <h1 class="font-display font-extrabold text-2xl md:text-3xl text-text dark:text-dark-text flex items-center gap-2">
        <MessageSquare class="text-primary" /> Mis Mensajes
      </h1>
      <p class="text-sm text-text-muted mt-1">Chat directo con tus profesores.</p>
    </div>

    <BaseCard class="flex-1 flex overflow-hidden shadow-sm">
      <!-- Sidebar de Chats -->
      <div class="w-full md:w-80 border-r border-border dark:border-white/10 flex flex-col bg-surface/50 dark:bg-dark-card2" :class="{'hidden md:flex': selectedChat}">
        <div class="flex-1 overflow-y-auto divide-y divide-border dark:divide-white/10">
          <div 
            v-for="chat in chats" 
            :key="chat.id"
            class="p-4 flex items-center gap-3 cursor-pointer hover:bg-card dark:hover:bg-dark-card transition-colors"
            :class="{'bg-primary/5 dark:bg-primary/10 border-l-4 border-primary': selectedChat?.id === chat.id}"
            @click="selectChat(chat.id)"
          >
            <div class="w-10 h-10 rounded-full bg-primary-bg dark:bg-primary/20 text-primary flex items-center justify-center font-bold text-sm flex-shrink-0 relative">
              <img v-if="chat.avatar" :src="chat.avatar" class="w-full h-full rounded-full object-cover" />
              <span v-else>{{ chat.name.charAt(0).toUpperCase() }}</span>
              <div v-if="chat.unread > 0" class="absolute -top-1 -right-1 w-4 h-4 bg-danger text-white text-[10px] font-bold rounded-full flex items-center justify-center border-2 border-surface dark:border-dark-card2">
                {{ chat.unread }}
              </div>
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex justify-between items-baseline mb-0.5">
                <h4 class="font-bold text-sm text-text dark:text-dark-text truncate">{{ chat.name }}</h4>
                <span class="text-[10px] text-text-muted whitespace-nowrap">{{ new Date(chat.lastDate).toLocaleDateString() }}</span>
              </div>
              <p class="text-xs text-text-muted truncate" :class="{'font-bold text-text dark:text-dark-text': chat.unread > 0}">
                {{ chat.lastMessage }}
              </p>
            </div>
          </div>
          
          <div v-if="chats.length === 0" class="p-6 text-center text-sm text-text-muted">
            No tienes mensajes privados aún.
          </div>
        </div>
      </div>

      <!-- Área de Chat -->
      <div class="flex-1 flex flex-col bg-card dark:bg-dark-card" :class="{'hidden md:flex': !selectedChat}">
        <template v-if="selectedChat">
          <!-- Header -->
          <div class="h-16 border-b border-border dark:border-white/10 flex items-center px-4 gap-3">
            <button class="md:hidden p-2 -ml-2 text-text-muted" @click="selectedChat = null">
              <ArrowLeft :size="20" />
            </button>
            <div class="w-10 h-10 rounded-full bg-primary-bg dark:bg-primary/20 text-primary flex items-center justify-center font-bold text-sm overflow-hidden">
              <img v-if="selectedChat.avatar" :src="selectedChat.avatar" class="w-full h-full object-cover" />
              <span v-else>{{ selectedChat.name.charAt(0).toUpperCase() }}</span>
            </div>
            <div>
              <h3 class="font-bold text-text dark:text-dark-text">{{ selectedChat.name }}</h3>
              <p class="text-[10px] text-mint font-medium bg-mint/10 px-1.5 py-0.5 rounded inline-block mt-0.5 uppercase">Docente</p>
            </div>
          </div>

          <!-- Mensajes -->
          <div id="chat-container" class="flex-1 overflow-y-auto p-4 space-y-4 bg-surface/30 dark:bg-dark-bg/20">
            <div v-if="loadingChat" class="flex justify-center p-4">
              <div class="w-6 h-6 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
            </div>
            
            <template v-else>
              <div v-if="selectedChat.isNew" class="text-center p-4 bg-primary/10 text-primary text-sm rounded-xl mb-4">
                Envía tu primer mensaje a {{ selectedChat.name }} para iniciar la conversación.
              </div>
              <div 
                v-for="msg in chatMessages" 
                :key="msg.id"
                class="flex flex-col max-w-[80%]"
                :class="[msg.autor_id === authStore.user?.id ? 'ml-auto items-end' : 'mr-auto items-start']"
              >
                <div 
                  class="px-4 py-2 rounded-2xl text-sm"
                  :class="[
                    msg.autor_id === authStore.user?.id 
                      ? 'bg-primary text-white rounded-tr-sm' 
                      : 'bg-surface dark:bg-dark-card2 text-text dark:text-dark-text border border-border dark:border-white/10 rounded-tl-sm'
                  ]"
                >
                  {{ msg.contenido }}
                </div>
                <div class="flex items-center gap-1 mt-1 px-1">
                  <span class="text-[10px] text-text-muted">{{ new Date(msg.creado_en).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) }}</span>
                  <template v-if="msg.autor_id === authStore.user?.id">
                    <CheckCheck v-if="msg.leido" :size="12" class="text-blue-500" />
                    <Check v-else :size="12" class="text-text-light" />
                  </template>
                </div>
              </div>
            </template>
          </div>

          <!-- Input -->
          <div class="p-3 bg-surface dark:bg-dark-card2 border-t border-border dark:border-white/10">
            <form @submit.prevent="sendMessage" class="flex items-center gap-2">
              <input 
                v-model="newMessage" 
                type="text" 
                placeholder="Escribe un mensaje..." 
                class="flex-1 h-10 px-4 bg-card dark:bg-dark-bg border border-border dark:border-white/10 rounded-full text-sm outline-none focus:ring-2 focus:ring-primary/50"
              />
              <button 
                type="submit" 
                class="w-10 h-10 rounded-full bg-primary text-white flex items-center justify-center hover:bg-primary-hover transition-colors disabled:opacity-50"
                :disabled="!newMessage.trim()"
              >
                <Send :size="16" class="ml-0.5" />
              </button>
            </form>
          </div>
        </template>
        
        <div v-else class="flex-1 flex flex-col items-center justify-center text-text-muted p-6">
          <div class="w-16 h-16 rounded-full bg-surface dark:bg-dark-card2 flex items-center justify-center mb-4">
            <MessageSquare :size="24" class="text-primary/50" />
          </div>
          <h3 class="font-bold text-text dark:text-dark-text text-lg">Tus Mensajes</h3>
          <p class="text-sm text-center max-w-sm mt-2">Selecciona una conversación para leer y responder mensajes.</p>
        </div>
      </div>
    </BaseCard>
  </div>
</template>
