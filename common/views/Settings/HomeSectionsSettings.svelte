<script>
  import { click } from '@/modules/click.js'
  import { sections } from '@/modules/sections.js'
  import { SUPPORTS } from '@/modules/support.js';

  const allowedHomeSections = sections.map(({ title }) => title)
  export let homeSections

  let mouseYCoordinate = null // pointer y coordinate within client
  let distanceTopGrabbedVsPointer = null

  let draggingItem = null
  let draggingItemIndex = null

  let hoveredItemIndex = null

  $: {
    if (draggingItemIndex != null && hoveredItemIndex != null && draggingItemIndex !== hoveredItemIndex) {
      [homeSections[draggingItemIndex], homeSections[hoveredItemIndex]] = [homeSections[hoveredItemIndex], homeSections[draggingItemIndex]]

      draggingItemIndex = hoveredItemIndex
    }
  }

  function moveItem(index, direction) {
    if (direction === 'up' && index > 0) {
      [homeSections[index], homeSections[index - 1]] = [homeSections[index - 1], homeSections[index]];
    } else if (direction === 'down' && index < homeSections.length - 1) {
      [homeSections[index], homeSections[index + 1]] = [homeSections[index + 1], homeSections[index]];
    }
    homeSections = homeSections; // Trigger reactivity
  }
</script>

{#if mouseYCoordinate}
  <div
    class='input-group mb-10 ghost w-full'
    style='top: {mouseYCoordinate + distanceTopGrabbedVsPointer}px;'>
    <div class='input-group-prepend'>
      <span class='input-group-text d-flex justify-content-center px-5 material-symbols-outlined font-size-20'>swap_vert</span>
    </div>
    <select class='form-control' value={draggingItem}>
      {#each allowedHomeSections as section}
        <option>{section}</option>
      {/each}
    </select>
    <div class='input-group-append'>
      <button type='button' class='btn btn-danger input-group-append px-5 material-symbols-outlined font-size-20'>delete</button>
    </div>
  </div>
{/if}
{#each homeSections as item, index}
  <div
    class='input-group mb-10'
    class:tp={draggingItem === item}
    draggable='true'
    role='menuitem'
    tabindex='-1'
    on:dragstart={({ clientY, target }) => {
      mouseYCoordinate = clientY
      draggingItem = item
      draggingItemIndex = index
      distanceTopGrabbedVsPointer = target.offsetTop - clientY
    }}
    on:drag={e => { mouseYCoordinate = e.clientY }}
    on:dragover={() => { hoveredItemIndex = index }}
    on:dragend={() => {
      mouseYCoordinate = null
      draggingItem = null
      hoveredItemIndex = null
    }}>
    {#if !SUPPORTS.isAndroid}
      <div class='input-group-prepend grab'>
        <span class='input-group-text d-flex justify-content-center px-5 material-symbols-outlined font-size-20'>swap_vert</span>
      </div>
    {:else}
      <div class='input-group-prepend'>
        <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
        <!-- svelte-ignore a11y-click-events-have-key-events -->
        <button on:click={() => moveItem(index, 'up')} class='input-group-text d-flex justify-content-center px-5 material-symbols-outlined font-size-20 pointer'>arrow_upward</button>
        <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
        <!-- svelte-ignore a11y-click-events-have-key-events -->
        <button on:click={() => moveItem(index, 'down')} class='input-group-text d-flex justify-content-center px-5 material-symbols-outlined font-size-20 pointer'>arrow_downward</button>
      </div>
    {/if}
    <select class='form-control bg-dark w-400 mw-full' bind:value={homeSections[index]}>
      {#each allowedHomeSections as section}
        <option>{section}</option>
      {/each}
    </select>
    <div class='input-group-append'>
      <button type='button' use:click={() => { homeSections.splice(index, 1); homeSections = homeSections }} class='btn btn-danger input-group-append px-5 material-symbols-outlined font-size-20'>delete</button>
    </div>
  </div>
{/each}
<button type='button' use:click={() => { homeSections[homeSections.length] = 'Trending Now' }} class='btn btn-primary'>Add Section</button>

<style>
    .ghost {
      margin-bottom: 10px;
      pointer-events: none;
      z-index: 9999;
      position: absolute !important;
    }

    .tp {
      opacity: 0;
    }

    .grab{
      cursor: grab;
    }
    
    .pointer {
      cursor: pointer;
    }
</style>