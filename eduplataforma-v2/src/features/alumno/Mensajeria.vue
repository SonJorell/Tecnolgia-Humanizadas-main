<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { supabase } from '@/services/supabase'
import { useAuthStore } from '@/stores/auth'
import { useAppStore } from '@/stores/app'
import { useCursosStore } from '@/stores/cursos'

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
 <div class="px-margin-mobile md:px-margin-desktop py-8 max-w-container-max mx-auto h-[calc(100vh-80px)] flex flex-col animate-fade-in">
 <div class="mb-6 flex items-center gap-4">
 <div class="p-3 bg-primary/10 rounded-2xl text-primary flex items-center justify-center">
 <span class="material-symbols-outlined text-[32px]">forum</span>
 </div>
 <div>
 <h1 class="font-headline-lg text-headline-lg font-extrabold text-on-surface tracking-tight">
 Mis Mensajes
 </h1>
 <p class="font-body-md text-body-md text-on-surface-variant mt-1">Comunícate directamente con tus profesores y asesores.</p>
 </div>
 </div>

 <div class="flex-1 flex overflow-hidden rounded-3xl bg-surface-container-lowest border border-border-subtle shadow-lg">
 <!-- Sidebar de Chats -->
 <div class="w-full md:w-80 lg:w-96 border-r border-border-subtle flex flex-col bg-surface/50 backdrop-blur-xl" :class="{'hidden md:flex': selectedChat}">
 <!-- Search Bar in Chats -->
 <div class="p-4 border-b border-border-subtle">
 <div class="relative">
 <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
 <input id="input_text_10" name="input_text_10" type="text" placeholder="Buscar chat..." class="w-full pl-10 pr-4 py-2.5 bg-surface-container-lowest border border-border-subtle rounded-xl text-body-sm font-body-sm outline-none focus:ring-2 focus:ring-primary focus:border-primary transition-all shadow-sm">
 </div>
 </div>

 <div class="flex-1 overflow-y-auto">
 <div 
 v-for="chat in chats" 
 :key="chat.id"
 class="p-4 flex items-center gap-4 cursor-pointer hover:bg-surface-container-lowest border-b border-border-subtle/50 transition-all duration-300"
 :class="{'bg-surface-container-lowest shadow-sm ring-1 ring-primary/20': selectedChat?.id === chat.id}"
 @click="selectChat(chat.id)"
 >
 <div class="w-12 h-12 rounded-full bg-primary-fixed text-primary flex items-center justify-center font-bold text-lg flex-shrink-0 relative shadow-sm">
 <img v-if="chat.avatar && chat.avatar.length > 5" :src="chat.avatar" class="w-full h-full rounded-full object-cover" />
 <span v-else>{{ chat.name.charAt(0).toUpperCase() }}</span>
 <div v-if="chat.unread > 0" class="absolute -top-1 -right-1 w-5 h-5 bg-error text-on-error text-[11px] font-bold rounded-full flex items-center justify-center border-2 border-white shadow-sm">
 {{ chat.unread }}
 </div>
 </div>
 <div class="flex-1 min-w-0">
 <div class="flex justify-between items-center mb-1">
 <h4 class="font-label-md text-label-md text-on-surface truncate">{{ chat.name }}</h4>
 <span class="font-label-sm text-[10px] text-on-surface-variant whitespace-nowrap">{{ new Date(chat.lastDate).toLocaleDateString() }}</span>
 </div>
 <p class="font-body-sm text-[13px] text-on-surface-variant truncate" :class="{'font-bold text-on-surface ': chat.unread > 0}">
 {{ chat.lastMessage }}
 </p>
 </div>
 </div>
 
 <div v-if="chats.length === 0" class="p-10 flex flex-col items-center justify-center text-center">
 <span class="material-symbols-outlined text-4xl text-outline mb-3">inbox</span>
 <p class="font-body-md text-body-md text-on-surface-variant">No tienes mensajes privados aún.</p>
 </div>
 </div>
 </div>

 <!-- Área de Chat -->
 <div class="flex-1 flex flex-col bg-surface" :class="{'hidden md:flex': !selectedChat}">
 <template v-if="selectedChat">
 <!-- Header del Chat -->
 <div class="h-[72px] bg-surface-container-lowest border-b border-border-subtle flex items-center justify-between px-6 shadow-sm z-10">
 <div class="flex items-center gap-4">
 <button type="button" class="md:hidden p-2 -ml-2 rounded-full hover:bg-surface-variant text-on-surface-variant transition-colors" @click="selectedChat = null">
 <span class="material-symbols-outlined">arrow_back</span>
 </button>
 <div class="w-10 h-10 rounded-full bg-primary-fixed text-primary flex items-center justify-center font-bold text-sm shadow-sm overflow-hidden">
 <img v-if="selectedChat.avatar && selectedChat.avatar.length > 5" :src="selectedChat.avatar" class="w-full h-full object-cover" />
 <span v-else>{{ selectedChat.name.charAt(0).toUpperCase() }}</span>
 </div>
 <div>
 <h3 class="font-label-md text-label-md text-on-surface">{{ selectedChat.name }}</h3>
 <p class="font-label-sm text-[10px] text-secondary font-bold bg-secondary-container text-on-secondary-container px-2 py-0.5 rounded-md inline-block mt-1 uppercase tracking-wider">Docente</p>
 </div>
 </div>
 <button type="button" class="p-2 rounded-full hover:bg-surface-variant text-on-surface-variant transition-colors">
 <span class="material-symbols-outlined">more_vert</span>
 </button>
 </div>

 <!-- Mensajes -->
 <div id="chat-container" class="flex-1 overflow-y-auto p-6 space-y-6 relative bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] [background-size:16px_16px]">
 <div v-if="loadingChat" class="absolute inset-0 flex items-center justify-center bg-surface/50 backdrop-blur-sm z-20">
 <div class="w-10 h-10 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
 </div>
 
 <template v-else>
 <div v-if="selectedChat.isNew" class="text-center max-w-sm mx-auto p-6 bg-surface-container-lowest border border-border-subtle text-on-surface shadow-sm rounded-3xl mt-4">
 <div class="w-12 h-12 bg-primary/10 text-primary rounded-full flex items-center justify-center mx-auto mb-3">
 <span class="material-symbols-outlined text-[24px]">waving_hand</span>
 </div>
 <h4 class="font-headline-md text-lg mb-1">¡Di Hola!</h4>
 <p class="font-body-sm text-sm text-on-surface-variant">Envía tu primer mensaje a {{ selectedChat.name }} para iniciar la conversación.</p>
 </div>
 
 <div 
 v-for="msg in chatMessages" 
 :key="msg.id"
 class="flex flex-col max-w-[75%]"
 :class="[msg.autor_id === authStore.user?.id ? 'ml-auto items-end' : 'mr-auto items-start']"
 >
 <div 
 class="px-5 py-3 text-[15px] font-body-md shadow-sm"
 :class="[
 msg.autor_id === authStore.user?.id 
 ? 'bg-primary text-on-primary rounded-3xl rounded-tr-sm' 
 : 'bg-surface-container-lowest text-on-surface border border-border-subtle rounded-3xl rounded-tl-sm'
 ]"
 >
 {{ msg.contenido }}
 </div>
 <div class="flex items-center gap-1 mt-1.5 px-2">
 <span class="font-label-sm text-[11px] text-on-surface-variant opacity-80">{{ new Date(msg.creado_en).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) }}</span>
 <template v-if="msg.autor_id === authStore.user?.id">
 <span v-if="msg.leido" class="material-symbols-outlined text-[14px] text-primary" style="font-variation-settings: 'FILL' 1;">done_all</span>
 <span v-else class="material-symbols-outlined text-[14px] text-on-surface-variant opacity-50">check</span>
 </template>
 </div>
 </div>
 </template>
 </div>

 <!-- Input -->
 <div class="p-4 bg-surface-container-lowest border-t border-border-subtle z-10">
 <form @submit.prevent="sendMessage" class="flex items-center gap-3 max-w-4xl mx-auto">
 <button type="button" class="p-2 text-on-surface-variant hover:text-primary transition-colors hover:bg-primary/10 rounded-full">
 <span class="material-symbols-outlined text-[24px]">attach_file</span>
 </button>
 <input id="newMessage" name="newMessage" 
 v-model="newMessage" 
 type="text" 
 placeholder="Escribe tu mensaje aquí..." 
 class="flex-1 h-12 px-6 bg-surface-container-lowest border border-border-subtle rounded-full font-body-md text-sm outline-none focus:ring-2 focus:ring-primary/40 focus:border-primary transition-all shadow-sm"
 />
 <button 
 type="submit" 
 class="w-12 h-12 rounded-full bg-primary text-white flex items-center justify-center hover:bg-primary-container hover:text-on-primary-container shadow-md transition-all disabled:opacity-50 disabled:scale-95 active:scale-95"
 :disabled="!newMessage.trim()"
 >
 <span class="material-symbols-outlined text-[20px] ml-1">send</span>
 </button>
 </form>
 </div>
 </template>
 
 <!-- Empty State -->
 <div v-else class="flex-1 flex flex-col items-center justify-center text-center p-8 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] [background-size:16px_16px]">
 <div class="w-24 h-24 rounded-full bg-surface-container-lowest border border-border-subtle shadow-sm flex items-center justify-center mb-6">
 <span class="material-symbols-outlined text-5xl text-primary/40">chat_bubble</span>
 </div>
 <h3 class="font-headline-lg text-2xl font-bold text-on-surface">Tus Mensajes</h3>
 <p class="font-body-md text-body-md text-on-surface-variant max-w-sm mt-3">Selecciona una conversación del panel lateral para leer y responder a tus mensajes directamente.</p>
 </div>
 </div>
 </div>
 </div>
</template>

<style scoped>
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}
.animate-fade-in {
  animation: fadeIn 0.4s ease-out forwards;
}

/* Custom Scrollbar for Chat */
#chat-container::-webkit-scrollbar {
  width: 6px;
}
#chat-container::-webkit-scrollbar-track {
  background: transparent;
}
#chat-container::-webkit-scrollbar-thumb {
  background-color: var(--color-outline-variant, #c0c7d1);
  border-radius: 10px;
}
</style>
