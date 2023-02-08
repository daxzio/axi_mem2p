module dut (
     clk
    ,resetn
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
    
    parameter         G_INIT_FILE = "" ;
    //parameter         G_INIT_FILE = "init.hmem" ;
    
    input clk;
    input resetn;
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

    
    blk_mem_gen #(
        .G_MEMWIDTH  (32),
        .G_MEMDEPTH  (1024),
        .G_INIT_FILE (G_INIT_FILE)
    )
    i_blk_mem_gen (
        .s_aclk            ( clk           ),
        .s_aresetn         ( resetn        ),
        .s_axi_awid        ( s_axi_awid    ),
        .s_axi_awaddr      ( s_axi_awaddr  ),
        .s_axi_awlen       ( s_axi_awlen   ),
        .s_axi_awsize      ( s_axi_awsize  ),
        .s_axi_awburst     ( s_axi_awburst ),
        .s_axi_awvalid     ( s_axi_awvalid ),
        .s_axi_awready     ( s_axi_awready ),
        .s_axi_wdata       ( s_axi_wdata   ),
        .s_axi_wstrb       ( s_axi_wstrb   ),
        .s_axi_wlast       ( s_axi_wlast   ),
        .s_axi_wvalid      ( s_axi_wvalid  ),
        .s_axi_wready      ( s_axi_wready  ),
        .s_axi_bid         ( s_axi_bid     ),
        .s_axi_bresp       ( s_axi_bresp   ),
        .s_axi_bvalid      ( s_axi_bvalid  ),
        .s_axi_bready      ( s_axi_bready  ),
        .s_axi_arid        ( s_axi_arid    ),
        .s_axi_araddr      ( s_axi_araddr  ),
        .s_axi_arlen       ( s_axi_arlen   ),
        .s_axi_arsize      ( s_axi_arsize  ),
        .s_axi_arburst     ( s_axi_arburst ),
        .s_axi_arvalid     ( s_axi_arvalid ),
        .s_axi_arready     ( s_axi_arready ),
        .s_axi_rid         ( s_axi_rid     ),
        .s_axi_rdata       ( s_axi_rdata   ),
        .s_axi_rresp       ( s_axi_rresp   ),
        .s_axi_rlast       ( s_axi_rlast   ),
        .s_axi_rvalid      ( s_axi_rvalid  ),
        .s_axi_rready      ( s_axi_rready  )
    );

    `ifdef COCOTB_SIM
    initial begin
        $dumpfile ("dut.vcd");
        $dumpvars (0, dut);
        #1;
    end
    `endif    


endmodule

