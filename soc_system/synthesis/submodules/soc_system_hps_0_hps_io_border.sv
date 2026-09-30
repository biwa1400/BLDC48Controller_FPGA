// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module soc_system_hps_0_hps_io_border(
// gpio_loanio
  output wire [29 - 1 : 0 ] gpio_loanio_loanio0_i
 ,input wire [29 - 1 : 0 ] gpio_loanio_loanio0_oe
 ,input wire [29 - 1 : 0 ] gpio_loanio_loanio0_o
 ,output wire [29 - 1 : 0 ] gpio_loanio_loanio1_i
 ,input wire [29 - 1 : 0 ] gpio_loanio_loanio1_oe
 ,input wire [29 - 1 : 0 ] gpio_loanio_loanio1_o
 ,output wire [9 - 1 : 0 ] gpio_loanio_loanio2_i
 ,input wire [9 - 1 : 0 ] gpio_loanio_loanio2_oe
 ,input wire [9 - 1 : 0 ] gpio_loanio_loanio2_o
// memory
 ,output wire [15 - 1 : 0 ] mem_a
 ,output wire [3 - 1 : 0 ] mem_ba
 ,output wire [1 - 1 : 0 ] mem_ck
 ,output wire [1 - 1 : 0 ] mem_ck_n
 ,output wire [1 - 1 : 0 ] mem_cke
 ,output wire [1 - 1 : 0 ] mem_cs_n
 ,output wire [1 - 1 : 0 ] mem_ras_n
 ,output wire [1 - 1 : 0 ] mem_cas_n
 ,output wire [1 - 1 : 0 ] mem_we_n
 ,output wire [1 - 1 : 0 ] mem_reset_n
 ,inout wire [32 - 1 : 0 ] mem_dq
 ,inout wire [4 - 1 : 0 ] mem_dqs
 ,inout wire [4 - 1 : 0 ] mem_dqs_n
 ,output wire [1 - 1 : 0 ] mem_odt
 ,output wire [4 - 1 : 0 ] mem_dm
 ,input wire [1 - 1 : 0 ] oct_rzqin
// hps_io
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_CMD
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_D0
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_D1
 ,output wire [1 - 1 : 0 ] hps_io_sdio_inst_CLK
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_D2
 ,inout wire [1 - 1 : 0 ] hps_io_sdio_inst_D3
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D0
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D1
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D2
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D3
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D4
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D5
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D6
 ,inout wire [1 - 1 : 0 ] hps_io_usb1_inst_D7
 ,input wire [1 - 1 : 0 ] hps_io_usb1_inst_CLK
 ,output wire [1 - 1 : 0 ] hps_io_usb1_inst_STP
 ,input wire [1 - 1 : 0 ] hps_io_usb1_inst_DIR
 ,input wire [1 - 1 : 0 ] hps_io_usb1_inst_NXT
 ,input wire [1 - 1 : 0 ] hps_io_uart0_inst_RX
 ,output wire [1 - 1 : 0 ] hps_io_uart0_inst_TX
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO00
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO14
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO15
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO16
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO17
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO18
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO19
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO22
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO23
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO24
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO25
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO26
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO27
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO29
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO30
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO31
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO32
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO34
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO48
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO49
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO50
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO51
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO52
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO53
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO54
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO55
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO56
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO57
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO58
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO59
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO60
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO63
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO64
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO65
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO66
);

assign hps_io_sdio_inst_CMD = intermediate[1] ? intermediate[0] : 'z;
assign hps_io_sdio_inst_D0 = intermediate[3] ? intermediate[2] : 'z;
assign hps_io_sdio_inst_D1 = intermediate[5] ? intermediate[4] : 'z;
assign hps_io_sdio_inst_D2 = intermediate[7] ? intermediate[6] : 'z;
assign hps_io_sdio_inst_D3 = intermediate[9] ? intermediate[8] : 'z;
assign hps_io_usb1_inst_D0 = intermediate[11] ? intermediate[10] : 'z;
assign hps_io_usb1_inst_D1 = intermediate[13] ? intermediate[12] : 'z;
assign hps_io_usb1_inst_D2 = intermediate[15] ? intermediate[14] : 'z;
assign hps_io_usb1_inst_D3 = intermediate[17] ? intermediate[16] : 'z;
assign hps_io_usb1_inst_D4 = intermediate[19] ? intermediate[18] : 'z;
assign hps_io_usb1_inst_D5 = intermediate[21] ? intermediate[20] : 'z;
assign hps_io_usb1_inst_D6 = intermediate[23] ? intermediate[22] : 'z;
assign hps_io_usb1_inst_D7 = intermediate[25] ? intermediate[24] : 'z;
assign hps_io_gpio_inst_LOANIO00 = intermediate[27] ? intermediate[26] : 'z;
assign hps_io_gpio_inst_LOANIO14 = intermediate[29] ? intermediate[28] : 'z;
assign hps_io_gpio_inst_LOANIO15 = intermediate[31] ? intermediate[30] : 'z;
assign hps_io_gpio_inst_LOANIO16 = intermediate[33] ? intermediate[32] : 'z;
assign hps_io_gpio_inst_LOANIO17 = intermediate[35] ? intermediate[34] : 'z;
assign hps_io_gpio_inst_LOANIO18 = intermediate[37] ? intermediate[36] : 'z;
assign hps_io_gpio_inst_LOANIO19 = intermediate[39] ? intermediate[38] : 'z;
assign hps_io_gpio_inst_LOANIO22 = intermediate[41] ? intermediate[40] : 'z;
assign hps_io_gpio_inst_LOANIO23 = intermediate[43] ? intermediate[42] : 'z;
assign hps_io_gpio_inst_LOANIO24 = intermediate[45] ? intermediate[44] : 'z;
assign hps_io_gpio_inst_LOANIO25 = intermediate[47] ? intermediate[46] : 'z;
assign hps_io_gpio_inst_LOANIO26 = intermediate[49] ? intermediate[48] : 'z;
assign hps_io_gpio_inst_LOANIO27 = intermediate[51] ? intermediate[50] : 'z;
assign hps_io_gpio_inst_LOANIO29 = intermediate[53] ? intermediate[52] : 'z;
assign hps_io_gpio_inst_LOANIO30 = intermediate[55] ? intermediate[54] : 'z;
assign hps_io_gpio_inst_LOANIO31 = intermediate[57] ? intermediate[56] : 'z;
assign hps_io_gpio_inst_LOANIO32 = intermediate[59] ? intermediate[58] : 'z;
assign hps_io_gpio_inst_LOANIO34 = intermediate[61] ? intermediate[60] : 'z;
assign hps_io_gpio_inst_LOANIO48 = intermediate[63] ? intermediate[62] : 'z;
assign hps_io_gpio_inst_LOANIO49 = intermediate[65] ? intermediate[64] : 'z;
assign hps_io_gpio_inst_LOANIO50 = intermediate[67] ? intermediate[66] : 'z;
assign hps_io_gpio_inst_LOANIO51 = intermediate[69] ? intermediate[68] : 'z;
assign hps_io_gpio_inst_LOANIO52 = intermediate[71] ? intermediate[70] : 'z;
assign hps_io_gpio_inst_LOANIO53 = intermediate[73] ? intermediate[72] : 'z;
assign hps_io_gpio_inst_LOANIO54 = intermediate[75] ? intermediate[74] : 'z;
assign hps_io_gpio_inst_LOANIO55 = intermediate[77] ? intermediate[76] : 'z;
assign hps_io_gpio_inst_LOANIO56 = intermediate[79] ? intermediate[78] : 'z;
assign hps_io_gpio_inst_LOANIO57 = intermediate[81] ? intermediate[80] : 'z;
assign hps_io_gpio_inst_LOANIO58 = intermediate[83] ? intermediate[82] : 'z;
assign hps_io_gpio_inst_LOANIO59 = intermediate[85] ? intermediate[84] : 'z;
assign hps_io_gpio_inst_LOANIO60 = intermediate[87] ? intermediate[86] : 'z;
assign hps_io_gpio_inst_LOANIO63 = intermediate[89] ? intermediate[88] : 'z;
assign hps_io_gpio_inst_LOANIO64 = intermediate[91] ? intermediate[90] : 'z;
assign hps_io_gpio_inst_LOANIO65 = intermediate[93] ? intermediate[92] : 'z;
assign hps_io_gpio_inst_LOANIO66 = intermediate[95] ? intermediate[94] : 'z;

wire [96 - 1 : 0] intermediate;

wire [93 - 1 : 0] floating;

cyclonev_hps_peripheral_sdmmc sdio_inst(
 .SDMMC_DATA_I({
    hps_io_sdio_inst_D3[0:0] // 3:3
   ,hps_io_sdio_inst_D2[0:0] // 2:2
   ,hps_io_sdio_inst_D1[0:0] // 1:1
   ,hps_io_sdio_inst_D0[0:0] // 0:0
  })
,.SDMMC_CMD_O({
    intermediate[0:0] // 0:0
  })
,.SDMMC_CCLK({
    hps_io_sdio_inst_CLK[0:0] // 0:0
  })
,.SDMMC_DATA_O({
    intermediate[8:8] // 3:3
   ,intermediate[6:6] // 2:2
   ,intermediate[4:4] // 1:1
   ,intermediate[2:2] // 0:0
  })
,.SDMMC_CMD_OE({
    intermediate[1:1] // 0:0
  })
,.SDMMC_CMD_I({
    hps_io_sdio_inst_CMD[0:0] // 0:0
  })
,.SDMMC_DATA_OE({
    intermediate[9:9] // 3:3
   ,intermediate[7:7] // 2:2
   ,intermediate[5:5] // 1:1
   ,intermediate[3:3] // 0:0
  })
);


cyclonev_hps_peripheral_usb usb1_inst(
 .USB_ULPI_STP({
    hps_io_usb1_inst_STP[0:0] // 0:0
  })
,.USB_ULPI_DATA_I({
    hps_io_usb1_inst_D7[0:0] // 7:7
   ,hps_io_usb1_inst_D6[0:0] // 6:6
   ,hps_io_usb1_inst_D5[0:0] // 5:5
   ,hps_io_usb1_inst_D4[0:0] // 4:4
   ,hps_io_usb1_inst_D3[0:0] // 3:3
   ,hps_io_usb1_inst_D2[0:0] // 2:2
   ,hps_io_usb1_inst_D1[0:0] // 1:1
   ,hps_io_usb1_inst_D0[0:0] // 0:0
  })
,.USB_ULPI_NXT({
    hps_io_usb1_inst_NXT[0:0] // 0:0
  })
,.USB_ULPI_DIR({
    hps_io_usb1_inst_DIR[0:0] // 0:0
  })
,.USB_ULPI_DATA_O({
    intermediate[24:24] // 7:7
   ,intermediate[22:22] // 6:6
   ,intermediate[20:20] // 5:5
   ,intermediate[18:18] // 4:4
   ,intermediate[16:16] // 3:3
   ,intermediate[14:14] // 2:2
   ,intermediate[12:12] // 1:1
   ,intermediate[10:10] // 0:0
  })
,.USB_ULPI_CLK({
    hps_io_usb1_inst_CLK[0:0] // 0:0
  })
,.USB_ULPI_DATA_OE({
    intermediate[25:25] // 7:7
   ,intermediate[23:23] // 6:6
   ,intermediate[21:21] // 5:5
   ,intermediate[19:19] // 4:4
   ,intermediate[17:17] // 3:3
   ,intermediate[15:15] // 2:2
   ,intermediate[13:13] // 1:1
   ,intermediate[11:11] // 0:0
  })
);


cyclonev_hps_peripheral_uart uart0_inst(
 .UART_RXD({
    hps_io_uart0_inst_RX[0:0] // 0:0
  })
,.UART_TXD({
    hps_io_uart0_inst_TX[0:0] // 0:0
  })
);


cyclonev_hps_peripheral_gpio gpio_inst(
 .LOANIO0_O({
    gpio_loanio_loanio0_o[28:0] // 28:0
  })
,.GPIO2_PORTA_O({
    intermediate[94:94] // 8:8
   ,intermediate[92:92] // 7:7
   ,intermediate[90:90] // 6:6
   ,intermediate[88:88] // 5:5
   ,floating[1:0] // 4:3
   ,intermediate[86:86] // 2:2
   ,intermediate[84:84] // 1:1
   ,intermediate[82:82] // 0:0
  })
,.GPIO0_PORTA_O({
    intermediate[50:50] // 27:27
   ,intermediate[48:48] // 26:26
   ,intermediate[46:46] // 25:25
   ,intermediate[44:44] // 24:24
   ,intermediate[42:42] // 23:23
   ,intermediate[40:40] // 22:22
   ,floating[3:2] // 21:20
   ,intermediate[38:38] // 19:19
   ,intermediate[36:36] // 18:18
   ,intermediate[34:34] // 17:17
   ,intermediate[32:32] // 16:16
   ,intermediate[30:30] // 15:15
   ,intermediate[28:28] // 14:14
   ,floating[16:4] // 13:1
   ,intermediate[26:26] // 0:0
  })
,.LOANIO2_O({
    gpio_loanio_loanio2_o[8:0] // 8:0
  })
,.LOANIO0_I({
    gpio_loanio_loanio0_i[28:0] // 28:0
  })
,.GPIO2_PORTA_I({
    hps_io_gpio_inst_LOANIO66[0:0] // 8:8
   ,hps_io_gpio_inst_LOANIO65[0:0] // 7:7
   ,hps_io_gpio_inst_LOANIO64[0:0] // 6:6
   ,hps_io_gpio_inst_LOANIO63[0:0] // 5:5
   ,floating[18:17] // 4:3
   ,hps_io_gpio_inst_LOANIO60[0:0] // 2:2
   ,hps_io_gpio_inst_LOANIO59[0:0] // 1:1
   ,hps_io_gpio_inst_LOANIO58[0:0] // 0:0
  })
,.GPIO0_PORTA_I({
    hps_io_gpio_inst_LOANIO27[0:0] // 27:27
   ,hps_io_gpio_inst_LOANIO26[0:0] // 26:26
   ,hps_io_gpio_inst_LOANIO25[0:0] // 25:25
   ,hps_io_gpio_inst_LOANIO24[0:0] // 24:24
   ,hps_io_gpio_inst_LOANIO23[0:0] // 23:23
   ,hps_io_gpio_inst_LOANIO22[0:0] // 22:22
   ,floating[20:19] // 21:20
   ,hps_io_gpio_inst_LOANIO19[0:0] // 19:19
   ,hps_io_gpio_inst_LOANIO18[0:0] // 18:18
   ,hps_io_gpio_inst_LOANIO17[0:0] // 17:17
   ,hps_io_gpio_inst_LOANIO16[0:0] // 16:16
   ,hps_io_gpio_inst_LOANIO15[0:0] // 15:15
   ,hps_io_gpio_inst_LOANIO14[0:0] // 14:14
   ,floating[33:21] // 13:1
   ,hps_io_gpio_inst_LOANIO00[0:0] // 0:0
  })
,.GPIO2_PORTA_OE({
    intermediate[95:95] // 8:8
   ,intermediate[93:93] // 7:7
   ,intermediate[91:91] // 6:6
   ,intermediate[89:89] // 5:5
   ,floating[35:34] // 4:3
   ,intermediate[87:87] // 2:2
   ,intermediate[85:85] // 1:1
   ,intermediate[83:83] // 0:0
  })
,.LOANIO2_I({
    gpio_loanio_loanio2_i[8:0] // 8:0
  })
,.GPIO0_PORTA_OE({
    intermediate[51:51] // 27:27
   ,intermediate[49:49] // 26:26
   ,intermediate[47:47] // 25:25
   ,intermediate[45:45] // 24:24
   ,intermediate[43:43] // 23:23
   ,intermediate[41:41] // 22:22
   ,floating[37:36] // 21:20
   ,intermediate[39:39] // 19:19
   ,intermediate[37:37] // 18:18
   ,intermediate[35:35] // 17:17
   ,intermediate[33:33] // 16:16
   ,intermediate[31:31] // 15:15
   ,intermediate[29:29] // 14:14
   ,floating[50:38] // 13:1
   ,intermediate[27:27] // 0:0
  })
,.LOANIO0_OE({
    gpio_loanio_loanio0_oe[28:0] // 28:0
  })
,.GPIO1_PORTA_O({
    intermediate[80:80] // 28:28
   ,intermediate[78:78] // 27:27
   ,intermediate[76:76] // 26:26
   ,intermediate[74:74] // 25:25
   ,intermediate[72:72] // 24:24
   ,intermediate[70:70] // 23:23
   ,intermediate[68:68] // 22:22
   ,intermediate[66:66] // 21:21
   ,intermediate[64:64] // 20:20
   ,intermediate[62:62] // 19:19
   ,floating[63:51] // 18:6
   ,intermediate[60:60] // 5:5
   ,floating[64:64] // 4:4
   ,intermediate[58:58] // 3:3
   ,intermediate[56:56] // 2:2
   ,intermediate[54:54] // 1:1
   ,intermediate[52:52] // 0:0
  })
,.LOANIO1_O({
    gpio_loanio_loanio1_o[28:0] // 28:0
  })
,.LOANIO1_OE({
    gpio_loanio_loanio1_oe[28:0] // 28:0
  })
,.GPIO1_PORTA_I({
    hps_io_gpio_inst_LOANIO57[0:0] // 28:28
   ,hps_io_gpio_inst_LOANIO56[0:0] // 27:27
   ,hps_io_gpio_inst_LOANIO55[0:0] // 26:26
   ,hps_io_gpio_inst_LOANIO54[0:0] // 25:25
   ,hps_io_gpio_inst_LOANIO53[0:0] // 24:24
   ,hps_io_gpio_inst_LOANIO52[0:0] // 23:23
   ,hps_io_gpio_inst_LOANIO51[0:0] // 22:22
   ,hps_io_gpio_inst_LOANIO50[0:0] // 21:21
   ,hps_io_gpio_inst_LOANIO49[0:0] // 20:20
   ,hps_io_gpio_inst_LOANIO48[0:0] // 19:19
   ,floating[77:65] // 18:6
   ,hps_io_gpio_inst_LOANIO34[0:0] // 5:5
   ,floating[78:78] // 4:4
   ,hps_io_gpio_inst_LOANIO32[0:0] // 3:3
   ,hps_io_gpio_inst_LOANIO31[0:0] // 2:2
   ,hps_io_gpio_inst_LOANIO30[0:0] // 1:1
   ,hps_io_gpio_inst_LOANIO29[0:0] // 0:0
  })
,.LOANIO1_I({
    gpio_loanio_loanio1_i[28:0] // 28:0
  })
,.LOANIO2_OE({
    gpio_loanio_loanio2_oe[8:0] // 8:0
  })
,.GPIO1_PORTA_OE({
    intermediate[81:81] // 28:28
   ,intermediate[79:79] // 27:27
   ,intermediate[77:77] // 26:26
   ,intermediate[75:75] // 25:25
   ,intermediate[73:73] // 24:24
   ,intermediate[71:71] // 23:23
   ,intermediate[69:69] // 22:22
   ,intermediate[67:67] // 21:21
   ,intermediate[65:65] // 20:20
   ,intermediate[63:63] // 19:19
   ,floating[91:79] // 18:6
   ,intermediate[61:61] // 5:5
   ,floating[92:92] // 4:4
   ,intermediate[59:59] // 3:3
   ,intermediate[57:57] // 2:2
   ,intermediate[55:55] // 1:1
   ,intermediate[53:53] // 0:0
  })
);


hps_sdram hps_sdram_inst(
 .mem_dq({
    mem_dq[31:0] // 31:0
  })
,.mem_odt({
    mem_odt[0:0] // 0:0
  })
,.mem_ras_n({
    mem_ras_n[0:0] // 0:0
  })
,.mem_dqs_n({
    mem_dqs_n[3:0] // 3:0
  })
,.mem_dqs({
    mem_dqs[3:0] // 3:0
  })
,.mem_dm({
    mem_dm[3:0] // 3:0
  })
,.mem_we_n({
    mem_we_n[0:0] // 0:0
  })
,.mem_cas_n({
    mem_cas_n[0:0] // 0:0
  })
,.mem_ba({
    mem_ba[2:0] // 2:0
  })
,.mem_a({
    mem_a[14:0] // 14:0
  })
,.mem_cs_n({
    mem_cs_n[0:0] // 0:0
  })
,.mem_ck({
    mem_ck[0:0] // 0:0
  })
,.mem_cke({
    mem_cke[0:0] // 0:0
  })
,.oct_rzqin({
    oct_rzqin[0:0] // 0:0
  })
,.mem_reset_n({
    mem_reset_n[0:0] // 0:0
  })
,.mem_ck_n({
    mem_ck_n[0:0] // 0:0
  })
);

endmodule

