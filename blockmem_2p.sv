module blockmem_2p (
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
    parameter  integer G_DATAWIDTH = 32;
    parameter  integer G_MEMDEPTH  = 1024;
    parameter  integer G_BWENABLE = 0;
    parameter          G_INIT_FILE = "" ;
    localparam integer G_ADDRWIDTH = $clog2(G_MEMDEPTH);
    localparam integer G_PADWIDTH  = ($ceil(real'(G_DATAWIDTH) / 8) * 8);
    localparam integer G_WEWIDTH   = (((G_PADWIDTH - 1) / 8) * G_BWENABLE) + 1;
    localparam integer G_WWIDTH    = ((G_PADWIDTH - 1) / 8) + 1;
    localparam integer G_DIFFWIDTH = G_PADWIDTH - G_DATAWIDTH;


    input                    clka;
    input                    ena;
    input  [G_WEWIDTH-1:0]   wea;
    input  [G_ADDRWIDTH-1:0] addra;
    input  [G_DATAWIDTH-1:0] dina;
    input                    clkb;
    input                    enb;
    input  [G_ADDRWIDTH-1:0] addrb;
    output [G_DATAWIDTH-1:0] doutb;

    logic [G_PADWIDTH-1:0] f_ram [G_MEMDEPTH-1:0];
    //logic [G_DATAWIDTH-1:0] f_ram [G_MEMDEPTH];
    logic [G_DATAWIDTH-1:0] f_doutb = 0;

    wire   [G_WWIDTH-1:0]   w_wea;
    wire   [G_PADWIDTH-1:0] w_dina;

    assign w_wea  = G_BWENABLE ? wea : {G_WWIDTH{wea[0]}};
    generate
        if (G_DIFFWIDTH == 0)
            assign w_dina = dina;
        else
            assign w_dina = {{G_DIFFWIDTH{1'b0}}, dina};
    endgenerate    
    
    initial begin
        // synthesis translate_off
        for(integer x=0; x<G_MEMDEPTH; x=x+1) begin
            f_ram[x] = 0;
        end
        // synthesis translate_on
        if (G_INIT_FILE != "") begin
            $readmemh(G_INIT_FILE, f_ram);
        end
    end

    always @(posedge clka)
    begin
        for (integer i = 0 ; i < G_WWIDTH ; i=i+1) begin
            if (ena & w_wea[i])
                f_ram[addra][(8*i)+:8] <= w_dina[(8*i)+:8];
        end
    end

    always @(posedge clkb) begin
        if (enb)
            f_doutb <= f_ram[addrb][0+:G_DATAWIDTH];
    end
    assign doutb = f_doutb;

endmodule

