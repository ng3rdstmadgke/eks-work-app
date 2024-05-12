<template>
  <div>
    <div class="mb-3">
      <div class="text-h4">{{ title }}</div>
    </div>
    <div>
      <v-sheet class="mx-auto mb-5" width="400">
        <v-form @submit.prevent="submit">
          <v-text-field
            v-model="src"
            variant="outlined"
            label="src"
          ></v-text-field>
          <v-text-field
            v-model="dst"
            variant="outlined"
            label="dst"
          ></v-text-field>
          <v-btn class="mt-2" type="submit" block>Submit</v-btn>
        </v-form>
      </v-sheet>
      <v-sheet class="mx-auto" width="400">
        <div class="py-3 d-flex justify-center">
          <div class="text-h3">{{ result }}</div>
        </div>
      </v-sheet>
    </div>
  </div>
</template>

<script setup lang="ts">
// refは明示的なインポートは不要だが、説明のために記述している
import { ref } from 'vue'

const title = ref<string>('')
const src = ref<string>('')
const dst = ref<string>('')
const result = ref<number | null>(null)


/**
 * ページタイトルを取得
 * フロントサーバー -> バックエンドサーバーへのリクエスト
 */
const { data: titleData, error: titleError } = await useAsyncData<any>(
  "title",
  () => {
    return $fetch("http://backend.eks-work-app.local:8000/api/title", {
      method: "GET",
    })
  },
)

if (titleData.value instanceof Error) {
  console.error(titleError.value)
} else {
  title.value = titleData.value.title
}

/**
 * フォームの送信処理
 * ブラウザ -> Nginxサーバーへのリクエスト
 */
async function submit() {
  console.log(src.value, dst.value)
  const { data, error } = await useAsyncData<any>(
    "edit_distance",
    () => {
      return $fetch("/api/edit_distance", {
        method: "POST",
        body: JSON.stringify({
          src: src.value,
          dst: dst.value,
        }),
      })
    },
  )
  if (!data.value || error.value) {
    console.error(error.value)
    return
  }
  result.value = data.value.distance
}

/**
 * ページタイトルを取得
 */

</script>