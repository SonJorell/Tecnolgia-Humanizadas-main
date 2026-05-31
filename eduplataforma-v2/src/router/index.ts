import { createRouter, createWebHistory } from 'vue-router'
import { setupGuards } from './guards'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('@/features/auth/Login.vue'),
      meta: { public: true }
    },

    // ═══ Alumno ═══
    {
      path: '/alumno',
      component: () => import('@/components/layout/AppLayout.vue'),
      meta: { roles: ['alumno'] },
      children: [
        { path: '', name: 'alumno-inicio', component: () => import('@/features/alumno/Inicio.vue') },
        { path: 'cursos', name: 'alumno-cursos', component: () => import('@/features/alumno/Cursos.vue') },
        { path: 'perfil', name: 'alumno-perfil', component: () => import('@/features/shared/PerfilUniversal.vue') },
        { path: 'cursos/:id', name: 'alumno-curso-detalle', component: () => import('@/features/alumno/CursoDetalle.vue') },
        { path: 'tareas', name: 'alumno-tareas', component: () => import('@/features/alumno/Tareas.vue') },
        { path: 'tareas/:id', name: 'alumno-tarea-detalle', component: () => import('@/features/alumno/EntregaTarea.vue') },
        { path: 'logros', name: 'alumno-logros', component: () => import('@/features/alumno/Logros.vue') },
        { path: 'buscador', name: 'alumno-buscador', component: () => import('@/features/alumno/Buscador.vue') },
        { path: 'feedback', name: 'alumno-feedback', component: () => import('@/features/alumno/Feedback.vue') },
        { path: 'tienda', name: 'alumno-tienda', component: () => import('@/features/alumno/Tienda.vue') },
        { path: 'mensajeria', name: 'alumno-mensajeria', component: () => import('@/features/alumno/Mensajeria.vue') },
      ]
    },

    // ═══ Docente ═══
    {
      path: '/docente',
      component: () => import('@/components/layout/AppLayout.vue'),
      meta: { roles: ['docente'] },
      children: [
        { path: '', name: 'docente-panel', component: () => import('@/features/docente/Panel.vue') },
        { path: 'cursos', name: 'docente-cursos', component: () => import('@/features/docente/GestionCursos.vue') },
        { path: 'cursos/:id', name: 'docente-curso-detalle', component: () => import('@/features/docente/CursoDetalle.vue') },
        { path: 'alumnos', name: 'docente-alumnos', component: () => import('@/features/docente/Alumnos.vue') },
        { path: 'alumnos/:id', name: 'docente-alumno-detalle', component: () => import('@/features/docente/AlumnoDetalle.vue') },
        { path: 'materiales', name: 'docente-materiales', component: () => import('@/features/docente/Materiales.vue') },
        { path: 'entregas', name: 'docente-entregas', component: () => import('@/features/docente/Entregas.vue') },
        { path: 'mensajeria', name: 'docente-mensajeria', component: () => import('@/features/docente/Mensajeria.vue') },
        { path: 'logros', name: 'docente-logros-personalizados', component: () => import('@/features/docente/LogrosPersonalizados.vue') },
        { path: 'dashboard', name: 'docente-dashboard', component: () => import('@/features/docente/Dashboard.vue') },
        { path: 'reportes', name: 'docente-reportes', component: () => import('@/features/docente/Reportes.vue') },
        { path: 'perfil', name: 'docente-perfil', component: () => import('@/features/shared/PerfilUniversal.vue') },
      ]
    },

    // ═══ Directivo ═══
    {
      path: '/directivo',
      component: () => import('@/components/layout/AppLayout.vue'),
      meta: { roles: ['directivo'] },
      children: [
        { path: '', name: 'directivo-resumen', component: () => import('@/features/directivo/Resumen.vue') },
        { path: 'rendimiento', name: 'directivo-rendimiento', component: () => import('@/features/directivo/Rendimiento.vue') },
        { path: 'infraestructura', name: 'directivo-infra', component: () => import('@/features/directivo/Infraestructura.vue') },
        { path: 'alertas', name: 'directivo-alertas', component: () => import('@/features/directivo/Alertas.vue') },
        { path: 'gestion', name: 'directivo-gestion', component: () => import('@/features/directivo/GestionAcademica.vue') },
        { path: 'comunicados', name: 'directivo-comunicados', component: () => import('@/features/directivo/Comunicados.vue') },
        { path: 'perfil', name: 'directivo-perfil', component: () => import('@/features/shared/PerfilUniversal.vue') },
      ]
    },

    // ═══ TI ═══
    {
      path: '/ti',
      component: () => import('@/components/layout/AppLayout.vue'),
      meta: { roles: ['ti'] },
      children: [
        { path: '', name: 'ti-panel', component: () => import('@/features/ti/PanelTI.vue') },
        { path: 'usuarios', name: 'ti-usuarios', component: () => import('@/features/ti/GestionUsuarios.vue') },
        { path: 'perfil', name: 'ti-perfil', component: () => import('@/features/shared/PerfilUniversal.vue') },
      ]
    },

    // ═══ Redirects ═══
    { path: '/', redirect: '/login' },
    { path: '/:pathMatch(.*)*', redirect: '/' }
  ]
})

setupGuards(router)

export default router
