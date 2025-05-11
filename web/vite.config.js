import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(),tailwindcss(),],
  server: {
    https: {
        key: './sslcerts/web-server.key',
        cert: './sslcerts/web-server.crt'
    },
    host: '0.0.0.0',
    port: 443,
  }
})
