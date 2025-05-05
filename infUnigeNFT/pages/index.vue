<template>
  <div
    class="min-h-screen flex justify-center items-center px-6 py-16 text-center"
  >
    <CardHome class="w-full max-w-4xl mx-auto p-6 shadow-lg">
      <CardContentHome>
        <h1
          class="text-2xl sm:text-5xl md:text-5xl font-bold tracking-tight mb-6 text-center p-4"
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
          professors, and a special card. The professors and the special card
          are rarier than the student ones. Each student card is associated with
          one of three categories: Defense, Attack, or Mind.<br /><br />
          On this site, you can view your collection and open new packs to
          expand it, a total of 300 packs can be opened. You can buy and sell
          your NFTs using major platforms like OpenSea. You can reach the
          marketplace by clicking any card from your collection if the card is
          already minted.<br /><br />
          <strong
            @click="goToScan()"
            class="hover:text-black transition-colors underline hover:cursor-pointer"
            >Click here to view on Etherscan</strong
          >
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
      </CardContentHome>
    </CardHome>
  </div>
</template>

<script setup>
import { CardHome, CardContentHome } from "@/components/ui/card";
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
