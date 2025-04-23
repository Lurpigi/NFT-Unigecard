<template>
  <div
    class="min-h-screen w-full text-white"
    :class="{ 'overflow-x-hidden': true }"
  >
    <div class="px-6 py-10 max-w-6xl mx-auto">
      <div
        class="mb-8 flex flex-col sm:flex-row justify-between items-center gap-4"
      >
        <NuxtLink to="/">
          <Button class="text-white hover:bg-white/10">
            ← Torna alla Home
          </Button>
        </NuxtLink>

        <div class="flex items-center gap-2">
          <label class="text-sm text-white">Mostra solo possedute</label>
          <Switch
            v-model="showOnlyOwned"
            class="data-[state=checked]:bg-yellow-400"
          />
        </div>
      </div>

      <h1 class="text-3xl font-bold text-center mb-10">La Mia Collezione</h1>

      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
        <Card
          v-for="id in filteredCardIds"
          :key="id"
          class="aspect-[3/4] relative overflow-hidden bg-white/5 border border-white/20 rounded-xl shadow-md transition-transform duration-300 hover:scale-110 hover:drop-shadow-lg cursor-pointer"
          @click="goToCard(id)"
        >
          <CardContent
            class="w-full h-full flex items-center justify-center p-2 relative"
          >
            <template v-if="hasCard(id)">
              <img
                :src="`/cards/${id}.png`"
                :alt="`Carta #${id}`"
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
                <span>Carta #{{ id }}</span>
                <span>non posseduta</span>
              </div>
            </template>
          </CardContent>
        </Card>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";

const totalCards = 80;
const userCards = ref({});
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

onMounted(() => {
  userCards.value = {
    0: 1,
    1: 2,
    3: 1,
    5: 1,
    20: 4,
    42: 1,
    78: 1,
  };
});
</script>
