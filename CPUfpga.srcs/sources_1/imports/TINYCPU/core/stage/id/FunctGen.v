`timescale 1ns / 1ps

// 操作码 funct 生成模块，主要用于读取指令中的 funct 段并进行归一化，输出最终提交给 EX 的 funct。
// 因为当 OP 段（指令的操作码）为 SPECIAL 时候的指令已经带有了 funct 字段，只需将指令自己的 funct 字段赋值给输出的 funct
// 而对于其他指令，如访存指令，其在执行阶段只是计算访存地址加法运算，因此完全可以根据具体情况，将这些指令归并在一起。


`include "bus.v"
`include "opcode.v"
`include "funct.v"

module FunctGen(
  input       [`INST_OP_BUS]  op,
  input                       funct_en,
  input       [`FUNCT_BUS]    funct_in,
  output  reg [`FUNCT_BUS]    funct
);

  // 生成 FUNCT 信号，以便于 ALU 执行操作
  always @(*) begin
    if ( funct_en ) begin
      case (op)
        `OP_SPECIAL,`OP_SPECIAL2: funct <= funct_in;
        `OP_LUI,`OP_ORI: funct <= `FUNCT_OR;
        `OP_XORI: funct <= `FUNCT_XOR;
        `OP_ANDI: funct <= `FUNCT_AND;
        `OP_SB, `OP_SW, `OP_ADDIU, `OP_ADDI,
        `OP_LBU, `OP_LHU, 
        `OP_LB, `OP_LH, `OP_LW: funct <= `FUNCT_ADDU;
        `OP_JAL,`OP_J,`OP_BEQ,`OP_BNE,`OP_BGTZ,`OP_BLEZ,`OP_REGIMM: funct <= `FUNCT_OR;
        default: funct <= `FUNCT_NOP;
      endcase
    end
    else begin
      funct <= `FUNCT_NOP;
    end
  end

endmodule // FunctGen
