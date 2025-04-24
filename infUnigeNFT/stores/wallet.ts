import { defineStore } from 'pinia'
import { ethers } from 'ethers'

export const useWalletStore = defineStore('wallet', {
  state: () => ({
    address: null as string | null,
    provider: null as ethers.BrowserProvider | null,
  }),

  actions: {
    async connect() {
      if (!process.client || typeof window === 'undefined' || !window.ethereum) return

      try {
        await window.ethereum.request({ method: 'eth_requestAccounts' })
        this.provider = new ethers.BrowserProvider(window.ethereum)
        const signer = await this.provider.getSigner()
        this.address = await signer.getAddress()
      } catch (err) {
        console.error('Errore durante la connessione al wallet:', err)
      }
    },

    async checkConnection() {
      if (!process.client || typeof window === 'undefined' || !window.ethereum) return

      try {
        const provider = new ethers.BrowserProvider(window.ethereum)
        const accounts = await provider.send('eth_accounts', [])
        if (accounts.length > 0) {
          this.provider = provider
          this.address = accounts[0]
        }
      } catch (err) {
        console.error('Errore nel checkConnection:', err)
      }
    },

    disconnect() {
      this.address = null
      this.provider = null
    },
  },
})
