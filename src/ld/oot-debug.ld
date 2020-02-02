/* OoT debug */
ADDRESS_START = 0x80001B30; /* where code goes in ram */
//ADDRESS_START = 0x8000B280; /* this one overwrites file name list */

Bcopy         = 0x80006F10;
DMARomToRam   = 0x80000BFC;
dec           = 0x800140E0; /* external variable */

/* important offsets
00002730    ROMOFS   where code is injected into rom
                       NOTE change to 0000BE80 to overwrite
                            file name table instead; great
                            for testing functions that don't
                            fit right away
00002148    ROMJAL   location of jal to update in rom
00000000    MMJUMP   unused in OoT
*/

/* extra compilation flags (one per line)
-DMAJORA=0     DEFINE
*/

/* note: how many bytes can safely be overwritten?
816            MAXBYTES */

INCLUDE src/ld/n64.ld
