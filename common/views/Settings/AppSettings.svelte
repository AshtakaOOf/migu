<script context='module'>
  import { click } from '@/modules/click.js'
  import { toast } from 'svelte-sonner'
  import { resetSettings } from '@/modules/settings.js'
  import IPC from '@/modules/ipc.js'
  import { SUPPORTS } from '@/modules/support.js'
  import SettingCard from './SettingCard.svelte';

  async function importSettings () {
    localStorage.setItem('settings', await navigator.clipboard.readText())
    location.reload()
  }
  function exportSettings () {
    navigator.clipboard.writeText(localStorage.getItem('settings'))
    toast('Copied to clipboard', {
      description: 'Copied settings to clipboard',
      duration: 5000
    })
  }
  function restoreSettigs () {
    resetSettings()
    location.reload()
  }
  function checkUpdate () {
    IPC.emit('update')
  }
  setInterval(checkUpdate, 1200000)
</script>
<script>
  export let settings
</script>

<div class='d-inline-flex flex-column'>
  <button
    use:click={importSettings}
    class='btn btn-primary mx-20 mt-10'
    type='button'>
    Import Settings From Clipboard
  </button>
  <button
    use:click={exportSettings}
    class='btn btn-primary mx-20 mt-10 mb-15'
    type='button'>
    Export Settings To Clipboard
  </button>
  {#if SUPPORTS.update}
    <SettingCard title='Enable auto update' description='Enables auto updater upon startup. Automatically update to a new version of Migu if possible after exiting. Disable this if you have issues with it.'>
      <div class='custom-switch'>
        <input type='checkbox' id='enable-auto-updater' bind:checked={settings.enableAutoUpdate} />
        <label for='enable-auto-updater'>{settings.enableAutoUpdate ? 'On' : 'Off'}</label>
      </div>
    </SettingCard>
    <button
      use:click={checkUpdate}
      class='btn btn-primary mx-20'
      type='button'>
      Check For Updates
    </button>
  {/if}
  <button
    use:click={restoreSettigs}
    class='btn btn-danger mx-20 mt-10'
    type='button'
    data-toggle='tooltip'
    data-placement='top'
    data-title='Restores All Settings Back To Their Recommended Defaults'>
    Restore Default Settings
  </button>
</div>
