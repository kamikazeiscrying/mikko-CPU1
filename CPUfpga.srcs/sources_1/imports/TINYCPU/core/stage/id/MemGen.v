`timescale 1ns / 1ps

// 生成访存指令相关的控制信号
// 当 mem_sel 为 4’b1111 时表示读取或写入 4 个字节内容（LW、SW）
// 当 mem_sel 为 4’b0001 时表示只读取或写入一个字节的内容（LB、LBU、SB ）。

`include "bus.v"
`include "opcode.v"

module MemGen(
  input       [`INST_OP_BUS]  op,
  input                       mem_en,
  input       [`DATA_BUS]     reg_data_2,
  output  reg                 mem_read_flag,
  output  reg                 mem_write_flag,
  output  reg                 mem_sign_flag,
  output  reg [`MEM_SEL_BUS]  mem_sel,           // 内存选择信号
  output  reg [`DATA_BUS]     mem_write_data
);

  // 生成内存访问控制信号
  always @(*) begin
    if ( mem_en ) begin
      case (op)
        `OP_SB, `OP_SW,`OP_SH: mem_write_flag <= 1;
        default: mem_write_flag <= 0;
      endcase      
    end
    else begin
        mem_write_flag <= 0;
    end
  end
  
  always @(*) begin
    if ( mem_en ) begin
      case (op)
        `OP_LB, `OP_LBU, `OP_LW, `OP_LH, `OP_LHU: mem_read_flag <= 1;
        default: mem_read_flag <= 0;
      endcase
    end
      else begin
        mem_read_flag <= 0;
      end
  end
  
  always @(*) begin
     if ( mem_en ) begin
        case (op)
          `OP_LB, `OP_LH: mem_sign_flag <= 1;
          default: mem_sign_flag <= 0;
        endcase
     end
     else begin
       mem_sign_flag <= 0;
     end
  end

  // mem_sel: lb & sb -> 1, lw & sw -> 1111
  always @(*) begin
    if ( mem_en ) begin
      case (op)
        `OP_LB, `OP_LBU,`OP_SB: mem_sel <= 4'b0001;
        `OP_SH, `OP_LHU,`OP_LH: mem_sel <= 4'b0011;
        `OP_LW, `OP_SW: mem_sel <= 4'b1111;
        default: mem_sel <= 4'b0000;
      endcase  
    end
    else begin
      mem_sel <= 4'b0000;
    end

  end

  // 生成写入内存的数据
  always @(*) begin
    if ( mem_en ) begin
      case (op)
        `OP_SB, `OP_SW, `OP_SH: mem_write_data <= reg_data_2;
        default: mem_write_data <= 0;
      endcase
    end
    else begin
       mem_write_data <= 0;
    end
  end

endmodule // MemGen
