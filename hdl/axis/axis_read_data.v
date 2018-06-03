/**
 * Module:
 *  axis_read_data
 *
 * Description:
 *  The axis_read_data handles the AXI read data channel.
 *
 * Testbench:
 *  axis_read_data_tb.v
 *
 * Created:
 *  Tue Nov  4 22:18:14 EST 2014
 *
 * Author:
 *  Berin Martini (berin.martini@gmail.com)
 */
`ifndef _axis_read_data_ `define _axis_read_data_


`include "fifo_simple.v"
`include "axis_serializer.v"

module axis_read_data
  #(parameter
    BUF_CFG_AWIDTH  = 5,
    BUF_AWIDTH      = 9,
    CFG_DWIDTH      = 32,
    WIDTH_RATIO     = 2,

    AXI_DATA_WIDTH  = 64,
    DATA_WIDTH      = 32)
   (input                               clk,
    input                               rst,

    input       [CFG_DWIDTH-1:0]        cfg_length,
    input                               cfg_val,
    output                              cfg_rdy,

    input       [AXI_DATA_WIDTH-1:0]    axi_rdata,
    input                               axi_rvalid,
    output                              axi_rready,

    output      [DATA_WIDTH-1:0]        data,
    output                              valid,
    input                               ready
);

    /**
     * Local parameters
     */

    localparam
        CONFIG  =  0,
        SET     =  1,
        ACTIVE  =  2;


`ifdef VERBOSE
    initial $display("\using 'axis_read_data'\n");
`endif


    /**
     * Internal signals
     */

    reg  [2:0]                  state;
    reg  [2:0]                  state_nx;

    wire                        cfg_buf_pop;
    wire                        cfg_buf_full;
    wire                        cfg_buf_empty;
    wire [CFG_DWIDTH-1:0]       cfg_buf_length;

    reg  [CFG_DWIDTH-1:0]       str_cnt;
    reg  [CFG_DWIDTH-1:0]       str_length;

    wire                        buf_afull;
    wire                        buf_empty;
    wire [AXI_DATA_WIDTH-1:0]   buf_data;
    reg                         buf_en;
    wire                        buf_pop;
    wire                        buf_rdy;


    /**
     * Implementation
     */


    assign cfg_rdy = ~cfg_buf_full;


    fifo_simple #(
        .DATA_WIDTH (CFG_DWIDTH),
        .ADDR_WIDTH (BUF_CFG_AWIDTH))
    cfg_buffer_ (
        .clk        (clk),
        .rst        (rst),

        .count      (),
        .empty      (cfg_buf_empty),
        .empty_a    (),
        .full       (cfg_buf_full),
        .full_a     (),

        .push_data  (cfg_length),
        .push       (cfg_val),

        .pop_data   (cfg_buf_length),
        .pop        (cfg_buf_pop)
    );

    assign cfg_buf_pop = ~cfg_buf_empty & state[CONFIG];


    always @(posedge clk)
        if (state[SET]) begin
            str_length <= cfg_buf_length-1;
        end


    always @(posedge clk)
        if (state[SET]) str_cnt <= 'b0;
        else if (valid) begin
            str_cnt <= str_cnt + 'b1;
        end


    assign axi_rready = ~buf_afull;


    fifo_simple #(
        .DATA_WIDTH (AXI_DATA_WIDTH),
        .ADDR_WIDTH (BUF_AWIDTH))
    buffer_ (
        .clk        (clk),
        .rst        (rst),

        .count      (),
        .empty      (buf_empty),
        .empty_a    (),
        .full       (),
        .full_a     (buf_afull),

        .push_data  (axi_rdata),
        .push       (axi_rvalid & axi_rready),

        .pop_data   (buf_data),
        .pop        (buf_pop)
    );


    assign buf_pop = ~buf_en | buf_rdy;


    always @(posedge clk)
        if      (rst)       buf_en <= 1'b0;
        else if (buf_pop)   buf_en <= ~buf_empty;


    axis_serializer #(
        .DATA_NB    (WIDTH_RATIO),
        .DATA_WIDTH (DATA_WIDTH))
    serializer_ (
        .clk        (clk),
        .rst        (state[CONFIG]),

        .up_data    (buf_data),
        .up_valid   (buf_en),
        .up_ready   (buf_rdy),

        .down_data  (data),
        .down_valid (valid_i),
        .down_ready (ready)
    );


    assign valid = valid_i & state[ACTIVE];


    always @(posedge clk)
        if (rst) begin
            state           <= 'b0;
            state[CONFIG]   <= 1'b1;
        end
        else state <= state_nx;


    always @* begin : DATA_
        state_nx = 'b0;

        case (1'b1)
            state[CONFIG] : begin
                if ( ~cfg_buf_empty) begin
                    state_nx[SET] = 1'b1;
                end
                else state_nx[CONFIG] = 1'b1;
            end
            state[SET] : begin
                state_nx[ACTIVE] = 1'b1;
            end
            state[ACTIVE] : begin
                if (valid & (str_length == str_cnt)) begin
                    state_nx[CONFIG] = 1'b1;
                end
                else state_nx[ACTIVE] = 1'b1;
            end
            default : begin
                state_nx[CONFIG] = 1'b1;
            end
        endcase
    end


endmodule

`endif //  `ifndef _axis_read_data_
