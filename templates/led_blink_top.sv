// led_blink_top.sv -- minimal toolchain check for a Gowin board.
// Blinks one LED from a free-running counter. Use it to prove the
// toolchain, pins and programmer work before any real design.
// Pin and I/O standard come from the board schematic (see the .cst template).
module led_blink_top #(
    parameter int CLK_HZ = 27_000_000,   // board oscillator frequency
    parameter int BLINK_HZ = 1           // LED toggles at this rate
) (
    input  logic clk,      // board oscillator
    output logic led       // active level depends on the board wiring
);
    localparam int HALF = CLK_HZ / (2 * BLINK_HZ);
    logic [$clog2(HALF)-1:0] cnt = '0;

    // Initial value so the LED is defined from power-up (Gowin supports register init).
    initial led = 1'b0;

    always_ff @(posedge clk) begin
        if (cnt == HALF - 1) begin
            cnt <= '0;
            led <= ~led;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end
endmodule
