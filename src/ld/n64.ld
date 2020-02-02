/* name of main function */
ENTRY_POINT = main;

/* Libaries here -- add or remove as needed */
SEARCH_DIR( lib )

/* This script is for MIPS */
OUTPUT_ARCH( mips )
OUTPUT_FORMAT( "elf32-bigmips", "elf32-bigmips", "elf32-littlemips" )

/* Entrypoint is function `n64start` */
ENTRY( ENTRY_POINT )


SECTIONS
{
	/* Program run address */
	. = ADDRESS_START;

	/* Machine code */
	.text ALIGN( 4 ):
	{
		/* Pad with NULL */
		FILL( 0 );

		/* Address to start of text section */
		__text_start = . ;

		/* Data goes here */
		*(.text)
		
		/* Address to end of text section */
		. = ALIGN( 8 );
		__text_end = . ;
	}
	
	/* Initialized data */
        .data ALIGN( 8 ): 
	{ 
		/* Pad with NULL */
		FILL( 0 );
		
		/* Address to start of data section */
		__data_start = . ;
		
		/* Data goes here*/
		*(.data);
		
		/* Data pointer */
		. = ALIGN( 8 );
		_gp = . ;
         	*(.sdata)
		
		/* Address to end of data section */
		__data_end = . ;
	}
	
	/* Read-only data */
	.rodata ALIGN( 8 ):
	{
		/* Pad with NULL */
		FILL( 0 );
		
		/* Address to start of rodata section */
		__rodata_start = . ;
		
		/* Data goes here*/
		*(.rodata);
		
		/* Address to end of rodata section */
		__rodata_end = . ;
	}
	
	/* Memory initialized to zero */
        .bss ALIGN( 8 ): 
	{
		/* Address to start of BSS section */
		__bss_start = . ;
			
		/* BSS data */
		*(.bss)
		*(.sbss)
		
		/* Address to end of BSS section */
		__bss_end = . ;
	}
	
	/* End of our memory use */
	. = ALIGN( 8 );
	end = .;
}
