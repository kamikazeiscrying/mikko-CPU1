## 项目概览
- 这是一个基于五级流水线的精简 MIPS CPU（TINYCPU），包含取指(IF)→译码(ID)→执行(EX)→访存(MEM)→回写(WB)全流程，以及前递/暂停控制、HI/LO 乘除单元和调试可视化电路。  
- 工程提供 FPGA 上板顶层 `Mycpu_top`、仿真用 `ROM/RAM`、以及按键/数码管/LED 的人机接口。默认内置一段示例指令序列（`sim/ROM.v` 中的初始化）用于验证算术、乘除与跳转。

## 目录结构
- `sources_1/imports/include/`：总线与常量定义（`bus.v`、`opcode.v`、`funct.v`、`pcdef.v`、`segpos.v`、`sim.v`）。
- `sources_1/imports/TINYCPU/core/`：CPU 主体  
  - `stage/if,id,ex,mem,wb/`：各流水级实现与级间寄存器 `IFID/IDEX/EXMEM/MEMWB`。  
  - `pipeline/`：流水控制与通用寄存模块。  
  - `storage/`：通用寄存器堆、HI/LO 寄存器与旁路代理。  
  - `Core.v`：将各级、旁路与暂停控制连线的顶层。
- `sources_1/imports/TINYCPU/fpga/`：上板外设逻辑（按键防抖 `btn_out`、暂停按钮 `Stall_btn`、开关直连 LED、八选一调试多路复用 `mux_5to1`、数码管驱动 `Digic_led/Digic_seg/Counter`、顶层 `Mycpu_top`）。
- `sources_1/imports/TINYCPU/sim/`：仿真内存模型 `ROM.v`、`RAM.v`，指令存储默认 256B，数据存储 32 words。
- `sim_1/new/testbench.v`：简单仿真激励（时钟/复位/按键）。
- `constrs_1/imports/fpga/digic_led.xdc`：FPGA 约束示例（引脚与时钟约束）。
- `操作说明.md`：面向上板的按键/开关/显示操作指南。

## 设计要点
- **顶层互连**：`Mycpu_top` 将 `Core` 与 ROM/RAM、暂停按钮、拨码开关选择的调试总线、多路复用后的数码管显示、LED 状态指示对接。`stall` 由 `btn[1]` 解除（上电默认暂停）。  
- **流水线与暂停**：`PipelineController` 按 ID（load-use）与 EX（乘/除未完成）请求产生分级 `stall_pc/if/id/ex/mem/wb`；`PipelineDeliver` 负责级间寄存保持与气泡注入。  
- **旁路/冒险处理**：`RegReadProxy` 根据 EX/MEM 写回信息与 load 标记，实现数据前递并检测 load-use 冒险；`HILOReadProxy` 提供 HI/LO 写后读前递。  
- **执行单元**：  
  - 算术/逻辑：`Adder`（带溢出检测）、`Logic`（移位/逻辑/比较）、`Mux` 汇总结果。  
  - 乘除：`Multiplier`（串行乘法，`full_adder`/`rca` 结构）与 `Divider`（CAS 阵列），完成后写 HI/LO。  
  - HI/LO：`Hilo_Gen` 负责 `MFHI/MFLO/MTHI/MTLO` 以及乘除结果写回。  
- **访存**：`MemGen` 译码出读/写/符号扩展/字节选信号；`MEM` 生成 RAM 控制信号并合成访存结果；`RAM`/`ROM` 是简化的行为级模型。  
- **指令支持概览**：R 型 `ADD/ADDU/SUB/SUBU/AND/OR/XOR/SLT/SLL/SLLV/SRLV/SRAV/JR/JALR/MFHI/MTLO/MFLO/MTHI/MULT/DIV`，I/J 型 `ADDI/ADDIU/ANDI/ORI/XORI/LUI/LB/LH/LW/LBU/LHU/SB/SH/SW/LWL/LWR/SWL/SWR/BEQ/BNE/BGTZ/BLEZ`，以及 `J/JAL`、延迟槽标记。分支/跳转在 ID 生成 `branch_flag` 与 `branch_addr`，PC 直接跳转。
- **调试可视化**：`mux_5to1` 根据 `switch[7:0]` 选择显示 `debug_pc/operand_1/operand_2/branch_addr/wb_result/hi/lo/ifid_inst`，`Digic_led` 将 32 位数据按 8 位十六进制轮显；`small_led`/`led` 直接映射按钮与开关状态。

## 内置程序（ROM 初始化）
- `sim/ROM.v` 在复位时写入一段示例指令：设置寄存器、进行加法、乘法、除法并跳回起始地址，可用来观察 PC、写回结果及 HI/LO 的变化。需要自定义程序时，修改 `inst_mem[...] <= 32'hxxxx_xxxx;` 的初始化块即可。

## 仿真指南（Vivado/iverilog 等）
1. 将 `sources_1/imports/TINYCPU` 与 `sources_1/imports/include`、`sources_1/imports/TINYCPU/sim` 加入仿真工程，设 `Mycpu_top` 或 `Core` 为仿真顶层。  
2. 使用现有 `sim_1/new/testbench.v` 或自行编写 testbench，必要时连接 `switch/seg_code/pos` 等调试端口。  
3. 运行行为仿真，重点观测 `debug_*` 信号、`ram_*` 读写以及 `stall` 行为，验证数据冒险与分支处理。

## 上板要点
- 参考 `操作说明.md`：上电默认暂停，按下并释放 `btn[1]` 后开始运行；拨码开关选择显示内容；LED 显示输入状态。  
- 使用 Vivado 新建 FPGA 工程，添加源码目录与 `constrs_1/imports/fpga/digic_led.xdc`，设 `Mycpu_top` 为综合顶层，生成并下载比特流。  
- 若需更换程序，修改 `sim/ROM.v` 后重新综合；若需外部存储或真实 ROM，可用 IP/Block RAM 替换行为模型并保持接口一致。

## 扩展与定制建议
- 增加指令：在 `opcode.v/funct.v` 定义后，补充 `RegGen/OperandGen/MemGen/EX` 中的译码与执行路径。  
- 调试信号：在 `Core.v` 增加新的 `debug_*` 连线，并在 `mux_5to1` 扩展选择分支与显示顺序。  
- 程序/容量：调整 `sim.v` 的地址宽度以扩大 ROM/RAM；或接入外部指令/数据总线。  
- 性能：当前乘/除为多周期，EX 会发起暂停；可替换为流水化乘法器或硬核 IP 减少停顿。 

