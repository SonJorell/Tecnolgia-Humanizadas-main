<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useDirectivoStore } from '@/stores/directivo'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import { PlusCircle, UserPlus, Users, GraduationCap, X, CheckCircle, AlertTriangle } from 'lucide-vue-next'

const store = useDirectivoStore()

// Tabs
const activeTab = ref<'cursos' | 'inscripciones' | 'usuarios'>('cursos')

// Form states
const formCurso = ref({
 nombre: '',
 nivel: '',
 color: '#3b82f6',
 icono: '📚',
 docente_id: ''
})

const formUsuario = ref({
 nombre: '',
 email: '',
 rol: 'alumno'
})

const formInscripcion = ref({
 curso_id: '',
 alumnos: [] as string[]
})

// UI state
const dismissMessage = () => {
 store.successMsg = ''
 store.errorMsg = ''
}

onMounted(() => {
 store.cargarDatosGestion()
})

const submitCurso = async () => {
 dismissMessage()
 await store.crearCurso(
 formCurso.value.nombre,
 formCurso.value.nivel,
 formCurso.value.docente_id,
 formCurso.value.color,
 formCurso.value.icono
 )
 if (!store.errorMsg) {
 formCurso.value = { nombre: '', nivel: '', color: '#3b82f6', icono: '📚', docente_id: '' }
 }
}

const submitUsuario = async () => {
 dismissMessage()
 await store.crearUsuarioPrueba(
 formUsuario.value.email,
 formUsuario.value.nombre,
 formUsuario.value.rol
 )
 if (!store.errorMsg) {
 formUsuario.value = { nombre: '', email: '', rol: 'alumno' }
 }
}

const submitInscripcion = async () => {
 dismissMessage()
 if (formInscripcion.value.alumnos.length === 0) {
 store.errorMsg = 'Debes seleccionar al menos un alumno'
 return
 }
 await store.inscribirAlumnos(formInscripcion.value.curso_id, formInscripcion.value.alumnos)
 if (!store.errorMsg) {
 formInscripcion.value.alumnos = []
 }
}

const toggleAlumno = (id: string) => {
 const index = formInscripcion.value.alumnos.indexOf(id)
 if (index === -1) {
 formInscripcion.value.alumnos.push(id)
 } else {
 formInscripcion.value.alumnos.splice(index, 1)
 }
}

const alumnosFiltrados = computed(() => {
 if (!formInscripcion.value.curso_id) return store.alumnosDisponibles
 const cursoSeleccionado = store.cursosExistentes.find(c => c.id === formInscripcion.value.curso_id)
 // Opcionalmente se podrían filtrar alumnos por nivel, pero aquí los mostramos todos
 return store.alumnosDisponibles
})
</script>

<template>
 <div class="p-4 md:p-6 max-w-5xl mx-auto space-y-6 animate-fade-in">
 <div>
 <h1 class="font-headline-md font-extrabold text-2xl md:text-3xl text-on-surface flex items-center gap-2">
 <GraduationCap :size="32" class="text-primary" />
 Gestión Académica
 </h1>
 <p class="text-sm text-on-surface-variant mt-1">Administra cursos, asigna profesores e inscribe alumnos fácilmente.</p>
 </div>

 <!-- Mensajes de Feedback -->
 <div v-if="store.successMsg || store.errorMsg" class="flex items-start gap-3 p-4 rounded-xl border" :class="store.errorMsg ? 'bg-error-container/50 border-error/30' : 'bg-secondary-container/50 border-secondary/30'">
 <AlertTriangle v-if="store.errorMsg" class="text-error flex-shrink-0" />
 <CheckCircle v-else class="text-secondary flex-shrink-0" />
 <div class="flex-1">
 <p class="font-medium text-sm" :class="store.errorMsg ? 'text-error' : 'text-secondary'">
 {{ store.errorMsg || store.successMsg }}
 </p>
 </div>
 <button type="button" @click="dismissMessage" class="text-on-surface-variant hover:text-on-surface transition-colors">
 <X :size="18" />
 </button>
 </div>

 <!-- Tabs -->
 <div class="flex border-b border-border-subtle">
 <button type="button" 
 class="px-4 py-3 text-sm font-semibold border-b-2 transition-colors flex items-center gap-2"
 :class="activeTab === 'cursos' ? 'border-primary text-primary' : 'border-transparent text-on-surface-variant hover:text-on-surface'"
 @click="activeTab = 'cursos'"
 >
 <PlusCircle :size="16" /> Crear Curso
 </button>
 <button type="button" 
 class="px-4 py-3 text-sm font-semibold border-b-2 transition-colors flex items-center gap-2"
 :class="activeTab === 'inscripciones' ? 'border-primary text-primary' : 'border-transparent text-on-surface-variant hover:text-on-surface'"
 @click="activeTab = 'inscripciones'"
 >
 <Users :size="16" /> Inscribir Alumnos
 </button>
 <button type="button" 
 class="px-4 py-3 text-sm font-semibold border-b-2 transition-colors flex items-center gap-2"
 :class="activeTab === 'usuarios' ? 'border-primary text-primary' : 'border-transparent text-on-surface-variant hover:text-on-surface'"
 @click="activeTab = 'usuarios'"
 >
 <UserPlus :size="16" /> Nuevo Usuario
 </button>
 </div>

 <!-- Contenido Tabs -->
 <div class="mt-6">
 
 <!-- TAB: CURSOS -->
 <BaseCard v-if="activeTab === 'cursos'" class="max-w-2xl">
 <h3 class="font-bold text-lg mb-4 text-on-surface">Crear Nueva Asignatura/Curso</h3>
 <form @submit.prevent="submitCurso" class="space-y-4">
 <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
 <div class="space-y-1">
 <label class="text-xs font-semibold text-on-surface-variant">Nombre del Curso</label>
 <input id="formCurso_nombre" name="formCurso_nombre" v-model="formCurso.nombre" required type="text" placeholder="Ej: Física Cuántica" class="w-full px-3 py-2 bg-surface-container-low border border-border-subtle rounded-lg text-sm" />
 </div>
 <div class="space-y-1">
 <label class="text-xs font-semibold text-on-surface-variant">Nivel</label>
 <input id="formCurso_nivel" name="formCurso_nivel" v-model="formCurso.nivel" required type="text" placeholder="Ej: 3ro Medio A" class="w-full px-3 py-2 bg-surface-container-low border border-border-subtle rounded-lg text-sm" />
 </div>
 <div class="space-y-1">
 <label class="text-xs font-semibold text-on-surface-variant">Profesor Asignado</label>
 <select id="formCurso_docente_id" name="formCurso_docente_id" v-model="formCurso.docente_id" required class="w-full px-3 py-2 bg-surface-container-low border border-border-subtle rounded-lg text-sm">
 <option value="" disabled>Seleccione un profesor</option>
 <option v-for="profe in store.profesoresDisponibles" :key="profe.id" :value="profe.id">
 {{ profe.nombre }}
 </option>
 </select>
 </div>
 <div class="space-y-1">
 <label class="text-xs font-semibold text-on-surface-variant">Color & Ícono</label>
 <div class="flex gap-2">
 <input id="formCurso_color" name="formCurso_color" v-model="formCurso.color" type="color" class="h-9 w-12 rounded cursor-pointer" />
 <input id="formCurso_icono" name="formCurso_icono" v-model="formCurso.icono" type="text" placeholder="📚" class="w-16 px-3 py-2 bg-surface-container-low border border-border-subtle rounded-lg text-sm text-center" />
 </div>
 </div>
 </div>
 <div class="pt-4 flex justify-end">
 <BaseButton type="submit" variant="primary" :disabled="store.loading">
 {{ store.loading ? 'Guardando...' : 'Crear Curso' }}
 </BaseButton>
 </div>
 </form>
 </BaseCard>

 <!-- TAB: INSCRIPCIONES -->
 <BaseCard v-else-if="activeTab === 'inscripciones'">
 <h3 class="font-bold text-lg mb-4 text-on-surface">Inscripción Masiva de Alumnos</h3>
 <form @submit.prevent="submitInscripcion" class="space-y-6">
 <div class="max-w-md space-y-1">
 <label class="text-xs font-semibold text-on-surface-variant">Seleccionar Curso</label>
 <select id="formInscripcion_curso_id" name="formInscripcion_curso_id" v-model="formInscripcion.curso_id" required class="w-full px-3 py-2 bg-surface-container-low border border-border-subtle rounded-lg text-sm">
 <option value="" disabled>Elige el curso destino</option>
 <option v-for="curso in store.cursosExistentes" :key="curso.id" :value="curso.id">
 {{ curso.nombre }} ({{ curso.nivel }})
 </option>
 </select>
 </div>

 <div v-if="formInscripcion.curso_id" class="space-y-2">
 <div class="flex justify-between items-center">
 <label class="text-xs font-semibold text-on-surface-variant">Seleccionar Alumnos ({{ formInscripcion.alumnos.length }} seleccionados)</label>
 <button type="button" @click="formInscripcion.alumnos = alumnosFiltrados.map(a => a.id)" class="text-xs text-primary hover:underline">
 Seleccionar todos
 </button>
 </div>
 <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3 max-h-96 overflow-y-auto p-1">
 <div 
 v-for="alumno in alumnosFiltrados" :key="alumno.id"
 class="flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-colors"
 :class="formInscripcion.alumnos.includes(alumno.id) ? 'bg-primary/10 border-primary/50' : 'bg-surface-container-low border-border-subtle hover:border-primary/30'"
 @click="toggleAlumno(alumno.id)"
 >
 <div class="w-5 h-5 rounded border border-primary flex items-center justify-center flex-shrink-0" :class="formInscripcion.alumnos.includes(alumno.id) ? 'bg-primary' : 'bg-transparent'">
 <CheckCircle v-if="formInscripcion.alumnos.includes(alumno.id)" :size="14" class="text-white" />
 </div>
 <div class="flex-1 truncate">
 <p class="font-medium text-sm text-on-surface truncate">{{ alumno.nombre }}</p>
 <p class="text-xs text-on-surface-variant truncate">{{ alumno.email }}</p>
 </div>
 </div>
 </div>
 </div>

 <div class="pt-4 flex justify-end">
 <BaseButton type="submit" variant="primary" :disabled="store.loading || !formInscripcion.curso_id">
 {{ store.loading ? 'Inscribiendo...' : 'Inscribir Seleccionados' }}
 </BaseButton>
 </div>
 </form>
 </BaseCard>

 <!-- TAB: USUARIOS -->
 <BaseCard v-else-if="activeTab === 'usuarios'" class="max-w-xl border-l-4 border-l-violet">
 <h3 class="font-bold text-lg mb-2 text-on-surface flex items-center gap-2">
 <UserPlus :size="20" class="text-violet" /> Dar de alta nuevo usuario
 </h3>
 <p class="text-sm text-on-surface-variant mb-6">Todos los usuarios creados aquí tendrán la contraseña <strong class="text-on-surface">prueba123</strong> por defecto.</p>
 
 <form @submit.prevent="submitUsuario" class="space-y-4">
 <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
 <div class="space-y-1">
 <label class="text-xs font-semibold text-on-surface-variant">Nombre Completo</label>
 <input id="formUsuario_nombre" name="formUsuario_nombre" v-model="formUsuario.nombre" required type="text" placeholder="Ej: Juan Pérez" class="w-full px-3 py-2 bg-surface-container-low border border-border-subtle rounded-lg text-sm" />
 </div>
 <div class="space-y-1">
 <label class="text-xs font-semibold text-on-surface-variant">Correo Electrónico</label>
 <input id="formUsuario_email" name="formUsuario_email" v-model="formUsuario.email" required type="email" placeholder="ejemplo@escuela.cl" class="w-full px-3 py-2 bg-surface-container-low border border-border-subtle rounded-lg text-sm" />
 </div>
 </div>
 <div class="space-y-1">
 <label class="text-xs font-semibold text-on-surface-variant">Rol en la plataforma</label>
 <div class="flex gap-4 mt-1">
 <label class="flex items-center gap-2 cursor-pointer">
 <input id="formUsuario_rol" name="formUsuario_rol" type="radio" v-model="formUsuario.rol" value="alumno" class="text-primary" />
 <span class="text-sm font-medium">Alumno</span>
 </label>
 <label class="flex items-center gap-2 cursor-pointer">
 <input id="formUsuario_rol" name="formUsuario_rol" type="radio" v-model="formUsuario.rol" value="docente" class="text-primary" />
 <span class="text-sm font-medium">Docente</span>
 </label>
 <label class="flex items-center gap-2 cursor-pointer">
 <input id="formUsuario_rol" name="formUsuario_rol" type="radio" v-model="formUsuario.rol" value="directivo" class="text-primary" />
 <span class="text-sm font-medium">Directivo</span>
 </label>
 </div>
 </div>
 
 <div class="pt-4 flex justify-end">
 <BaseButton type="submit" variant="primary" :disabled="store.loading">
 {{ store.loading ? 'Creando...' : 'Crear Usuario' }}
 </BaseButton>
 </div>
 </form>
 </BaseCard>

 </div>
 </div>
</template>
