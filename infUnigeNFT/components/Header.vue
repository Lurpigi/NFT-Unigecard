<template>
  <header class="bg-white shadow-sm sticky top-0 z-50">
    
    <div class="relative flex items-center justify-between h-16">
    <!-- Logo -->
      <NuxtLink to="/" class="text-xl font-bold tracking-tight text-gray-900 z-10">
        <div class="flex items-center">
          <img src="/favicon.ico" alt="Logo" class="h-8 w-8 mr-2" />
          InfUnigeCardsNFT
        </div>
      </NuxtLink>

      <!-- Nav Links -->
      <nav class="hidden md:flex space-x-4 text-gray-600 absolute left-1/2 transform -translate-x-1/2 z-0">
        <NuxtLink to="/" class="hover:text-black transition">Home</NuxtLink>
        <NuxtLink to="/about" class="hover:text-black transition">About</NuxtLink>
        <NuxtLink to="/mint" class="hover:text-black transition">Mint</NuxtLink>
      </nav>

      <!-- Wallet Button -->
      <WalletButton class="z-10" />
    </div>

  </header>
</template>

<script setup lang="ts">
  import WalletButton from './ui/button/WalletButton.vue';
</script>
