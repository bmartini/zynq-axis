
`include "axi4lite_cfg.v"
`include "axis.v"

module zedboard_axis
   (inout       [14:0]  DDR_addr,
    inout       [2:0]   DDR_ba,
    inout               DDR_cas_n,
    inout               DDR_ck_n,
    inout               DDR_ck_p,
    inout               DDR_cke,
    inout               DDR_cs_n,
    inout       [3:0]   DDR_dm,
    inout       [31:0]  DDR_dq,
    inout       [3:0]   DDR_dqs_n,
    inout       [3:0]   DDR_dqs_p,
    inout               DDR_odt,
    inout               DDR_ras_n,
    inout               DDR_reset_n,
    inout               DDR_we_n,
    inout               FIXED_IO_ddr_vrn,
    inout               FIXED_IO_ddr_vrp,
    inout       [53:0]  FIXED_IO_mio,
    inout               FIXED_IO_ps_clk,
    inout               FIXED_IO_ps_porb,
    inout               FIXED_IO_ps_srstb
);

    localparam CFG_AWIDTH       = 5;
    localparam CFG_DWIDTH       = 32;

    localparam AXI_ID_WIDTH     = 6;
    localparam AXI_LEN_WIDTH    = 4;
    localparam AXI_ADDR_WIDTH   = 32;
    localparam AXI_DATA_WIDTH   = 64;

    localparam
        CFG_AXIS_ADDR       = 0,
        CFG_AXIS_DATA       = 1,
        CFG_HP0_DST_CNT     = 2,
        CFG_HP0_SRC_CNT     = 3,
        CFG_HP0_DST_DATA    = 4,
        CFG_HP0_SRC_DATA    = 5,
        CFG_EMPTY           = 6;


    genvar i;

    wire            axi_clk;
    wire            axi_rst_n;

    wire [31:0]     axi_araddr;
    wire [2:0]      axi_arprot;
    wire            axi_arready;
    wire            axi_arvalid;
    wire [31:0]     axi_awaddr;
    wire [2:0]      axi_awprot;
    wire            axi_awready;
    wire            axi_awvalid;
    wire            axi_bready;
    wire [1:0]      axi_bresp;
    wire            axi_bvalid;
    wire [31:0]     axi_rdata;
    wire            axi_rready;
    wire [1:0]      axi_rresp;
    wire            axi_rvalid;
    wire [31:0]     axi_wdata;
    wire            axi_wready;
    wire [3:0]      axi_wstrb;
    wire            axi_wvalid;

    wire [31:0]     axi_hp0_araddr;
    wire [1:0]      axi_hp0_arburst;
    wire [3:0]      axi_hp0_arcache;
    wire [5:0]      axi_hp0_arid;
    wire [3:0]      axi_hp0_arlen;
    wire [1:0]      axi_hp0_arlock;
    wire [2:0]      axi_hp0_arprot;
    wire [3:0]      axi_hp0_arqos;
    wire            axi_hp0_arready;
    wire [2:0]      axi_hp0_arsize;
    wire            axi_hp0_arvalid;
    wire [31:0]     axi_hp0_awaddr;
    wire [1:0]      axi_hp0_awburst;
    wire [3:0]      axi_hp0_awcache;
    wire [5:0]      axi_hp0_awid;
    wire [3:0]      axi_hp0_awlen;
    wire [1:0]      axi_hp0_awlock;
    wire [2:0]      axi_hp0_awprot;
    wire [3:0]      axi_hp0_awqos;
    wire            axi_hp0_awready;
    wire [2:0]      axi_hp0_awsize;
    wire            axi_hp0_awvalid;
    wire [5:0]      axi_hp0_bid;
    wire            axi_hp0_bready;
    wire [1:0]      axi_hp0_bresp;
    wire            axi_hp0_bvalid;
    wire [63:0]     axi_hp0_rdata;
    wire [5:0]      axi_hp0_rid;
    wire            axi_hp0_rlast;
    wire            axi_hp0_rready;
    wire [1:0]      axi_hp0_rresp;
    wire            axi_hp0_rvalid;
    wire [63:0]     axi_hp0_wdata;
    wire [5:0]      axi_hp0_wid;
    wire            axi_hp0_wlast;
    wire            axi_hp0_wready;
    wire [7:0]      axi_hp0_wstrb;
    wire            axi_hp0_wvalid;

    wire [31:0]     cfg_wr_data;
    wire [4:0]      cfg_wr_addr;
    wire            cfg_wr_en;

    reg  [31:0]     cfg_rd_data;
    wire [4:9]      cfg_rd_addr;
    wire            cfg_rd_en;

    reg  [31:0]     cfg_hold [0:31];
    reg  [0:31]     cfg_hold_en;

    wire [31:0]     sys_hp0_dst_data;
    wire            sys_hp0_dst_valid;
    wire            sys_hp0_dst_ready;

    wire [31:0]     sys_hp0_src_data;
    wire            sys_hp0_src_valid;
    wire            sys_hp0_src_ready;

    reg  [CFG_DWIDTH-1:0]   axis_hp0_dst_cnt;
    reg  [CFG_DWIDTH-1:0]   axis_hp0_src_cnt;


    system
    system_i (
        .DDR_addr           (DDR_addr),
        .DDR_ba             (DDR_ba),
        .DDR_cas_n          (DDR_cas_n),
        .DDR_ck_n           (DDR_ck_n),
        .DDR_ck_p           (DDR_ck_p),
        .DDR_cke            (DDR_cke),
        .DDR_cs_n           (DDR_cs_n),
        .DDR_dm             (DDR_dm),
        .DDR_dq             (DDR_dq),
        .DDR_dqs_n          (DDR_dqs_n),
        .DDR_dqs_p          (DDR_dqs_p),
        .DDR_odt            (DDR_odt),
        .DDR_ras_n          (DDR_ras_n),
        .DDR_reset_n        (DDR_reset_n),
        .DDR_we_n           (DDR_we_n),
        .FIXED_IO_ddr_vrn   (FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp   (FIXED_IO_ddr_vrp),
        .FIXED_IO_mio       (FIXED_IO_mio),
        .FIXED_IO_ps_clk    (FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb   (FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb  (FIXED_IO_ps_srstb),

        .axi_clk            (axi_clk),
        .axi_rst_n          (axi_rst_n),

        .M00_AXI_araddr     (axi_araddr),
        .M00_AXI_arprot     (axi_arprot),
        .M00_AXI_arready    (axi_arready),
        .M00_AXI_arvalid    (axi_arvalid),
        .M00_AXI_awaddr     (axi_awaddr),
        .M00_AXI_awprot     (axi_awprot),
        .M00_AXI_awready    (axi_awready),
        .M00_AXI_awvalid    (axi_awvalid),
        .M00_AXI_bready     (axi_bready),
        .M00_AXI_bresp      (axi_bresp),
        .M00_AXI_bvalid     (axi_bvalid),
        .M00_AXI_rdata      (axi_rdata),
        .M00_AXI_rready     (axi_rready),
        .M00_AXI_rresp      (axi_rresp),
        .M00_AXI_rvalid     (axi_rvalid),
        .M00_AXI_wdata      (axi_wdata),
        .M00_AXI_wready     (axi_wready),
        .M00_AXI_wstrb      (axi_wstrb),
        .M00_AXI_wvalid     (axi_wvalid),

        .S_AXI_HP0_araddr   (axi_hp0_araddr),
        .S_AXI_HP0_arburst  (axi_hp0_arburst),
        .S_AXI_HP0_arcache  (axi_hp0_arcache),
        .S_AXI_HP0_arid     (axi_hp0_arid),
        .S_AXI_HP0_arlen    (axi_hp0_arlen),
        .S_AXI_HP0_arlock   (axi_hp0_arlock),
        .S_AXI_HP0_arprot   (axi_hp0_arprot),
        .S_AXI_HP0_arqos    (axi_hp0_arqos),
        .S_AXI_HP0_arready  (axi_hp0_arready),
        .S_AXI_HP0_arsize   (axi_hp0_arsize),
        .S_AXI_HP0_arvalid  (axi_hp0_arvalid),

        .S_AXI_HP0_awaddr   (axi_hp0_awaddr),
        .S_AXI_HP0_awburst  (axi_hp0_awburst),
        .S_AXI_HP0_awcache  (axi_hp0_awcache),
        .S_AXI_HP0_awid     (axi_hp0_awid),
        .S_AXI_HP0_awlen    (axi_hp0_awlen),
        .S_AXI_HP0_awlock   (axi_hp0_awlock),
        .S_AXI_HP0_awprot   (axi_hp0_awprot),
        .S_AXI_HP0_awqos    (axi_hp0_awqos),
        .S_AXI_HP0_awready  (axi_hp0_awready),
        .S_AXI_HP0_awsize   (axi_hp0_awsize),
        .S_AXI_HP0_awvalid  (axi_hp0_awvalid),

        .S_AXI_HP0_bid      (axi_hp0_bid),
        .S_AXI_HP0_bready   (axi_hp0_bready),
        .S_AXI_HP0_bresp    (axi_hp0_bresp),
        .S_AXI_HP0_bvalid   (axi_hp0_bvalid),

        .S_AXI_HP0_rdata    (axi_hp0_rdata),
        .S_AXI_HP0_rid      (axi_hp0_rid),
        .S_AXI_HP0_rlast    (axi_hp0_rlast),
        .S_AXI_HP0_rready   (axi_hp0_rready),
        .S_AXI_HP0_rresp    (axi_hp0_rresp),
        .S_AXI_HP0_rvalid   (axi_hp0_rvalid),

        .S_AXI_HP0_wdata    (axi_hp0_wdata),
        .S_AXI_HP0_wid      (axi_hp0_wid),
        .S_AXI_HP0_wlast    (axi_hp0_wlast),
        .S_AXI_HP0_wready   (axi_hp0_wready),
        .S_AXI_HP0_wstrb    (axi_hp0_wstrb),
        .S_AXI_HP0_wvalid   (axi_hp0_wvalid)
    );


    axi4lite_cfg
    axi4lite_cfg_ (
        .clk            (axi_clk),
        .rst            ( ~axi_rst_n),

        .cfg_wr_data    (cfg_wr_data),
        .cfg_wr_addr    (cfg_wr_addr),
        .cfg_wr_en      (cfg_wr_en),

        .cfg_rd_data    (cfg_rd_data),
        .cfg_rd_addr    (cfg_rd_addr),
        .cfg_rd_en      (cfg_rd_en),

        .axi_awaddr     (axi_awaddr),
        .axi_awprot     (axi_awprot),
        .axi_awvalid    (axi_awvalid),
        .axi_awready    (axi_awready),

        .axi_wdata      (axi_wdata),
        .axi_wstrb      (axi_wstrb),
        .axi_wvalid     (axi_wvalid),
        .axi_wready     (axi_wready),

        .axi_bresp      (axi_bresp),
        .axi_bvalid     (axi_bvalid),
        .axi_bready     (axi_bready),

        .axi_araddr     (axi_araddr),
        .axi_arprot     (axi_arprot),
        .axi_arvalid    (axi_arvalid),
        .axi_arready    (axi_arready),

        .axi_rdata      (axi_rdata),
        .axi_rresp      (axi_rresp),
        .axi_rvalid     (axi_rvalid),
        .axi_rready     (axi_rready)
    );


    generate
        for (i=0; i<32; i=i+1) begin : WRITE_CONFIG_

            always @(posedge axi_clk) begin
                cfg_hold_en[i] <= 1'b0;

                if (cfg_wr_en & (i == cfg_wr_addr)) begin
                    cfg_hold_en[i] <= 1'b1;
                end
            end


            always @(posedge axi_clk) begin
                if ( ~axi_rst_n) begin
                    cfg_hold[i] <= 'b0;
                end
                else if (cfg_wr_en & (i == cfg_wr_addr)) begin
                    cfg_hold[i] <= cfg_wr_data;
                end
            end

        end
    endgenerate


    always @(posedge axi_clk) begin
        cfg_rd_data <= 'b0;

        if (cfg_rd_en) begin
            case (cfg_rd_addr)
                CFG_HP0_DST_CNT     : cfg_rd_data <= axis_hp0_dst_cnt;
                CFG_HP0_SRC_CNT     : cfg_rd_data <= axis_hp0_src_cnt;
                CFG_HP0_SRC_DATA    : cfg_rd_data <= sys_hp0_src_data;

                default : cfg_rd_data <= cfg_hold[cfg_rd_addr];
            endcase
        end
    end


    axis #(
        .BUF_AWIDTH     (9),
        .CONFIG_ID_RD   (1),
        .CONFIG_ID_WR   (2),
        .CONFIG_ADDR    (CFG_AXIS_ADDR),
        .CONFIG_DATA    (CFG_AXIS_DATA),
        .CONFIG_AWIDTH  (CFG_AWIDTH),
        .CONFIG_DWIDTH  (CFG_DWIDTH),
        .STREAM_WIDTH   (32),
        .AXI_ID_WIDTH   (AXI_ID_WIDTH),
        .AXI_LEN_WIDTH  (AXI_LEN_WIDTH),
        .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH (AXI_DATA_WIDTH))
    axis_hp0_ (
        .clk            (axi_clk),
        .rst            ( ~axi_rst_n),

        .cfg_addr       (cfg_wr_addr),
        .cfg_data       (cfg_wr_data),
        .cfg_valid      (cfg_wr_en),

        .wr_data        (sys_hp0_dst_data),
        .wr_valid       (sys_hp0_dst_valid),
        .wr_ready       (sys_hp0_dst_ready),

        .rd_data        (sys_hp0_src_data),
        .rd_valid       (sys_hp0_src_valid),
        .rd_ready       (sys_hp0_src_ready),

        .axi_awready    (axi_hp0_awready),
        .axi_awid       (axi_hp0_awid),
        .axi_awaddr     (axi_hp0_awaddr),
        .axi_awlen      (axi_hp0_awlen),
        .axi_awsize     (axi_hp0_awsize),
        .axi_awburst    (axi_hp0_awburst),
        .axi_awlock     (axi_hp0_awlock),
        .axi_awcache    (axi_hp0_awcache),
        .axi_awprot     (axi_hp0_awprot),
        .axi_awqos      (axi_hp0_awqos),
        .axi_awvalid    (axi_hp0_awvalid),

        .axi_wready     (axi_hp0_wready),
        .axi_wid        (axi_hp0_wid),
        .axi_wdata      (axi_hp0_wdata),
        .axi_wstrb      (axi_hp0_wstrb),
        .axi_wlast      (axi_hp0_wlast),
        .axi_wvalid     (axi_hp0_wvalid),

        .axi_bid        (axi_hp0_bid),
        .axi_bresp      (axi_hp0_bresp),
        .axi_bvalid     (axi_hp0_bvalid),
        .axi_bready     (axi_hp0_bready),

        .axi_arready    (axi_hp0_arready),
        .axi_arid       (axi_hp0_arid),
        .axi_araddr     (axi_hp0_araddr),
        .axi_arlen      (axi_hp0_arlen),
        .axi_arsize     (axi_hp0_arsize),
        .axi_arburst    (axi_hp0_arburst),
        .axi_arlock     (axi_hp0_arlock),
        .axi_arcache    (axi_hp0_arcache),
        .axi_arprot     (axi_hp0_arprot),
        .axi_arvalid    (axi_hp0_arvalid),
        .axi_arqos      (axi_hp0_arqos),

        .axi_rid        (axi_hp0_rid),
        .axi_rresp      (axi_hp0_rresp),
        .axi_rvalid     (axi_hp0_rvalid),
        .axi_rdata      (axi_hp0_rdata),
        .axi_rlast      (axi_hp0_rlast),
        .axi_rready     (axi_hp0_rready)
    );


    assign sys_hp0_dst_data     = cfg_hold[CFG_HP0_DST_DATA];
    assign sys_hp0_dst_valid    = cfg_hold_en[CFG_HP0_DST_DATA];
    assign sys_hp0_src_ready    = cfg_rd_en & (CFG_HP0_SRC_DATA == cfg_rd_addr);


    // counts number of system data sent from AXIS port
    always @(posedge axi_clk)
        if ( ~axi_rst_n) axis_hp0_dst_cnt <= 'b0;
        else if (sys_hp0_dst_valid) begin
            axis_hp0_dst_cnt <= axis_hp0_dst_cnt + 1;
        end

    always @(posedge axi_clk)
        if ( ~axi_rst_n) axis_hp0_src_cnt <= 'b0;
        else if (sys_hp0_src_valid) begin
            axis_hp0_src_cnt <= axis_hp0_src_cnt + 1;
        end


endmodule
