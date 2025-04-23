<template>
    <div>
      <!-- Top bar -->
      <div class="mb-8">
        <NuxtLink to="/">
          <Button>
            ← Back to Home
          </Button>
        </NuxtLink>
      </div>
  
      <!-- Main Content -->
      <div>
        <Card>
            <CardContent>
                <h1>
                Open packs
                </h1>
        
                <!-- Package counter -->
                <div class="flex items-center justify-center gap-4 mb-6">
                <Button variant="outline" @click="decreasePacks">-</Button>
                <span class="text-xl font-semibold">{{ packCount }}</span>
                <Button variant="outline" @click="increasePacks">+</Button>
                </div>
        
                <!-- Open button -->
                <div class="text-center">
                <Button @click="openPacks" class="bg-yellow-400 text-black hover:bg-yellow-500 font-bold px-6 py-3">
                    Open {{ packCount }} pack{{ packCount > 1 ? 's' : '' }}
                </Button>
                </div>

                <!-- Address input -->
                <div class="mb-6">
                <Label for="address">Address (optional)</Label>
                <Input
                    id="address"
                    type="text"
                    placeholder="0x... oppure lascia vuoto per usare il tuo"
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
  import { ref } from 'vue'
  import { Button } from '@/components/ui/button'
  import { Input } from '@/components/ui/input'
  import { Label } from '@/components/ui/label'
  import { Card, CardContent } from '@/components/ui/card'

  const packCount = ref(1)
  const customAddress = ref('')
  
  const increasePacks = () => {
    packCount.value++
  }
  const decreasePacks = () => {
    if (packCount.value > 1) packCount.value--
  }
  
  const openPacks = () => {
    console.log(`Apro ${packCount.value} pacchetti per l’indirizzo:`, customAddress.value || 'wallet attuale')
    // Qui puoi aggiungere la logica reale con ethers.js
  }
  </script>
  