`timescale 1ps / 1ps

module testbench;
    reg clk,rst;
    reg[4:0] btn;

    initial begin
        clk <= 1'b0;
        rst <= 1'b0;
        btn <= 5'b00000;

        #2 rst <= 1'b1;
    end
    always #1 clk <= ~clk;   

    Mycpu_top mycpu_top(
        .clk  (clk),
        .rst  (rst),
        .btn (btn)
    );
    
endmodule