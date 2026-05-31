/// <reference types="vite/client" />

declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<{}, {}, any>
  export default component
}

interface ImportMetaEnv {
  readonly VITE_SUPABASE_URL: string
  readonly VITE_SUPABASE_ANON_KEY: string
  readonly VITE_LAN_SERVER_URL: string
  readonly VITE_APP_NAME: string
  readonly VITE_APP_SHORT_NAME: string
  readonly VITE_SYNC_INTERVAL_MS: string
  readonly VITE_SYNC_MAX_RETRIES: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
