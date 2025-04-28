<template>
  <Toaster />
  <div class="min-h-screen px-6 py-10 text-white">
    <template v-if="isConnected">
      <div>
        <Card
          class="max-w-2xl mx-auto p-10 rounded-2xl shadow-lg backdrop-blur border border-white/20"
        >
          <CardContent>
            <h1 class="text-3xl font-bold mb-6 text-center">Open Packs</h1>

            <div class="flex justify-center mb-6">
              <img :src="packImage" alt="Pack preview" class="w-60" />
            </div>

            <div class="flex items-center justify-center gap-4 mb-6">
              <Button
                variant="outline"
                @click="decreasePacks"
                class="bg-yellow-200 text-xl text-black hover:bg-yellow-300 font-bold"
                >-</Button
              >
              <Button
                @click="openPacks"
                :disabled="packCount === 0 || isLoading"
                :class="[
                  'sm:w-48 h-14 text-xl font-bold px-6 py-3 flex items-center justify-center',
                  packCount === 0 || isLoading
                    ? 'bg-gray-400 text-white cursor-not-allowed'
                    : 'bg-yellow-400 text-black hover:bg-yellow-500',
                ]"
              >
                <template v-if="isLoading">
                  <svg
                    class="animate-spin h-6 w-6 text-black"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      class="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      stroke-width="4"
                    ></circle>
                    <path
                      class="opacity-75"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"
                    ></path>
                  </svg>
                </template>
                <template v-else>
                  Open {{ packCount }} pack{{ packCount > 1 ? "s" : "" }}
                </template>
              </Button>

              <Button
                variant="outline"
                @click="increasePacks"
                class="bg-yellow-200 text-xl text-black hover:bg-yellow-300 font-bold"
                >+</Button
              >
            </div>

            <p class="text-center text-sm mb-4">
              Estimated total: <strong>{{ totalCost }} ETH</strong> + gas fee
            </p>

            <div class="mb-6">
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
              <strong
                >Each pack contains 5 random NFTs and costs 0.05 ETH + gas
                fee</strong
              ><br /><br />
              You can open a pack for yourself or for a friend by specifying the
              destination wallet address. If you don't, the pack will be opened
              for your current wallet.

              <br /><br />
              ⚠️ <strong>Warning</strong>: you can't open more packs if you
              reach a total of 250 cards on your wallet.
            </p>
          </CardContent>
        </Card>
      </div>
    </template>

    <template v-else>
      <div class="flex justify-center px-6 py-16 text-center">
        <Card class="max-w-4xl p-8">
          <CardContent>
            <h1
              class="text-4xl sm:text-5xl md:text-4xl font-bold tracking-tight mb-6 text-center p-4"
            >
              Wallet not connected
            </h1>
            <p class="md:text-xl leading-relaxed">
              To view your collection, connect with MetaMask
            </p>
          </CardContent>
        </Card>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed } from "vue";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";
import { ethers } from "ethers";
import { getTotalMyNFTs } from "~/composables/useContract.js";
import { Toaster } from "@/components/ui/sonner";
import { showError } from "../lib/stuff.js";

const packCount = ref(1);
const customAddress = ref("");
const isConnected = ref(false);
let provider;
let signer;
const maxPacks = ref(60);
const isLoading = ref(false);
const totalCost = computed(() => (packCount.value * 0.05).toFixed(2));

const packImage = computed(() => {
  if (packCount.value === 0) {
    return "/imgs/pacc0.png"; //
  } else if (packCount.value === 1) {
    return "/imgs/pacc1.png";
  } else if (packCount.value === 2) {
    return "/imgs/pacc2.png";
  } else if (packCount.value === 3) {
    return "/imgs/pacc3.png";
  } else if (packCount.value === 4) {
    return "/imgs/pacc4.png";
  } else {
    return "/imgs/pacc5.png";
  }
});

const increasePacks = () => {
  if (packCount.value < maxPacks.value) packCount.value++;
  else showError(`You can only buy ${maxPacks} packs`, e);
};
const decreasePacks = () => {
  if (packCount.value > 1) packCount.value--;
};

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
      await getMax();
    } else {
      showError("Wallet not connected", e);
    }
  } catch (e) {
    showError("Connection Error", e);
  }
};

const getMax = async () => {
  try {
    const count = await getTotalMyNFTs();
    //console.log('Total NFTs:', count) // 5n ??
    maxPacks.value = (250 - Number(count)) / 5;
    if (maxPacks.value < 0) {
      maxPacks.value = 0;
      packCount.value = 0;
    }
  } catch (e) {
    showError("Error Fetching NFTs", e);
  }
};

const router = useRouter();

const openPacks = async () => {
  try {
    isLoading.value = true;
    if (!isConnected.value) {
      throw new Error("Wallet not connected.");
    }
    if (packCount.value > maxPacks.value) {
      throw new Error(`You can only buy ${maxPacks.value} packs.`);
    }
    const address =
      customAddress.value != ""
        ? customAddress.value
        : await signer.getAddress();
    const packPrice = ethers.parseEther(totalCost.value);
    //console.log('Pack Price:', packPrice.toString())
    const tx = await mintFor(address, packCount.value, packPrice);
    console.log("Waiting for confirmation...");
    const receipt = await tx.wait();
    console.log("Minting successful! :", tx);
    router.push({
      path: "/result",
      query: {
        address,
        txHash: tx.hash,
        packs: packCount.value,
      },
    });
  } catch (e) {
    showError("Minting Error", e);
  } finally {
    isLoading.value = false;
  }
};

onMounted(async () => {
  await checkConnection();
});
</script>
