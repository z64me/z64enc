/****************************************************
 * <z64.me> put.c - patch roms, create cloudpatches *
 ****************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static
enum
{
	ROM
	, CLOUDPATCH
} mode;

static
void
size_test(FILE *of, unsigned int ofs)
{
	unsigned int of_sz;
	
	fseek(of, 0, SEEK_END);
	of_sz = ftell(of);
	
	if (ofs > of_sz)
	{
		fprintf(stderr, "offset 0x%X exceeds rom size 0x%X", ofs, of_sz);
		exit(EXIT_FAILURE);
	}
}

static
void
putbyte(int byte, FILE *of)
{
	if (mode == ROM)
		fputc(byte, of);
	
	else
		fprintf(of, "%02X", byte & 0xFF);
}

static
void
seek(FILE *of, unsigned int ofs)
{
	if (mode == ROM)
	{
		/* make sure offset does not exceed rom size */
		size_test(of, ofs);
	
		/* advance to offset within rom */
		fseek(of, ofs, SEEK_SET);
	}
	
	else
	{
		fprintf(of, "0x%X,", ofs);
	}
}

static
unsigned int
str2hex(char *str)
{
	unsigned int offset;
	
	/* get offset */
	if (sscanf(str, "%X", &offset) != 1)
	{
		fprintf(stderr, "failed to read hexadecimal offset '%s'\n", str);
		exit(EXIT_FAILURE);
	}
	
	return offset;
}

static
int
hilo(FILE *of, unsigned int lo, unsigned int ptr)
{
	if (ptr & 0x8000)
		ptr += 0x10000;
	
	putbyte(ptr >> 24, of);
	putbyte(ptr >> 16, of);
	
	/* advance to offset within rom */
	seek(of, lo);
	
	putbyte(ptr >> 8, of);
	putbyte(ptr, of);
	
	return 0;
}

static
int
jump(FILE *of, unsigned int ptr)
{
	ptr /= 4;
	ptr &= 0x03FFFFFF;
	ptr |= 0x08000000;
	
	putbyte(ptr >> 24, of);
	putbyte(ptr >> 16, of);
	putbyte(ptr >> 8, of);
	putbyte(ptr, of);
	
	/* delay slot: nop */
	for (ptr = 0; ptr < 4; ++ptr)
		putbyte(0, of);
	
	return 0;
}

static
int
jal(FILE *of, unsigned int ptr)
{
	ptr /= 4;
	ptr &= 0x03FFFFFF;
	ptr |= 0x0C000000;
	
	putbyte(ptr >> 24, of);
	putbyte(ptr >> 16, of);
	putbyte(ptr >> 8, of);
	putbyte(ptr, of);
	
	return 0;
}

static
int
bytes(FILE *of, char *str)
{
	char buf[3] = {0};
	int v;
	
	/* confirm number of characters is even */
	if (strlen(str)&1)
	{
		fprintf(stderr, "invalid byte string: uneven number of characters\n");
		return -1;
	}
	
	/* confirm all characters are valid */
	if (strcspn(str, "0123456789ABCDEFabcdef"))
	{
		fprintf(stderr, "invalid byte string: contains non-hex characters\n");
		return -1;
	}
	
	/* convert every byte to an integer and write into rom */
	while (*str)
	{
		memcpy(buf, str, 2);
		sscanf(buf, "%X", &v);
		putbyte(v, of);
		str += 2;
	}
	
	return 0;
}

static
int
file(FILE *of, char *fn)
{
	FILE *fp;
	unsigned char *raw;
	unsigned int sz;
	
	/* open for reading */
	fp = fopen(fn, "rb");
	if (!fp)
	{
		fprintf(stderr, "failed to open '%s' for reading\n", fn);
		return -1;
	}
	
	/* get size */
	fseek(fp, 0, SEEK_END);
	sz = ftell(fp);
	if (!sz)
	{
		fprintf(stderr, "size of file '%s' == 0\n", fn);
		return -1;
	}
	
	/* allocate memory to hold file */
	raw = malloc(sz);
	if (!raw)
	{
		fprintf(stderr, "memory error\n");
		return -1;
	}
	
	/* read file */
	fseek(fp, 0, SEEK_SET);
	if (fread(raw, 1, sz, fp) != sz)
	{
		fprintf(stderr, "error reading '%s'\n", fn);
		return -1;
	}
	
	if (mode == ROM)
	{
		/* write into rom */
		if (fwrite(raw, 1, sz, of) != sz)
		{
			fprintf(stderr, "error writing '%s' into rom\n", fn);
			return -1;
		}
	}
	
	else
	{
		unsigned int i;
		for (i = 0; i < sz; ++i)
			putbyte(raw[i], of);
	}
	
	/* cleanup */
	free(raw);
	fclose(fp);
	return 0;	
}

int
main(int argc, char *argv[])
{
	FILE *of;
	unsigned int offset;
	int rv;
	
	if (argc < 5)
	{
		fprintf(
			stderr,
			"invalid arguments; args: put target --type 0xOffset data\n"
			"target can either be a rom, or a .txt for cloudpatch\n"
			"valid types: --file, --bytes, --hilo, --jal, --jump\n"
			"hilo note: must provide 0xHi 0xLo instead of 0xOffset, with space\n"
			"jump: must provide 0xFrom 0xTo instead of 0xOffset, with space\n"
		);
		return -1;
	}
	
	/* open cloudpatch in append mode */
	if (strstr(argv[1], ".txt"))
	{
		of = fopen(argv[1], "a");
		mode = CLOUDPATCH;
	}
	
	/* open of for reading and writing */
	else
	{
		of = fopen(argv[1], "rb+");
		mode = ROM;
	}
	
	if (!of)
	{
		fprintf(stderr, "could not open '%s'\n", argv[1]);
		return -1;
	}
	
	/* get offset */
	offset = str2hex(argv[3]);
	
	/* advance to offset within of */
	seek(of, offset);
	
	/* types */
	switch (argv[2][2])
	{
		/* file */
		case 'f':
			rv = file(of, argv[4]);
			break;
		
		/* bytes */
		case 'b':
			rv = bytes(of, argv[4]);
			break;
		
		/* hilo */
		case 'h':
			rv = hilo(of, str2hex(argv[4]), str2hex(argv[5]));
			break;
		
		/* jal */
		case 'j':
			/* jump */
			if (argv[2][3] == 'u')
				rv = jump(of, str2hex(argv[4]));
			/* jal */
			else
				rv = jal(of, str2hex(argv[4]));
			break;
		
		/* unknown */
		default:
			fprintf(stderr, "unknown type argument '%s'\n", argv[2]);
			rv = -1;
			break;
	}
	
	/* something went wrong */
	if (rv)
		return rv;
	
	/* add trailing newline, for consecutive calls */
	if (mode == CLOUDPATCH)
		fprintf(of, "\n");
	
	/* success */
	fclose(of);
	return 0;
}
