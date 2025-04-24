import { useWalletStore } from '@/stores/wallet'

export default defineNuxtRouteMiddleware(async () => {
    const wallet = useWalletStore()
    await wallet.checkConnection()
  })
  