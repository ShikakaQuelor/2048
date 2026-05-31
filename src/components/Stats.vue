<template>
  <div class="stats-wrapper">
    <p class="title">2048</p>
    <div class="score-wrapper statbox">
      <span class="stat-text">Score</span>
      <div class="stat-data">{{ score }}</div>
      <transition name="rise">
        <div :key="score" class="score-inc">+{{ scoreInc }}</div>
      </transition>
    </div>
    <div class="highscore-wrapper statbox">
      <span class="stat-text">Highscore</span>
      <div class="stat-data"> {{ highScore }} </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  score: Number,
})

const highScore = ref(Number(localStorage.getItem('2048high')) || 0)
const scoreInc = ref(0)

watch(() => props.score, (newVal, oldVal) => {
  scoreInc.value = newVal - oldVal
  highScore.value = Math.max(newVal, highScore.value)
})

watch(highScore, (val) => {
  localStorage.setItem('2048high', val)
})
</script>

<style scoped>
.stats-wrapper {
  margin-top: 48px;
  position: relative;
  width: 470px;
  height: 120px;
  display: flex;
  left: 50%;
  transform: translate(-50%);
  user-select: none;
}

.statbox {
  width: 148px;
  height: 60px;
  background: #bbada0;
  text-align: center;
  border-radius: 4px;
  padding-top: 6px;
  margin-left: 6px;
  margin-top: 6px;
}

.stat-data {
  font-family: Verdana;
  font-size: 2.2rem;
  font-weight: bold;
}

.stat-text {
  color: white;
}

.score-inc {
  position: relative;
  display: block;
  font-size: 1.2rem;
  top: -45px;
  left: 35px;
  opacity: 0;
}

.title {
  font-family: verdana;
  font-size: 5rem;
  font-weight: bolder;
  width: 248px;
  margin-top: 6px;
  margin-right: 26px;
}

.rise-enter-active {
  animation: rise 1.5s ease-out;
}

@keyframes rise {
  0% {
    opacity: 1;
  }
  100% {
    opacity: 0;
    transform: translateY(-40px);
  }
}
</style>
