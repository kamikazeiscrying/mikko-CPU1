// 定义 MIPS 指令的 funct/分支功能码常量
// funct为函数功能码，主要用于 special 型指令中指示寄存器指令的具体功能

`ifndef TINYMIPS_FUNCT_V_
`define TINYMIPS_FUNCT_V_

// 移位类
`define FUNCT_SLL       6'b000000
`define FUNCT_SLLV      6'b000100
`define FUNCT_SRLV      6'b000110
`define FUNCT_SRAV      6'b000111

// 跳转类
`define FUNCT_JALR      6'b001001
`define FUNCT_JR        6'b001000

// 算术类
`define FUNCT_ADD       6'b100000
`define FUNCT_ADDU      6'b100001
`define FUNCT_SUB       6'b100010
`define FUNCT_SUBU      6'b100011

// 逻辑类
`define FUNCT_AND       6'b100100
`define FUNCT_OR        6'b100101
`define FUNCT_XOR       6'b100110

// 比较类
`define FUNCT_SLT       6'b101010
`define FUNCT_SLTU      6'b101011

// 来自 OP_SPECIAL2
`define FUNCT_MADD       6'b000000
`define FUNCT_MADDU      6'b000001
`define FUNCT_MSUB       6'b000100
`define FUNCT_MSUBU      6'b000101
`define FUNCT_CLZ        6'b100000
`define FUNCT_CLO        6'b100001
`define FUNCT_MUL        6'b000010

// 来自 OP_REGIMM
`define FUNCT_BLTZ       5'b00000
`define FUNCT_BLTZAL     5'b10000
`define FUNCT_BGEZ       5'b00001
`define FUNCT_BGEZAL     5'b10001

// HI / LO 相关
`define FUNCT_MFHI      6'b010000
`define FUNCT_MTHI      6'b010001
`define FUNCT_MFLO      6'b010010
`define FUNCT_MTLO      6'b010011

// 中断/异常类
`define FUNCT_BREAK     6'b001101

// 乘法与除法
`define FUNCT_MULT      6'b011000
`define FUNCT_MULTU     6'b011001
`define FUNCT_DIV       6'b011010
`define FUNCT_DIVU      6'b011011

// 注意：非常规用法
// 当前 MIPS ISA 中 '111111' 无含义，被视为 NOP
// 未来版本可能会定义为其他用途
`define FUNCT_NOP       6'b111111

`endif  // TINYMIPS_FUNCT_V_
