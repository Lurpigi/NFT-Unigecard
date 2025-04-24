<template>
  <div
    class="min-h-screen w-full text-white"
    :class="{ 'overflow-x-hidden': true }"
  >
    <div class="px-6 py-10 max-w-6xl mx-auto">
        <!--<NuxtLink to="/">
          <Button class="text-white hover:bg-white/10">
            ← Back to Home
          </Button>
        </NuxtLink> -->

        <template v-if="isConnected">
            <div class="flex items-center gap-2 justify-center md:justify-end p-4 sm:justify-center">
            <label class="text-sm text-white">Show only owned</label>
            <Switch
              v-model="showOnlyOwned"
              class="data-[state=checked]:bg-yellow-400"
            />
          </div>
        </template>
      

      <h1 class="text-4xl font-bold text-center mb-10">My Collection</h1>
        <template v-if="isConnected">
          <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
            <Card
              v-for="id in filteredCardIds"
              :key="id"
              class="aspect-[3/4] relative overflow-hidden bg-white/5 border border-white/20 rounded-xl shadow-md transition-transform duration-300 hover:scale-110 hover:drop-shadow-lg cursor-pointer"
              @click="goToCard(id)"
            >
              <CardContent class="w-full h-full flex items-center justify-center p-2 relative">
                <template v-if="hasCard(id)">
                  <img
                    :src="`/cards/${id}.png`"
                    :alt="`Card #${id}`"
                    class="object-contain w-full h-full"
                  />
                  <div
                    class="absolute bottom-2 right-2 bg-black/70 text-white text-xs px-2 py-1 rounded"
                  >
                    ×{{ userCards[id] }}
                  </div>
                </template>
                <template v-else>
                  <div
                    class="flex flex-col items-center justify-center text-white/40 text-sm text-center px-4"
                  >
                    <span>Card #{{ id }}</span>
                    <span>not owned</span>
                  </div>
                </template>
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
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { Card, CardContent } from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { ethers } from 'ethers'
import { useNFTContract } from '~/composables/useContract.js'

const { getMyNFTs } = useNFTContract()
//const nfts = ref([])
const errorMessage = ref('')
const isConnected = ref(false)

const totalCards = 80;
const userCards = ref([]);
const showOnlyOwned = ref(false);

const config = useRuntimeConfig();
const contractAddress = config.public.proxyAddress;

function hasCard(id) {
  return userCards.value[id] && userCards.value[id] > 0;
}

const filteredCardIds = computed(() => {
  return Array.from({ length: totalCards }, (_, i) => i).filter((id) =>
    showOnlyOwned.value ? hasCard(id) : true
  );
});

function goToCard(id) {
  window.location.href = `https://testnets.opensea.io/assets/sepolia/${contractAddress}/${id}`;
}

let provider
let signer

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
      await fetchNFTs()
    } else {
      errorMessage.value = 'Wallet not connected.'
    }
  } catch (e) {
    errorMessage.value = `Error during connection: ${e.message}`
  }
}

const fetchNFTs = async () => {
  try {
    const { ids, amounts } = await getMyNFTs()
    const cards = {}
    ids.forEach((id, i) => {
      cards[id.toString()] = parseInt(amounts[i].toString())
    })
    userCards.value = cards
  } catch (e) {
    errorMessage.value = `Error fetching cards: ${e.message}`
    console.error(e)
  }
}


onMounted(async () => {
  await checkConnection()
});
</script>
