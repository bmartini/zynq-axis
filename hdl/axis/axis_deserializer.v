/**
 * Module:
 *  axis_deserializer
 *
 * Description:
 *  Deserializes multiple 'up' flow bus data words into a single, larger
 *  'down' data words. Arranges them first to the right and moving left.
 *
 *  If there is a pause in the incoming 'up' stream the values already written
 *  into the larger 'down' word will stay until enough 'up' data has been sent
 *  in to complete the 'down' word unless a 'up_last' signal forces the down
 *  transfer. The module will stall when the down_ready flag deasserts.
 *
 * Testbench:
 *  axis_deserializer_tb.v
 *
 * Created:
 *  Thu Nov  6 17:29:58 EST 2014
 *
 * Authors:
 *  Berin Martini (berin.martini@gmail.com)
 */
`ifndef _axis_deserializer_ `define _axis_deserializer_

module axis_deserializer
  #(parameter
    DATA_NB     = 2,
    DATA_WIDTH  = 8)
   (input                                   clk,
    input                                   rst,

    output                                  up_ready,
    input                                   up_valid,
    input       [DATA_WIDTH-1:0]            up_data,
    input                                   up_last,

    input                                   down_ready,
    output reg                              down_valid,
    output reg  [(DATA_WIDTH*DATA_NB)-1:0]  down_data,
    output reg                              down_last
);


    /**
     * Local parameters
     */


`ifdef VERBOSE
    initial $display("\using 'axis_deserializer' with %0d words\n", DATA_NB);
`endif


    /**
     * Internal signals
     */

    genvar ii;

    reg  [DATA_NB-1:0] token;


    /**
     * Implementation
     */


    assign up_ready = down_ready;


    always @(posedge clk)
        if      (rst)           down_last <= 1'b0;
        else if (down_ready)    down_last <= up_last;


    always @(posedge clk)
        if (rst) down_valid <= 1'b0;
        else if (down_ready) begin
            down_valid <= (token[DATA_NB-1] & up_valid) | up_last;
        end


    always @(posedge clk)
        if (rst | (down_ready & up_last)) token <= 'b1;
        else if (down_ready & up_valid) begin
            token <= {token, token[DATA_NB-1]};
        end


    generate
        for (ii=0; ii<DATA_NB; ii=ii+1) begin : CONCAT_

            always @(posedge clk)
                if (down_ready & token[ii]) begin
                    down_data[ii*DATA_WIDTH +: DATA_WIDTH] <= up_data;
                end

        end
    endgenerate



endmodule

`endif //  `ifndef _axis_deserializer_
