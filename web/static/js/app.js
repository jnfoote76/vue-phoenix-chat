import "phoenix_html"
import Vue from 'vue'
import VueResource from 'vue-resource'
import MyApp from "../components/my-app.vue"
import store from "./store.js"

// Create the main component
Vue.component('my-app', MyApp)
Vue.use(VueResource);

// And create the top-level view model:
new Vue({
  el: '#app',
  store,
  render(createElement) {
    return createElement(MyApp, {})
  }
});
