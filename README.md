# 👨‍✈️ captain

A suite of packet capture and analysis tools for FFXI targeting both Windower v4 and Ashita v3.

## Goal

Windower and Ashita are both great, but they offer different APIs for inspecting and interacting with FFXI.

- `captain` - TODO
- `backend` - A "cross-platform" set of functions that can be used in both Windower and Ashita.

## Instructions

### Windower

- Download and place in `<Ashita folder>\addons`
- Either:
  - Add to `scripts/init.txt` to auto-load when you log in
  - Load on demand with `//lua load captain`

### Ashita

- Download and place in `<Windower folder>\addons\`
- Either:
  - Add to `scripts/Default.txt` to auto-load when you log in
  - Load on demand with `/addon load captain`

### General

- To start a capture press: `CTRL + ALT + C`
- To end a capture press: `CTRL + ALT + V`

### Development

The easiest way to develop and test for both Windower and Ashita is to set up a _symbolic link_ to your development folder in their addons directories.

For example:
```
cd C:\ffxi\Ashita\addons
mklink /D captain C:\ffxi\captain
```
```
cd C:\ffxi\Windower\addons
mklink /D captain C:\ffxi\captain
```

Then you'll be able to work in `C:\ffxi\captain` and have your changes immediately available to Windower and Ashita.

**NOTE:** Certain operations do not work with symbolic links, such as creating new directories. If your client freezes, it's likely that.

## Based on & made possible by
- `Packeteer` by atom0s
- `capture` by ibm2431
- TODO
