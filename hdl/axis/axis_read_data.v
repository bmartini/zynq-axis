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
    BUF_AWIDTH      = 9,
    CFG_DWIDTH      = 32,
    WIDTH_RATIO     = 2,

    AXI_DATA_WIDTH  = 64,
    DATA_WIDTH      = 32)
   (input                               clk,
    input                               rst,

    input       [CFG_DWIDTH-1:0]        cfg_length,
    input                               cfg_valid,
    output                              cfg_ready,

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
        IDLE    =  0,
        ACTIVE  =  1;


`ifdef VERBOSE
    initial $display("\using 'axis_read_data'\n");
`endif


    /**
     * Internal signals
     */

    reg  [1:0]                  state;
    reg  [1:0]                  state_nx;

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

    assign cfg_ready = state[IDLE];


    always @(posedge clk)
        if (cfg_valid) begin
            str_length <= cfg_length-1;
        end


    always @(posedge clk)
        if (state[IDLE]) str_cnt <= 'b0;
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
        .rst        (state[IDLE]),

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
            state       <= 'b0;
            state[IDLE] <= 1'b1;
        end
        else state <= state_nx;


    always @* begin : DATA_
        state_nx = 'b0;

        case (1'b1)
            state[IDLE] : begin
                if (cfg_valid) begin
                    state_nx[ACTIVE] = 1'b1;
                end
                else state_nx[IDLE] = 1'b1;
            end
            state[ACTIVE] : begin
                if (valid & (str_length == str_cnt)) begin
                    state_nx[IDLE] = 1'b1;
                end
                else state_nx[ACTIVE] = 1'b1;
            end
            default : begin
                state_nx[IDLE] = 1'b1;
            end
        endcase
    end



endmodule

`endif //  `ifndef _axis_read_data_
