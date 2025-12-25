`timescale 1ns / 1ps

// 寄存器读代理部件用于解决数据冒险问题  RAW冲突
// 如果模块发现 ID 正在读取的数据正好是 EX 或是 MEM 模块要写入的，那么就要将输出设为 EX 或 MEM 级的写入数据
// 反之直接输出 RegFile中读取的数据

`include "bus.v"

module RegReadProxy(
  // 从 ID 阶段传递过来的控制信号
  input                       read_en_1,
  input                       read_en_2,
  input       [`REG_ADDR_BUS] read_addr_1,
  input       [`REG_ADDR_BUS] read_addr_2,
  // 从寄存器文件传递过来的数据
  input       [`DATA_BUS]     data_1_from_reg,
  input       [`DATA_BUS]     data_2_from_reg,
  // 从 EX 阶段传递过来的控制信号 (解决数据冒险)
  input                       ex_load_flag,
  input                       reg_write_en_from_ex,
  input       [`REG_ADDR_BUS] reg_write_addr_from_ex,
  input       [`DATA_BUS]     data_from_ex,
  // 从 MEM 阶段传递过来的控制信号 (解决数据冒险)
  input                       mem_load_flag,
  input                       reg_write_en_from_mem,
  input       [`REG_ADDR_BUS] reg_write_addr_from_mem,
  input       [`DATA_BUS]     data_from_mem,
  // 加载相关信号
  output                      load_related_1,
  output                      load_related_2,
  // 寄存器数据输出 (WB 阶段)
  output  reg [`DATA_BUS]     read_data_1,
  output  reg [`DATA_BUS]     read_data_2
);

  // 生成加载相关信号
  assign load_related_1 =
      ( ex_load_flag && read_en_1 && read_addr_1 == reg_write_addr_from_ex) ||
      ( mem_load_flag && read_en_1 && read_addr_1 == reg_write_addr_from_mem);
  assign load_related_2 =
      ( ex_load_flag && read_en_2 && read_addr_2 == reg_write_addr_from_ex) ||
      ( mem_load_flag && read_en_2 && read_addr_2 == reg_write_addr_from_mem);

  assign ex_flag = ( reg_write_addr_from_ex != 0 );
  assign mem_flag = ( reg_write_addr_from_mem != 0 );
  // 生成输出 read_data_1
  always @(*) begin
    if (read_en_1) begin
      if ( reg_write_en_from_ex &&
          read_addr_1 == reg_write_addr_from_ex && ex_flag) begin
        read_data_1 <= data_from_ex;
      end
      else if (reg_write_en_from_mem &&
          read_addr_1 == reg_write_addr_from_mem && mem_flag) begin
        read_data_1 <= data_from_mem;
      end
      else begin
        read_data_1 <= data_1_from_reg;
      end
    end
    else begin
      read_data_1 <= 0;
    end
  end

  // 生成输出 read_data_2
  always @(*) begin
    if (read_en_2) begin
      if (reg_write_en_from_ex &&
          read_addr_2 == reg_write_addr_from_ex && ex_flag) begin
        read_data_2 <= data_from_ex;
      end
      else if (reg_write_en_from_mem &&
          read_addr_2 == reg_write_addr_from_mem && mem_flag) begin
        read_data_2 <= data_from_mem;
      end
      else begin
        read_data_2 <= data_2_from_reg;
      end
    end
    else begin
      read_data_2 <= 0;
    end
  end

endmodule // RegReadProxy
