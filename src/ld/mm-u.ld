/* MM (U) */
ADDRESS_START = 0x80080E30; /* where code goes in ram */


Bcopy         = 0x800912C0;
DMARomToRam   = 0x80080790;
dec           = 0x8009BA10; /* external variable */

/* important offsets
00001E30    ROMOFS   where code is injected into rom
00001B48    ROMJAL   location of jal to update in rom
00002178    MMJUMP   see makefile for details
*/

/* extra compilation flags (one per line)
-DMAJORA=1     DEFINE
*/

/* note: how many bytes can safely be overwritten?
840            MAXBYTES */

INCLUDE src/ld/n64.ld
