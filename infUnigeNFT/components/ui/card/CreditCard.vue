<template>
    <div class="flex flex-col items-center text-center p-4">
      <img :src="person.img" :alt="person.name" class="w-24 h-24 rounded-full shadow-md mb-3 object-cover" />
      <h3 class="text-lg font-semibold p-2">{{ person.name }}</h3>
      <a :href="person.link" target="_blank" rel="noopener" class="text-blue-500 hover:underline">
        {{ person.ig }}
      </a>
    </div>
  </template>
  
  <script setup>
  defineProps({
    person: {
      type: Object,
      required: true,
    },
  })
  </script>
  