module blockmem_2p_wrapper (
     clka
    ,ena
    ,wea
    ,addra
    ,dina
    ,clkb
    ,enb
    ,addrb
    ,doutb
    );
    parameter  integer G_DATAWIDTH  = 32;
    parameter  integer G_MEMDEPTH  = 1024;
    parameter          G_INIT_FILE = "" ;
    parameter  integer G_USEIP     = 0 ;
    localparam integer G_ADDRWIDTH = $clog2(G_MEMDEPTH);
    localparam integer G_WEWIDTH   = ((G_DATAWIDTH-1)/8)+1;

    input                    clka;
    input                    ena;
    input  [G_WEWIDTH-1:0]   wea;
    input  [G_ADDRWIDTH-1:0] addra;
    input  [G_DATAWIDTH-1:0]  dina;
    input                    clkb;
    input                    enb;
    input  [G_ADDRWIDTH-1:0] addrb;
    output [G_DATAWIDTH-1:0]  doutb;


    if (0 == G_USEIP) begin
        blockmem_2p #(
            .G_DATAWIDTH (G_DATAWIDTH),
            .G_MEMDEPTH  (G_MEMDEPTH),
            .G_INIT_FILE (G_INIT_FILE)
        )
        i_blockmem_2p (
            .*
        );
    end else begin
        blockmem_2p #(
            .G_DATAWIDTH (G_DATAWIDTH),
            .G_MEMDEPTH  (G_MEMDEPTH),
            .G_INIT_FILE (G_INIT_FILE)
        )
        i_blockmem_2p (
            .*
        );
    end

endmodule

