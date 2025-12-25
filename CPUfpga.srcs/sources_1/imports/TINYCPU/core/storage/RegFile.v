`timescale 1ns / 1ps

// 寄存器文件本质上是小型、快速的存储元素，用于在处理过程中快速访问临时数据和指令
// RegFile 模块表示 CPU 内部的寄存器堆，用于存放 MIPS 中使用的 32 个通用寄存器
// 考虑到大部分 MIPS 指令会同时读取两个寄存器中的数据，需要设置两个读端口以及一个写端口
// 寄存器堆对于读数据是异步的，写数据是同步（需要上升沿触发）的

`include "bus.v"

module RegFile(
  input                       clk,
  input                       rst,
  // 读通道 #1
  input                       read_en_1,
  input       [`REG_ADDR_BUS] read_addr_1,
  output  reg [`DATA_BUS]     read_data_1,
  // 读通道 #2
  input                       read_en_2,
  input       [`REG_ADDR_BUS] read_addr_2,
  output  reg [`DATA_BUS]     read_data_2,
  // 写通道
  input                       write_en,
  input       [`REG_ADDR_BUS] write_addr,
  input       [`DATA_BUS]     write_data
);

  (*dont_touch = "true"*) reg[`DATA_BUS] registers[0:31];  // 32 个寄存器，每个寄存器 32 位 
  wire forward_flag;
  assign forward_flag = ( write_addr != 0 );  // 写地址不为 0 时，表示有写操作
 
  integer i;
  // 写操作
  always @(posedge clk) begin
    if (rst) begin
      for (i = 0; i < 32; i = i + 1) begin
        registers[i] <= 0;
        //reg_flag <= 0;
      end
    end
    else if ( write_en && |write_addr && write_addr!=5'b11000) begin
      registers[write_addr] <= write_data;
    end
  end

  // reading #1
  always @(*) begin
    if (rst) begin
      read_data_1 <= 0;
    end
    else if (read_addr_1 == write_addr && write_en && read_en_1 && forward_flag) begin
      // forward data to output
      read_data_1 <= write_data;
    end
    else if (read_en_1) begin
      read_data_1 <= registers[read_addr_1];
    end
    else begin
      read_data_1 <= 0;
    end
  end

  // reading @2
  always @(*) begin
    if (rst) begin
      read_data_2 <= 0;
    end
    else if (read_addr_2 == write_addr && write_en && read_en_2 && forward_flag) begin
      // forward data to output
      read_data_2 <= write_data;
    end
    else if (read_en_2) begin
      read_data_2 <= registers[read_addr_2];
    end
    else begin
      read_data_2 <= 0;
    end
  end

endmodule // RegFile
