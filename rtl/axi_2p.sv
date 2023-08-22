module axi_2p #(
      integer G_DATAWIDTH = 32
    , integer G_MEMDEPTH  = 1024
    , integer G_INIT_FILE = ""
    , integer G_ID_WIDTH  = 4
    , integer G_ADDRWIDTH = $clog2(G_MEMDEPTH)
    , integer G_WEWIDTH   = ((G_DATAWIDTH - 1) / 8) + 1
) (
    input s_aclk
    , input s_aresetn
    , input [G_ID_WIDTH-1:0] s_axi_awid
    , input [G_ADDRWIDTH-1:0] s_axi_awaddr
    , input [7:0] s_axi_awlen
    , input [2:0] s_axi_awsize
    , input [1:0] s_axi_awburst
    , input s_axi_awvalid
    , output s_axi_awready
    , input [G_DATAWIDTH-1:0] s_axi_wdata
    , input [G_WEWIDTH-1:0] s_axi_wstrb
    , input s_axi_wlast
    , input s_axi_wvalid
    , output s_axi_wready
    , output [G_ID_WIDTH-1:0] s_axi_bid
    , output [1:0] s_axi_bresp
    , output s_axi_bvalid
    , input s_axi_bready
    , input [G_ID_WIDTH-1:0] s_axi_arid
    , input [G_ADDRWIDTH-1:0] s_axi_araddr
    , input [7:0] s_axi_arlen
    , input [2:0] s_axi_arsize
    , input [1:0] s_axi_arburst
    , input s_axi_arvalid
    , output s_axi_arready
    , output [G_ID_WIDTH-1:0] s_axi_rid
    , output [G_DATAWIDTH-1:0] s_axi_rdata
    , output [1:0] s_axi_rresp
    , output s_axi_rlast
    , output s_axi_rvalid
    , input s_axi_rready
);


    logic [G_ADDRWIDTH-1:0] w_raddr;
    logic [G_ADDRWIDTH-1:0] w_waddr;
    logic [G_DATAWIDTH-1:0] w_rdata;
    logic [G_DATAWIDTH-1:0] w_wdata;
    logic [  G_WEWIDTH-1:0] w_wstrb;
    logic                   w_rd;
    logic                   w_wr;
    logic [G_WEWIDTH-1:0] w_wea;
    logic [G_WEWIDTH-1:0] w_web;
    logic                 f_rvalid;

    axi_config #(
        .ADDR_WIDTH(G_ADDRWIDTH)
        , .DATA_WIDTH(G_DATAWIDTH)
        , .ID_WIDTH(G_ID_WIDTH)
        , .SINGLE_ADDR(0)
        , .REG_DATA(0)
    ) i_axi_config (
        .*
        , .clk           (s_aclk)
        , .rst           (~s_aresetn)
        , .s_axi_awlock  (1'd0)
        , .s_axi_awcache (4'd0)
        , .s_axi_awprot  (3'd0)
        , .s_axi_awqos   (4'd0)
        , .s_axi_awregion(4'd0)
        , .s_axi_awuser  (1'd0)
        , .s_axi_wuser   (1'd0)
        , .s_axi_buser   ()
        , .s_axi_arlock  (1'd0)
        , .s_axi_arcache (4'd0)
        , .s_axi_arprot  (3'd0)
        , .s_axi_arqos   (4'd0)
        , .s_axi_arregion(4'd0)
        , .s_axi_aruser  (1'd0)
        , .s_axi_ruser   ()
        , .rd            (w_rd)
        , .raddr         (w_raddr)
        , .rdata         (w_rdata)
        , .rvalid        (f_rvalid)
        , .wr            (w_wr)
        , .waddr         (w_waddr)
        , .wdata         (w_wdata)
        , .wstrb         (w_wstrb)
    );


    assign w_wea = w_wstrb;

    always @(posedge s_aclk) begin
        f_rvalid <= w_rd;
    end

    blockmem_2p_wrapper #(
          .G_DATAWIDTH(G_DATAWIDTH)
        , .G_MEMDEPTH (G_MEMDEPTH)
        , .G_BWENABLE (1)
        , .G_INIT_FILE(G_INIT_FILE)
    ) i_blockmem_2p (
          .clka (s_aclk)
        , .ena  (w_wr)
        , .wea  (w_wea)
        , .addra(w_waddr)
        , .dina (w_wdata)
        , .clkb (s_aclk)
        , .enb  (w_rd)
        , .addrb(w_raddr)
        , .doutb(w_rdata)
    );
endmodule

