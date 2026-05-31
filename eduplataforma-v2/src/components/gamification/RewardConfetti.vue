<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const props = defineProps<{
  active: boolean
}>()

const emit = defineEmits(['complete'])
const canvasRef = ref<HTMLCanvasElement | null>(null)

let particles: any[] = []
let animationFrameId: number

const colors = ['#1a6fa8', '#2db88a', '#e8a020', '#6c5ce7', '#e05050', '#ffffff']

function initConfetti() {
  if (!canvasRef.value) return
  const canvas = canvasRef.value
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight

  particles = []
  for (let j = 0; j < 150; j++) {
    particles.push({
      x: canvas.width / 2,
      y: canvas.height / 2 + 100, // Starts a bit lower from center
      r: Math.random() * 6 + 2,
      dx: Math.random() * 10 - 5,
      dy: Math.random() * -10 - 5,
      color: colors[Math.floor(Math.random() * colors.length)],
      tilt: Math.floor(Math.random() * 10) - 10,
      tiltAngleInc: (Math.random() * 0.07) + 0.05,
      tiltAngle: 0
    })
  }

  animate()
  setTimeout(() => {
    emit('complete')
  }, 3000)
}

function animate() {
  if (!canvasRef.value) return
  const ctx = canvasRef.value.getContext('2d')
  if (!ctx) return

  ctx.clearRect(0, 0, canvasRef.value.width, canvasRef.value.height)

  particles.forEach((p, i) => {
    p.tiltAngle += p.tiltAngleInc
    p.y += (Math.cos(p.tiltAngle) + 1 + p.r / 2) / 2
    p.x += Math.sin(p.tiltAngle) * 2

    ctx.beginPath()
    ctx.lineWidth = p.r
    ctx.strokeStyle = p.color
    ctx.moveTo(p.x + p.tilt + p.r, p.y)
    ctx.lineTo(p.x + p.tilt, p.y + p.tilt + p.r)
    ctx.stroke()
  })

  animationFrameId = requestAnimationFrame(animate)
}

onMounted(() => {
  if (props.active) initConfetti()
})

onUnmounted(() => {
  if (animationFrameId) cancelAnimationFrame(animationFrameId)
})
</script>

<template>
  <div v-if="active" class="fixed inset-0 z-[100] pointer-events-none">
    <canvas ref="canvasRef" class="w-full h-full" />
    <div class="absolute inset-0 flex items-center justify-center animate-fade-in-up">
      <div class="bg-card dark:bg-dark-card shadow-modal px-8 py-6 rounded-2xl text-center scale-up-center">
        <p class="text-6xl mb-3">🌟</p>
        <h2 class="font-display font-extrabold text-2xl text-text dark:text-dark-text">¡Buen trabajo!</h2>
        <p class="text-mint font-bold mt-2 text-lg">+50 XP</p>
        <p class="text-amber font-bold">+20 🪙</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.animate-fade-in-up {
  animation: fadeInUp 0.5s ease-out forwards;
}
.scale-up-center {
  animation: scaleUp 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
}
@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes scaleUp {
  0% { transform: scale(0.5); opacity: 0; }
  100% { transform: scale(1); opacity: 1; }
}
</style>
