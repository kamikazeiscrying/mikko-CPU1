`timescale 1ns / 1ps

// RAM 用于保存数据。
// RAM 在设计当中，对读取是异步的，给出地址就能得到数据；（数据可以在给定地址后立即被读取，无需等待时钟信号）
// 写入是同步的，只当时钟上升沿的时候才会写入。
// RAM 存储容量为 128B。对于一个 32 位的数据，我们按字节分为 4 个部分。

`include "bus.v"
`include "sim.v"

module RAM(
  input                       clk,
  input                       ram_en,
  input       [`MEM_SEL_BUS]  ram_write_en,   // 以 1 的位置用来控制写入 RAM 的位置。
  input       [`ADDR_BUS]     ram_addr,
  input       [`DATA_BUS]     ram_write_data,
  output  reg [`DATA_BUS]     ram_read_data
);

// 例如，当 ram_write_en=4’b1111 时，我们对 32 位进行写入；
// 为 4’b0001 时，写入低 8 位；为 4’b1100 时，对高 16 位进行写入。

  reg[7:0] data_mem0[`DATA_MEM_BUS];
  reg[7:0] data_mem1[`DATA_MEM_BUS];
  reg[7:0] data_mem2[`DATA_MEM_BUS];
  reg[7:0] data_mem3[`DATA_MEM_BUS];

  // write operation
  always @(posedge clk) begin
    if (ram_en && |ram_write_en) begin
      if (ram_write_en[3]) data_mem3[ram_addr[`DATA_MEM_ADDR_WIDTH + 1:2]] <= ram_write_data[31:24];
      if (ram_write_en[2]) data_mem2[ram_addr[`DATA_MEM_ADDR_WIDTH + 1:2]] <= ram_write_data[23:16];
      if (ram_write_en[1]) data_mem1[ram_addr[`DATA_MEM_ADDR_WIDTH + 1:2]] <= ram_write_data[15:8];
      if (ram_write_en[0]) data_mem0[ram_addr[`DATA_MEM_ADDR_WIDTH + 1:2]] <= ram_write_data[7:0];
    end
  end

  // read operation
  always @(*) begin
    if (!ram_en || |ram_write_en) begin
      ram_read_data <= 0;
    end
    else begin
      ram_read_data <= {
        data_mem3[ram_addr[`DATA_MEM_ADDR_WIDTH + 1:2]],
        data_mem2[ram_addr[`DATA_MEM_ADDR_WIDTH + 1:2]],
        data_mem1[ram_addr[`DATA_MEM_ADDR_WIDTH + 1:2]],
        data_mem0[ram_addr[`DATA_MEM_ADDR_WIDTH + 1:2]]
      };
    end
  end

endmodule // RAM
