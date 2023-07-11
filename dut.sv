module dut (
    input s_aclk
   ,input s_aresetn
   ,input [0:0]s_axi_awid
   ,input [31:0]s_axi_awaddr
   ,input [7:0]s_axi_awlen
   ,input [2:0]s_axi_awsize
   ,input [1:0]s_axi_awburst
   ,input s_axi_awvalid
   ,output s_axi_awready
   ,input [31:0]s_axi_wdata
   ,input [3:0]s_axi_wstrb
   ,input s_axi_wlast
   ,input s_axi_wvalid
   ,output s_axi_wready
   ,output [0:0]s_axi_bid
   ,output [1:0]s_axi_bresp
   ,output s_axi_bvalid
   ,input s_axi_bready
   ,input [0:0]s_axi_arid
   ,input [31:0]s_axi_araddr
   ,input [7:0]s_axi_arlen
   ,input [2:0]s_axi_arsize
   ,input [1:0]s_axi_arburst
   ,input s_axi_arvalid
   ,output s_axi_arready
   ,output [0:0]s_axi_rid
   ,output [31:0]s_axi_rdata
   ,output [1:0]s_axi_rresp
   ,output s_axi_rlast
   ,output s_axi_rvalid
   ,input s_axi_rready

    );
    
    parameter         G_INIT_FILE = "" ;
    //parameter         G_INIT_FILE = "init.hmem" ;
    

    
    blk_mem_gen #(
        .G_DATAWIDTH  (32),
        .G_MEMDEPTH  (1024),
        .G_INIT_FILE (G_INIT_FILE)
    )
    i_blk_mem_gen (
        .*
    );

    `ifdef COCOTB_SIM
    initial begin
        $dumpfile ("dut.vcd");
        $dumpvars (0, dut);
        #1;
    end
    `endif    


endmodule

