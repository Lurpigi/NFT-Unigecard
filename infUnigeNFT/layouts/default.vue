<template>
  <div
    class="min-h-screen bg-cover bg-center bg-no-repeat bg-fixed"
    style="background-image: url('/imgs/bg.png')"
  >
    <div class="layout-container">
      <Header />
      <main class="main-content">
        <slot />
      </main>
      <Footer />
    </div>
  </div>
</template>

<script>
// This is the default layout for your application
// It wraps the content of your pages with a header and footer
//import Header from "~/components/Header.vue";
import Header from "../components/Header.vue";
import Footer from "../components/Footer.vue";

export default {
  components: {
    Header,
    Footer,
  },
};
</script>

<style scoped>
.layout-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh; /* Ensure the layout takes the full viewport height */
}

.main-content {
  flex: 1; /* This ensures the main content takes up all the available space */
}
</style>
