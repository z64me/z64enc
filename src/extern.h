/* <z64.me> extern.h - contains prototypes for in-game functions */

#ifndef Z64ENC_EXTERN_H_INCLUDED

#define Z64ENC_EXTERN_H_INCLUDED

void Bcopy(void *src, void *dst, unsigned int n);

void DMARomToRam(unsigned rom_src, void *ram_dst, unsigned sz);

#endif /* Z64ENC_EXTERN_H_INCLUDED */
