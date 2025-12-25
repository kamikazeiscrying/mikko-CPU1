`timescale 1ns / 1ps

// 生成所有与寄存器读写相关的控制信号。
// 对所有 OP_SPECIAL 的指令（R 型指令）而言，我们需要同时读取 rs 与 rt 的内容，并将结果写入 rd 寄存器。
// 而对于 OP_ADDIU 这条 I 型指令，只需读取 rs 寄存器的值（因为另一个操作数是立即 数而非寄存器），并将结果写入 rt 寄存器。

`include "bus.v"
`include "opcode.v"
`include "funct.v"

module RegGen(
  input       [`INST_OP_BUS]  op,
  input                       reg_en,
  input       [`REG_ADDR_BUS] rs,
  input       [`REG_ADDR_BUS] rt,
  input       [`REG_ADDR_BUS] rd,
  output  reg                 reg_read_en_1,
  output  reg                 reg_read_en_2,
  output  reg [`REG_ADDR_BUS] reg_addr_1,
  output  reg [`REG_ADDR_BUS] reg_addr_2,
  output  reg                 reg_write_en,
  output  reg [`REG_ADDR_BUS] reg_write_addr
);

  // 生成读地址
  always @(*) begin
    if (reg_en) begin
      case (op)
      // 算术 & 逻辑 (立即数)
      `OP_ADDIU,`OP_ADDI,
      `OP_LUI,`OP_ORI,
      `OP_XORI,
      `OP_ANDI,
      // 内存访问
      `OP_LB, `OP_LW, `OP_LBU: begin
        reg_read_en_1 <= 1;
        reg_read_en_2 <= 0;
        reg_addr_1 <= rs;
        reg_addr_2 <= 0;
      end
      // 分支
      `OP_BEQ, `OP_BNE,`OP_BGTZ,`OP_BLEZ,`OP_REGIMM,
      // 内存访问
      `OP_SB,`OP_SH,`OP_SW,`OP_LWL,`OP_LWR,`OP_SWL,`OP_SWR,
      // R 型
      `OP_SPECIAL,`OP_SPECIAL2: begin
        reg_read_en_1 <= 1;
        reg_read_en_2 <= 1;
        reg_addr_1 <= rs;
        reg_addr_2 <= rt;
      end
      default: begin  // `OP_JAL, `OP_LUI
        reg_read_en_1 <= 0;
        reg_read_en_2 <= 0;
        reg_addr_1 <= 0;
        reg_addr_2 <= 0;
      end
    endcase
  end
    else begin
        reg_read_en_1 <= 0;
        reg_read_en_2 <= 0;
        reg_addr_1 <= 0;
        reg_addr_2 <= 0;
    end

 
  end

  // 生成写地址
  always @(*) begin
    if(reg_en) begin
      case (op)
      // 立即数
      `OP_ADDIU, `OP_ADDI,
      `OP_LUI,`OP_ORI,
      `OP_XORI,
      `OP_ANDI
      : begin
        reg_write_en <= 1;
        reg_write_addr <= rt;
      end
      `OP_SPECIAL,`OP_SPECIAL2: begin
        reg_write_en <= 1;
        reg_write_addr <= rd;
      end
      `OP_JAL: begin
        reg_write_en <= 1;
        reg_write_addr <= 31;   // $ra (返回地址)
      end
      `OP_LB,`OP_LH,`OP_LW,`OP_LBU,`OP_LHU: begin
        reg_write_en <= 1;
        reg_write_addr <= rt;
      end
      `OP_REGIMM: begin
        if ( rt == `FUNCT_BLTZAL || rt == `FUNCT_BGEZAL ) begin
          reg_write_en <= 1;
          reg_write_addr <= 31;   // $ra (返回地址)          
        end
        else begin
          reg_write_en <= 0;
          reg_write_addr <= 0;           
        end
      end
      default: begin
        reg_write_en <= 0;
        reg_write_addr <= 0;
      end
    endcase
    end
    else begin
        reg_write_en <= 0;
        reg_write_addr <= 0;
    end
 
  end

endmodule // RegGen
