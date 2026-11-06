// led_blink_top_tb.sv -- simulate the blink logic with a short period.
`timescale 1ns/1ps
module led_blink_top_tb;
    logic clk = 0;
    logic led;
    // Use a small CLK_HZ and BLINK_HZ so the simulation stays short.
    led_blink_top #(.CLK_HZ(100), .BLINK_HZ(1)) dut (.clk(clk), .led(led));
    always #5 clk = ~clk;
    int toggles = 0;
    logic prev = 0;
    initial begin
        // HALF = 100 / 2 = 50 cycles per toggle; 400 cycles should give about 8 toggles
        repeat (400) begin
            @(posedge clk);
            if (led !== prev) toggles++;
            prev = led;
        end
        if (toggles >= 7 && toggles <= 9) $display("PASS: led toggled %0d times", toggles);
        else $display("FAIL: led toggled %0d times, expected about 8", toggles);
        $finish;
    end
endmodule
