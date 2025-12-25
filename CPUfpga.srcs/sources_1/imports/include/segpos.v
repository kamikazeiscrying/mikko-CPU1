// 定义 32 位指令各字段在指令中的位段
`ifndef TINYMIPS_SEGPOS_V_
`define TINYMIPS_SEGPOS_V_

// opcode 字段
`define SEG_OPCODE   31:26

// 寄存器字段
`define SEG_RS       25:21
`define SEG_RT       20:16
`define SEG_RD       15:11

// 立即数或偏移字段
`define SEG_IMM      15:0
`define SEG_OFFSET   15:0

// 移位量字段
`define SEG_SHAMT    10:6

// funct 字段
`define SEG_FUNCT    5:0

`endif  // TINYMIPS_SEGPOS_V_
