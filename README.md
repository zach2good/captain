# 👨‍✈️ captain

A suite of packet capture and analysis tools for FFXI targeting both Windower v4 and Ashita v3.

## Goal

Windower and Ashita are both great, but they offer different APIs for inspecting and interacting with FFXI.

- `captain` - TODO
- `backend` - A "cross-platform" set of functions that can be used in both Windower and Ashita.

## Instructions

### Windower

- Download and place in `<Windower folder>/addons`
- Add to `scripts/init.txt` to auto-load when you log in
- Load on demand with `//lua load captain`
- Unload with `//lua unload captain`

### Ashita

- Download and place in `<Ashita folder>/addons`
- Add to `scripts/Default.txt` to auto-load when you log in
- Load on demand with `/addon load captain`
- Unload with `/addon unload captain`

### General

- (TODO) To start a capture press: `CTRL + ALT + C`
- (TODO) To end a capture press: `CTRL + ALT + V`

### Development

- TODO
- NOTE: Symlinks appear to not work

## Based on & made possible by
- [Windower](https://www.windower.net/)
- [Ashita](https://ashitaxi.com/)
- `Packeteer` by atom0s
- `capture` by ibm2431
- `PacketViewer` by Arcon
