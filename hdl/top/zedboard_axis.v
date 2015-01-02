
`include "axi4lite_cfg.v"

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

    wire [31:0]     cfg_wr_data;
    wire [4:0]      cfg_wr_addr;
    wire            cfg_wr_en;

    reg  [31:0]     cfg_rd_data;
    wire [4:9]      cfg_rd_addr;
    wire            cfg_rd_en;

    reg  [31:0]     cfg_hold [0:31];
    reg  [0:31]     cfg_hold_en;

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

                default : cfg_rd_data <= cfg_hold[cfg_rd_addr];
            endcase
        end
    end


endmodule
