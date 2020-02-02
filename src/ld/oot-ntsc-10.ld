/* OoT NTSC 1.0 */
ADDRESS_START = 0x80000F60; /* where code goes in ram */


Bcopy         = 0x80004DC0;
DMARomToRam   = 0x8000085C;
dec           = 0x80008490; /* external variable */

/* important offsets
00001B60    ROMOFS   where code is injected into rom
00001820    ROMJAL   location of jal to update in rom
00000000    MMJUMP   unused in OoT
*/

/* extra compilation flags (one per line)
-DMAJORA=0     DEFINE
*/

/* note: how many bytes can safely be overwritten?
832            MAXBYTES */

INCLUDE src/ld/n64.ld
