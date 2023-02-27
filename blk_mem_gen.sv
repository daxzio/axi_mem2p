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
    
    parameter  integer G_DATAWIDTH = 32;
    parameter  integer G_MEMDEPTH = 1024;
    parameter          G_INIT_FILE = "" ;
    localparam integer G_ADDRWIDTH = $clog2(G_MEMDEPTH);
    localparam integer G_WEWIDTH = ((G_DATAWIDTH-1)/8)+1;

    input s_aclk;
    input s_aresetn;
    input [0:0] s_axi_awid;
    input [31:0] s_axi_awaddr;
    input [7:0] s_axi_awlen;
    input [2:0] s_axi_awsize;
    input [1:0] s_axi_awburst;
    input s_axi_awvalid;
    output s_axi_awready;
    input [G_DATAWIDTH-1:0] s_axi_wdata;
    input [3:0] s_axi_wstrb;
    input s_axi_wlast;
    input s_axi_wvalid;
    output s_axi_wready;
    output [0:0] s_axi_bid;
    output [1:0] s_axi_bresp;
    output s_axi_bvalid;
    input s_axi_bready;
    input [0:0] s_axi_arid;
    input [31:0] s_axi_araddr;
    input [7:0] s_axi_arlen;
    input [2:0] s_axi_arsize;
    input [1:0] s_axi_arburst;
    input s_axi_arvalid;
    output s_axi_arready;
    output [0:0] s_axi_rid;
    output [G_DATAWIDTH-1:0] s_axi_rdata;
    output [1:0] s_axi_rresp;
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

    localparam bit [1:0] WIDLE = 2'b00, WRITE0 = 2'b01, WRITE1 = 2'b10, WRITE2 = 2'b11;

    always @(posedge s_aclk) begin : p_clk_write
        if (0 == s_aresetn) begin
            f_axi_write_state <= WIDLE;
            f_axi_awready     <= 0;
            f_axi_wready      <= 0;
            f_axi_bid         <= 0;
            f_axi_bvalid      <= 0;
            f_waddr           <= 0;
        end else begin
            f_axi_write_state <= d_axi_write_state;
            f_axi_awready     <= d_axi_awready;
            f_axi_wready      <= d_axi_wready;
            f_axi_bid         <= d_axi_bid;
            f_axi_bvalid      <= d_axi_bvalid;
            f_waddr           <= d_waddr;
        end
    end

    always @(*) begin : p_write_axi
        d_axi_write_state <= f_axi_write_state;
        d_axi_bid         <= f_axi_bid;

        d_axi_awready     <= 1;
        d_axi_wready      <= 0;
        d_axi_bvalid      <= 0;
        d_waddr           <= f_waddr;
        case (f_axi_write_state)
            WIDLE: begin
                d_waddr <= s_axi_awaddr;
                if (s_axi_awvalid && f_axi_awready) begin
                    d_axi_write_state <= WRITE0;
                    d_axi_bid         <= s_axi_awid;
                    d_axi_awready     <= 0;
                    d_axi_wready      <= 1;
                end
            end
            WRITE0: begin
                d_axi_wready <= 1;
                if (s_axi_wvalid) begin
                    d_waddr <= f_waddr + 4;
                    if (s_axi_wlast) begin
                        d_axi_write_state <= WRITE1;
                        d_axi_wready      <= 0;
                    end
                end
            end
            WRITE1: begin
                d_axi_bvalid <= 1;
                if (s_axi_bready && f_axi_bvalid) begin
                    d_axi_write_state <= WRITE2;
                    d_axi_bvalid      <= 0;
                end
            end
            WRITE2:  d_axi_write_state <= WIDLE;
            default: d_axi_write_state <= WIDLE;
        endcase
        ;
    end

    assign s_axi_awready = f_axi_awready;
    assign s_axi_wready = f_axi_wready;
    assign s_axi_bid = f_axi_bid;
    assign s_axi_bresp = 0;
    assign s_axi_bvalid = f_axi_bvalid;

    reg [1:0] f_axi_write_state;
    reg [1:0] d_axi_write_state;
    reg [G_ADDRWIDTH-1:0] f_waddr;
    reg [G_ADDRWIDTH-1:0] d_waddr;

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
    
    localparam bit [1:0] RIDLE = 2'b00, READ0 = 2'b01, READ1 = 2'b10, READ2 = 2'b11;
    
    reg [1:0] f_axi_read_state;
    reg [1:0] d_axi_read_state;
    reg [G_ADDRWIDTH-1:0] f_raddr;
    reg [G_ADDRWIDTH-1:0] d_raddr;
    
    always @(posedge s_aclk) begin : p_clk_read
        if (0 == s_aresetn) begin
            f_axi_read_state  <= RIDLE;
            f_axi_arready     <= 0;
            f_axi_rid         <= 0;
            f_axi_rlast       <= 0;
            f_axi_rvalid      <= 0;
            f_axi_arlen       <= 0;
            f_raddr           <= 0;
        end else begin
            f_axi_read_state  <= d_axi_read_state;
            f_axi_arready     <= d_axi_arready;
            f_axi_rid         <= d_axi_rid;
            f_axi_rlast       <= d_axi_rlast;
            f_axi_rvalid      <= d_axi_rvalid;
            f_axi_arlen       <= d_axi_arlen;
            f_raddr           <= d_raddr;
        end
    end

    always @(*) begin : p_read_axi
        d_axi_read_state <= f_axi_read_state;
        d_axi_arlen      <= f_axi_arlen;
        d_axi_rid        <= f_axi_rid;

        d_axi_arready    <= 1;
        d_axi_rvalid     <= 0;
        d_axi_rlast      <= 0;
        d_raddr          <= f_raddr;
        case (f_axi_read_state)
            RIDLE: begin
                if (s_axi_arvalid && f_axi_arready) begin
                    d_axi_arready <= 0;
                    d_axi_rid     <= s_axi_arid;
                    d_raddr       <= s_axi_araddr;

                    d_axi_rvalid  <= 1;
                    if (0 == s_axi_arlen) begin
                        d_axi_rlast      <= 1;
                        d_axi_read_state <= READ1;
                    end else begin
                        d_axi_arlen      <= s_axi_arlen;
                        d_axi_read_state <= READ0;
                    end
                end
            end
            READ0: begin
                d_axi_rvalid <= 1;
                if (s_axi_rready) begin
                    d_raddr <= f_raddr + 4;
                    if (f_axi_arlen <= 1) begin
                        d_axi_read_state <= READ1;
                        d_axi_rlast      <= 1;
                    end else begin
                        d_axi_arlen <= f_axi_arlen - 1;
                    end
                end
            end
            READ1: begin
                d_axi_rvalid <= 1;
                d_axi_rlast  <= 1;
                if (s_axi_rready) begin
                    d_axi_read_state <= RIDLE;
                    d_axi_rvalid     <= 0;
                    d_axi_rlast      <= 0;
                end
            end
            default: d_axi_read_state <= RIDLE;
        endcase
        ;
    end
    assign s_axi_arready = f_axi_arready;
    assign s_axi_rid = f_axi_rid;
    assign s_axi_rresp = 0;
    assign s_axi_rlast = f_axi_rlast;
    assign s_axi_rvalid = f_axi_rvalid;


    assign s_axi_rdata = w_doutb;

    // This sections deals with the data that in non used on the AXI side of the interface
    wire                   w_ena   ;
    wire [G_WEWIDTH-1:0]   w_wea   ;
    wire [G_WEWIDTH-1:0]   w_web   ;
    wire [G_DATAWIDTH-1:0]  w_doutb ;
    wire [G_DATAWIDTH-1:0]  w_dina  ;
    wire                   w_enb   ;
    wire [G_ADDRWIDTH-1:0] w_raddr ;
    
    
    assign  w_ena   = f_axi_wready;
    assign  w_wea   = {G_WEWIDTH{1'b1}};
    assign  w_dina  = s_axi_wdata[G_DATAWIDTH-1:0];
    assign  w_enb   = d_axi_rvalid;
    assign  w_web   = {G_WEWIDTH{1'b1}};
    assign  w_raddr = d_raddr;

    blockmem_2p_wrapper #(
        .G_DATAWIDTH (G_DATAWIDTH),
        .G_MEMDEPTH  (G_MEMDEPTH),
        .G_INIT_FILE (G_INIT_FILE)
    )
    i_blockmem_2p (
        .clka       ( s_aclk  ),
        .ena        ( w_ena   ),
        .wea        ( w_wea   ),
        .addra      ( f_waddr ),
        .dina       ( w_dina  ),
        .clkb       ( s_aclk  ),
        .enb        ( w_enb   ),
        .addrb      ( w_raddr ),
        .doutb      ( w_doutb )
    );
endmodule

