module blk_mem_gen (
     s_aclk
    ,s_aresetn
    ,s_axi_awid
    ,s_axi_awaddr
    ,s_axi_awlen
    ,s_axi_awsize
    ,s_axi_awburst
    ,s_axi_awvalid
    ,s_axi_awready
    ,s_axi_wdata
    ,s_axi_wstrb
    ,s_axi_wlast
    ,s_axi_wvalid
    ,s_axi_wready
    ,s_axi_bid
    ,s_axi_bresp
    ,s_axi_bvalid
    ,s_axi_bready
    ,s_axi_arid
    ,s_axi_araddr
    ,s_axi_arlen
    ,s_axi_arsize
    ,s_axi_arburst
    ,s_axi_arvalid
    ,s_axi_arready
    ,s_axi_rid
    ,s_axi_rdata
    ,s_axi_rresp
    ,s_axi_rlast
    ,s_axi_rvalid
    ,s_axi_rready
    );
    
    parameter  integer G_MEMWIDTH = 32;
    parameter  integer G_MEMDEPTH = 1024;
    parameter          G_INIT_FILE = "" ;
    localparam integer G_ADDRWIDTH = $clog2(G_MEMDEPTH);
    localparam integer G_WEWIDTH = ((G_MEMWIDTH-1)/8)+1;

    input s_aclk;
    input s_aresetn;
    input [0:0]s_axi_awid;
    input [31:0]s_axi_awaddr;
    input [7:0]s_axi_awlen;
    input [2:0]s_axi_awsize;
    input [1:0]s_axi_awburst;
    input s_axi_awvalid;
    output s_axi_awready;
    input [31:0]s_axi_wdata;
    input [3:0]s_axi_wstrb;
    input s_axi_wlast;
    input s_axi_wvalid;
    output s_axi_wready;
    output [0:0]s_axi_bid;
    output [1:0]s_axi_bresp;
    output s_axi_bvalid;
    input s_axi_bready;
    input [0:0]s_axi_arid;
    input [31:0]s_axi_araddr;
    input [7:0]s_axi_arlen;
    input [2:0]s_axi_arsize;
    input [1:0]s_axi_arburst;
    input s_axi_arvalid;
    output s_axi_arready;
    output [0:0]s_axi_rid;
    output [31:0]s_axi_rdata;
    output [1:0]s_axi_rresp;
    output s_axi_rlast;
    output s_axi_rvalid;
    input s_axi_rready;

    reg f_axi_awready;
    reg d_axi_awready;
    reg f_axi_wready;
    reg d_axi_wready;
    reg f_axi_bid;
    reg d_axi_bid;
    reg f_axi_bvalid;
    reg d_axi_bvalid;
    reg f_axi_arready;
    reg d_axi_arready;
    reg f_axi_rid;
    reg d_axi_rid;
    reg f_axi_rlast;
    reg d_axi_rlast;
    reg f_axi_rvalid;
    reg d_axi_rvalid;
    reg [7:0] f_axi_arlen;
    reg [7:0] d_axi_arlen;
    
    localparam [1:0]
        WIDLE  = 2'b00,
        WRITE0 = 2'b01, 
        WRITE1 = 2'b10,    
        WRITE2 = 2'b11;    
    
    localparam [1:0]
        RIDLE  = 2'b00,
        READ0  = 2'b01, 
        READ1  = 2'b10,   
        READ2  = 2'b11;   
    
    reg [1:0] f_axi_write_state;
    reg [1:0] d_axi_write_state;
    reg [1:0] f_axi_read_state;
    reg [1:0] d_axi_read_state;
    
    reg [G_ADDRWIDTH-1:0]  f_addra ;
    reg [G_ADDRWIDTH-1:0]  f_addrb ;
    reg [G_MEMWIDTH-1:0]   f_doutb ;
    reg [G_ADDRWIDTH-1:0]  d_addra ;
    reg [G_ADDRWIDTH-1:0]  d_addrb ;

    wire                   w_ena   ;
    wire [G_WEWIDTH-1:0]   w_wea   ;
    wire [G_WEWIDTH-1:0]   w_web   ;
    wire [G_MEMWIDTH-1:0]  w_doutb ;
    wire [G_MEMWIDTH-1:0]  w_dina  ;
    wire                   w_enb   ;
    wire [G_ADDRWIDTH-1:0] w_addrb ;
    
    blockmem_2p #(
        .G_MEMWIDTH  (G_MEMWIDTH),
        .G_MEMDEPTH  (G_MEMDEPTH),
        .G_INIT_FILE (G_INIT_FILE)
    )
    i_blockmem_2p (
        .clka       ( s_aclk  ),
        .ena        ( w_ena   ),
        .wea        ( w_wea   ),
        .addra      ( f_addra ),
        .dina       ( w_dina  ),
        .clkb       ( s_aclk  ),
        .enb        ( w_enb   ),
        .addrb      ( w_addrb ),
        .doutb      ( w_doutb )
    );

//     blockmem_dp_wrapper #(
//         .G_MEMWIDTH  (G_MEMWIDTH),
//         .G_MEMDEPTH  (G_MEMDEPTH),
//         .G_INIT_FILE (G_INIT_FILE)
//     )
//     i_blockmem_dp (
//         .clka       ( s_aclk  ),
//         .ena        ( w_ena   ),
//         .wea        ( w_wea   ),
//         .addra      ( f_addra ),
//         .dina       ( w_dina  ),
//         .douta      (  ),
//         .clkb       ( s_aclk  ),
//         .enb        ( w_enb   ),
//         .web        ( w_web   ),
//         .addrb      ( w_addrb ),
//         .dinb       ( w_dinb  ),
//         .doutb      ( w_doutb )
//     );

    assign  w_ena   = f_axi_wready;
    assign  w_wea   = {G_WEWIDTH{1'b1}};
    assign  w_dina  = s_axi_wdata[G_MEMWIDTH-1:0];
    assign  w_enb   = d_axi_rvalid;
    assign  w_web   = {G_WEWIDTH{1'b1}};
    assign  w_addrb = d_addrb;
    
    always @(posedge s_aclk) begin : p_clk_reset
        if (0 == s_aresetn) begin
            f_axi_write_state <= WIDLE;
            f_axi_read_state  <= RIDLE;
            f_axi_awready     <= 0;
            f_axi_wready      <= 0;
            f_axi_bid         <= 0;
            f_axi_bvalid      <= 0;
            f_axi_arready     <= 0;
            f_axi_rid         <= 0;
            f_axi_rlast       <= 0;
            f_axi_rvalid      <= 0;
            f_axi_arlen       <= 0;
            f_addra           <= 0;
            f_addrb           <= 0;
        end else begin
            f_axi_write_state <= d_axi_write_state;
            f_axi_read_state  <= d_axi_read_state;
            f_axi_awready     <= d_axi_awready;
            f_axi_wready      <= d_axi_wready;
            f_axi_bid         <= d_axi_bid;
            f_axi_bvalid      <= d_axi_bvalid;
            f_axi_arready     <= d_axi_arready;
            f_axi_rid         <= d_axi_rid;
            f_axi_rlast       <= d_axi_rlast ;
            f_axi_rvalid      <= d_axi_rvalid;
            f_axi_arlen       <= d_axi_arlen;
            f_addra           <= d_addra;
            f_addrb           <= d_addrb;
        end
    end

    always @(*) begin : p_write_axi
        d_axi_write_state <= f_axi_write_state;
        d_addra           <= f_addra;
        d_axi_bid         <= f_axi_bid;
        
        d_axi_awready     <= 1;
        d_axi_wready      <= 0;
        d_axi_bvalid      <= 0;
        case(f_axi_write_state)
            WIDLE:
                if (s_axi_awvalid && f_axi_awready) begin
                    d_axi_write_state <= WRITE0;
                    d_axi_bid         <= s_axi_awid;
                    d_axi_awready     <= 0;
                    d_addra           <= s_axi_awaddr[G_ADDRWIDTH+1:2];
                    d_axi_wready      <= 1;
                end
            WRITE0: begin
                if (s_axi_wvalid) begin
                    d_axi_wready      <= 1;
                    d_addra           <= f_addra+1;
                    if (s_axi_wlast) begin
                        d_axi_write_state <= WRITE1;
                        d_axi_wready      <= 0;
                        d_addra           <= 0;
                        //d_axi_bvalid      <= s_axi_bready;
                    end
                end
            end
            WRITE1: begin
                d_axi_bvalid      <= 1;
                if (s_axi_bready && f_axi_bvalid) begin
                    d_axi_write_state <= WRITE2;
                    d_axi_bvalid      <= 0;
                end
            end
            WRITE2: begin
                d_axi_write_state <= WIDLE;
            end
        endcase;      
        
	end

    always @(*) begin : p_read_axi
        d_axi_read_state  <= f_axi_read_state;
        d_axi_arlen       <= f_axi_arlen;
        d_axi_rid         <= f_axi_rid;
        d_addrb           <= f_addrb;

        d_axi_arready     <= 1;
        d_axi_rvalid      <= 0;
        d_axi_rlast       <= 0;
        case(f_axi_read_state)
            RIDLE: begin
                if (s_axi_arvalid && f_axi_arready) begin
                    d_axi_arready     <= 0;
                    d_addrb           <= s_axi_araddr[G_ADDRWIDTH+1:2];
                    d_axi_rvalid      <= 1;
                    d_axi_rid         <= s_axi_arid;

                    if (0 == s_axi_arlen) begin
                        d_axi_rlast       <= 1 ;
                    end else begin
                        d_axi_arlen       <= s_axi_arlen;
                        d_axi_read_state  <= READ0;
                    end
                end
            end
            READ0: begin
                d_axi_rvalid      <= 1;
                if (s_axi_rready) begin
                    d_addrb           <= f_addrb+1;
                    if (f_axi_arlen <= 1 ) begin
                        d_axi_read_state  <= RIDLE;
                        d_axi_rlast       <= 1 ;
                    end else begin
                        d_axi_arlen       <= f_axi_arlen-1;
                    end
                end
            end
        endcase;      
	end

    assign s_axi_awready = f_axi_awready;
    assign s_axi_wready  = f_axi_wready;
    assign s_axi_bid = f_axi_bid;
    assign s_axi_bresp = 0;
    assign s_axi_bvalid = f_axi_bvalid;
    assign s_axi_arready = f_axi_arready;
    assign s_axi_rid = f_axi_rid;
    assign s_axi_rdata = w_doutb;
    assign s_axi_rresp = 0;
    assign s_axi_rlast = f_axi_rlast;
    assign s_axi_rvalid = f_axi_rvalid;

endmodule

