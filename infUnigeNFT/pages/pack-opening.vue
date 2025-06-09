<template>
  <Toaster />
  <div class="min-h-screen px-6 py-10 text-white">
    <template v-if="isConnected">
      <div>
        <CardHome
          class="max-w-2xl mx-auto p-10 rounded-2xl shadow-lg backdrop-blur border border-white/20"
        >
          <CardContentHome>
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
                :disabled="packCount === 0 || isLoading || !isValidAddress"
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
                :class="[
                  'mt-2',
                  !isValidAddress && customAddress ? 'border-red-500' : '',
                ]"
                @keyup="updateP"
              />
              <p
                v-if="!isValidAddress && customAddress"
                class="text-red-500 text-sm mb-4 mt-1"
              >
                Invalid Ethereum address
              </p>
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
              reach a total of 250 cards on your wallet or if the maximum limit
              of packs that can be opened is reached. <br />
            </p>
            <p class="text-center text-sm mb-2">
              <template v-if="isValidAddress && customAddress"
                >The address you have specified</template
              ><template v-else>You</template>
              can still open
              {{ packYouCanopen }} packs. There are still {{ totalPacks }} packs
              available in the Blockchain. <br /><br />
            </p>
          </CardContentHome>
        </CardHome>
      </div>
    </template>

    <template v-else>
      <div class="flex justify-center px-6 py-16 text-center">
        <CardHome class="max-w-4xl p-8">
          <CardContentHome>
            <h1
              class="text-4xl sm:text-5xl md:text-4xl font-bold tracking-tight mb-6 text-center p-4"
            >
              Wallet not connected
            </h1>
            <p class="md:text-xl leading-relaxed">
              To view your collection, connect with MetaMask
            </p>
          </CardContentHome>
        </CardHome>
      </div>
    </template>
  </div>
</template>

<script setup>
useHead({
  link: [
    {
      rel: "preload",
      as: "image",
      href: `${useRuntimeConfig().app.baseURL}/imgs/pacc0.png`,
    },
    {
      rel: "preload",
      as: "image",
      href: `${useRuntimeConfig().app.baseURL}/imgs/pacc1.png`,
    },
    {
      rel: "preload",
      as: "image",
      href: `${useRuntimeConfig().app.baseURL}/imgs/pacc2.png`,
    },
    {
      rel: "preload",
      as: "image",
      href: `${useRuntimeConfig().app.baseURL}/imgs/pacc3.png`,
    },
    {
      rel: "preload",
      as: "image",
      href: `${useRuntimeConfig().app.baseURL}/imgs/pacc4.png`,
    },
    {
      rel: "preload",
      as: "image",
      href: `${useRuntimeConfig().app.baseURL}/imgs/pacc5.png`,
    },
  ],
});

import { ref, computed } from "vue";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { CardHome, CardContentHome } from "@/components/ui/card";
import { ethers } from "ethers";
import {
  getTotalMyNFTs,
  getTotalNFTsOf,
  getPointer,
} from "~/composables/useContract.js";
import { Toaster } from "@/components/ui/sonner";
import { showError } from "../lib/stuff.js";

const packCount = ref(1);
const customAddress = ref("");
const isConnected = ref(false);
let provider;
let signer;
const maxPacks = ref(60);
const totalPacks = ref(0);
const packYouCanopen = ref(0);
const isLoading = ref(false);
const totalCost = computed(() => (packCount.value * 0.05).toFixed(2));

const isValidAddress = computed(() => {
  return customAddress.value === "" || ethers.isAddress(customAddress.value);
});

const packImage = computed(() => {
  if (packCount.value === 0) {
    return `${useRuntimeConfig().app.baseURL}/imgs/pacc0.png`; //
  } else if (packCount.value === 1) {
    return `${useRuntimeConfig().app.baseURL}/imgs/pacc1.png`;
  } else if (packCount.value === 2) {
    return `${useRuntimeConfig().app.baseURL}/imgs/pacc2.png`;
  } else if (packCount.value === 3) {
    return `${useRuntimeConfig().app.baseURL}/imgs/pacc3.png`;
  } else if (packCount.value === 4) {
    return `${useRuntimeConfig().app.baseURL}/imgs/pacc4.png`;
  } else {
    return `${useRuntimeConfig().app.baseURL}/imgs/pacc5.png`;
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
      await getMax(0);
    } else {
      showError("Wallet not connected", e);
    }
  } catch (e) {
    showError("Connection Error", e);
  }
};

const updateP = () => {
  if (customAddress.value && ethers.isAddress(customAddress.value)) {
    getMax(1);
  } else if (customAddress.value === "") {
    getMax(0);
  }
};

const getMax = async (who) => {
  try {
    const count =
      who == 0
        ? await getTotalMyNFTs()
        : await getTotalNFTsOf(customAddress.value); // da 0 a x

    const pointer = await getPointer(); // da 0 a 1500
    console.log("Pointer:", pointer);
    console.log("Count:", count);

    totalPacks.value = (1500 - Number(pointer)) / 5; // 1500 - x
    packYouCanopen.value = Math.floor((250 - Number(count)) / 5);
    maxPacks.value = Math.min(totalPacks.value, packYouCanopen.value);
    if (maxPacks.value < 0) {
      maxPacks.value = 0;
      packCount.value = 0;
    } else {
      packCount.value = 1;
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

    if (!ethers.isAddress(address)) {
      //showError("Invalid address format.");
      throw new Error("Invalid address format.");
    }
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
