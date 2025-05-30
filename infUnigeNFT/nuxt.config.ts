// https://nuxt.com/docs/api/configuration/nuxt-config
import tailwindcss from "@tailwindcss/vite";

export default defineNuxtConfig({
  app: {
    head: {
      link: [
        {
          rel: "icon",
          type: "image/x-icon",
          href: "/NFT-Unigecard/favicon.ico",
        },
      ],
    },
    baseURL: "",
  },
  ssr: true,
  nitro: {
    preset: "static", // output statico (Nuxt 3)
  },

  compatibilityDate: "2024-11-01",
  devtools: { enabled: true },
  css: ["~/assets/css/tailwind.css"],

  vite: {
    plugins: [tailwindcss()],
  },

  modules: ["shadcn-nuxt", "@pinia/nuxt"],
  shadcn: {
    /**
     * Prefix for all the imported component
     */
    prefix: "",
    /**
     * Directory that the component lives in.
     * @default "./components/ui"
     */
    componentDir: "./components/ui",
  },

  runtimeConfig: {
    // Solo lato server
    privateKey: "",

    // Lato client (esposte pubblicamente)
    public: {
      proxyAddress: process.env.PROXY_ADDRESS,
    },
  },
});
