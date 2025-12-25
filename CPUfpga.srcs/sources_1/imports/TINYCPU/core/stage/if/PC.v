`timescale 1ns / 1ps

// PC 为取指阶段核心部件，其主要功能用于更新指令地址，并将指令地址传输给 ROM

`include "bus.v"
`include "pcdef.v"

module PC(
  input                       clk,
  input                       rst,
  // stall signal
  input                       stall_pc,  //暂停信号
  // branch control
  input                       branch_flag,  //分支标志，用于判断是否需要分支，1代表跳转
  input       [`ADDR_BUS]     branch_addr,  //分支地址，用于指定分支的地址
  // to ID stage
  output  reg [`ADDR_BUS]     pc,  //程序计数器
  output      [`MEM_SEL_BUS]  rom_write_en,  //ROM写使能
  output      [`ADDR_BUS]     rom_addr,  //ROM地址
  output      [`DATA_BUS]     rom_write_data  //ROM写数据
);

  reg[`ADDR_BUS] next_pc;  //下一个PC地址

  assign rom_addr = next_pc;  //将下一个PC地址赋值给ROM地址
  assign rom_write_en = 0;  //ROM写使能清零
  assign rom_write_data = 0;  //ROM写数据清零

  always @(posedge clk) begin       //在时钟上升沿时，更新PC地址
    if ( rst ) begin
      pc <= `INIT_PC - 4;
    end
     else if (!stall_pc) begin
      pc <= next_pc;  //如果当前级不暂停，则将下一个PC地址赋值给PC地址    
    end
  end

  // generate value of next PC
  always @(*) begin
    if (!stall_pc) begin
      if (branch_flag) begin
        next_pc <= branch_addr;
      end
      else begin
        next_pc <= pc + 4;
      end
    end
    else begin
      // pc & rom_addr stall
      next_pc <= pc;
     end
  end


endmodule // PC
