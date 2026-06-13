import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { VitePWA } from 'vite-plugin-pwa'
import { ViteWebfontDownload } from 'vite-plugin-webfont-dl'
import { resolve } from 'path'

export default defineConfig({
  plugins: [
    vue(),
    ViteWebfontDownload([
      'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Hanken+Grotesk:wght@600;700;800&family=Syne:wght@600;700;800&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600;1,9..40,300&display=swap',
      'https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap'
    ]),
    VitePWA({
      registerType: 'autoUpdate',
      manifest: {
        name: 'EduPlataforma v2.0',
        short_name: 'EduPlata',
        description: 'Tu escuela, sin límites',
        theme_color: '#1a6fa8',
        background_color: '#f2f6fb',
        display: 'standalone',
        orientation: 'portrait',
        start_url: '/',
        icons: [
          { src: '/icons/icon-192.png', sizes: '192x192', type: 'image/png' },
          { src: '/icons/icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'any maskable' }
        ]
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/slmbeartbgkihoznylly\.supabase\.co\/rest\/.*/,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'supabase-data',
              networkTimeoutSeconds: 5,
              expiration: { maxAgeSeconds: 86400 }
            }
          },
          {
            urlPattern: /^https:\/\/slmbeartbgkihoznylly\.supabase\.co\/storage\/.*/,
            handler: 'CacheFirst',
            options: {
              cacheName: 'materiales-cache',
              expiration: { maxEntries: 100, maxAgeSeconds: 604800 }
            }
          },
          {
            urlPattern: /^https:\/\/fonts\.(googleapis|gstatic)\.com\/.*/,
            handler: 'CacheFirst',
            options: { cacheName: 'fonts-cache', expiration: { maxAgeSeconds: 2592000 } }
          }
        ]
      }
    })
  ],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src')
    }
  }
})
