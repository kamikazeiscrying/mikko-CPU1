`timescale 1ns / 1ps

// HILO 寄存器主要用于存放运算指令中计算得出的结果
// 32 位乘法指令中高32 位存在 HI 寄存器中，低 32 位存在 LO 寄存器中
// 32 位除法指令中余数存放在 HI寄存器中，除法结果存放在 LO 寄存器中

`include "bus.v"
module HILO(
    input clk,
    input rst,
    input write_en,
    input [`DATA_BUS] hi_write_data,
    input [`DATA_BUS] lo_write_data,
    output [`DATA_BUS] hi_read_data,
    output [`DATA_BUS] lo_read_data
);

    reg [`DATA_BUS] hi;
    reg [`DATA_BUS] lo;

    assign hi_read_data = hi;
    assign lo_read_data = lo;

    always @(posedge clk) begin
        if(rst) begin
            hi <= 0;
            lo <= 0;
        end 
        else if (write_en) begin
            hi <= hi_write_data;
            lo <= lo_write_data;
        end
    end
    
endmodule