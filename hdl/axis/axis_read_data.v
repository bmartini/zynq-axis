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
    CONFIG_DWIDTH   = 32,
    WIDTH_RATIO     = 16,

    AXI_DATA_WIDTH  = 32,
    DATA_WIDTH      = 32)
   (input                               clk,
    input                               rst,

    input       [CONFIG_DWIDTH-1:0]     cfg_length,
    input                               cfg_valid,
    output                              cfg_ready,

    input       [AXI_DATA_WIDTH-1:0]    axi_rdata,
    input                               axi_rvalid,
    output                              axi_rready,

    output      [DATA_WIDTH-1:0]        data,
    output reg                          valid,
    input                               ready
);

    /**
     * Local parameters
     */

    localparam
        IDLE    =  0,
        ACTIVE  =  1,
        WAIT    =  2,
        DONE    =  3;


`ifdef VERBOSE
    initial $display("\using 'axis_read_data'\n");
`endif


    /**
     * Internal signals
     */

    reg  [3:0]                  state;
    reg  [3:0]                  state_nx;

    reg  [CONFIG_DWIDTH-1:0]    str_cnt;
    reg  [CONFIG_DWIDTH-1:0]    str_length;

    wire                        buf_pop;
    wire                        buf_full;
    wire                        buf_empty;
    wire [DATA_WIDTH-1:0]       buf_data;
    wire                        buf_valid;

    /**
     * Implementation
     */

    assign cfg_ready = state[IDLE];

    assign buf_pop = ~buf_empty & ready;


    always @(posedge clk)
        if (cfg_valid) begin
            str_length <= cfg_length-1;
        end


    always @(posedge clk)
        if (state[IDLE]) str_cnt <= 'b0;
        else if (buf_pop) begin
            str_cnt <= str_cnt + 'b1;
        end


    always @(posedge clk)
        if (rst)    valid <= 1'b0;
        else        valid <= buf_pop & state[ACTIVE];


    fifo_simple #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (BUF_AWIDTH))
    buffer_ (
        .clk        (clk),
        .rst        (state[IDLE]),

        .count      (),
        .empty      (buf_empty),
        .empty_a    (),
        .full       (buf_full),
        .full_a     (),

        .push_data  (buf_data),
        .push       (buf_valid),

        .pop_data   (data),
        .pop        (buf_pop)
    );


    axis_serializer #(
        .DATA_NB    (WIDTH_RATIO),
        .DATA_WIDTH (DATA_WIDTH))
    serializer_ (
        .clk        (clk),
        .rst        (state[IDLE]),

        .up_data    (axi_rdata),
        .up_valid   (axi_rvalid),
        .up_ready   (axi_rready),

        .down_data  (buf_data),
        .down_valid (buf_valid),
        .down_ready ( ~buf_full)
    );


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
                if (buf_pop & (str_length == str_cnt)) begin
                    state_nx[WAIT] = 1'b1;
                end
                else state_nx[ACTIVE] = 1'b1;
            end
            state[WAIT] : begin
                state_nx[DONE] = 1'b1;
            end
            state[DONE] : begin
                state_nx[IDLE] = 1'b1;
            end
            default : begin
                state_nx[IDLE] = 1'b1;
            end
        endcase
    end



endmodule

`endif //  `ifndef _axis_read_data_
