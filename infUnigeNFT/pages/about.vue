<template>
  <div>
    <button @click="fetchNFTs" class="px-4 py-2 bg-blue-500 text-white rounded">
      Mostra le mie carte
    </button>
  </div>
</template>

<script setup>
import { Button } from '@/components/ui/button'

import { useNFTContract } from '~/composables/useContract.js'

const { getMyNFTs } = useNFTContract()

const fetchNFTs = async () => {
  try {
    const { ids, amounts } = await getMyNFTs()
    console.log('Carte possedute:')
    ids.forEach((id, i) => {
      console.log(`ID: ${id.toString()} - Quantità: ${amounts[i].toString()}`)
    })
  } catch (e) {
    console.error('Errore nel recupero delle carte:', e.message)
  }
}
</script>