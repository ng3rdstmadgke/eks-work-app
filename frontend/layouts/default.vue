<!-- front/layouts/default.vue -->
<template>
  <v-app id="inspire">
    <!-- ヘッダー >>> -->
    <v-app-bar color="primary" :elevation="2">
      <v-app-bar-nav-icon @click.stop="drawer = !drawer"></v-app-bar-nav-icon>
      <v-app-bar-title>
        <div @click="useRouter().push('/')" style="cursor: pointer;">EKS Work App</div>
      </v-app-bar-title>
      <v-btn :icon="mdiLogout"></v-btn>
    </v-app-bar>
    <!-- <<< ヘッダー -->

    <!-- サイドメニュー >>> -->
    <v-navigation-drawer v-model="drawer">
      <!-- プロフィール -->
      <v-sheet color="grey-lighten-4" class="pa-4 d-flex" >
        <v-avatar class="mr-4" color="primary" size="64" >Gu</v-avatar>
        <div class="d-flex align-center">Guest</div>
      </v-sheet>
      <!-- プロフィール -->
      <v-divider></v-divider>
      <!-- メニューリスト >>> -->
      <v-list>
        <template v-for="item in menu" :key="item.name" >
          <v-list-item link :to="item.path">
            <template v-slot:prepend>
              <v-icon>{{ item.icon }}</v-icon>
            </template>
            <v-list-item-title>{{ item.name }}</v-list-item-title>
          </v-list-item>
        </template>
      </v-list>
      <!-- メニューリスト >>> -->
    </v-navigation-drawer>
    <!-- <<< サイドメニュー -->

    <!-- コンテンツ >>> -->
    <v-main>
      <v-container class="py-8 px-6" fluid >
        <slot />
      </v-container>
    </v-main>
    <!-- <<< コンテンツ -->

    <!-- フッター >>> -->
    <v-footer class="footer justify-center">
      <div>&copy; 2024 eks-work-app</div>
    </v-footer>
    <!-- <<< フッター -->
  </v-app>
</template>

<script setup lang="ts">
import { mdiAccount, mdiNote, mdiLogin, mdiInformation } from '@mdi/js'

interface MenuItem {
  icon: string
  name: string
  path: string
}

const drawer = ref<boolean>(false)
const menu = ref<Array<MenuItem>>([
  {
    icon: mdiNote,
    name: "Item",
    path: "/",
  },
  {
    icon: mdiAccount,
    name: "User",
    path: "/",
  },
])
</script>

<style lang="scss">
.footer {
  width: 100%;
  position: absolute;
  bottom: 0;
}
</style>