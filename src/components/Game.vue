<template>
  <div class="game">
    <div class="game-inner" :style="{ zoom: scale }">
    <Stats :score="score" />
    <div class="config-wrapper">
      <div class="new-game config-button" @click="newGame"><b>New Game</b></div>
      <div class="size-buttons">
        <button
          v-for="n in availableSizes"
          :key="n"
          :class="['size-btn', { active: boardSize === n, disabled: gameActive }]"
          :disabled="gameActive"
          @click="selectSize(n)"
        >{{ n }}×{{ n }}</button>
      </div>
    </div>
    <transition name="gg">
      <div v-if="gameState === 0" :key="gameState" class="postgame-text">GAME OVER</div>
    </transition>
    <transition name="gg">
      <div v-if="gameState === 2" :key="gameState" @click="gameState = 1" class="postgame-text">
        YOU WON
        <span class="continue-button">- click to continue -</span>
      </div>
    </transition>
    <div
      :class="['game-wrapper', gameOver]"
      :style="{ width: gameSize + 'px', height: gameSize + 'px' }"
      @touchstart.passive="onTouchStart"
      @touchend.passive="onTouchEnd"
    >
      <div class="gameBoard">
        <template v-for="row in 6" :key="row">
          <template v-for="col in 6" :key="col">
            <div :class="['tile', gridSize]"></div>
          </template>
        </template>
      </div>
      <div class="tileBoard">
        <template v-for="tile in tiles" :key="tile">
          <Tile :cell="tile" />
        </template>
      </div>
    </div>
    <Info />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'

import Tile from './Tile.vue'
import Stats from './Stats.vue'
import Info from './Info.vue'

const STARTAMOUNT = 2

const boardSize = ref(4)
const tiles = ref([])
const score = ref(0)
const gameState = ref(1)
const moved = ref(false)
var grid

// natural content width per board size: gameSize (123n-15) + 30px padding + ~18px breathing room
const naturalWidth = computed(() => 123 * boardSize.value + 18)
// cap board size to what produces a comfortable tile size (≥ ~80px) at current viewport
const maxBoardSize = computed(() => {
  const w = window.innerWidth
  if (w >= 560) return 6
  if (w >= 470) return 5
  return 4
})
const scale = ref(Math.min(1, window.innerWidth / (123 * 4 + 18)))

function updateScale() {
  // clamp board size if viewport shrank (e.g. orientation change)
  if (boardSize.value > maxBoardSize.value) boardSize.value = maxBoardSize.value
  scale.value = Math.min(1, window.innerWidth / naturalWidth.value)
}

// true once the player has made at least one move in the current game
const gameActive = computed(() => gameState.value === 1 && moved.value)
const availableSizes = computed(() => [4, 5, 6].filter(n => n <= maxBoardSize.value))

watch(boardSize, () => {
  scale.value = Math.min(1, window.innerWidth / naturalWidth.value)
})

function selectSize(n) {
  boardSize.value = n
  newGame()
}

const gridSize = computed(() => `grid-${boardSize.value}`)
const gameSize = computed(() => 123 * boardSize.value - 15)
const gameOver = computed(() => gameState.value !== 1 ? 'gameOver' : '')

let touchStart = null

function onTouchStart(e) {
  const t = e.touches[0]
  touchStart = { x: t.clientX, y: t.clientY }
}

function onTouchEnd(e) {
  if (!touchStart) return
  const t = e.changedTouches[0]
  const dx = t.clientX - touchStart.x
  const dy = t.clientY - touchStart.y
  touchStart = null

  const THRESHOLD = 30
  if (Math.abs(dx) < THRESHOLD && Math.abs(dy) < THRESHOLD) return

  if (Math.abs(dx) > Math.abs(dy)) {
    move(getVector(dx > 0 ? 1 : 2)) // right : left
  } else {
    move(getVector(dy > 0 ? 3 : 0)) // down : up
  }
}

function handleKeyUp(e) {
  switch (e.key) {
    case 'ArrowUp':    move(getVector(0)); break
    case 'ArrowRight': move(getVector(1)); break
    case 'ArrowLeft':  move(getVector(2)); break
    case 'ArrowDown':  move(getVector(3)); break
  }
}

onMounted(() => {
  document.addEventListener('keyup', handleKeyUp)
  window.addEventListener('resize', updateScale)

  const load = localStorage.getItem('2048state')
  if (load) {
    loadGame(load)
  } else {
    newGame()
  }
})

onUnmounted(() => {
  document.removeEventListener('keyup', handleKeyUp)
  window.removeEventListener('resize', updateScale)
})

function newGame() {
  resetProgress()
  grid = Array(6).fill().map(() => Array(6).fill(0))
  tiles.value.length = 0
  score.value = 0
  gameState.value = 1
  moved.value = false
  for (let i = 0; i < STARTAMOUNT; i++) {
    addTile(addNewTile())
  }
}

function loadGame(state) {
  let data = JSON.parse(state)
  tiles.value = data.tile
  boardSize.value = data.size
  grid = data.grid
  score.value = data.score
}

function move(vector) {
  let didMove = false
  let traversal = getTraversal(vector)

  clearMerged(tiles.value)

  traversal.x.forEach(function (x) {
    traversal.y.forEach(function (y) {
      let cell = { x, y }

      if (grid[x][y]) {
        let curr = getTile(cell)
        let positions = findFurthest(cell, vector)
        let next = getTile(positions.next)

        if (next && withinBounds(next.pos) && next.value === curr.value && !next.merged && !curr.merged) {
          grid[x][y] = 0
          curr = mergeTiles(curr)
          curr.pos = next.pos
          removeTile(next)
          didMove = true
          if (curr.value === 2048) {
            gameState.value = 2
          }
        } else if (cell !== positions.farthest) {
          curr.pos = positions.farthest
          grid[x][y] = 0
          grid[curr.pos.x][curr.pos.y] = 1
          didMove = true
        }
      }
    })
  })

  if (didMove) {
    moved.value = true
    addTile(addNewTile())
    if (!emptyTiles() && !checkMerge()) {
      gameState.value = 0
      resetProgress()
    } else saveProgress()
  }
}

function checkMerge() {
  for (let x = 0; x < boardSize.value; x++) {
    for (let y = 0; y < boardSize.value; y++) {
      const tile1 = getTile({ x, y })
      if (tile1) {
        for (let i = 0; i < 4; i++) {
          const vector = getVector(i)
          const tile2 = getTile({ x: x + vector.x, y: y + vector.y })
          if (tile2 && withinBounds(tile2.pos) && tile1.value === tile2.value) {
            return true
          }
        }
      }
    }
  }
  return false
}

function emptyTiles() {
  for (let i = 0; i < boardSize.value; i++) {
    for (let j = 0; j < boardSize.value; j++) {
      if (grid[i][j] === 0) return true
    }
  }
  return false
}

function withinBounds(cell) {
  return (
    cell.x >= 0 &&
    cell.x < boardSize.value &&
    cell.y >= 0 &&
    cell.y < boardSize.value
  )
}

function mergeTiles(tile) {
  tile.value *= 2
  score.value += tile.value
  tile.merged = true
  return tile
}

function findFurthest(cell, vector) {
  let prev
  do {
    prev = cell
    cell = { x: prev.x + vector.x, y: prev.y + vector.y }
  } while (withinBounds(cell) && !grid[cell.x][cell.y])
  return { farthest: prev, next: cell }
}

function getTraversal(vector) {
  let trav = { x: [], y: [] }
  for (let i = 0; i < boardSize.value; i++) {
    trav.x.push(i)
    trav.y.push(i)
  }
  if (vector.x === 1) trav.x.reverse()
  if (vector.y === 1) trav.y.reverse()
  return trav
}

function getVector(direction) {
  const map = {
    0: { x: 0,  y: -1 }, // Up
    1: { x: 1,  y: 0  }, // Right
    2: { x: -1, y: 0  }, // Left
    3: { x: 0,  y: 1  }, // Down
  }
  return map[direction]
}

function getTile(pos) {
  return tiles.value.filter(tile => tile.pos.x === pos.x && tile.pos.y === pos.y)[0]
}

function clearMerged(tiles) {
  tiles.forEach(tile => { tile.merged = false })
}

function addTile(tile) {
  tiles.value.push(tile)
  grid[tile.pos.x][tile.pos.y] = 1
}

function removeTile(remove) {
  tiles.value = tiles.value.filter(tile => tile !== remove)
}

function addNewTile() {
  let pos = Math.floor(Math.random() * (boardSize.value * boardSize.value))
  let row, col
  do {
    pos = (pos + 1) % (boardSize.value * boardSize.value)
    row = Math.floor(pos / boardSize.value)
    col = pos % boardSize.value
  } while (grid[row][col] !== 0)
  const value = Math.random() < 0.1 ? 4 : 2
  return { pos: { x: row, y: col }, value, fresh: true, merged: false }
}

function saveProgress() {
  localStorage.setItem('2048state', JSON.stringify({
    tile: tiles.value, grid, score: score.value, size: boardSize.value
  }))
}

function resetProgress() {
  localStorage.removeItem('2048state')
}
</script>

<style scoped>
.game {
  color: #2c3e50;
  width: 100%;
  min-height: 100%;
  overflow-y: auto;
  background: #fdebd5;
}

.game-inner {
  width: 510px;
  margin: 0 auto;
  transform-origin: top left;
}

.config-wrapper {
  width: 470px;
  height: 32px;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  left: 50%;
  transform: translate(-50%);
  gap: 8px;
}

.config-button {
  width: 156px;
  display: block;
  line-height: 32px;
  text-align: center;
  border-radius: 10px;
  background: #bbada0;
  color: #f9f6f2;
  user-select: none;
}

.config-button:hover {
  background: #dac9ba;
  cursor: pointer;
}

.size-buttons {
  display: flex;
  gap: 6px;
}

.size-btn {
  height: 32px;
  padding: 0 10px;
  border: none;
  border-radius: 10px;
  background: #bbada0;
  color: #f9f6f2;
  font-size: 0.85rem;
  font-weight: bold;
  cursor: pointer;
  user-select: none;
}

.size-btn:hover:not(:disabled) {
  background: #dac9ba;
}

.size-btn.active {
  background: #3c3a32;
}

.size-btn.disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

.game-wrapper {
  width: 477px;
  height: 477px;
  position: relative;
  margin: 25px auto;
  padding: 15px;
  background: #bbada0;
  border-radius: 10px;
  overflow: hidden;
}

.tileBoard {
  z-index: 2;
  position: absolute;
}

.gameBoard {
  position: absolute;
  z-index: 1;
}

.tile {
  width: 108px;
  height: 108px;
  border-radius: 10px;
  margin-right: 15px;
  margin-bottom: 15px;
  float: left;
  background: #3c3a32;
}

.grid-4:nth-child(4n)      { margin-right: 0; }
.grid-4:nth-last-child(-n+4) { margin-bottom: 0; }
.grid-5:nth-child(5n)      { margin-right: 0; }
.grid-5:nth-last-child(-n+5) { margin-bottom: 0; }
.grid-6:nth-child(6n)      { margin-right: 0; }
.grid-6:nth-last-child(-n+6) { margin-bottom: 0; }

.postgame-text {
  position: absolute;
  display: block;
  width: 460px;
  height: 80px;
  border-radius: 16px;
  line-height: 80px;
  background: #3c3a32;
  color: #bbada0;
  text-align: center;
  left: 50%;
  top: 440px;
  transform: translateX(-50%);
  font-size: 4rem;
  z-index: 55;
}

.continue-button {
  position: absolute;
  top: 40%;
  left: 50%;
  transform: translateX(-50%);
  display: block;
  font-size: 1rem;
}

.gg-enter-active {
  animation: pop-in 2s ease-in-out;
  opacity: 1;
}

.gameOver {
  transition: filter 2s ease-in;
  filter: brightness(50%) blur(2px);
}

@keyframes pop-in {
  0%   { opacity: 0; }
  100% { opacity: 1; }
}
</style>
