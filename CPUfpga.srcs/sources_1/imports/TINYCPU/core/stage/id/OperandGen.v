`timescale 1ns / 1ps

// 生成 EX 阶段的两个操作数。
// 之前的 RegGen 模块只负责生成读RegFile 的控制信号，并没有把数据读出来。
// 而 OperandGen 模块要做的就是：
// 判断指令操作数来自寄存器堆还是立即数，然后从 RegFile 或者指令本身中，读出寄存器或立即数的值，作为操作数的输出。

`include "bus.v"
`include "opcode.v"
`include "funct.v"

module OperandGen(
  input       [`ADDR_BUS]       addr,
  input       [`INST_OP_BUS]    op,
  input                         operand_en,
  input       [`FUNCT_BUS]      funct,
  input       [`HALF_DATA_BUS]  imm,
  input       [`DATA_BUS]       reg_data_1,
  input       [`DATA_BUS]       reg_data_2,
  output  reg [`DATA_BUS]       operand_1,
  output  reg [`DATA_BUS]       operand_2
);

  // 计算链接地址
  wire[`ADDR_BUS] link_addr = addr + 8;

  // 提取立即数
  wire[`DATA_BUS] zero_ext_imm_hi = {imm, 16'b0};
  wire[`DATA_BUS] sign_ext_imm = { {16{imm[15]}},  imm };

  // 生成 operand_1
  always @(*) begin
    if(operand_en) begin
      case (op)
        // 立即数
        `OP_ADDIU, `OP_ADDI,
        `OP_ORI,`OP_LUI,
        `OP_XORI,`OP_ANDI,
        // 内存访问
        `OP_LB,`OP_LH,`OP_LW,`OP_LBU,`OP_LHU,
        `OP_SB,`OP_SH,`OP_SW,
        `OP_LWL,`OP_LWR,`OP_SWL,`OP_SWR,
        // 分支
        `OP_BNE,`OP_BEQ,`OP_BGTZ,`OP_BLEZ,`OP_REGIMM
        :begin
          operand_1 <= reg_data_1;
        end
        `OP_SPECIAL,`OP_SPECIAL2: begin
          operand_1 <= funct == `FUNCT_JALR ? link_addr : reg_data_1;
        end
        `OP_JAL,`OP_J: begin
          operand_1 <= link_addr;
        end
        default: begin
          operand_1 <= 0;
        end
      endcase
    end
    else begin
      operand_1 <= 0;
    end  
  end

  // 生成 operand_2
  always @(*) begin
    if(operand_en) begin
      case (op)
      `OP_LUI,`OP_ORI,
      `OP_XORI,
      `OP_ANDI
      : begin
        operand_2 <= zero_ext_imm_hi;
      end
      // 算术 & 逻辑 (立即数)
      `OP_ADDIU,`OP_ADDI,
      // 内存访问
      `OP_LB,`OP_LH,`OP_LW,`OP_LBU,`OP_LHU,
      `OP_SB,`OP_SH,`OP_SW,
      `OP_LWL,`OP_LWR,`OP_SWL,`OP_SWR
      : begin
        operand_2 <= sign_ext_imm;
      end
      // 分支
      `OP_BNE,`OP_BEQ,`OP_BGTZ,`OP_BLEZ,`OP_REGIMM,
      `OP_SPECIAL,`OP_SPECIAL2: begin
        operand_2 <= reg_data_2;
      end
      default: begin
        operand_2 <= 0;
      end
    endcase
    end
    else begin
      operand_2 <= 0;
    end
    
  end

endmodule // OperandGen
