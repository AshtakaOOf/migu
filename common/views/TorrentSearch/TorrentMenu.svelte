<script context='module'>
  import { toast } from 'svelte-sonner'
  import { settings } from '@/modules/settings.js'
  import { click } from '@/modules/click.js'
  import getResultsFromExtensions from '@/modules/extensions/index.js'

  /** @typedef {import('@/modules/al.d.ts').Media} Media */

  /** @param {Media} media */
  function isMovie (media) {
    if (media.format === 'MOVIE') return true
    if ([...Object.values(media.title), ...media.synonyms].some(title => title?.toLowerCase().includes('movie'))) return true
    // if (!getParentForSpecial(media)) return true // TODO: this is good for checking movies, but false positives with normal TV shows
    return media.duration > 80 && media.episodes === 1
  }

/**
 * @param {ReturnType<typeof getResultsFromExtensions>} promise
 */
 async function getBest(promise) {
  const results = await promise

  if (settings.value.sortByEco) {
    return results[0]
  } else {
    const best = results.find(result => result.type === 'best') || 
                 results.find(result => result.type === 'alt') || 
                 results[0]

    if (best?.seeders < 10) return results[0]

    return best
  }
}

function filterResults(results, searchText) {
  return results.filter(({ title }) => title.toLowerCase().includes(searchText.toLowerCase()))
}

/**
 * @param {ReturnType<typeof getResultsFromExtensions>} results
 */
async function sortResults(results) {
  const awaitedResults = await results
  
  if (settings.value.sortByEco) {
    // Normalize size and seeders to a 0-1 scale
    const maxSize = Math.max(...awaitedResults.map(r => r.size))
    const maxSeeders = Math.max(...awaitedResults.map(r => r.seeders))
    
    return awaitedResults.sort((a, b) => {
      // Normalize values (smaller size and more seeders are better)
      const aScore = (1 - a.size / maxSize) *0.7 + (a.seeders / maxSeeders) * 0.3
      const bScore = (1 - b.size / maxSize) *0.7 + (b.seeders / maxSeeders) * 0.3
      
      return bScore - aScore // Sort in descending order of score
    })
  } else {
    return awaitedResults.sort((a, b) => b.seeders - a.seeders)
  }
}
</script>

<script>
  import { media as currentMedia } from '../Player/MediaHandler.svelte'
  import TorrentCard from './TorrentCard.svelte'
  import { add } from '@/modules/torrent.js'
  import TorrentSkeletonCard from './TorrentSkeletonCard.svelte'
  import { onDestroy } from 'svelte'
  import { SUPPORTS } from '@/modules/support';

  /** @type {{ media: Media, episode?: number }} */
  export let search

  let countdown = 2
  let timeoutHandle

  /** @param {ReturnType<typeof getBest>} promise */
  async function autoPlay (promise, autoPlay) {
    const best = await promise
    if (!search) return
    if ($settings.rssAutoplay) {
      clearTimeout(timeoutHandle)
      const decrement = () => {
        countdown--
        if (countdown === 0) {
          play(best)
          if (SUPPORTS.isAndroid) document.querySelector('.content-wrapper').requestFullscreen()
        } else {
          timeoutHandle = setTimeout(decrement, 1000)
        }
      }
      timeoutHandle = setTimeout(decrement, 1000)
    }
  }

  const movie = isMovie(search.media)
  let batch = search.media.status === 'FINISHED' && !movie

  $: resolution = $settings.rssQuality

  $: lookup = sortResults(getResultsFromExtensions({ ...search, batch, movie, resolution }))
  $: best = getBest(lookup)

  onDestroy(() => {
    clearTimeout(timeoutHandle)
    search = null
  })

  $: if (!$settings.rssAutoplay) clearTimeout(timeoutHandle)
  $: autoPlay(best, $settings.rssAutoplay)

  $: lookup.catch(err => {
    console.error(err)
    toast.error(`No torrent found for ${search.media.title.userPreferred} Episode ${search.episode}!`, { description: err.message })
  })

  $: firstLoad = !firstLoad && lookup.catch(close)

  let searchText = ''

  /** @param {import('@thaunknown/ani-resourced/sources/types.d.ts').Result} result */
  function play (result) {
    $currentMedia = search
    $currentMedia.verified = result.verified
    if (!isNaN(result.seeders) && result.seeders < 10) {
      toast('Availability Warning', {
        description: 'This release is poorly seeded and likely will have playback issues such as buffering!'
      })
    }
    add(result.link)
    close()
  }

  function episodeInput ({ target }) {
    const episode = Number(target.value)
    if (episode) search.episode = episode
  }

  export let close
</script>

<div class='w-full bg-very-dark position-sticky top-0 z-10 pt-20 px-30'>
  <div class='d-flex' style="padding-top: var(--safe-area-top)">
    <h3 class='mb-10 font-weight-bold text-white'>Find Torrents</h3>
    <button class='btn btn-square rounded-circle ml-auto pointer' type='button' use:click={close}> &times; </button>
  </div>
  <h4 class='mb-10 text-light'>Auto-Selected Torrent</h4>
  {#await best}
    <TorrentSkeletonCard />
  {:then bestRelease}
    <TorrentCard result={bestRelease} {play} media={search.media} />
  {:catch error}
    <div class='p-15 mb-10'><div class='h-100' /></div>
  {/await}
  <div class='input-group mt-20'>
    <div class='input-group-prepend'>
      <span class='input-group-text d-flex material-symbols-outlined bg-dark pr-0 font-size-18'>search</span>
    </div>
    <input
      type='search'
      class='form-control bg-dark border-left-0'
      autocomplete='off'
      data-option='search'
      placeholder='Find a specific torrent...' bind:value={searchText} />
  </div>
  <div class='row mt-20 mb-10'>
    <div class='col-12 col-md-6 d-flex align-items-center justify-content-around'>
      <div class='custom-switch'>
        <input type='checkbox' id='rss-autoplay' bind:checked={$settings.rssAutoplay} />
        <label for='rss-autoplay'>Auto-Select Torrents [{countdown}]</label>
      </div>
      <div class='custom-switch'>
        <input type='checkbox' id='eco-mode' bind:checked={$settings.sortByEco} on:change={()=>{search.episode = search.episode}} />
        <label for='eco-mode'>Less Bandwidth</label>
      </div>
      <div class='custom-switch'>
        <input type='checkbox' id='batches' bind:checked={batch} disabled={(search.media.status !== 'FINISHED') || movie} min='1' />
        <label for='batches'>Find Batches</label>
      </div>
    </div>
    <div class='col-12 col-md-6 d-flex align-items-center justify-content-around mt-20 mt-md-0'>
      <div class='w-150 d-flex align-items-center'>
        <span>Episode</span>
        <input type='number' inputmode='numeric' pattern='[0-9]*' class='form-control bg-dark text-right ml-10' value={search.episode} on:input={episodeInput} disabled={!search.episode || movie} />
      </div>
      <div class='w-200 d-flex align-items-center'>
        <span>Resolution</span>
        <select class='form-control w-full bg-dark ml-10' bind:value={$settings.rssQuality}>
          <option value='1080' selected>1080p</option>
          <option value='720'>720p</option>
          <option value='540'>540p</option>
          <option value='480'>480p</option>
          <option value="">Any</option>
        </select>
      </div>
    </div>
  </div>
</div>
<div class='mt-10 px-30'>
  {#await lookup}
    {#each Array.from({ length: 10 }) as _}
      <TorrentSkeletonCard />
    {/each}
  {:then results}
    {#each filterResults(results, searchText) as result}
      <TorrentCard {result} {play} media={search.media} />
    {/each}
  {/await}
</div>

<style>
  .px-30 {
    padding-left: 3rem;
    padding-right: 3rem;
  }
</style>
