`timescale 1ns / 1ps

// 流水线中间级
// 用于在时钟上升沿时将上一个流水级的输出锁存（锁存器），并且传递给下一个流水级作为输入
// 内部可以由多个 D 触发器实现
// 在多级流水线中作为阶段间寄存器，配合暂停/气泡控制，确保数据与控制流正确推进或停滞。

module PipelineDeliver #(
  parameter WIDTH = 1
) (
  input                     clk,
  input                     rst,
  input                     stall_current_stage, //当前级暂停信号
  input                     stall_next_stage,    //下一级暂停信号
  input       [WIDTH - 1:0] in,                //上一级输出（待锁存的数据）
  output  reg [WIDTH - 1:0] out                //本级寄存的输出，供下一级使用
);

  always @(posedge clk) begin  //在时钟上升沿时，将输入数据锁存到输出数据
    if (rst) begin
      out <= 0;  //复位时，输出清零
    end
    else if (stall_current_stage && !stall_next_stage) begin
      out <= 0;  //当前级暂停，且下一级不暂停时，插入一个“气泡”，防止把陈旧数据推进去，同时清空本级输出
    end
    else if (!stall_current_stage) begin
      out <= in;  //当前级不暂停时，将输入数据锁存到输出数据  
    end
  end

endmodule // PipelineDeliver
