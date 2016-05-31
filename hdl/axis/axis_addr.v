/**
 * Module:
 *  axis_addr
 *
 * Description:
 *  The axis_addr handles the AXI write address channel.
 *
 * Test bench:
 *  axis_addr_tb.v
 *
 * Created:
 *  Wed Nov  5 21:15:56 EST 2014
 *
 * Author:
 *  Berin Martini (berin.martini@gmail.com)
 */
`ifndef _axis_addr_ `define _axis_addr_


module axis_addr
  #(parameter
    CONFIG_DWIDTH   = 32,
    WIDTH_RATIO     = 16,
    CONVERT_SHIFT   = 3,
    AXI_LEN_WIDTH   = 8,
    AXI_ADDR_WIDTH  = 32,
    AXI_DATA_WIDTH  = 256)
   (input                               clk,
    input                               rst,

    input       [CONFIG_DWIDTH-1:0]     cfg_address,
    input       [CONFIG_DWIDTH-1:0]     cfg_length,
    input                               cfg_valid,
    output                              cfg_ready,

    input                               axi_aready,
    output      [AXI_ADDR_WIDTH-1:0]    axi_aaddr,
    output      [AXI_LEN_WIDTH-1:0]     axi_alen,
    output                              axi_avalid
);

    /**
     * Local parameters
     */

    localparam BURST_NB_WIDTH   = CONFIG_DWIDTH-AXI_LEN_WIDTH;
    localparam BURST_LENGTH     = 1<<AXI_LEN_WIDTH;

    localparam
        IDLE    =  0,
        SETUP   =  1,
        BURST   =  2,
        LAST    =  3,
        DONE    =  4;



`ifdef VERBOSE
    initial $display("\using 'axis_addr'\n");
`endif


    /**
     * Internal signals
     */


    reg  [4:0]                  state;
    reg  [4:0]                  state_nx;

    reg                         last_en;
    reg  [AXI_LEN_WIDTH-1:0]    last_nb;

    reg                         burst_en;
    reg  [BURST_NB_WIDTH-1:0]   burst_nb;
    reg  [BURST_NB_WIDTH-1:0]   burst_cnt;
    wire                        burst_done;

    reg  [CONFIG_DWIDTH-1:0]    cfg_length_r;
    reg                         cfg_valid_r;
    reg                         cfg_done;

    reg  [CONFIG_DWIDTH-1:0]    axi_address;


    /**
     * Implementation
     */

    assign cfg_ready    = state[IDLE];

    assign axi_aaddr    = axi_address;

    assign axi_alen     = state[BURST] ? (BURST_LENGTH-1) : last_nb;

    assign axi_avalid   = state[BURST] | state[LAST];

    assign burst_done   = (burst_nb == burst_cnt);


    always @(posedge clk)
        if (rst)    cfg_valid_r <= 1'b0;
        else        cfg_valid_r <= cfg_valid;


    always @(posedge clk)
        if (cfg_valid) begin
            // the shift converts from number of stream elements to number of
            // bursts to be sent to the memory after stream is packed. adding a
            // bit to the length ensures that the shift rounds up

            cfg_length_r <= (cfg_length+WIDTH_RATIO-1) >> CONVERT_SHIFT;
        end


    always @(posedge clk)
        if (rst)    cfg_done <= 1'b0;
        else        cfg_done <= cfg_valid_r;


    always @(posedge clk)
        if (cfg_valid_r) begin
            last_en     <= |(cfg_length_r[AXI_LEN_WIDTH-1:0]);
            last_nb     <= cfg_length_r[AXI_LEN_WIDTH-1:0]-1;

            burst_en    <= |(cfg_length_r[AXI_LEN_WIDTH +: BURST_NB_WIDTH]);
            burst_nb    <= cfg_length_r[AXI_LEN_WIDTH +: BURST_NB_WIDTH]-1;
        end


    always @(posedge clk)
        if (cfg_valid) begin
            axi_address <= cfg_address;
        end
        else if (axi_aready & state[BURST]) begin
            // e.g. each burst has 256 long words & each long word has 32 bytes
            axi_address <= axi_address + (BURST_LENGTH * (AXI_DATA_WIDTH/8));
        end


    always @(posedge clk)
        if (state[IDLE]) begin
            burst_cnt <= 'b0;
        end
        else if (axi_aready & state[BURST]) begin
            burst_cnt <= burst_cnt + 1;
        end


    always @(posedge clk)
        if (rst) begin
            state       <= 'b0;
            state[IDLE] <= 1'b1;
        end
        else state <= state_nx;


    always @* begin : ADDR_
        state_nx = 'b0;

        case (1'b1)
            state[IDLE] : begin
                if (cfg_valid) begin
                    state_nx[SETUP] = 1'b1;
                end
                else state_nx[IDLE] = 1'b1;
            end
            state[SETUP] : begin
                if (cfg_done & burst_en) begin
                    state_nx[BURST] = 1'b1;
                end
                else if (cfg_done & ~burst_en) begin
                    state_nx[LAST] = 1'b1;
                end
                else state_nx[SETUP] = 1'b1;
            end
            state[BURST] : begin
                if (axi_aready & burst_done & last_en) begin
                    state_nx[LAST] = 1'b1;
                end
                else if (axi_aready & burst_done & ~last_en) begin
                    state_nx[DONE] = 1'b1;
                end
                else state_nx[BURST] = 1'b1;
            end
            state[LAST] : begin
                if (axi_aready) begin
                    state_nx[DONE] = 1'b1;
                end
                else state_nx[LAST] = 1'b1;
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

`endif //  `ifndef _axis_addr_
