# Showcase iPhone 6s / iOS 14 HCI test

This repository contains a reproducible test kit for the iPhone 6s (iPhone8,1) HCI investigation against Amine Rostane's Showcase.

It does **not** claim that iPhone 6s compatibility is solved. The first beta changes the legacy iPhone H4 path to:
- use a longer Bluetooth-controller wake settling delay (100 ms instead of 10 ms);
- log H4 TX/RX packets and wake-device state;
- log whether the H4 transport actually attaches;
- preserve the existing Skywalk/legacy transport selection.

The goal is to turn the current "no HCI controller-ready event" failure into a reproducible transport-level result before making deeper chipset-specific changes.

Upstream: https://github.com/amineross/showcase

## Build

Run on a Mac with SSH access to the jailbroken receiver. The script downloads the pinned Showcase source, applies the patch, then uses the upstream rootless package builder.

Example:

```bash
chmod +x build_6s_test.sh
IPAD_HOST=localhost IPAD_PORT=2222 IPAD_USER=mobile IPAD_PASS=alpine ./build_6s_test.sh
```

The resulting package is produced by the upstream packaging script under `packaging/build/`.

If your Taurine device is rootful rather than rootless, do not install this package; tell me and I will prepare the rootful variant.

## Test

After installation:
1. Reboot/respring if Sileo requests it.
2. Enable Personal Hotspot on the 6s.
3. Launch Showcase.
4. Try pairing from the main iPhone.
5. If it still fails, collect:
   - `/var/mobile/Library/Showcase/logs/carplay_bt.log`
   - `/var/mobile/Library/Showcase/logs/btdaemon.log`
   - `/var/log/BTstack.log` if present.

The important new lines contain `h4_6s:` and `h4_6s TX/RX`.

Do not post logs publicly without removing device names, hotspot names and network details.
