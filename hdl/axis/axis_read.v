/**
 * Module:
 *  axis_read
 *
 * Description:
 *   The axis_read is configured to read an area of memory and then converts
 *   the large words that are returned by the AXI into a system stream.
 *
 * Test bench:
 *  axis_write_tb.v
 *
 * Created:
 *  Fri Nov  7 17:23:00 EST 2014
 *
 * Author:
 *  Berin Martini (berin.martini@gmail.com)
 */
`ifndef _axis_read_ `define _axis_read_


`include "axis_addr.v"
`include "axis_read_data.v"

module axis_read
  #(parameter
    BUF_AWIDTH      = 9,

    CFG_ID          = 1,
    CFG_ADDR        = 23,
    CFG_DATA        = 24,
    CFG_AWIDTH      = 5,
    CFG_DWIDTH      = 32,

    AXI_LEN_WIDTH   = 8,
    AXI_ADDR_WIDTH  = 32,
    AXI_DATA_WIDTH  = 32,
    DATA_WIDTH      = 32)
   (input                               clk,
    input                               rst,

    input       [CFG_AWIDTH-1:0]        cfg_addr,
    input       [CFG_DWIDTH-1:0]        cfg_data,
    input                               cfg_valid,

    input                               axi_arready,
    output      [AXI_ADDR_WIDTH-1:0]    axi_araddr,
    output      [AXI_LEN_WIDTH-1:0]     axi_arlen,
    output                              axi_arvalid,

    input       [AXI_DATA_WIDTH-1:0]    axi_rdata,
    input                               axi_rlast,
    input                               axi_rvalid,
    output                              axi_rready,

    output      [DATA_WIDTH-1:0]        data,
    output                              valid,
    input                               ready
);

    /**
     * Local parameters
     */

    localparam WIDTH_RATIO  = AXI_DATA_WIDTH/DATA_WIDTH;
    localparam CFG_NB       = 2;
    localparam STORE_WIDTH  = CFG_DWIDTH*CFG_NB;

    localparam
        C_IDLE      = 0,
        C_CONFIG    = 1,
        C_WAIT      = 2,
        C_ENABLE    = 3;


`ifdef VERBOSE
    initial $display("\using 'axis_read'\n");
`endif


    /**
     * Internal signals
     */


    reg  [3:0]                          c_state;
    reg  [3:0]                          c_state_nx;

    wire                                cfg_addr_ready;
    wire                                cfg_data_ready;

    reg  [CFG_AWIDTH-1:0]               cfg_addr_r;
    reg  [CFG_DWIDTH-1:0]               cfg_data_r;
    reg                                 cfg_valid_r;
    wire [STORE_WIDTH+CFG_DWIDTH-1:0]   cfg_store_i;
    reg  [STORE_WIDTH-1:0]              cfg_store;
    reg  [7:0]                          cfg_cnt;

    wire [CFG_DWIDTH-1:0]               start_addr;
    reg  [CFG_DWIDTH-1:0]               cfg_address;
    wire [CFG_DWIDTH-1:0]               str_length;
    reg  [CFG_DWIDTH-1:0]               cfg_length;
    reg                                 cfg_enable;
    wire                                id_valid;
    wire                                addressed;
    wire                                axis_data;


    /**
     * Implementation
     */

    assign cfg_store_i  = {cfg_store, cfg_data_r};

    assign start_addr   = cfg_store[CFG_DWIDTH +: CFG_DWIDTH];

    assign str_length   = cfg_store[0 +: CFG_DWIDTH];

    assign id_valid     = (CFG_ID == cfg_data_r);

    assign addressed    = (CFG_ADDR == cfg_addr_r) & cfg_valid_r;

    assign axis_data    = (CFG_DATA == cfg_addr_r) & cfg_valid_r;


    // register for improved timing
    always @(posedge clk)
        if (rst)    cfg_valid_r <= 1'b0;
        else        cfg_valid_r <= cfg_valid;


    // register for improved timing
    always @(posedge clk) begin
        cfg_addr_r <= cfg_addr;
        cfg_data_r <= cfg_data;
    end


    always @(posedge clk)
        if (c_state[C_CONFIG] & axis_data) begin
            cfg_store <= cfg_store_i[0 +: STORE_WIDTH];
        end


    always @(posedge clk) begin
        cfg_cnt <= 'b0;

        if (c_state[C_CONFIG]) begin
            cfg_cnt <= cfg_cnt + {7'b0, axis_data};
        end
    end


    always @(posedge clk)
        if (rst)    cfg_enable <= 1'b0;
        else        cfg_enable <= c_state[C_ENABLE];


    always @(posedge clk) begin
        if (c_state[C_ENABLE]) begin
            cfg_address <= start_addr;
            cfg_length  <= str_length;
        end
    end


    always @(posedge clk)
        if (rst) begin
            c_state         <= 'b0;
            c_state[C_IDLE] <= 1'b1;
        end
        else c_state <= c_state_nx;


    always @* begin : CONFIG_
        c_state_nx = 'b0;

        case (1'b1)
            c_state[C_IDLE] : begin
                if (addressed & id_valid) begin
                    c_state_nx[C_CONFIG] = 1'b1;
                end
                else c_state_nx[C_IDLE] = 1'b1;
            end
            c_state[C_CONFIG] : begin
                if (axis_data & ((CFG_NB-1) <= cfg_cnt)) begin
                    c_state_nx[C_WAIT] = 1'b1;
                end
                else c_state_nx[C_CONFIG] = 1'b1;
            end
            c_state[C_WAIT] : begin
                if (cfg_addr_ready & cfg_data_ready) begin
                    c_state_nx[C_ENABLE] = 1'b1;
                end
                else c_state_nx[C_WAIT] = 1'b1;
            end
            c_state[C_ENABLE] : begin
                c_state_nx[C_IDLE] = 1'b1;
            end
            default : begin
                c_state_nx[C_IDLE] = 1'b1;
            end
        endcase
    end


    axis_addr #(
        .CFG_DWIDTH     (CFG_DWIDTH),
        .WIDTH_RATIO    (WIDTH_RATIO),
        .CONVERT_SHIFT  ($clog2(WIDTH_RATIO)),
        .AXI_LEN_WIDTH  (AXI_LEN_WIDTH),
        .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH (AXI_DATA_WIDTH))
    axis_addr_ (
        .clk            (clk),
        .rst            (rst),

        .cfg_address    (cfg_address),
        .cfg_length     (cfg_length),
        .cfg_val        (cfg_enable),
        .cfg_rdy        (cfg_addr_ready),

        .axi_aready     (axi_arready),
        .axi_aaddr      (axi_araddr),
        .axi_alen       (axi_arlen),
        .axi_avalid     (axi_arvalid)
    );


    axis_read_data #(
        .BUF_AWIDTH     (BUF_AWIDTH),
        .CFG_DWIDTH     (CFG_DWIDTH),
        .WIDTH_RATIO    (WIDTH_RATIO),
        .AXI_DATA_WIDTH (AXI_DATA_WIDTH),
        .DATA_WIDTH     (DATA_WIDTH))
    axis_read_data_ (
        .clk            (clk),
        .rst            (rst),

        .cfg_length     (cfg_length),
        .cfg_val        (cfg_enable),
        .cfg_rdy        (cfg_data_ready),

        .axi_rdata      (axi_rdata),
        .axi_rlast      (axi_rlast),
        .axi_rvalid     (axi_rvalid),
        .axi_rready     (axi_rready),

        .data           (data),
        .valid          (valid),
        .ready          (ready)
    );



endmodule

`endif //  `ifndef _axis_read_
