<template>
  <div class="min-h-screen px-6 py-16 flex flex-col items-center gap-10">
    <CardHome class="w-full max-w-4xl p-6 shadow-lg">
      <CardContentHome>
        <h1
          class="text-4xl sm:text-5xl md:text-6xl font-bold tracking-tight mb-6 text-center p-4"
        >
          Project Credits
        </h1>
        <p class="text-center text-muted-foreground text-base mb-8">
          A heartfelt thank you to everyone who brought
          <strong>InfUnigeCardsNFT</strong> to life
        </p>

        <section>
          <h2
            class="text-3xl sm:text-4xl md:text-4xl font-semibold mb-3 text-center md:p-2"
          >
            🎨 Illustrators
          </h2>
          <div class="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            <CreditCard
              v-for="person in illustrators"
              :key="person.name"
              :person="person"
            />
          </div>
        </section>

        <section class="mt-10">
          <h2
            class="text-3xl sm:text-4xl md:text-4xl font-semibold mb-3 text-center md:p-2"
          >
            ✍️ Writers
          </h2>
          <div class="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            <CreditCard
              v-for="person in writers"
              :key="person.name"
              :person="person"
            />
          </div>
        </section>

        <section class="mt-10">
          <h2
            class="text-3xl sm:text-4xl md:text-4xl font-semibold mb-3 text-center md:p-2"
          >
            💻 Devs
          </h2>
          <div class="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            <CreditCard
              v-for="person in devs"
              :key="person.name"
              :person="person"
            />
          </div>
        </section>

        <section class="mt-10">
          <h2
            class="text-3xl sm:text-4xl md:text-4xl font-semibold mb-3 text-center md:p-2"
          >
            ❤️ Special Thanks
          </h2>
          <ul class="list-none text-muted-foreground text-sm text-center p-4">
            <li>Arianna Pietrasanta</li>
            <li>Serena Bambara</li>
            <li>Ricardo Marin</li>
            <li>Corso di Informatica</li>
          </ul>
        </section>
      </CardContentHome>
    </CardHome>
  </div>
</template>

<script setup>
import { CardHome, CardContentHome } from "@/components/ui/card";
import CreditCard from "@/components/ui/card/CreditCard.vue";

const illustrators = [
  {
    name: "Alexandra Gavrilesu",
    img: `${useRuntimeConfig().app.baseURL}/imgs/dision.jpg`,
    ig: "@dision.drw",
    link: "https://www.instagram.com/dision.drw/",
  },
  {
    name: "Giovanni Cristilli",
    img: `${useRuntimeConfig().app.baseURL}/imgs/giova.jpg`,
    ig: "@giovanni_cristilli",
    link: "https://www.instagram.com/giovanni_cristilli/",
  },
  {
    name: "Luigi Timossi",
    img: `${useRuntimeConfig().app.baseURL}/imgs/lurpigi.jpg`,
    ig: "@lurpigi",
    link: "https://www.instagram.com/lurpigi/",
  },
  {
    name: "Milo Galli",
    img: `${useRuntimeConfig().app.baseURL}/imgs/milo.jpg`,
    ig: "@itsmemjlo",
    link: "https://www.instagram.com/itsmemjlo/",
  },
  {
    name: "Simone Bambara",
    img: `${useRuntimeConfig().app.baseURL}/imgs/simo.jpg`,
    ig: "@simonuccino",
    link: "https://www.instagram.com/simonuccino/",
  },
];

const writers = [
  {
    name: "Alice Sartori",
    img: `${useRuntimeConfig().app.baseURL}/imgs/alice.jpg`,
    ig: "@metaorizzonte",
    link: "https://www.instagram.com/metaorizzonte/",
  },
  {
    name: "Celeste Bazzi",
    img: `${useRuntimeConfig().app.baseURL}/imgs/cele.jpg`,
    ig: "@celeste_711",
    link: "https://www.instagram.com/celeste_711/",
  },
  {
    name: "Giovanni Cristilli",
    img: `${useRuntimeConfig().app.baseURL}/imgs/giova.jpg`,
    ig: "@giovanni_cristilli",
    link: "https://www.instagram.com/giovanni_cristilli/",
  },
  {
    name: "Mirco Vella",
    img: `${useRuntimeConfig().app.baseURL}/imgs/mirco.jpg`,
    ig: "@trustnomirco",
    link: "https://www.instagram.com/trustnomirco/",
  },
];

const devs = [
  {
    name: "Luigi Timossi",
    img: `${useRuntimeConfig().app.baseURL}/imgs/lurpigi.jpg`,
    ig: "@lurpigi",
    link: "https://www.instagram.com/lurpigi/",
  },
  {
    name: "Michele Frattini",
    img: `${useRuntimeConfig().app.baseURL}/imgs/frassers.jpg`,
    ig: "@fratt0o",
    link: "https://www.instagram.com/fratt0o/",
  },
];
</script>
