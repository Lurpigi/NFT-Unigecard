<template>
  <div
    class="min-h-screen flex justify-center items-center px-6 py-16 text-center"
  >
    <Card class="max-w-4xl p-8">
      <CardContent>
        <h1
          class="text-4xl sm:text-5xl md:text-5xl font-bold tracking-tight mb-6 text-center p-4"
        >
          InfUnigeCardsNFT
        </h1>
        <p class="md:text-xl leading-relaxed">
          <!-- Benvenuti sul sito ufficiale di <strong>InfUnigeCardsNFT</strong>!
          Il progetto rappresenta in modo unico e creativo studenti e docenti del corso di Informatica dell'università di Genova, trasformandoli in veri e propri NFT.<br /><br />
          La collezione è composta da 80 carte, suddivise tra studenti, docenti e carte speciali. Ogni studente è associato a una delle tre categorie: <strong>Difesa</strong>, <strong>Attacco</strong> o <strong>Mente</strong>.<br /><br />
          All’interno di questo sito è possibile visualizzare la propria collezione e aprire nuovi pacchetti per ampliarla.
          Ogni pacchetto contiene 5 NFT casuali dal costo di 0.05 ETH + gas fee ciascuno.<br /><br />
          Puoi aprire un pacchetto per te o per un tuo amico, specificando l'indirizzo del wallet di destinazione. Se non lo fai, il pacchetto verrà aperto per il tuo wallet attuale.<br /><br />
          Attenzione: puoi aprire un massimo di 60 pacchetti per wallet.<br /><br />
          E' possibile comprare e vendere i tuoi NFT usando le principali piattaforme, come OpenSea.<br /><br /> -->
          Welcome to the official website of
          <strong>InfUnigeCardsNFT</strong>!<br /><br />
          The project uniquely and creatively represents students and professors
          of the Computer Science course at the University of Genoa,
          transforming them into real NFTs.<br /><br />
          The collection consists of 80 cards, divided into students,
          professors, and special cards. Each student is associated with one of
          three categories: Defense, Attack, or Mind.<br /><br />
          On this site, you can view your collection and open new packs to
          expand it. Each pack contains 5 random NFTs, costing 0.05 ETH + gas
          fee each.<br /><br />
          You can open a pack for yourself or for a friend by specifying the
          destination wallet address. If you don't, the pack will be opened for
          your current wallet. You can buy and sell your NFTs using major
          platforms like OpenSea.<br /><br />
          <strong
            @click="goToScan()"
            class="hover:text-black transition-colors hover:underline hover:cursor-pointer"
            >View on EherScan</strong
          >
          <br /><br />
          ⚠️ <strong>Warning</strong>: you can't open more packs if you reach a
          total of 250 cards on your wallet.<br /><br />
        </p>

        <div class="flex flex-col sm:flex-row gap-6 justify-center mt-8">
          <NuxtLink to="/pack-opening" class="w-full sm:w-auto">
            <Button
              class="w-full sm:w-64 h-16 text-xl bg-yellow-400 hover:bg-yellow-500 text-black font-bold rounded-2xl"
            >
              Open Packs
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

<script setup>
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const config = useRuntimeConfig();
const contractAddress = config.public.proxyAddress;

function goToScan() {
  window.open(
    `https://sepolia.etherscan.io/address/${contractAddress}`,
    "_blank"
  );
}
</script>
