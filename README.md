# z64enc

`z64enc` is a collection of patches for customizing OoT and MM's compression codec. The goal of this project is to provide options for Zelda mods that contain too much content to fit in 32 MB when using the game's default codec. `z64enc` was inspired by [`spinout182's z-filenew`](http://www.spinout182.com/?a=z&p=zfsnew).

## Credits

**z64.me** - Programming

**CrookedPoe** - Finding functions, Ghidra magic, hardware testing

**Mikau6** - N64 and Wii VC hardware testing, comparison footage

## Codec comparison chart

| Codec         | Load time vs Yaz | Savings over Yaz (OoT NTSC 1.0) |
| ------------- | ---------------- | ------------------------------- |
| Yaz (default) | 1.00 x           | 0.00                            |
| UCL           | 2.27 x           | 2.35 MB                         |

## How to use

First, you need to compress your rom using [`zzrtl`](http://www.z64.me/tools/zzrtl).

Then, from this repo's `patch` folder, select the same codec you used with `zzrtl`. Find the appropriate patch for your rom. You can apply this patch to your rom using [CloudMax's online patcher](https://cloudmodding.com/app/rompatcher).

Alternatively, applying the patch can be part of your `zzrtl` build script, like so:

```C
rom.cloudpatch(0, "path/to/patch.txt");
```

It also integrates into `zzrtl` using the `--cloudpatch` and `--compress` arguments, if you want a command line solution. Here's an example of compressing and patching Majora's Mask (U) with the UCL codec (if you want a cache, remove `--nocache`):

```bash
zzrtl --nocache --compress "if='mmudec.z64' of='mmu-ucl.z64' mb='32' codec='ucl' cloudpatch='mm-u_z64enc_ucl.txt' dma='0x1A500,0x620' compress='10-14,23,24,31-END' NOcompress='1127' rearchive='15-20,22'"
```

## Codec comparison GIF

`TODO` put Mikau6's OoT footage side-by-side, comparing Yaz/UCL load times on both N64 and Wii VC

## Building from source, creating new codecs

If you're interested in this kind of thing, chances are you are already talented enough to do this without instructions. The only prerequisite other than that is [`glankk/n64`](https://github.com/glankk/n64).

If you manage to fit a codec into the game with savings like UCL and speed like Yaz, or at least get UCL running faster, please send a pull request.

