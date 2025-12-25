`timescale 1ns / 1ps

// 逻辑运算器模块，主要用于执行逻辑运算操作。
// 根据指令的类型，执行不同的逻辑运算操作。
// 包括或、与、异或、比较、移位等操作。

`include "bus.v"
`include "funct.v"

module Logic (
  input       [`FUNCT_BUS]        funct,
  input       [`SHAMT_BUS]        shamt,
  input                           logic_en,
  input       [`DATA_BUS]         operand_1,
  input       [`DATA_BUS]         operand_2,
  output reg  [`DATA_BUS]         result
);

  wire[`DATA_BUS] sub_result = operand_1 - operand_2;

  // 判断 operand_1 < operand_2
  wire operand_1_lt_operand_2 = funct == `FUNCT_SLT ?
        // operand_1 为负数 & operand_2 为正数
        ((operand_1[31] && !operand_2[31]) ||
          // operand_1 & operand_2 都是正数, operand_1 - operand_2 为负数
          (!operand_1[31] && !operand_2[31] && sub_result [31]) ||
          // operand_1 & operand_2 都是负数, operand_1 - operand_2 为负数
          (operand_1[31] && operand_2[31] && sub_result [31]))
          : (operand_1 < operand_2);

  always @(*) begin
    if ( logic_en ) begin
        case (funct)
            // 跳转并链接 & 逻辑
            `FUNCT_JALR, `FUNCT_OR: result <= operand_1 | operand_2;
            `FUNCT_AND: result <= operand_1 & operand_2;
            `FUNCT_XOR: result <= operand_1 ^ operand_2;
            // 比较
            `FUNCT_SLT, `FUNCT_SLTU: result <= {31'b0, operand_1_lt_operand_2};
            // 移位
            `FUNCT_SLL: result <= operand_2 << shamt;
            `FUNCT_SLLV: result <= operand_2 << operand_1[4:0];
            `FUNCT_SRLV: result <= operand_2 >> operand_1[4:0];
            `FUNCT_SRAV: result <= ({32{operand_2[31]}} << (6'd32 - {1'b0, operand_1[4:0]})) | operand_2 >> operand_1[4:0];
            default : result <= 0;
        endcase
    end
    else begin
        result <= 0;
    end
  end

endmodule
