/**
 * Testbench for:
 *  axis_deserializer
 *
 * Created:
 *  Thu Nov  6 17:29:45 EST 2014
 *
 * Author:
 *  Berin Martini (berin.martini@gmail.com)
 */

`timescale 1ns/10ps

`define TB_VERBOSE
//`define VERBOSE


`include "axis_deserializer.v"

module axis_deserializer_tb;

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
        $display("Testbench for unit 'axis_deserializer' data width: %d, nb: %d",
            DATA_WIDTH, DATA_NB);
    end
`endif


    /**
     *  signals, registers and wires
     */

    reg                                 rst;

    reg     [DATA_WIDTH-1:0]            up_data;
    reg                                 up_valid;
    wire                                up_ready;
    reg                                 up_last;

    wire    [DATA_NB*DATA_WIDTH-1:0]    down_data;
    wire                                down_valid;
    reg                                 down_ready;
    wire                                down_last;

    reg     [DATA_WIDTH-1:0]            stream  [0:STREAM_LENGTH-1];
    integer                             cnt;

    /**
     * Unit under test
     */

    axis_deserializer #(
        .DATA_NB    (DATA_NB),
        .DATA_WIDTH (DATA_WIDTH))
    uut (
        .clk        (clk),
        .rst        (rst),

        .up_data    (up_data),
        .up_valid   (up_valid),
        .up_ready   (up_ready),
        .up_last    (up_last),

        .down_data  (down_data),
        .down_valid (down_valid),
        .down_ready (down_ready),
        .down_last  (down_last)
    );


    /**
     * Wave form display
     */

    task display_signals;
        $display(
            "%d\t%d",
            $time, rst,

            "\t%x\t%b\t%b\t%b",
            up_data,
            up_valid,
            up_ready,
            up_last,

            "\t%x\t%b\t%b\t%b",
            down_data,
            down_valid,
            down_ready,
            down_last,

        );

    endtask // display_signals

    task display_header;
        $display(
            "\t\ttime\trst",

            "\tu_d",
            "\tu_v",
            "\tu_r",
            "\tu_l",

            "\td_d",
            "\td_v",
            "\td_r",
            "\td_l",

        );
    endtask


    /**
     * Testbench program
     */


    always @(posedge clk)
        if (up_ready) begin
            cnt <= cnt + 1;
        end


    always @(posedge clk)
        up_data <= stream[cnt];


    always @(posedge clk) begin
        up_valid <= 1'b0;

        if (up_ready) begin
            up_valid <= 1'b1;
        end
    end


    initial begin
        // init values
        clk = 0;
        rst = 0;

        up_last = 'b0;

        down_ready = 'b0;

        cnt = 0;
        repeat (STREAM_LENGTH) begin
            stream[cnt] = cnt + 1;
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
        repeat(10) @(negedge clk);


`ifdef TB_VERBOSE
    $display("test continuous ready with unalined last");
`endif

        cnt <= 0;
        repeat(3) @(negedge clk);

        down_ready <= 1'b1;
        //repeat(15) @(negedge clk);
        repeat(16) @(negedge clk);
        //repeat(17) @(negedge clk);
        //repeat(18) @(negedge clk);
        up_last     <= 1'b1;
        @(negedge clk);
        up_last     <= 1'b0;
        repeat(5) @(negedge clk);
        down_ready  <= 1'b0;
        repeat(10) @(negedge clk);



`ifdef TB_VERBOSE
    $display("END");
`endif
        -> end_trigger;
    end

endmodule
