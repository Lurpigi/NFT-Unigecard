<template>
  <Button @click="handleClick" variant="outline" class="rounded-xl">
    {{ buttonLabel }}
  </Button>
</template>

<script setup lang="ts">
import { Button } from "@/components/ui/button";
import { useWalletStore } from "@/stores/wallet";
import { computed, onMounted } from "vue";

const wallet = useWalletStore();

onMounted(() => {
  wallet.checkConnection();
});

// Non cambia l'indirizzo dinamicamente senza refresh della pagina
const buttonLabel = computed(() => {
  return wallet.address
    ? `${wallet.address.slice(0, 6)}...${wallet.address.slice(-4)}`
    : "Connect Wallet";
});

const handleClick = () => {
  if (wallet.address) return;

  if (typeof window.ethereum !== "undefined") {
    wallet.connect();
  } else if (/Mobi|Android/i.test(navigator.userAgent)) {
    const dappUrl = "lurpigi.github.io/NFT-Unigecard";
    window.location.href = `https://metamask.app.link/dapp/${dappUrl}`;
  } else {
    alert("Please install MetaMask");
  }
};
</script>
