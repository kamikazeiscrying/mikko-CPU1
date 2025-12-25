`timescale 1ns / 1ps

// 流水线控制器用于控制流水线的暂停和气泡插入，确保数据正确传递和处理。

`include "bus.v"

module PipelineController(
  // 暂停请求信号
  input                     request_from_id,
  input                     request_from_ex,
  // 暂停整个流水线
  input                     stall_all,

  // 每个中间级的暂停信号
  output                    stall_pc,
  output                    stall_if,
  output                    stall_id, // ID 级暂停信号
  output                    stall_ex, // EX 级暂停信号
  output                    stall_mem, // MEM 级暂停信号
  output                    stall_wb
);

  reg[5:0] stall;

  // 赋值暂停信号
  assign {stall_wb, stall_mem, stall_ex,
          stall_id, stall_if, stall_pc} = stall;

  always @(*) begin
    if (stall_all) begin
      stall <= 6'b111111;
    end
    else if (request_from_id) begin
      stall <= 6'b000111;
    end
    else if (request_from_ex) begin
      stall <= 6'b001111;
    end
    else begin
      stall <= 6'b000000;
    end
  end


endmodule // PipelineController
