<script>
  import { getContext } from 'svelte'
  import { anilistClient } from '@/modules/anilist.js'
  import { media } from '../views/Player/MediaHandler.svelte'
  import { platformMap } from '@/views/Settings/Settings.svelte'
  import { settings } from '@/modules/settings.js'
  import { toast } from 'svelte-sonner'
  import { click } from '@/modules/click.js'
  import { logout } from './Logout.svelte'
  import { rss } from '@/views/TorrentSearch/TorrentModal.svelte'
  import IPC from '@/modules/ipc.js'

  let wasUpdated = false

  globalThis.dd = IPC

  IPC.on('update-available', () => {
    console.log('uwu')
    if (!wasUpdated) {
      // insert icon in 2nd to last position
      links.splice(links.length - 1, 0, {
        click: () => {
          toast('Update is downloading...')
        },
        icon: 'download',
        text: 'Update Downloading...'
      })
      links = links
    }
    wasUpdated = true
  })
  IPC.on('update-downloaded', () => {
    links[links.length - 2].css = 'update'
    links[links.length - 2].text = 'Update Ready!'
    links[links.length - 2].click = () => {
      IPC.emit('quit-and-install')
    }
    links = links
  })

  const view = getContext('view')

  export let page

  let links = [
    {
      click: () => {
        if (anilistClient.userID?.viewer?.data?.Viewer) {
          $logout = true
        } else {
          IPC.emit('open', 'https://anilist.co/api/v2/oauth/authorize?client_id=20321&response_type=token') // Change redirect_url to migu://auth/
          if (platformMap[window.version.platform] === 'Linux') {
            toast('Support Notification', {
              description: "If your linux distribution doesn't support custom protocol handlers, you can simply paste the full URL into the app.",
              duration: 300000
            })
          }
        }
      },
      icon: 'login',
      text: 'Login With AniList',
      css: 'mt-auto'
    },
    {
      click: () => {
        page = 'home'
        $view = null
        $rss = null
      },
      page: 'home',
      icon: 'home',
      text: 'Home'
    },
    {
      click: () => {
        page = 'search'
      },
      page: 'search',
      icon: 'search',
      text: 'Search'
    },
    {
      click: () => {
        page = 'schedule'
        $view = null
        $rss = null
      },
      page: 'schedule',
      icon: 'schedule',
      text: 'Schedule'
    },
    {
      click: () => {
        if (!($view === null)) {
          $view = null
          return
        }
        if ($media) $view = $media.media
        $rss = null
      },
      icon: 'queue_music',
      text: 'Now Playing'
    },
    {
      click: () => {
        page = 'watchtogether'
        $view = null
        $rss = null
      },
      page: 'watchtogether',
      icon: 'groups',
      text: 'Watch Together'
    },
    // {
    //   click: () => {
    //     IPC.emit('open', 'https://github.com/sponsors/ThaUnknown/')
    //   },
    //   icon: 'favorite',
    //   text: 'Support This App',
    //   css: 'mt-auto donate'
    // },
    {
      click: () => {
        page = 'settings'
        $view = null
        $rss = null
      },
      css: 'mt-auto',
      page: 'settings',
      icon: 'settings',
      text: 'Settings'
    }
  ]
  if (anilistClient.userID?.viewer?.data?.Viewer) {
    links[0].image = anilistClient.userID.viewer.data.Viewer.avatar.medium
    links[0].text = 'Logout'
  }
</script>

<div class='sidebar z-30 d-md-block' class:animated={$settings.expandingSidebar}>
  <div class='sidebar-overlay pointer-events-none h-full position-absolute' />
  <div class='sidebar-menu h-full d-flex flex-column justify-content-center align-items-center m-0 pb-5' class:animate={page !== 'player'}>
    {#each links as { click: _click, icon, text, image, css, page: _page } (_click)}
      <div
        class='sidebar-link sidebar-link-with-icon pointer overflow-hidden {css}'
        use:click={_click}>
        <span class='text-nowrap d-flex align-items-center w-full h-full'>
          {#if image}
            <span class='material-symbols-outlined rounded' class:filled={page === _page}>
              <img src={image} class='h-30 rounded' alt='logo' />
            </span>
            <span class='text ml-20'>{text}</span>
          {:else}
            <span class='material-symbols-outlined rounded' class:filled={page === _page}>{icon}</span>
            <span class='text ml-20'>{text}</span>
          {/if}
        </span>
      </div>
    {/each}
  </div>
</div>

<style>
  @keyframes glow {
    from {
      text-shadow: 0 0 2rem #fa68b6;
    }
    to {
      text-shadow: 0 0 1rem #fa68b6;
    }
  }
  .animate .donate .material-symbols-outlined {
    animation: glow 1s ease-in-out infinite alternate;
  }
  .donate:hover .material-symbols-outlined {
    background: #fff;
    color: #fa68b6 !important;
  }
  .donate .material-symbols-outlined {
    font-variation-settings: 'FILL' 1;
    color: #fa68b6;
    text-shadow: 0 0 1rem #fa68b6;
  }
  .update .material-symbols-outlined {
    color: #47cb6a;
    font-variation-settings: 'FILL' 1;
  }
  .sidebar-menu {
    padding-top: 10rem;
  }
  .text {
    opacity: 1;
    transition: opacity 0.8s cubic-bezier(0.25, 0.8, 0.25, 1);
    display: inline-flex;
    justify-content: center;
    align-items: center;
  }

  .sidebar-link > span {
    color: #fff;
    border-radius: 0.3rem;
  }

  .material-symbols-outlined {
    color: #fff;
    transition: background .8s cubic-bezier(0.25, 0.8, 0.25, 1), color .8s cubic-bezier(0.25, 0.8, 0.25, 1);
  }

  .sidebar-link:hover > span > *:nth-child(1) {
    background: #fff;
    color: var(--dark-color);
  }

  .sidebar-link {
    width: 100%;
    font-size: 1.4rem;
    padding: 0.75rem 1.5rem;
    height: 5.5rem;
  }

  .material-symbols-outlined {
    font-size: 2.2rem;
    min-width: 4rem;
    width: 4rem;
    height: 4rem;
    display: inline-flex;
    justify-content: center;
    align-items: center;
  }

  .sidebar-link img {
    font-size: 2.2rem;
    width: 3rem;
    height: 3rem;
    margin: 0.5rem;
    display: inline-flex;
    justify-content: center;
    align-items: center;
  }

  img {
    margin-right: var(--sidebar-brand-image-margin-right);
  }

  .sidebar {
    transition: width .8s cubic-bezier(0.25, 0.8, 0.25, 1), left .8s cubic-bezier(0.25, 0.8, 0.25, 1) !important;
    background: none !important;
    overflow-y: unset;
    overflow-x: visible;
    left: unset;
  }
  .sidebar.animated:hover {
    width: 22rem
  }
  .sidebar-overlay {
    width: var(--sidebar-width);
    transition: width .8s cubic-bezier(0.25, 0.8, 0.25, 1), left .8s cubic-bezier(0.25, 0.8, 0.25, 1) !important;
    background: var(--sidebar-gradient);
    backdrop-filter: blur(2px);
    z-index: -1;
  }
  .sidebar.animated:hover .sidebar-overlay {
    width: 63rem
  }
</style>
