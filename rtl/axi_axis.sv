module axi_axis #(
      integer G_AXI_DATAWIDTH  = 32
    , integer G_MEMDEPTH       = 1024
    , integer G_INIT_FILE      = ""
    , integer G_ID_WIDTH       = 4
    , integer G_AXIS_DATAWIDTH = 32
    , integer G_ADDRWIDTH      = $clog2(G_MEMDEPTH)
    , integer G_WSTRB          = ((G_AXI_DATAWIDTH - 1) / 8) + 1
    , integer G_WEWIDTH        = ((G_AXIS_DATAWIDTH - 1) / 8) + 1
    , integer G_AXI_PACK       = (G_AXIS_DATAWIDTH + 31) / G_AXI_DATAWIDTH
    //, integer G_ZZ  = 32*G_AXI_PACK
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
    , input [G_AXI_DATAWIDTH-1:0] s_axi_wdata
    , input [G_WSTRB-1:0] s_axi_wstrb
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
    , output [G_AXI_DATAWIDTH-1:0] s_axi_rdata
    , output [1:0] s_axi_rresp
    , output s_axi_rlast
    , output s_axi_rvalid
    , input s_axi_rready
    , input m_aclk
    , input m_aresetn
    , output [G_AXIS_DATAWIDTH-1:0] m_axi_tdata
    , output m_axi_tvalid
    , output m_axi_tlast
    , input m_axi_tready
);


    logic [     G_ADDRWIDTH-1:0] w_axi_raddr;
    logic [     G_ADDRWIDTH-1:0] f_axi_raddr;
    logic [     G_ADDRWIDTH-1:0] w_axi_waddr;
    logic [     G_ADDRWIDTH-1:0] w_waddr;
    logic [ G_AXI_DATAWIDTH-1:0] w_axi_rdata;
    logic [G_AXIS_DATAWIDTH-1:0] w_rdata;
    logic [(G_AXI_DATAWIDTH*G_AXI_PACK)-1:0] w_rdata_expand;
    logic [ G_AXI_DATAWIDTH-1:0] w_axi_wdata;
    logic [ (G_AXI_DATAWIDTH*G_AXI_PACK)-1:0] w_wdata;
    logic [         G_WSTRB-1:0] w_wstrb;
    logic                        w_axi_rd;
    logic                        w_wr;
    logic [  (G_AXI_PACK*4)-1:0] w_wea;
    logic                        f_rvalid;

    localparam logic [1:0] STATE_IDLE = 2'd0, STATE_RDY = 2'd1, STATE_LAST = 2'd2, STATE_DATA_READ = 2'd3;

    logic [2:0] f_axis_state = STATE_IDLE, d_axis_state;
    logic [     G_ADDRWIDTH-1:0] f_axis_raddr;
    logic [     G_ADDRWIDTH-1:0] d_axis_raddr;
    logic [G_AXIS_DATAWIDTH-1:0] f_axis_rdata;
    logic [G_AXIS_DATAWIDTH-1:0] d_axis_rdata;
    logic                        f_axis_rd;
    logic                        d_axis_rd;
    logic                        f_axis_tvalid;
    logic                        d_axis_tvalid;
    logic                        f_axis_tlast;
    logic                        d_axis_tlast;
    logic [                 7:0] f_axis_cnt;
    logic [                 7:0] d_axis_cnt;
    logic                        f_thres;
    logic                        d_thres;

    logic [     G_ADDRWIDTH-1:0] w_raddr;
    logic                        w_rd;

    logic [7:0]                  f_axi_frame_length = 32;
//     logic                        f_axi_enable = 1;

    axi_config #(
        .ADDR_WIDTH(G_ADDRWIDTH)
        , .DATA_WIDTH(G_AXI_DATAWIDTH)
        , .ID_WIDTH(G_ID_WIDTH)
        , .SINGLE_ADDR(1)
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
        , .rd            (w_axi_rd)
        , .raddr         (w_axi_raddr)
        , .rdata         (w_axi_rdata)
        , .rvalid        (f_rvalid)
        , .wr            (w_wr)
        , .waddr         (w_axi_waddr)
        , .wdata         (w_axi_wdata)
        , .wstrb         (w_wstrb)
    );


    always @(posedge s_aclk) begin
        f_rvalid <= w_axi_rd;
    end


    always @(posedge s_aclk) begin : p_clk_reset_axis
        if (0 == s_aresetn) begin
            f_axis_state <= STATE_IDLE;
            f_axis_raddr <= 0;
            f_axis_rdata <= 0;
            f_axis_rd <= 0;
            f_axis_tvalid <= 0;
            f_axis_tlast <= 0;
            f_axis_cnt <= 0;
            f_thres <= 0;
        end else begin
            f_axis_state <= d_axis_state;
            f_axis_raddr <= d_axis_raddr;
            f_axis_rdata <= d_axis_rdata;
            f_axis_rd    <= d_axis_rd   ;
            f_axis_tvalid<= d_axis_tvalid;
            f_axis_tlast<= d_axis_tlast;
            f_axis_cnt<= d_axis_cnt;
            f_thres <= d_thres;
        end
        f_axi_raddr <= w_axi_raddr;
    end

    always @* begin
        d_axis_state = f_axis_state;
        d_axis_raddr = f_axis_raddr;
        d_axis_rdata = w_rdata;
        d_axis_rd    = 0 ;
        d_axis_tvalid = f_axis_tvalid;
        d_axis_tlast = f_axis_tlast;
        d_axis_cnt = f_axis_cnt;
        d_thres    = 1 ;
        case (f_axis_state)
            STATE_IDLE: begin
                d_axis_tvalid = 0;
                d_axis_tlast  = 0;
                if (f_thres && m_axi_tready) begin
                    d_axis_state = STATE_RDY;
                    //d_axis_raddr = 0;
                    d_axis_cnt = 0;
                    d_axis_rd = 1;
                end
            end
            STATE_RDY: begin
                if (m_axi_tready) begin
                    d_axis_tvalid = 1;
                    d_axis_rd = 1;
                    if ((f_axi_frame_length / G_AXI_PACK) - 1 == f_axis_cnt) begin
                        d_axis_state = STATE_LAST;
                        d_axis_tlast = 1;
                    end else begin
                        d_axis_raddr = f_axis_raddr + 1;
                        d_axis_cnt   = f_axis_cnt + 1;
                    end
                end
            end
            STATE_LAST: begin
                if (m_axi_tready) begin
                    d_axis_tvalid = 0;
                    d_axis_tlast  = 0;
                    d_axis_state  = STATE_IDLE;
                    d_axis_raddr = f_axis_raddr + 1;
                    //d_axis_raddr  = 0;
                end
            end
            default: d_axis_state = STATE_IDLE;
        endcase
    end

    assign m_axi_tdata = d_axis_rdata;
    assign m_axi_tvalid = f_axis_tvalid;
    assign m_axi_tlast = f_axis_tlast;

    assign w_raddr = w_axi_rd ? w_axi_raddr[(G_AXI_PACK+1)+:$bits(w_axi_raddr)-G_AXI_PACK-1] : f_axis_raddr;
    assign w_rd = w_axi_rd | d_axis_rd;
    //assign w_axi_rdata = ~f_axi_raddr[G_AXI_PACK] ? w_rdata_expand[0+:32] : w_rdata_expand[32+:32];
    
    generate
        if (G_AXI_PACK <= 1) begin
            assign w_axi_rdata = w_rdata_expand[0+:G_AXI_DATAWIDTH];
        end else begin
            assign w_axi_rdata = w_rdata_expand[(f_axi_raddr[G_AXI_PACK+:G_AXI_PACK-1]*G_AXI_DATAWIDTH)+:G_AXI_DATAWIDTH];
        end
    endgenerate

    genvar i;

    generate
        for (i = 0; i < G_AXI_PACK; i = i + 1) begin
            assign w_wdata[(G_AXI_DATAWIDTH*i)+:G_AXI_DATAWIDTH] = w_axi_wdata[0+:G_AXI_DATAWIDTH];
            //assign w_wea[(4*i)+:4] = w_axi_waddr[2] == i ? w_wstrb : 4'h0;
            assign w_wea[(4*i)+:4] = w_axi_waddr[G_AXI_PACK] == i ? 4'hf : 4'h0;
        end
    endgenerate
    assign w_waddr = w_axi_waddr[(G_AXI_PACK+1)+:$bits(w_axi_waddr)-G_AXI_PACK-1];

    blockmem_2p_wrapper #(
          .G_DATAWIDTH(G_AXIS_DATAWIDTH)
        , .G_MEMDEPTH (G_MEMDEPTH)
        , .G_BWENABLE (1)
        , .G_INIT_FILE(G_INIT_FILE)
    ) i_blockmem_2p (
          .clka (s_aclk)
        , .ena  (w_wr)
        , .wea  (w_wea[0+:G_WEWIDTH])
        , .addra(w_waddr)
        , .dina (w_wdata[0+:G_AXIS_DATAWIDTH])
        , .clkb (s_aclk)
        , .enb  (w_rd)
        , .addrb(w_raddr)
        , .doutb(w_rdata)
    );
    assign w_rdata_expand = w_rdata;



endmodule

