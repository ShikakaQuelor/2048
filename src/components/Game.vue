<template>
  <div class="game">
    <Stats :score="score"></Stats>
    <div class="config-wrapper">
      <div class="new-game config-button" @click="newGame"><b>New Game</b></div>
      <div class="size"><input type="range" min="4" max="6" v-model="boardSize" @keydown.prevent
          class="size-range config-button"></div>
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
    <div :class="['game-wrapper', gameOver]" :style="{ width: gameSize + 'px', height: gameSize + 'px' }">
      <div class="gameBoard">
        <template v-for="row in 6" :key="row">
          <template v-for="col in 6" :key="col">
            <div :class="['tile', gridSize]"></div>
          </template>
        </template>
      </div>
      <div class="tileBoard">
        <template v-for="tile in tiles" :key="tile">
          <Tile :cell="tile"></Tile>
        </template>
      </div>
    </div>
    <Info />
  </div>
</template>

<script>
import { ref, computed } from 'vue';

import Tile from "./Tile";
import Stats from "./Stats";
import Info from "./Info";

export const STARTAMOUNT = 2;
export const TARGET = 2048;
export const KEYCODE = {
  up: 38,
  down: 40,
  left: 37,
  right: 39,
};

export default {
  name: 'Board',
  components: {
    Tile,
    Stats,
    Info,
  },
  setup() {
    const boardSize = ref(4);
    const tiles = ref([]);
    const score = ref(0);
    const gameState = ref(1);
    var grid;

    const gridSize = computed(() => {
      return `grid-${boardSize.value}`;
    });
    const gameSize = computed(() => {
      return 123 * boardSize.value - 15;
    });
    const gameOver = computed(() => {
      return gameState.value !== 1 ? "gameOver" : "";
    })



    setupGame();

    function setupGame() {
      document.addEventListener("keyup", handleKeyUp);

      let load = localStorage.getItem("2048state");

      if (load) {
        loadGame(load);
      } else {
        newGame();
      }
    }

    function newGame() {
      resetProgress();
      grid = Array(6).fill().map(() => Array(6).fill(0));
      tiles.value.length = 0;
      score.value = 0;
      gameState.value = 1;
      for (let i = 0; i < STARTAMOUNT; i++) {
        addTile(addNewTile());
      }
    }

    function loadGame(state) {
      let data = JSON.parse(state);
      tiles.value = data.tile;
      boardSize.value = data.size;
      grid = data.grid;
      score.value = data.score;
    }

    function move(vector) {
      let moved = false;
      let traversal = getTraversal(vector)

      clearMerged(tiles.value);

      traversal.x.forEach(function (x) {
        traversal.y.forEach(function (y) {
          let cell = { x, y };

          if (grid[x][y]) {
            let curr = getTile(cell);
            let positions = findFurthest(cell, vector)
            let next = getTile(positions.next);

            if (next && withinBounds(next.pos) && next.value === curr.value && !next.merged && !curr.merged) {
              grid[x][y] = 0;
              curr = mergeTiles(curr);
              curr.pos = next.pos;
              removeTile(next);
              moved = true;
              if (curr.value === 2048) {
                gameState.value = 2;
                console.log("GAME WON");
              }
            } else if (cell !== positions.farthest) {
              curr.pos = positions.farthest;
              grid[x][y] = 0;
              grid[curr.pos.x][curr.pos.y] = 1;
              moved = true;
            }
          }
        })
      })
      if (moved) {
        addTile(addNewTile());
        if (!emptyTiles() && !checkMerge()) {
          gameState.value = 0;
          console.log("GAME OVER");
          resetProgress();
        } else saveProgress();
      }
    }

    function checkMerge() {
      let tile1;
      let tile2;

      for (let x = 0; x < boardSize.value; x++) {
        for (let y = 0; y < boardSize.value; y++) {
          tile1 = getTile({ x, y });

          if (tile1) {
            for (let i = 0; i < 4; i++) {
              let vector = getVector(i);
              tile2 = getTile({ x: x + vector.x, y: y + vector.y });
              if (tile2 && withinBounds(tile2.pos) && tile1.value === tile2.value) {
                return true;
              }
            }
          }
        }
      }
      return false;
    }

    function emptyTiles() {
      for (let i = 0; i < boardSize.value; i++) {
        for (let j = 0; j < boardSize.value; j++) {
          if (grid[i][j] === 0) {
            return true;
          }
        }
      }
      return false;
    }

    function withinBounds(cell) {
      return (
        cell.x >= 0 &&
        cell.x < boardSize.value &&
        cell.y >= 0 &&
        cell.y < boardSize.value);
    }

    function mergeTiles(tile) {
      tile.value *= 2;
      score.value += tile.value;
      tile.merged = true;
      return tile;
    }

    function findFurthest(cell, vector) {
      let prev;
      do {
        prev = cell;
        cell = { x: prev.x + vector.x, y: prev.y + vector.y };
      } while (withinBounds(cell) && !grid[cell.x][cell.y]);
      return {
        farthest: prev,
        next: cell
      };
    }

    function getTraversal(vector) {
      let trav = { x: [], y: [] };
      for (let i = 0; i < boardSize.value; i++) {
        trav.x.push(i);
        trav.y.push(i);
      }
      if (vector.x === 1) { trav.x.reverse() }
      if (vector.y === 1) { trav.y.reverse() }
      return trav;
    }

    function getVector(direction) {
      let map = {
        0: { x: 0, y: -1 }, //Up
        1: { x: 1, y: 0 },  //Right
        2: { x: -1, y: 0 }, //Left
        3: { x: 0, y: 1 },  //Down
      }
      return map[direction];
    }

    function getTile(pos) {
      return tiles.value.filter((tile) => {
        return tile.pos.x === pos.x && tile.pos.y === pos.y;
      })[0];
    }

    function clearMerged(tiles) {
      tiles.forEach(tile => {
        tile.merged = false;
      });
    }

    function addTile(tile) {
      tiles.value.push(tile);
      grid[tile.pos.x][tile.pos.y] = 1;
    }

    function removeTile(remove) {
      tiles.value = tiles.value.filter(tile => tile !== remove);
    }

    function addNewTile() {
      let pos = Math.floor(Math.random() * (boardSize.value * boardSize.value));
      let row;
      let col;
      do {
        pos = (pos + 1) % (boardSize.value * boardSize.value);
        row = Math.floor(pos / boardSize.value);
        col = pos % boardSize.value;
      } while (grid[row][col] !== 0);
      let value = Math.random() < 0.1 ? 4 : 2;
      return {
        pos: { x: row, y: col },
        value,
        fresh: true,
        merged: false
      };
    }

    function saveProgress() {
      let state = JSON.stringify({ tile: tiles.value, grid: grid, score: score.value, size: boardSize.value });
      localStorage.setItem("2048state", state);
    }

    function resetProgress() {
      localStorage.removeItem("2048state");
    }

    function handleKeyUp(e) {
      const code = e.which || e.keyCode;
      switch (code) {
        case KEYCODE.up:
          move(getVector(0));
          break;
        case KEYCODE.down:
          move(getVector(3));
          break;
        case KEYCODE.left:
          move(getVector(2));
          break;
        case KEYCODE.right:
          move(getVector(1));
          break;
        default:
          break;
      }
    }

    return {
      boardSize,
      tiles,
      score,
      newGame,
      gridSize,
      gameSize,
      gameOver,
      gameState,
    }
  }
};
</script>

<style scoped lang="scss">
.game {
  color: #2c3e50;
  width: 100%;
  height: 100%;
  overflow: hidden;
  background: #fdebd5;
  position: absolute;
}

.config-wrapper {
  width: 470px;
  height: 32px;
  position: relative;
  display: flex;
  justify-content: center;
  left: 50%;
  transform: translate(-50%);
}

.config-button {
  width: 156px;
  display: block;
  margin-right: 26px;
  line-height: 32px;
  text-align: center;
  border-radius: 10px;
  background: #bbada0;
  color: #f9f6f2;
  user-select: none;

  &:hover {
    background: #dac9ba;
    cursor: pointer;
  }
}

.size-range {
  appearance: none;
  outline: none;
  height: 100%;
  margin-left: 26px;
  margin-top: 0;

  &::-webkit-slider-thumb {
    appearance: none;
    width: 33%;
    height: 30px;
    border-radius: 10px;
    background: #3c3a32;
    box-shadow: 0 0 4px 0 rgba($color: #000000, $alpha: 0.1);
  }

  &::-moz-range-thumb {
    appearance: none;
    width: 33%;
    height: 30px;
    border-radius: 10px;
    background: #3c3a32;
    box-shadow: 0 0 4px 0 rgba($color: #000000, $alpha: 0.1);
  }
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

.grid- {
  &4 {
    &:nth-child(4n) {
      margin-right: 0px;
    }

    &:nth-last-child(-n+4) {
      margin-bottom: 0px;
    }
  }

  &5 {
    &:nth-child(5n) {
      margin-right: 0px;
    }

    &:nth-last-child(-n+5) {
      margin-bottom: 0px;
    }
  }

  &6 {
    &:nth-child(6n) {
      margin-right: 0px;
    }

    &:nth-last-child(-n+6) {
      margin-bottom: 0px;
    }
  }
}

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
  opacity: 100%;
}

.gameOver {
  transition: filter 2s ease-in;
  filter: brightness(50%) blur(2px);
}

@keyframes pop-in {
  0% {
    opacity: 0;
  }

  100% {
    opacity: 100;
  }
}
</style>
