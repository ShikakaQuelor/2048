<template>
  <div :class="['cell', tileMove]">
    <div :class="['inner', tileBackgroundClass, tileMerged, tileNew]">{{ cell.value }}</div>
  </div>
</template>

<script>
export default {
    name: "Tile",
    props: {
      pos: {
        x: Number,
        y: Number,
      },
      cell: Object
    },
    computed: {
      tileBackgroundClass() {
        return `background-${this.cell?.value}`;
      },
      tileMerged() {
        return this.cell?.merged ? "merged" : "";
      },
      tileNew() {
        return this.cell?.fresh ? "new" : "";
      },
      tileMove() {
        return `tile-move-${this.cell?.pos?.x}-${this.cell?.pos?.y}`;
      },
    },
};
</script>

<style lang="scss">
$background-2: #eee4da;
$background-4: #ede0c8;
$background-8: #f2b179;
$background-16: #f59563;
$background-32: #f67c5f;
$background-64: #f65e3b;
$background-128: #edcf72;
$background-256: #edcc61;
$background-512: #edc850;
$background-1024: #edc53f;
$background-2048: #edc22e;

$colorAdv: #f9f6f2;

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

.background- {
  &2 {
    background: $background-2;
  }
  &4 {
    background: $background-4;
  }
  &8 {
    background: $background-8;
    color: $colorAdv;
  }
  &16 {
    background: $background-16;
    color: $colorAdv;
  }
  &32 {
    background: $background-32;
    color: $colorAdv;
  }
  &64 {
    background: $background-64;
    color: $colorAdv;
  }
  &128 {
    background: $background-128;
    color: $colorAdv;
  }
  &256 {
    background: $background-256;
    color: $colorAdv;
  }
  &512 {
    background: $background-512;
    color: $colorAdv;
  }
  &1024 {
    background: $background-1024;
    color: $colorAdv;
    font-size: 2.2rem;
  }
  &2048 {
    background: $background-2048;
    color:$colorAdv;
  }
}

@for $i from 0 to 6 {
  @for $j from 0 to 6 {
    .tile-move- {
      &#{$i}-#{$j} {
        transform: translate(123px * $i, 123px * $j);
      }
    }
  }
}

.merged {
  animation: merge 0.32s ease 100ms;
  animation-fill-mode: backwards;
}

.new {
  animation: bounce-in 0.22s 100ms;
  animation-fill-mode: backwards;
}



@keyframes bounce-in {
  0% {
      transform: scale(0);
  }
  50% {
      transform: scale(0.5);
  }
  100% {
      transform: scale(1);
  }
}

@keyframes merge {
    0% {
        transform: scale(0);
    }
    50% {
        transform: scale(1.2);
    }
    100% {
        transform: scale(1);
    }
}
</style>