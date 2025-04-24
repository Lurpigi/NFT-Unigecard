<template>
  <div class="min-h-screen px-6 py-10 text-white">
    
  <template v-if="isConnected">

    <div>
      <Card class="max-w-2xl mx-auto p-10 rounded-2xl shadow-lg backdrop-blur border border-white/20">
        <CardContent>

          <h1 class="text-3xl font-bold mb-6 text-center">Open Packs</h1>

          <div class="flex justify-center mb-6">
            <img
              src="../public/imgs/Carte-Singole-IT.png"
              alt="Single Cards"
              class="w-60"
            />
          </div>
          

          <!--
          <div class="flex items-center justify-center gap-4 mb-4">
            <Button variant="outline" @click="decreasePacks">-</Button>
            <span class="text-xl font-semibold">{{ packCount }}</span>
            <Button variant="outline" @click="increasePacks">+</Button>
          </div> -->

          <div class="flex items-center justify-center gap-4 mb-6">
            <Button variant="outline" @click="decreasePacks" class="bg-yellow-200 text-xl text-black hover:bg-yellow-300 font-bold">-</Button>
            <Button @click="openPacks" class="bg-yellow-400 sm:w-48 h-14 text-xl text-black hover:bg-yellow-500 font-bold px-6 py-3">
              Open {{ packCount }} pack{{ packCount > 1 ? 's' : '' }}</Button>
            <Button variant="outline" @click="increasePacks" class="bg-yellow-200 text-xl text-black hover:bg-yellow-300 font-bold">+</Button>
          </div>

          <p class="text-center text-sm mb-4">
            Estimated total: <strong>{{ totalCost }} ETH</strong> + gas fee
          </p>

          <div class="mb-6 p-4">
            <Label for="address">Address (optional)</Label>
            <Input
              id="address"
              type="text"
              placeholder="0x... or leave blank to use your own"
              v-model="customAddress"
              class="mt-2"
            />
          </div>

          <p class="text-center text-sm mb-2">
            Each pack contains 5 random NFTs and costs <strong>0.05 ETH</strong> + gas fee<br>
            Specify your friend's address above if you want to buy him some packs!
          </p>

        </CardContent>
      </Card>
    </div>
  </template>

  <template v-else>
    <div class="flex justify-center px-6 py-16 text-center">
      <Card class="max-w-4xl p-8">
        <CardContent>
          <h1 class="text-4xl sm:text-5xl md:text-4xl font-bold tracking-tight mb-6 text-center p-4">Wallet not connected</h1>
            <p class="md:text-xl leading-relaxed">To view your collection, connect with MetaMask</p>
          </CardContent>
        </Card>
    </div>
  </template>

  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent } from '@/components/ui/card'
import { ethers } from 'ethers'
import { getTotalMyNFTs } from '~/composables/useContract.js'

const packCount = ref(1)
const customAddress = ref('')
const isConnected = ref(false)
let provider
let signer
const maxPacks = ref(60)

const totalCost = computed(() => (packCount.value * 0.05).toFixed(2))

const increasePacks = () => {
  if (packCount.value < maxPacks.value)
    packCount.value++
  else
    errorMessage.value = `You can only buy ${maxPacks} packs.`
}
const decreasePacks = () => {
  if (packCount.value > 1) packCount.value--
}

const checkConnection = async () => {
  try {
    if (!window.ethereum) {
      throw new Error('Wallet not found. Install MetaMask.')
    }
    provider = new ethers.BrowserProvider(window.ethereum)
    const accounts = await provider.send('eth_accounts', [])
    if (accounts.length > 0) {
      signer = await provider.getSigner()
      isConnected.value = true
      await getMax()
    } else {
      errorMessage.value = 'Wallet not connected.'
    }
  } catch (e) {
    errorMessage.value = `Error during connection: ${e.message}`
  }
}

const getMax = async () => {
  try {
    const count = await getTotalMyNFTs()
    //console.log('Total NFTs:', count) // 5n ??
    maxPacks.value = (300 - Number(count)) / 5 
    if (maxPacks.value < 0) {
      maxPacks.value = 0
    }
  } catch (e) {
    errorMessage.value = `Error fetching count: ${e.message}`
    console.error(e)
  }
}

const openPacks = async () => {
  try {
    if (!isConnected.value) {
      throw new Error('Wallet not connected.')
    }
    if (packCount.value > maxPacks.value) {
      throw new Error(`You can only buy ${maxPacks.value} packs.`)
    }
    const address = customAddress.value!= "" ? customAddress.value : await signer.getAddress()
    const packPrice = ethers.parseEther(totalCost.value)
    //console.log('Pack Price:', packPrice.toString())
    const tx = await mintFor(address, packCount.value, packPrice)
    console.log('Minting successful! :', tx)
    //router.push('/') // non funziona
  } catch (e) {
    errorMessage.value = `Error openPacks: ${e.message}`
    console.error(e)
  }
}

onMounted(async () => {
  await checkConnection()
});
</script>
