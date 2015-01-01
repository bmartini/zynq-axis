
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
        .M00_AXI_wvalid     (axi_wvalid)
    );


endmodule
