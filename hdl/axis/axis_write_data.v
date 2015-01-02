/**
 * Module:
 *  axis_write_data
 *
 * Description:
 *  The axis_write_data handles the AXI write data channel.
 *
 * Test bench:
 *  axis_write_tb.v
 *
 * Created:
 *  Tue Nov  4 22:18:14 EST 2014
 *
 * Author:
 *  Berin Martini (berin.martini@gmail.com)
 */
`ifndef _axis_write_data_ `define _axis_write_data_


`include "fifo_simple.v"
`include "axis_deserializer.v"

module axis_write_data
  #(parameter
    BUF_AWIDTH      = 9,
    CONFIG_DWIDTH   = 32,
    WIDTH_RATIO     = 16,
    CONVERT_SHIFT   = 3,

    AXI_LEN_WIDTH   = 8,
    AXI_DATA_WIDTH  = 32,
    DATA_WIDTH      = 32)
   (input                               clk,
    input                               rst,

    input       [CONFIG_DWIDTH-1:0]     cfg_length,
    input                               cfg_valid,
    output                              cfg_ready,

    output                              axi_wlast,
    output      [AXI_DATA_WIDTH-1:0]    axi_wdata,
    output                              axi_wvalid,
    input                               axi_wready,

    input       [DATA_WIDTH-1:0]        data,
    input                               valid,
    output reg                          ready
);

    /**
     * Local parameters
     */

    localparam BURST_WIDTH  = AXI_LEN_WIDTH+CONVERT_SHIFT;
    localparam BURST_LAST   = (1<<BURST_WIDTH)-1;

    localparam
        IDLE    =  0,
        ACTIVE  =  1,
        WAIT    =  2,
        DONE    =  3;


`ifdef VERBOSE
    initial $display("\using 'axis_write_data'\n");
`endif


    /**
     * Internal signals
     */

    reg  [3:0]                  state;
    reg  [3:0]                  state_nx;

    reg  [CONFIG_DWIDTH-1:0]    str_cnt;
    reg  [CONFIG_DWIDTH-1:0]    str_length;

    wire [BUF_AWIDTH:0]         buf_count;
    wire                        buf_pop;
    wire                        buf_empty;

    reg                         deser_last;
    wire [DATA_WIDTH-1:0]       deser_data;
    reg                         deser_valid;

    /**
     * Implementation
     */

    assign cfg_ready = state[IDLE];

    assign buf_pop = ~buf_empty & axi_wready;


    always @(posedge clk)
        if (cfg_valid) begin
            str_length <= cfg_length-1;
        end


    // use axi_wready as a stall signal
    always @(posedge clk)
        if      (state[IDLE])   deser_valid <= 1'b0;
        else if (axi_wready)    deser_valid <= buf_pop;


    // half way mark ready flag
    always @(posedge clk)
        if (state[IDLE])    ready <= 1'b0;
        else                ready <= ~|(buf_count[BUF_AWIDTH:BUF_AWIDTH-1]);


    always @(posedge clk)
        if      (state[IDLE])   str_cnt <= 'b0;
        else if (axi_wready)    str_cnt <= str_cnt + buf_pop;


    always @(posedge clk)
        if (state[IDLE]) deser_last <= 1'b0;
        else if (axi_wready) begin
            // trigger on last word in stream or last word in burst
            deser_last <= buf_pop &
                ((str_length == str_cnt) | (BURST_LAST == str_cnt[0 +: BURST_WIDTH]));
        end


    fifo_simple #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (BUF_AWIDTH))
    buffer_ (
        .clk        (clk),
        .rst        (state[IDLE]),

        .count      (buf_count),
        .empty      (buf_empty),
        .empty_a    (),
        .full       (),
        .full_a     (),

        .push_data  (data),
        .push       (valid),

        .pop_data   (deser_data),
        .pop        (buf_pop)
    );


    axis_deserializer #(
        .DATA_NB    (WIDTH_RATIO),
        .DATA_WIDTH (DATA_WIDTH))
    deser_ (
        .clk        (clk),
        .rst        (state[IDLE]),

        .up_data    (deser_data),
        .up_valid   (deser_valid),
        .up_ready   (),
        .up_last    (deser_last),

        .down_data  (axi_wdata),
        .down_valid (axi_wvalid),
        .down_ready (axi_wready),
        .down_last  (axi_wlast)
    );


    always @(posedge clk)
        if (rst) begin
            state       <= 'b0;
            state[IDLE] <= 1'b1;
        end
        else state <= state_nx;


    always @* begin : DATA_
        state_nx <= 'b0;

        case (1'b1)
            state[IDLE] : begin
                if (cfg_valid) begin
                    state_nx[ACTIVE] <= 1'b1;
                end
                else state_nx[IDLE] <= 1'b1;
            end
            state[ACTIVE] : begin
                if (axi_wready & buf_pop & (str_length == str_cnt)) begin
                    state_nx[WAIT] <= 1'b1;
                end
                else state_nx[ACTIVE] <= 1'b1;
            end
            state[WAIT] : begin
                if (axi_wready & axi_wlast) begin
                    state_nx[DONE] <= 1'b1;
                end
                else state_nx[WAIT] <= 1'b1;
            end
            state[DONE] : begin
                state_nx[IDLE] <= 1'b1;
            end
            default : begin
                state_nx[IDLE] <= 1'b1;
            end
        endcase
    end


endmodule

`endif //  `ifndef _axis_write_data_
