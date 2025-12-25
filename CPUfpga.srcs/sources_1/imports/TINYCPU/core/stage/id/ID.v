`timescale 1ns / 1ps

// 将 IF 阶段传递过来的指令进行译码，生成各类控制信号，并将这些信号传递给流水线的其余部件（IF、EX、MEM、WB）
// 判断指令类型并得到指令的操作数：如果为 I 型（立即数型）指令，则从指令中读取其中的立即数；
// 如果为 R 型（寄存器型）指令，则通过指令内的寄存器编号将数据从 RegFile 中取出；
// 获取指令的目的寄存器号，并将此信息作为输出传递到 WB 级，以便于将指令的执行结果写回 RegFile。

`include "bus.v"
`include "segpos.v"
`include "opcode.v"
`include "funct.v"

module ID(
  //  取指阶段传递过来的指令地址和指令
  input   [`ADDR_BUS]     addr,
  input   [`INST_BUS]     inst,
  //  加载相关信号
  input                   load_related_1,
  input                   load_related_2,
  //  延迟槽标志
  input                   delayslot_flag_in,
  //  寄存器通道 #1
  output                  reg_read_en_1,
  output  [`REG_ADDR_BUS] reg_addr_1,
  input   [`DATA_BUS]     reg_data_1,
  //  寄存器通道 #2
  output                  reg_read_en_2,
  output  [`REG_ADDR_BUS] reg_addr_2,
  input   [`DATA_BUS]     reg_data_2,
  //  暂停请求
  output                  stall_request,
  //  传递给取指阶段
  output                  branch_flag,
  output  [`ADDR_BUS]     branch_addr,
  //  传递给执行阶段
  output  [`FUNCT_BUS]    funct,
  output  [`SHAMT_BUS]    shamt,
  output  [`DATA_BUS]     operand_1,
  output  [`DATA_BUS]     operand_2,
  //  传递给存储阶段
  output                  mem_read_flag,
  output                  mem_write_flag,
  output                  mem_sign_flag,
  output  [`MEM_SEL_BUS]  mem_sel,
  output  [`DATA_BUS]     mem_write_data,
  //  传递给写回阶段
  output                  reg_write_en,
  output  [`REG_ADDR_BUS] reg_write_addr,
  output  [`ADDR_BUS]     current_pc_addr,

  //  异常信号  
  output                  delayslot_flag_out,
  output                  next_inst_delayslot_flag
);

  // 从指令中提取信息
  wire[`INST_OP_BUS]    inst_op     = inst[`SEG_OPCODE];
  wire[`REG_ADDR_BUS]   inst_rs     = inst[`SEG_RS];
  wire[`REG_ADDR_BUS]   inst_rt     = inst[`SEG_RT];
  wire[`REG_ADDR_BUS]   inst_rd     = inst[`SEG_RD];
  wire[`SHAMT_BUS]      inst_shamt  = inst[`SEG_SHAMT];
  wire[`FUNCT_BUS]      inst_funct  = inst[`SEG_FUNCT];
  wire[`HALF_DATA_BUS]  inst_imm    = inst[`SEG_IMM];
  wire                  id_en;
  // 生成输出信号
  assign shamt = inst_shamt;
  assign stall_request = load_related_1 || load_related_2;
  assign current_pc_addr = addr;
  assign delayslot_flag_out = delayslot_flag_in;
  assign id_en = ~delayslot_flag_in;
  assign next_inst_delayslot_flag = branch_flag;
  
  // 生成寄存器地址
  RegGen reg_gen(
    .op             (inst_op),
    .reg_en         (id_en),
    .rs             (inst_rs),
    .rt             (inst_rt),
    .rd             (inst_rd),
    .reg_read_en_1  (reg_read_en_1),
    .reg_read_en_2  (reg_read_en_2),
    .reg_addr_1     (reg_addr_1),
    .reg_addr_2     (reg_addr_2),
    .reg_write_en   (reg_write_en),
    .reg_write_addr (reg_write_addr)
  );

  // 生成 FUNCT 信号
  FunctGen funct_gen(
    .op       (inst_op),
    .funct_en (id_en),
    .funct_in (inst_funct),
    .funct    (funct)
  );

  // 生成操作数
  OperandGen operand_gen(
    .addr       (addr),
    .operand_en (id_en),
    .op         (inst_op),
    .funct      (inst_funct),
    .imm        (inst_imm),
    .reg_data_1 (reg_data_1),
    .reg_data_2 (reg_data_2),
    .operand_1  (operand_1),
    .operand_2  (operand_2)
  );

  // 生成分支地址
  BranchGen branch_gen(
    .addr         (addr),
    .branch_en    (id_en),
    .inst         (inst),
    .op           (inst_op),
    .funct        (inst_funct),
    .reg_data_1   (reg_data_1),
    .reg_data_2   (reg_data_2),
    .branch_flag  (branch_flag),
    .branch_addr  (branch_addr)
  );

  // 生成内存访问信号
  MemGen mem_gen(
    .op                 (inst_op),
    .mem_en             (id_en),
    .reg_data_2         (reg_data_2),
    .mem_read_flag      (mem_read_flag),
    .mem_write_flag     (mem_write_flag),
    .mem_sign_flag      (mem_sign_flag),
    .mem_sel            (mem_sel),
    .mem_write_data     (mem_write_data)
  );

endmodule // ID