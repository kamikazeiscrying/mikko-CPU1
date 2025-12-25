`timescale 1ns / 1ps

// 加法器模块，主要用于计算两个操作数的和。
// 考虑溢出情况，如果加法结果超出 32 位有符号数的表示范围，则产生溢出标志。

`include "bus.v"
`include "funct.v"

module Adder(
  input       [`FUNCT_BUS]    funct,
  input       add_en,
  input       [`DATA_BUS]     operand_1,
  input       [`DATA_BUS]     operand_2,
  output  reg [`DATA_BUS]     result,
  output                      overflow_flag
);

// 考虑溢出情况
 assign overflow_flag = add_en ?
          // operand_1 & operand_2 都是正数，结果为负数
          (!operand_1[31] && !operand_2[31] && result[31]) ||
          // operand_1 & operand_2 都是负数，结果为正数
          (operand_1[31] && operand_2[31] && !result[31]) : 0 ;

  wire[`DATA_BUS] op2;
  assign op2 = ( funct == `FUNCT_SUBU || funct == `FUNCT_SUB ) ? (~operand_2) + 1 : operand_2;
  
  always @(*) begin
      if (add_en) begin
        result = operand_1 + op2;          
      end
      else begin
        result <= 0;
      end
  end  

endmodule