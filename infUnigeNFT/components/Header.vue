<template>
  <header class="bg-white shadow-sm sticky top-0 z-50">

    <div class="relative flex items-center justify-between h-16 mx-4 md:mx-8 lg:mx-16">

      <NuxtLink to="/" class="text-xl font-bold tracking-tight text-gray-900 z-10">
        <div class="flex items-center">
          <img src="/favicon.ico" alt="Logo" class="h-8 w-8 mr-2" />
          InfUnigeCardsNFT
        </div>
      </NuxtLink>
      <WalletButton class="z-10" />
    </div>
  </header>
</template>

<script setup lang="ts">
  import WalletButton from './ui/button/WalletButton.vue';
</script>
