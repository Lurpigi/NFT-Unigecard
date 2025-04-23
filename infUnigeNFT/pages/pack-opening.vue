<template>
  <div class="min-h-screen px-6 py-10 text-white">
    <!-- Top bar -->
    <div class="mb-8">
      <NuxtLink to="/">
        <Button class="text-white hover:bg-white/10">← Back to Home</Button>
      </NuxtLink>
    </div>

    <!-- Immagine sopra la card -->
    <div class="flex justify-center mb-6">
      <img
        src="../public/imgs/Carte-Singole-IT.png"
        alt="Carte Singole"
        class="w-40 rounded-xl shadow-lg"
      />
    </div>

    <!-- Main Card -->
    <div>
      <Card class="max-w-2xl mx-auto p-10 rounded-2xl shadow-lg backdrop-blur border border-white/20">
        <CardContent>
          <h1 class="text-3xl font-bold mb-6 text-center">Open packs</h1>

          <!-- Package counter -->
          <div class="flex items-center justify-center gap-4 mb-4">
            <Button variant="outline" @click="decreasePacks">-</Button>
            <span class="text-xl font-semibold">{{ packCount }}</span>
            <Button variant="outline" @click="increasePacks">+</Button>
          </div>

          <!-- Prezzo unitario -->
          <p class="text-center text-sm mb-2">
            Ogni pacchetto costa <strong>0.05 ETH</strong> + gas fee
          </p>

          <!-- Open button -->
          <div class="text-center mb-6">
            <Button @click="openPacks" class="bg-yellow-400 text-black hover:bg-yellow-500 font-bold px-6 py-3">
              Open {{ packCount }} pack{{ packCount > 1 ? 's' : '' }}
            </Button>
          </div>

          <!-- Totale stimato -->
          <p class="text-center text-sm mb-4">
            Totale stimato: <strong>{{ totalCost }} ETH</strong> + gas fee
          </p>

          <!-- Address input -->
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
        </CardContent>
      </Card>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent } from '@/components/ui/card'

const packCount = ref(1)
const customAddress = ref('')

// Costo stimato (0.05 ETH per pacchetto)
const totalCost = computed(() => (packCount.value * 0.05).toFixed(2))

const increasePacks = () => {
  packCount.value++
}
const decreasePacks = () => {
  if (packCount.value > 1) packCount.value--
}

const openPacks = () => {
  console.log(`Apro ${packCount.value} pacchetti per l’indirizzo:`, customAddress.value || 'wallet attuale')
  // Logica ethers.js qui
}
</script>
