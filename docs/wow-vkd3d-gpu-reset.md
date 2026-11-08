# WoW VKD3D GPU reset

## Incident

On Ishimura at 2026-11-08 15:12 CST, the Wayland session ended while Discord
was streaming World of Warcraft. Kernel evidence identifies WoW's D3D12/VKD3D
queue as the initiating failure:

```text
ring gfx_0.0.0 timeout
Process Wow.exe ... thread vkd3d_queue
Illegal opcode in command stream
GPU reset begin
VRAM is lost due to GPU reset
```

Niri then aborted in Mesa EGL frame completion after the GPU reset. Xwayland
and Discord also crashed during session teardown. Discord capture increased GPU
activity but was not the process named by AMDGPU.

## Mitigation

Both installed WoW variants now use D3D11:

```text
Games/lutris/battlenet/drive_c/Program Files (x86)/World of Warcraft/
  _retail_/WTF/Config.wtf
  _forever_/WTF/Config.wtf
```

Each file contains:

```text
SET GxApi "D3D11"
```

This moves WoW from VKD3D-Proton to DXVK while leaving Battle.net, the Wine
prefix, and GE-Proton unchanged.

Pre-change files are beside each config with suffix:

```text
.20261108-1512-gpu-reset
```

## Kernel state

The crash occurred on Linux LTS `6.18.56`. Linux LTS `6.18.60` was installed
afterward but is not active until reboot. Finish package updates before
rebooting.

## Verification

After reboot:

1. confirm `uname -r` reports `6.18.60-1-lts` or newer;
2. launch WoW and confirm its graphics API is DirectX 11;
3. stream a WoW window in Discord;
4. check for new GPU faults:

   ```sh
   journalctl -k -b --no-pager |
     grep -Ei 'ring .* timeout|Illegal opcode|GPU reset|VRAM is lost'
   ```

No matching lines should appear.

## Rollback

D3D12 can be restored by changing `GxApi` back to `D3D12`, or by copying the
matching timestamped backup over `Config.wtf`. Restore only after a newer
kernel/Mesa/VKD3D stack has completed real-world streaming validation.
