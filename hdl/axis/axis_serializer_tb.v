/**
 * Testbench for:
 *  axis_serializer
 *
 * Created:
 *  Fri Nov  7 11:49:55 EST 2014
 *
 * Author:
 *  Berin Martini (berin.martini@gmail.com)
 */

`timescale 1ns/10ps

`define TB_VERBOSE
//`define VERBOSE


`include "axis_serializer.v"

module axis_serializer_tb;

    /**
     * Clock and control functions
     */

    // Generate a clk
    reg clk;
    always #1 clk = !clk;

    // End of simulation event definition
    event end_trigger;
    always @(end_trigger) $finish;

`ifdef TB_VERBOSE
    // Display header information
    initial #1 display_header();
    always @(end_trigger) display_header();

    // And strobe signals at each clk
    always @(posedge clk) display_signals();
`endif

//    initial begin
//        $dumpfile("result.vcd"); // Waveform file
//        $dumpvars;
//    end


    /**
     * Local parameters
     */

    localparam DATA_NB          = 3;
    localparam DATA_WIDTH       = 8;

    localparam STREAM_LENGTH    = 256;

`ifdef TB_VERBOSE
    initial begin
        $display("Testbench for unit 'axis_serializer' data width: %d, nb: %d",
            DATA_WIDTH, DATA_NB);
    end
`endif


    /**
     *  signals, registers and wires
     */

    reg                                 rst;

    reg     [DATA_NB*DATA_WIDTH-1:0]    up_data;
    wire                                up_valid;
    wire                                up_ready;

    wire    [DATA_WIDTH-1:0]            down_data;
    wire                                down_valid;
    reg                                 down_ready;

    reg     [DATA_WIDTH-1:0]            stream  [0:STREAM_LENGTH-1];
    integer                             cnt;

    /**
     * Unit under test
     */

    axis_serializer #(
        .DATA_NB    (DATA_NB),
        .DATA_WIDTH (DATA_WIDTH))
    uut (
        .clk        (clk),
        .rst        (rst),

        .up_data    (up_data),
        .up_valid   (up_valid),
        .up_ready   (up_ready),

        .down_data  (down_data),
        .down_valid (down_valid),
        .down_ready (down_ready)
    );


    /**
     * Wave form display
     */

    task display_signals;
        $display(
            "%d\t%d",
            $time, rst,

            "\tu2: %d\tu1: %d\tu0: %d",
            up_data[2*DATA_WIDTH+:DATA_WIDTH],
            up_data[1*DATA_WIDTH+:DATA_WIDTH],
            up_data[0*DATA_WIDTH+:DATA_WIDTH],

            "\tv %b\tr %b",
            up_valid,
            up_ready,

            "\t%d\t%b\t%b",
            down_data,
            down_valid,
            down_ready,

            "\t%b",
            uut.token,

            "\t%x\t%b",
            uut.serial_data,
            uut.serial_valid,
        );

    endtask // display_signals

    task display_header;
        $display(
            "\t\ttime\trst",

            "\tu2_d",
            "\tu1_d",
            "\tu0_d",

            "\tu_v",
            "\tu_r",

            "\td_d",
            "\td_v",
            "\td_r",

        );
    endtask


    /**
     * Testbench program
     */

    //assign up_valid = up_ready;
    assign up_valid = 1'b1;

    always @(posedge clk)
        if (up_ready & up_valid) begin
            cnt <= cnt + 1;
        end


    always @(posedge clk)
        up_data <= {stream[cnt]+4'd2, stream[cnt]+4'd1, stream[cnt]};



    initial begin
        // init values
        clk = 0;
        rst = 0;

        down_ready = 'b0;

        cnt = 0;
        repeat (STREAM_LENGTH) begin
            stream[cnt] = (DATA_NB*cnt)+1;
            cnt         = cnt + 1;
        end
        cnt = 0;
        //end init

`ifdef TB_VERBOSE
    $display("RESET");
`endif

        repeat(6) @(negedge clk);
        rst <= 1'b1;
        repeat(6) @(negedge clk);
        rst <= 1'b0;
        repeat(6) @(negedge clk);

`ifdef TB_VERBOSE
    $display("test continuous ready");
`endif

        @(negedge clk);
        down_ready <= 1'b1;
        repeat(20) @(negedge clk);
        down_ready <= 1'b0;
        repeat(10) @(negedge clk);


`ifdef TB_VERBOSE
    $display("test non-continuous ready");
`endif

        down_ready <= 1'b1;
        repeat(20) @(negedge clk);
        down_ready <= 1'b0;
        @(negedge clk);
        down_ready <= 1'b1;
        repeat(5) @(negedge clk);
        down_ready <= 1'b0;
        repeat(5) @(negedge clk);
        down_ready <= 1'b1;
        repeat(5) @(negedge clk);
        down_ready <= 1'b0;
        repeat(10) @(negedge clk);
        down_ready <= 1'b1;
        @(negedge clk);
        down_ready <= 1'b0;
        @(negedge clk);
        down_ready <= 1'b1;
        @(negedge clk);
        down_ready <= 1'b0;
        repeat(10) @(negedge clk);



`ifdef TB_VERBOSE
    $display("END");
`endif
        -> end_trigger;
    end

endmodule
