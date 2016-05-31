/**
 * Module:
 *  axis_serializer
 *
 * Description:
 *  Serializes the 'up' flow bus data word into multiple smaller 'down' data
 *  words. The module will stall when the down_ready flag deasserts.
 *
 * Testbench:
 *  axis_serializer_tb.v
 *
 * Created:
 *  Fri Nov  7 11:50:04 EST 2014
 *
 * Authors:
 *  Berin Martini (berin.martini@gmail.com)
 */
`ifndef _axis_serializer_ `define _axis_serializer_


module axis_serializer
  #(parameter
    DATA_NB     = 2,
    DATA_WIDTH  = 8)
   (input                                   clk,
    input                                   rst,

    output                                  up_ready,
    input                                   up_valid,
    input       [(DATA_WIDTH*DATA_NB)-1:0]  up_data,

    input                                   down_ready,
    output reg                              down_valid,
    output reg  [DATA_WIDTH-1:0]            down_data
);


    /**
     * Local parameters
     */


`ifdef VERBOSE
    initial $display("\using 'axis_serializer' with %0d words\n", DATA_NB);
`endif


    /**
     * Internal signals
     */

    wire [2*DATA_NB-1:0]            token_nx;
    reg  [DATA_NB-1:0]              token;
    reg  [DATA_NB:0]                serial_valid;
    reg  [(DATA_WIDTH*DATA_NB)-1:0] serial_data;
    wire                            serial_start;


    /**
     * Implementation
     */

    assign up_ready = down_ready & token[0];

    assign serial_start = |(token >> 1);

    assign token_nx = {token, token};


    always @(posedge clk)
        if (rst) token <= 'b1;
        else if (down_ready) begin

            if (serial_start | (up_ready & up_valid)) begin
                token <= token_nx[DATA_NB-1 +: DATA_NB];
            end
        end


    always @(posedge clk)
        if (down_ready) begin

            serial_data <= serial_data >> DATA_WIDTH;
            if (up_ready & up_valid) begin
                serial_data <= up_data;
            end
        end


    always @(posedge clk)
        if (rst) serial_valid <= 'b0;
        else if (down_ready) begin

            serial_valid <= {serial_valid[0 +: DATA_NB], 1'b0};
            if (up_ready & up_valid) begin
                serial_valid <= {serial_valid[0 +: DATA_NB], 1'b1};
            end
        end


    always @(posedge clk)
        if (down_ready) begin
            down_data <= serial_data[0 +: DATA_WIDTH];
        end


    always @(posedge clk)
        if (rst) down_valid <= 1'b0;
        else if (down_ready) begin
            down_valid <= |(serial_valid[0 +: DATA_NB]);
        end



endmodule

`endif //  `ifndef _axis_serializer_
