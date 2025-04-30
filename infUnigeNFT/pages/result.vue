<template>
  <Toaster />
  <template v-if="isConnected">
    <div
      class="min-h-screen flex justify-center items-center px-6 py-16 text-center"
    >
      <Card class="max-w-4xl p-8">
        <CardContent>
          <h1
            class="text-4xl sm:text-5xl md:text-5xl font-bold tracking-tight mb-6 text-center"
          >
            Congratulations!
          </h1>
          <p class="md:text-xl leading-relaxed">You found:</p>

          <div
            v-if="mintedNFTs.length"
            class="grid grid-cols-3 sm:grid-cols-3 md:grid-cols-3 gap-6 mt-6"
          >
            <Card
              v-for="nft in mintedNFTs"
              :key="nft.id"
              class="aspect-[3/4] relative overflow-hidden bg-white/5 border border-white/20 rounded-xl shadow-md transition-transform duration-300 hover:scale-105 hover:drop-shadow-lg"
            >
              <CardContent
                class="w-full h-full flex items-center justify-center relative"
              >
                <img
                  :src="`${useRuntimeConfig().app.baseURL}/cards/${nft.id}.png`"
                  :alt="`Card #${nft.id}`"
                  class="object-contain w-full h-full"
                />
                <div
                  class="absolute top-2 right-2 bg-black/70 text-white px-1 py-0.8 md:px-3 md:py-2 rounded"
                >
                  ×{{ nft.amount }}
                </div>
              </CardContent>
            </Card>
          </div>

          <p v-else class="mt-6">Loading or no NFTs found.</p>

          <div class="flex flex-col sm:flex-row gap-6 justify-center mt-8">
            <NuxtLink to="/pack-opening" class="w-full sm:w-auto">
              <Button
                class="w-full sm:w-64 h-16 text-xl bg-yellow-400 hover:bg-yellow-500 text-black font-bold rounded-2xl"
              >
                Open other packs
              </Button>
            </NuxtLink>

            <NuxtLink to="/my-collection" class="w-full sm:w-auto">
              <Button
                class="w-full sm:w-64 h-16 text-xl hover:text-white font-bold rounded-2xl"
              >
                My Collection
              </Button>
            </NuxtLink>
          </div>
        </CardContent>
      </Card>
    </div>
  </template>
</template>

<script setup>
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ethers } from "ethers";
import { ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import contractABI from "../public/ABI.json";
import { Toaster } from "@/components/ui/sonner";
import { showError } from "../lib/stuff.js";

const route = useRoute();
const mintedNFTs = ref([]);
const isConnected = ref(false);
let provider;
let signer;

const checkConnection = async () => {
  try {
    if (!window.ethereum) {
      showError("Wallet not found. Install MetaMask.", e);
    }
    provider = new ethers.BrowserProvider(window.ethereum);
    const accounts = await provider.send("eth_accounts", []);
    if (accounts.length > 0) {
      signer = await provider.getSigner();
      isConnected.value = true;
    } else {
      showError("Wallet not connected", e);
    }
  } catch (e) {
    showError("Connection Error", e);
  }
};

onMounted(async () => {
  await checkConnection();
  const { txHash } = route.query;
  const provider = new ethers.BrowserProvider(window.ethereum);
  const receipt = await provider.getTransactionReceipt(txHash);
  const contractInterface = new ethers.Interface(contractABI);

  for (const log of receipt.logs) {
    try {
      const parsed = contractInterface.parseLog(log);
      if (parsed.name === "Minted") {
        mintedNFTs.value = parsed.args.ids.map((id, i) => ({
          id: Number(id),
          amount: Number(parsed.args.amounts[i]),
        }));
        break;
      }
    } catch (e) {
      continue;
    }
  }
});
</script>
