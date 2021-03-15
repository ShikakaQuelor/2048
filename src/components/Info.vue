<template>
  <div class="info-wrapper">
      <div class="how-to">
        <span>
        <b>HOW TO PLAY: </b>
        Use <b>arrowkeys</b> or swipe to move the tiles. 
        If two tiles with the same value collide, they <b>merge into one</b>. 
        The goal of the game is to get a tile to <b>2048</b>.
        </span>
      </div>
      <div class="credits">
        <span>
          Created in <b>Vue</b> by Johan Berglund based on 2048 by <a href="http://gabrielecirulli.com/">Gabriele Cirulli</a>. 
          Based on <a href="https://itunes.apple.com/us/app/1024!/id823499224">1024 by Veewo Studio</a>.
        </span>
      </div>
  </div>
</template>

<script>
export default {

}
</script>

<style scoped lang="scss">

.info-wrapper {
  margin-top: 20px;
  position: relative;
  width: 470px;
  height: 200px;
  left: 50%;
  transform: translate(-50%);
  color: #3c3a32;
}

.credits {
  margin-top: 16px;
}

a {
  color: #2c3e50;
}

</style>