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
const buttonLabel = ref("Connect Wallet");

const updateLabel = () => {
  buttonLabel.value = wallet.address
    ? `${wallet.address.slice(0, 6)}...${wallet.address.slice(-4)}`
    : "Connect Wallet";
};

// Aggiorna automaticamente quando cambia address
watch(() => wallet.address, updateLabel);

onMounted(() => {
  wallet.checkConnection();
  updateLabel();
});

const handleClick = () => {
  if (wallet.address) {
    updateLabel();
    return;
  }

  if (typeof window.ethereum !== "undefined") {
    wallet.connect();
  } else if (/Mobi|Android/i.test(navigator.userAgent)) {
    const dappUrl = "lurpigi.github.io/NFT-Unigecard";
    window.location.href = `https://metamask.app.link/dapp/${dappUrl}`;
  } else {
    alert(
      "Please install MetaMask, if you are on IOS, open the link in Metamask"
    );
  }
};
</script>
