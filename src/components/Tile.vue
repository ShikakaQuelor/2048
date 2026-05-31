<template>
  <div :class="['cell', tileMove]">
    <div :class="['inner', tileBackgroundClass, tileMerged, tileNew]">{{ cell.value }}</div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  cell: Object,
})

const tileBackgroundClass = computed(() => `background-${props.cell?.value}`)
const tileMerged = computed(() => props.cell?.merged ? 'merged' : '')
const tileNew = computed(() => props.cell?.fresh ? 'new' : '')
const tileMove = computed(() => `tile-move-${props.cell?.pos?.x}-${props.cell?.pos?.y}`)
</script>

<style>
:root {
  --bg-2: #eee4da;
  --bg-4: #ede0c8;
  --bg-8: #f2b179;
  --bg-16: #f59563;
  --bg-32: #f67c5f;
  --bg-64: #f65e3b;
  --bg-128: #edcf72;
  --bg-256: #edcc61;
  --bg-512: #edc850;
  --bg-1024: #edc53f;
  --bg-2048: #edc22e;
  --color-adv: #f9f6f2;
}

.cell {
  display: flex;
  width: 108px;
  height: 108px;
  justify-content: center;
  align-items: center;
  user-select: none;
  border-radius: 10px;
  position: absolute;
  transition: transform 0.12s ease-in-out;
}

.inner {
  height: 108px;
  width: 108px;
  line-height: 108px;
  border-radius: 10px;
  text-align: center;
  font-family: Verdana;
  font-size: 2.6rem;
  font-weight: bold;
}

.background-2   { background: var(--bg-2); }
.background-4   { background: var(--bg-4); }
.background-8   { background: var(--bg-8);   color: var(--color-adv); }
.background-16  { background: var(--bg-16);  color: var(--color-adv); }
.background-32  { background: var(--bg-32);  color: var(--color-adv); }
.background-64  { background: var(--bg-64);  color: var(--color-adv); }
.background-128 { background: var(--bg-128); color: var(--color-adv); }
.background-256 { background: var(--bg-256); color: var(--color-adv); }
.background-512 { background: var(--bg-512); color: var(--color-adv); }
.background-1024 { background: var(--bg-1024); color: var(--color-adv); font-size: 2.2rem; }
.background-2048 { background: var(--bg-2048); color: var(--color-adv); }

/* tile positions: translate(123px * x, 123px * y) for x,y in 0..5 */
.tile-move-0-0 { transform: translate(0px,    0px);   }
.tile-move-0-1 { transform: translate(0px,    123px); }
.tile-move-0-2 { transform: translate(0px,    246px); }
.tile-move-0-3 { transform: translate(0px,    369px); }
.tile-move-0-4 { transform: translate(0px,    492px); }
.tile-move-0-5 { transform: translate(0px,    615px); }
.tile-move-1-0 { transform: translate(123px,  0px);   }
.tile-move-1-1 { transform: translate(123px,  123px); }
.tile-move-1-2 { transform: translate(123px,  246px); }
.tile-move-1-3 { transform: translate(123px,  369px); }
.tile-move-1-4 { transform: translate(123px,  492px); }
.tile-move-1-5 { transform: translate(123px,  615px); }
.tile-move-2-0 { transform: translate(246px,  0px);   }
.tile-move-2-1 { transform: translate(246px,  123px); }
.tile-move-2-2 { transform: translate(246px,  246px); }
.tile-move-2-3 { transform: translate(246px,  369px); }
.tile-move-2-4 { transform: translate(246px,  492px); }
.tile-move-2-5 { transform: translate(246px,  615px); }
.tile-move-3-0 { transform: translate(369px,  0px);   }
.tile-move-3-1 { transform: translate(369px,  123px); }
.tile-move-3-2 { transform: translate(369px,  246px); }
.tile-move-3-3 { transform: translate(369px,  369px); }
.tile-move-3-4 { transform: translate(369px,  492px); }
.tile-move-3-5 { transform: translate(369px,  615px); }
.tile-move-4-0 { transform: translate(492px,  0px);   }
.tile-move-4-1 { transform: translate(492px,  123px); }
.tile-move-4-2 { transform: translate(492px,  246px); }
.tile-move-4-3 { transform: translate(492px,  369px); }
.tile-move-4-4 { transform: translate(492px,  492px); }
.tile-move-4-5 { transform: translate(492px,  615px); }
.tile-move-5-0 { transform: translate(615px,  0px);   }
.tile-move-5-1 { transform: translate(615px,  123px); }
.tile-move-5-2 { transform: translate(615px,  246px); }
.tile-move-5-3 { transform: translate(615px,  369px); }
.tile-move-5-4 { transform: translate(615px,  492px); }
.tile-move-5-5 { transform: translate(615px,  615px); }

.merged {
  animation: merge 0.32s ease 100ms;
  animation-fill-mode: backwards;
}

.new {
  animation: bounce-in 0.22s 100ms;
  animation-fill-mode: backwards;
}

@keyframes bounce-in {
  0%   { transform: scale(0); }
  50%  { transform: scale(0.5); }
  100% { transform: scale(1); }
}

@keyframes merge {
  0%   { transform: scale(0); }
  50%  { transform: scale(1.2); }
  100% { transform: scale(1); }
}
</style>
