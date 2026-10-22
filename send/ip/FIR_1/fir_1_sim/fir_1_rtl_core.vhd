-- ------------------------------------------------------------------------- 
-- High Level Design Compiler for Intel(R) FPGAs Version 17.1 (Release Build #590)
-- Quartus Prime development tool and MATLAB/Simulink Interface
-- 
-- Legal Notice: Copyright 2017 Intel Corporation.  All rights reserved.
-- Your use of  Intel Corporation's design tools,  logic functions and other
-- software and  tools, and its AMPP partner logic functions, and any output
-- files any  of the foregoing (including  device programming  or simulation
-- files), and  any associated  documentation  or information  are expressly
-- subject  to the terms and  conditions of the  Intel FPGA Software License
-- Agreement, Intel MegaCore Function License Agreement, or other applicable
-- license agreement,  including,  without limitation,  that your use is for
-- the  sole  purpose of  programming  logic devices  manufactured by  Intel
-- and  sold by Intel  or its authorized  distributors. Please refer  to the
-- applicable agreement for further details.
-- ---------------------------------------------------------------------------

-- VHDL created from fir_1_rtl_core
-- VHDL created on Wed Sep 30 10:21:20 2026


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use std.TextIO.all;
use work.dspba_library_package.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
LIBRARY altera_lnsim;
USE altera_lnsim.altera_lnsim_components.altera_syncram;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity fir_1_rtl_core is
    port (
        xIn_v : in std_logic_vector(0 downto 0);  -- sfix1
        xIn_c : in std_logic_vector(7 downto 0);  -- sfix8
        xIn_0 : in std_logic_vector(15 downto 0);  -- sfix16
        xOut_v : out std_logic_vector(0 downto 0);  -- ufix1
        xOut_c : out std_logic_vector(7 downto 0);  -- ufix8
        xOut_0 : out std_logic_vector(40 downto 0);  -- sfix41
        clk : in std_logic;
        areset : in std_logic
    );
end fir_1_rtl_core;

architecture normal of fir_1_rtl_core is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_in0_m0_wi0_wo0_assign_id1_q_11_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_in0_m0_wi0_wo0_assign_id1_q_14_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_inputframe_seq_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_inputframe_seq_eq : std_logic;
    signal u0_m0_wo0_run_count : STD_LOGIC_VECTOR (1 downto 0);
    signal u0_m0_wo0_run_preEnaQ : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_run_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_run_out : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_run_enableQ : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_run_ctrl : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_memread_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_u0_m0_wo0_memread_q_14_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_compute_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_u0_m0_wo0_compute_q_14_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_u0_m0_wo0_compute_q_15_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_u0_m0_wo0_compute_q_16_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_ra0_count0_q : STD_LOGIC_VECTOR (1 downto 0);
    signal u0_m0_wo0_wi0_r0_ra0_count0_i : UNSIGNED (0 downto 0);
    attribute preserve : boolean;
    attribute preserve of u0_m0_wo0_wi0_r0_ra0_count0_i : signal is true;
    signal u0_m0_wo0_wi0_r0_ra0_count1_lutreg_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_ra0_count1_inner_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_ra0_count1_inner_i : SIGNED (0 downto 0);
    attribute preserve of u0_m0_wo0_wi0_r0_ra0_count1_inner_i : signal is true;
    signal u0_m0_wo0_wi0_r0_ra0_count1_inner_eq : std_logic;
    attribute preserve of u0_m0_wo0_wi0_r0_ra0_count1_inner_eq : signal is true;
    signal d_u0_m0_wo0_wi0_r0_ra0_count1_run_q_14_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_ra0_count1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal u0_m0_wo0_wi0_r0_ra0_count1_i : UNSIGNED (1 downto 0);
    attribute preserve of u0_m0_wo0_wi0_r0_ra0_count1_i : signal is true;
    signal u0_m0_wo0_wi0_r0_ra0_add_0_0_a : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_ra0_add_0_0_b : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_ra0_add_0_0_o : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_ra0_add_0_0_q : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_ra10_count0_q : STD_LOGIC_VECTOR (1 downto 0);
    signal u0_m0_wo0_wi0_r0_ra10_count0_i : UNSIGNED (0 downto 0);
    attribute preserve of u0_m0_wo0_wi0_r0_ra10_count0_i : signal is true;
    signal u0_m0_wo0_wi0_r0_ra10_count1_q : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_ra10_count1_i : UNSIGNED (2 downto 0);
    attribute preserve of u0_m0_wo0_wi0_r0_ra10_count1_i : signal is true;
    signal u0_m0_wo0_wi0_r0_ra10_count1_eq : std_logic;
    attribute preserve of u0_m0_wo0_wi0_r0_ra10_count1_eq : signal is true;
    signal u0_m0_wo0_wi0_r0_we10_seq_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_we10_seq_eq : std_logic;
    signal u0_m0_wo0_wi0_r0_wa0_q : STD_LOGIC_VECTOR (1 downto 0);
    signal u0_m0_wo0_wi0_r0_wa0_i : UNSIGNED (1 downto 0);
    attribute preserve of u0_m0_wo0_wi0_r0_wa0_i : signal is true;
    signal u0_m0_wo0_wi0_r0_wa10_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_wa10_i : UNSIGNED (2 downto 0);
    attribute preserve of u0_m0_wo0_wi0_r0_wa10_i : signal is true;
    signal u0_m0_wo0_wi0_r0_wa10_eq : std_logic;
    attribute preserve of u0_m0_wo0_wi0_r0_wa10_eq : signal is true;
    signal u0_m0_wo0_wi0_r0_memr0_reset0 : std_logic;
    signal u0_m0_wo0_wi0_r0_memr0_ia : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_memr0_aa : STD_LOGIC_VECTOR (1 downto 0);
    signal u0_m0_wo0_wi0_r0_memr0_ab : STD_LOGIC_VECTOR (1 downto 0);
    signal u0_m0_wo0_wi0_r0_memr0_iq : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_memr0_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_memr10_reset0 : std_logic;
    signal u0_m0_wo0_wi0_r0_memr10_ia : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_memr10_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_memr10_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_memr10_iq : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_memr10_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_ca8_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_ca9_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_cm0_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u0_m0_wo0_cm1_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u0_m0_wo0_cm2_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u0_m0_wo0_cm3_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u0_m0_wo0_cm4_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u0_m0_wo0_cm5_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u0_m0_wo0_cm6_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u0_m0_wo0_cm7_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u0_m0_wo0_cm8_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u0_m0_wo0_cm9_q : STD_LOGIC_VECTOR (18 downto 0);
    signal u0_m0_wo0_sym_add0_a : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add0_b : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add0_o : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add0_q : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add1_a : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add1_b : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add1_o : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add1_q : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add2_a : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add2_b : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add2_o : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add2_q : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add3_a : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add3_b : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add3_o : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add3_q : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add4_a : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add4_b : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add4_o : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add4_q : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add5_a : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add5_b : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add5_o : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add5_q : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add6_a : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add6_b : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add6_o : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add6_q : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add7_a : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add7_b : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add7_o : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add7_q : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add8_a : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add8_b : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add8_o : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add8_q : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add9_a : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add9_b : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add9_o : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_sym_add9_q : STD_LOGIC_VECTOR (16 downto 0);
    signal u0_m0_wo0_cma0_reset : std_logic;
    type u0_m0_wo0_cma0_a0type is array(NATURAL range <>) of SIGNED(16 downto 0);
    signal u0_m0_wo0_cma0_a0 : u0_m0_wo0_cma0_a0type(0 to 9);
    attribute preserve of u0_m0_wo0_cma0_a0 : signal is true;
    type u0_m0_wo0_cma0_c0type is array(NATURAL range <>) of SIGNED(18 downto 0);
    signal u0_m0_wo0_cma0_c0 : u0_m0_wo0_cma0_c0type(0 to 9);
    attribute preserve of u0_m0_wo0_cma0_c0 : signal is true;
    type u0_m0_wo0_cma0_ptype is array(NATURAL range <>) of SIGNED(35 downto 0);
    signal u0_m0_wo0_cma0_p : u0_m0_wo0_cma0_ptype(0 to 9);
    type u0_m0_wo0_cma0_utype is array(NATURAL range <>) of SIGNED(43 downto 0);
    signal u0_m0_wo0_cma0_u : u0_m0_wo0_cma0_utype(0 to 9);
    signal u0_m0_wo0_cma0_w : u0_m0_wo0_cma0_utype(0 to 9);
    signal u0_m0_wo0_cma0_x : u0_m0_wo0_cma0_utype(0 to 9);
    signal u0_m0_wo0_cma0_y : u0_m0_wo0_cma0_utype(0 to 9);
    signal u0_m0_wo0_cma0_z : u0_m0_wo0_cma0_utype(0 to 1);
    signal u0_m0_wo0_cma0_s : u0_m0_wo0_cma0_utype(0 to 9);
    signal u0_m0_wo0_cma0_anl : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_cma0_qq : STD_LOGIC_VECTOR (40 downto 0);
    signal u0_m0_wo0_cma0_q : STD_LOGIC_VECTOR (40 downto 0);
    signal u0_m0_wo0_cma0_ena0 : std_logic;
    signal u0_m0_wo0_cma0_ena1 : std_logic;
    signal u0_m0_wo0_aseq_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_aseq_eq : std_logic;
    signal u0_m0_wo0_oseq_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_oseq_eq : std_logic;
    signal u0_m0_wo0_oseq_gated_reg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_out0_m0_wo0_assign_id3_q_17_q : STD_LOGIC_VECTOR (0 downto 0);
    signal outchan_q : STD_LOGIC_VECTOR (1 downto 0);
    signal outchan_i : UNSIGNED (0 downto 0);
    attribute preserve of outchan_i : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr1_mem_reset0 : std_logic;
    signal u0_m0_wo0_wi0_r0_delayr1_mem_ia : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_mem_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_mem_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_mem_iq : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_mem_q : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_rdcnt_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_rdcnt_i : UNSIGNED (2 downto 0);
    attribute preserve of u0_m0_wo0_wi0_r0_delayr1_rdcnt_i : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr1_rdcnt_eq : std_logic;
    attribute preserve of u0_m0_wo0_wi0_r0_delayr1_rdcnt_eq : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr1_wraddr_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_mem_last_q : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute preserve_syn_only : boolean;
    attribute preserve_syn_only of u0_m0_wo0_wi0_r0_delayr1_sticky_ena_q : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr5_mem_reset0 : std_logic;
    signal u0_m0_wo0_wi0_r0_delayr5_mem_ia : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_mem_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_mem_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_mem_iq : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_mem_q : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_rdcnt_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_rdcnt_i : UNSIGNED (2 downto 0);
    attribute preserve of u0_m0_wo0_wi0_r0_delayr5_rdcnt_i : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr5_rdcnt_eq : std_logic;
    attribute preserve of u0_m0_wo0_wi0_r0_delayr5_rdcnt_eq : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr5_wraddr_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_mem_last_q : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute preserve_syn_only of u0_m0_wo0_wi0_r0_delayr5_sticky_ena_q : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr9_mem_reset0 : std_logic;
    signal u0_m0_wo0_wi0_r0_delayr9_mem_ia : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_mem_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_mem_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_mem_iq : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_mem_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_rdcnt_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_rdcnt_i : UNSIGNED (2 downto 0);
    attribute preserve of u0_m0_wo0_wi0_r0_delayr9_rdcnt_i : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr9_rdcnt_eq : std_logic;
    attribute preserve of u0_m0_wo0_wi0_r0_delayr9_rdcnt_eq : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr9_wraddr_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_mem_last_q : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute preserve_syn_only of u0_m0_wo0_wi0_r0_delayr9_sticky_ena_q : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr11_mem_reset0 : std_logic;
    signal u0_m0_wo0_wi0_r0_delayr11_mem_ia : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_mem_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_mem_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_mem_iq : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_mem_q : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_rdcnt_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_rdcnt_i : UNSIGNED (2 downto 0);
    attribute preserve of u0_m0_wo0_wi0_r0_delayr11_rdcnt_i : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr11_wraddr_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_mem_last_q : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute preserve_syn_only of u0_m0_wo0_wi0_r0_delayr11_sticky_ena_q : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr15_mem_reset0 : std_logic;
    signal u0_m0_wo0_wi0_r0_delayr15_mem_ia : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_mem_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_mem_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_mem_iq : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_mem_q : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_rdcnt_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_rdcnt_i : UNSIGNED (2 downto 0);
    attribute preserve of u0_m0_wo0_wi0_r0_delayr15_rdcnt_i : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr15_wraddr_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_mem_last_q : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute preserve_syn_only of u0_m0_wo0_wi0_r0_delayr15_sticky_ena_q : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr19_mem_reset0 : std_logic;
    signal u0_m0_wo0_wi0_r0_delayr19_mem_ia : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_mem_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_mem_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_mem_iq : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_mem_q : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_rdcnt_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_rdcnt_i : UNSIGNED (2 downto 0);
    attribute preserve of u0_m0_wo0_wi0_r0_delayr19_rdcnt_i : signal is true;
    signal u0_m0_wo0_wi0_r0_delayr19_wraddr_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_mem_last_q : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute preserve_syn_only of u0_m0_wo0_wi0_r0_delayr19_sticky_ena_q : signal is true;
    signal d_xIn_0_14_mem_reset0 : std_logic;
    signal d_xIn_0_14_mem_ia : STD_LOGIC_VECTOR (15 downto 0);
    signal d_xIn_0_14_mem_aa : STD_LOGIC_VECTOR (1 downto 0);
    signal d_xIn_0_14_mem_ab : STD_LOGIC_VECTOR (1 downto 0);
    signal d_xIn_0_14_mem_iq : STD_LOGIC_VECTOR (15 downto 0);
    signal d_xIn_0_14_mem_q : STD_LOGIC_VECTOR (15 downto 0);
    signal d_xIn_0_14_rdcnt_q : STD_LOGIC_VECTOR (1 downto 0);
    signal d_xIn_0_14_rdcnt_i : UNSIGNED (1 downto 0);
    attribute preserve of d_xIn_0_14_rdcnt_i : signal is true;
    signal d_xIn_0_14_rdcnt_eq : std_logic;
    attribute preserve of d_xIn_0_14_rdcnt_eq : signal is true;
    signal d_xIn_0_14_wraddr_q : STD_LOGIC_VECTOR (1 downto 0);
    signal d_xIn_0_14_mem_last_q : STD_LOGIC_VECTOR (1 downto 0);
    signal d_xIn_0_14_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_xIn_0_14_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute preserve_syn_only of d_xIn_0_14_sticky_ena_q : signal is true;
    signal u0_m0_wo0_inputframe_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_ra0_count1_run_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_oseq_gated_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_rdmux_s : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_rdmux_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_cmp_b : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr1_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_rdmux_s : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_rdmux_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_cmp_b : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr5_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_rdmux_s : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_rdmux_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_cmp_b : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr9_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_rdmux_s : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_rdmux_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_cmp_b : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr11_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_rdmux_s : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_rdmux_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_cmp_b : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr15_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_rdmux_s : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_rdmux_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_cmp_b : STD_LOGIC_VECTOR (3 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_delayr19_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_xIn_0_14_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_xIn_0_14_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_xIn_0_14_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal d_xIn_0_14_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_ra0_count1_lut_q : STD_LOGIC_VECTOR (2 downto 0);
    signal u0_m0_wo0_wi0_r0_ra0_resize_in : STD_LOGIC_VECTOR (1 downto 0);
    signal u0_m0_wo0_wi0_r0_ra0_resize_b : STD_LOGIC_VECTOR (1 downto 0);
    signal u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_BitSelect_for_a_in : STD_LOGIC_VECTOR (4 downto 0);
    signal u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_BitSelect_for_a_b : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_BitSelect_for_b_in : STD_LOGIC_VECTOR (4 downto 0);
    signal u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_BitSelect_for_b_b : STD_LOGIC_VECTOR (1 downto 0);
    signal u0_m0_wo0_ca8_1_lut_q : STD_LOGIC_VECTOR (0 downto 0);
    signal out0_m0_wo0_lineup_select_delay_0_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_split1_b : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split1_c : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split1_d : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split1_e : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split5_b : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split5_c : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split5_d : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split5_e : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split11_b : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split11_c : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split11_d : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split11_e : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split15_b : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split15_c : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split15_d : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_split15_e : STD_LOGIC_VECTOR (15 downto 0);
    signal u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_join_q : STD_LOGIC_VECTOR (4 downto 0);
    signal out0_m0_wo0_assign_id3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal u0_m0_wo0_wi0_r0_join1_q : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_join5_q : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_join11_q : STD_LOGIC_VECTOR (63 downto 0);
    signal u0_m0_wo0_wi0_r0_join15_q : STD_LOGIC_VECTOR (63 downto 0);

begin


    -- VCC(CONSTANT,1)@0
    VCC_q <= "1";

    -- d_in0_m0_wi0_wo0_assign_id1_q_11(DELAY,98)@10 + 1
    d_in0_m0_wi0_wo0_assign_id1_q_11 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => xIn_v, xout => d_in0_m0_wi0_wo0_assign_id1_q_11_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_inputframe_seq(SEQUENCE,13)@10 + 1
    u0_m0_wo0_inputframe_seq_clkproc: PROCESS (clk, areset)
        variable u0_m0_wo0_inputframe_seq_c : SIGNED(3 downto 0);
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_inputframe_seq_c := "0000";
            u0_m0_wo0_inputframe_seq_q <= "0";
            u0_m0_wo0_inputframe_seq_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                IF (u0_m0_wo0_inputframe_seq_c = "0000") THEN
                    u0_m0_wo0_inputframe_seq_eq <= '1';
                ELSE
                    u0_m0_wo0_inputframe_seq_eq <= '0';
                END IF;
                IF (u0_m0_wo0_inputframe_seq_eq = '1') THEN
                    u0_m0_wo0_inputframe_seq_c := u0_m0_wo0_inputframe_seq_c + 1;
                ELSE
                    u0_m0_wo0_inputframe_seq_c := u0_m0_wo0_inputframe_seq_c - 1;
                END IF;
                u0_m0_wo0_inputframe_seq_q <= STD_LOGIC_VECTOR(u0_m0_wo0_inputframe_seq_c(3 downto 3));
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_inputframe(LOGICAL,14)@11
    u0_m0_wo0_inputframe_q <= u0_m0_wo0_inputframe_seq_q and d_in0_m0_wi0_wo0_assign_id1_q_11_q;

    -- u0_m0_wo0_run(ENABLEGENERATOR,15)@11 + 2
    u0_m0_wo0_run_ctrl <= u0_m0_wo0_run_out & u0_m0_wo0_inputframe_q & u0_m0_wo0_run_enableQ;
    u0_m0_wo0_run_clkproc: PROCESS (clk, areset)
        variable u0_m0_wo0_run_enable_c : SIGNED(2 downto 0);
        variable u0_m0_wo0_run_inc : SIGNED(1 downto 0);
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_run_q <= "0";
            u0_m0_wo0_run_enable_c := TO_SIGNED(2, 3);
            u0_m0_wo0_run_enableQ <= "0";
            u0_m0_wo0_run_count <= "00";
            u0_m0_wo0_run_inc := (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_run_out = "1") THEN
                IF (u0_m0_wo0_run_enable_c(2) = '1') THEN
                    u0_m0_wo0_run_enable_c := u0_m0_wo0_run_enable_c - (-3);
                ELSE
                    u0_m0_wo0_run_enable_c := u0_m0_wo0_run_enable_c + (-1);
                END IF;
                u0_m0_wo0_run_enableQ <= STD_LOGIC_VECTOR(u0_m0_wo0_run_enable_c(2 downto 2));
            ELSE
                u0_m0_wo0_run_enableQ <= "0";
            END IF;
            CASE (u0_m0_wo0_run_ctrl) IS
                WHEN "000" | "001" => u0_m0_wo0_run_inc := "00";
                WHEN "010" | "011" => u0_m0_wo0_run_inc := "11";
                WHEN "100" => u0_m0_wo0_run_inc := "00";
                WHEN "101" => u0_m0_wo0_run_inc := "01";
                WHEN "110" => u0_m0_wo0_run_inc := "11";
                WHEN "111" => u0_m0_wo0_run_inc := "00";
                WHEN OTHERS => 
            END CASE;
            u0_m0_wo0_run_count <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_run_count) + SIGNED(u0_m0_wo0_run_inc));
            u0_m0_wo0_run_q <= u0_m0_wo0_run_out;
        END IF;
    END PROCESS;
    u0_m0_wo0_run_preEnaQ <= u0_m0_wo0_run_count(1 downto 1);
    u0_m0_wo0_run_out <= u0_m0_wo0_run_preEnaQ and VCC_q;

    -- u0_m0_wo0_memread(DELAY,16)@13
    u0_m0_wo0_memread : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u0_m0_wo0_run_q, xout => u0_m0_wo0_memread_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_compute(DELAY,18)@13
    u0_m0_wo0_compute : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => u0_m0_wo0_memread_q, xout => u0_m0_wo0_compute_q, clk => clk, aclr => areset );

    -- d_u0_m0_wo0_compute_q_14(DELAY,101)@13 + 1
    d_u0_m0_wo0_compute_q_14 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u0_m0_wo0_compute_q, xout => d_u0_m0_wo0_compute_q_14_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_ca8_1_lut(LOOKUP,54)@14
    u0_m0_wo0_ca8_1_lut_combproc: PROCESS (u0_m0_wo0_ca9_1_q)
    BEGIN
        -- Begin reserved scope level
        CASE (u0_m0_wo0_ca9_1_q) IS
            WHEN "0" => u0_m0_wo0_ca8_1_lut_q <= "1";
            WHEN "1" => u0_m0_wo0_ca8_1_lut_q <= "0";
            WHEN OTHERS => -- unreachable
                           u0_m0_wo0_ca8_1_lut_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- u0_m0_wo0_ca8_1(REG,55)@14
    u0_m0_wo0_ca8_1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_ca8_1_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                u0_m0_wo0_ca8_1_q <= u0_m0_wo0_ca8_1_lut_q;
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_ca9_1(REG,56)@14
    u0_m0_wo0_ca9_1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_ca9_1_q <= "1";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                u0_m0_wo0_ca9_1_q <= u0_m0_wo0_ca8_1_q;
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_cm9(LOOKUP,69)@14 + 1
    u0_m0_wo0_cm9_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm9_q <= "0110010010011100010";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca9_1_q) IS
                WHEN "0" => u0_m0_wo0_cm9_q <= "0110010010011100010";
                WHEN "1" => u0_m0_wo0_cm9_q <= "0111111111111111110";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm9_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_ra0_count1_inner(COUNTER,24)@13
    -- low=-1, high=0, step=1, init=-1
    u0_m0_wo0_wi0_r0_ra0_count1_inner_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_ra0_count1_inner_i <= TO_SIGNED(-1, 1);
            u0_m0_wo0_wi0_r0_ra0_count1_inner_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_memread_q = "1") THEN
                IF (u0_m0_wo0_wi0_r0_ra0_count1_inner_eq = '0') THEN
                    u0_m0_wo0_wi0_r0_ra0_count1_inner_eq <= '1';
                ELSE
                    u0_m0_wo0_wi0_r0_ra0_count1_inner_eq <= '0';
                END IF;
                IF (u0_m0_wo0_wi0_r0_ra0_count1_inner_eq = '1') THEN
                    u0_m0_wo0_wi0_r0_ra0_count1_inner_i <= u0_m0_wo0_wi0_r0_ra0_count1_inner_i + 1;
                ELSE
                    u0_m0_wo0_wi0_r0_ra0_count1_inner_i <= u0_m0_wo0_wi0_r0_ra0_count1_inner_i + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_r0_ra0_count1_inner_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_r0_ra0_count1_inner_i, 1)));

    -- u0_m0_wo0_wi0_r0_ra0_count1_run(LOGICAL,25)@13
    u0_m0_wo0_wi0_r0_ra0_count1_run_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_ra0_count1_inner_q(0 downto 0));

    -- d_u0_m0_wo0_wi0_r0_ra0_count1_run_q_14(DELAY,104)@13 + 1
    d_u0_m0_wo0_wi0_r0_ra0_count1_run_q_14 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u0_m0_wo0_wi0_r0_ra0_count1_run_q, xout => d_u0_m0_wo0_wi0_r0_ra0_count1_run_q_14_q, clk => clk, aclr => areset );

    -- d_u0_m0_wo0_memread_q_14(DELAY,100)@13 + 1
    d_u0_m0_wo0_memread_q_14 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => u0_m0_wo0_memread_q, xout => d_u0_m0_wo0_memread_q_14_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_wi0_r0_ra10_count1(COUNTER,32)@14
    -- low=0, high=5, step=-2, init=2
    u0_m0_wo0_wi0_r0_ra10_count1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_ra10_count1_i <= TO_UNSIGNED(2, 3);
            u0_m0_wo0_wi0_r0_ra10_count1_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_memread_q_14_q = "1" and d_u0_m0_wo0_wi0_r0_ra0_count1_run_q_14_q = "1") THEN
                IF (u0_m0_wo0_wi0_r0_ra10_count1_i = TO_UNSIGNED(2, 3)) THEN
                    u0_m0_wo0_wi0_r0_ra10_count1_eq <= '1';
                ELSE
                    u0_m0_wo0_wi0_r0_ra10_count1_eq <= '0';
                END IF;
                IF (u0_m0_wo0_wi0_r0_ra10_count1_eq = '1') THEN
                    u0_m0_wo0_wi0_r0_ra10_count1_i <= u0_m0_wo0_wi0_r0_ra10_count1_i - 4;
                ELSE
                    u0_m0_wo0_wi0_r0_ra10_count1_i <= u0_m0_wo0_wi0_r0_ra10_count1_i - 2;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_r0_ra10_count1_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_r0_ra10_count1_i, 4)));

    -- u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_BitSelect_for_b(BITSELECT,95)@14
    u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_BitSelect_for_b_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((4 downto 4 => u0_m0_wo0_wi0_r0_ra10_count1_q(3)) & u0_m0_wo0_wi0_r0_ra10_count1_q));
    u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_BitSelect_for_b_b <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_BitSelect_for_b_in(2 downto 1));

    -- u0_m0_wo0_wi0_r0_ra10_count0(COUNTER,29)@14
    -- low=0, high=1, step=1, init=1
    u0_m0_wo0_wi0_r0_ra10_count0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_ra10_count0_i <= TO_UNSIGNED(1, 1);
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_memread_q_14_q = "1") THEN
                u0_m0_wo0_wi0_r0_ra10_count0_i <= u0_m0_wo0_wi0_r0_ra10_count0_i + 1;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_r0_ra10_count0_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_r0_ra10_count0_i, 2)));

    -- u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_BitSelect_for_a(BITSELECT,94)@14
    u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_BitSelect_for_a_in <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((4 downto 2 => u0_m0_wo0_wi0_r0_ra10_count0_q(1)) & u0_m0_wo0_wi0_r0_ra10_count0_q));
    u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_BitSelect_for_a_b <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_BitSelect_for_a_in(0 downto 0));

    -- u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_join(BITJOIN,96)@14
    u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_join_q <= GND_q & GND_q & u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_BitSelect_for_b_b & u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_BitSelect_for_a_b;

    -- u0_m0_wo0_wi0_r0_we10_seq(SEQUENCE,35)@13 + 1
    u0_m0_wo0_wi0_r0_we10_seq_clkproc: PROCESS (clk, areset)
        variable u0_m0_wo0_wi0_r0_we10_seq_c : SIGNED(4 downto 0);
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_we10_seq_c := "11111";
            u0_m0_wo0_wi0_r0_we10_seq_q <= "0";
            u0_m0_wo0_wi0_r0_we10_seq_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_compute_q = "1") THEN
                IF (u0_m0_wo0_wi0_r0_we10_seq_c = "11111") THEN
                    u0_m0_wo0_wi0_r0_we10_seq_eq <= '1';
                ELSE
                    u0_m0_wo0_wi0_r0_we10_seq_eq <= '0';
                END IF;
                IF (u0_m0_wo0_wi0_r0_we10_seq_eq = '1') THEN
                    u0_m0_wo0_wi0_r0_we10_seq_c := u0_m0_wo0_wi0_r0_we10_seq_c + 3;
                ELSE
                    u0_m0_wo0_wi0_r0_we10_seq_c := u0_m0_wo0_wi0_r0_we10_seq_c - 1;
                END IF;
                u0_m0_wo0_wi0_r0_we10_seq_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_we10_seq_c(4 downto 4));
            ELSE
                u0_m0_wo0_wi0_r0_we10_seq_q <= "0";
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_wa10(COUNTER,37)@14
    -- low=0, high=5, step=1, init=5
    u0_m0_wo0_wi0_r0_wa10_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_wa10_i <= TO_UNSIGNED(5, 3);
            u0_m0_wo0_wi0_r0_wa10_eq <= '1';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_wi0_r0_we10_seq_q = "1") THEN
                IF (u0_m0_wo0_wi0_r0_wa10_i = TO_UNSIGNED(4, 3)) THEN
                    u0_m0_wo0_wi0_r0_wa10_eq <= '1';
                ELSE
                    u0_m0_wo0_wi0_r0_wa10_eq <= '0';
                END IF;
                IF (u0_m0_wo0_wi0_r0_wa10_eq = '1') THEN
                    u0_m0_wo0_wi0_r0_wa10_i <= u0_m0_wo0_wi0_r0_wa10_i + 3;
                ELSE
                    u0_m0_wo0_wi0_r0_wa10_i <= u0_m0_wo0_wi0_r0_wa10_i + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_r0_wa10_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_r0_wa10_i, 3)));

    -- u0_m0_wo0_wi0_r0_memr10(DUALMEM,39)@14
    u0_m0_wo0_wi0_r0_memr10_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr9_mem_q);
    u0_m0_wo0_wi0_r0_memr10_aa <= u0_m0_wo0_wi0_r0_wa10_q;
    u0_m0_wo0_wi0_r0_memr10_ab <= u0_m0_wo0_wi0_r0_ra10_add_0_0_replace_or_join_q(2 downto 0);
    u0_m0_wo0_wi0_r0_memr10_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 16,
        widthad_a => 3,
        numwords_a => 6,
        width_b => 16,
        widthad_b => 3,
        numwords_b => 6,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK0",
        outdata_aclr_b => "NONE",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "FALSE",
        init_file => "UNUSED",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken0 => '1',
        clock0 => clk,
        address_a => u0_m0_wo0_wi0_r0_memr10_aa,
        data_a => u0_m0_wo0_wi0_r0_memr10_ia,
        wren_a => u0_m0_wo0_wi0_r0_we10_seq_q(0),
        address_b => u0_m0_wo0_wi0_r0_memr10_ab,
        q_b => u0_m0_wo0_wi0_r0_memr10_iq
    );
    u0_m0_wo0_wi0_r0_memr10_q <= u0_m0_wo0_wi0_r0_memr10_iq(15 downto 0);

    -- u0_m0_wo0_wi0_r0_delayr9_notEnable(LOGICAL,135)@14
    u0_m0_wo0_wi0_r0_delayr9_notEnable_q <= STD_LOGIC_VECTOR(not (d_u0_m0_wo0_compute_q_14_q));

    -- u0_m0_wo0_wi0_r0_delayr9_nor(LOGICAL,136)@14
    u0_m0_wo0_wi0_r0_delayr9_nor_q <= not (u0_m0_wo0_wi0_r0_delayr9_notEnable_q or u0_m0_wo0_wi0_r0_delayr9_sticky_ena_q);

    -- u0_m0_wo0_wi0_r0_delayr9_mem_last(CONSTANT,132)
    u0_m0_wo0_wi0_r0_delayr9_mem_last_q <= "0100";

    -- u0_m0_wo0_wi0_r0_delayr9_cmp(LOGICAL,133)@14
    u0_m0_wo0_wi0_r0_delayr9_cmp_b <= STD_LOGIC_VECTOR("0" & u0_m0_wo0_wi0_r0_delayr9_rdmux_q);
    u0_m0_wo0_wi0_r0_delayr9_cmp_q <= "1" WHEN u0_m0_wo0_wi0_r0_delayr9_mem_last_q = u0_m0_wo0_wi0_r0_delayr9_cmp_b ELSE "0";

    -- u0_m0_wo0_wi0_r0_delayr9_cmpReg(REG,134)@14 + 1
    u0_m0_wo0_wi0_r0_delayr9_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr9_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr9_cmpReg_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr9_cmp_q);
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr9_sticky_ena(REG,137)@14 + 1
    u0_m0_wo0_wi0_r0_delayr9_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr9_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_wi0_r0_delayr9_nor_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr9_sticky_ena_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr9_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr9_enaAnd(LOGICAL,138)@14
    u0_m0_wo0_wi0_r0_delayr9_enaAnd_q <= u0_m0_wo0_wi0_r0_delayr9_sticky_ena_q and d_u0_m0_wo0_compute_q_14_q;

    -- u0_m0_wo0_wi0_r0_delayr9_rdcnt(COUNTER,129)@14 + 1
    -- low=0, high=5, step=1, init=0
    u0_m0_wo0_wi0_r0_delayr9_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr9_rdcnt_i <= TO_UNSIGNED(0, 3);
            u0_m0_wo0_wi0_r0_delayr9_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                IF (u0_m0_wo0_wi0_r0_delayr9_rdcnt_i = TO_UNSIGNED(4, 3)) THEN
                    u0_m0_wo0_wi0_r0_delayr9_rdcnt_eq <= '1';
                ELSE
                    u0_m0_wo0_wi0_r0_delayr9_rdcnt_eq <= '0';
                END IF;
                IF (u0_m0_wo0_wi0_r0_delayr9_rdcnt_eq = '1') THEN
                    u0_m0_wo0_wi0_r0_delayr9_rdcnt_i <= u0_m0_wo0_wi0_r0_delayr9_rdcnt_i + 3;
                ELSE
                    u0_m0_wo0_wi0_r0_delayr9_rdcnt_i <= u0_m0_wo0_wi0_r0_delayr9_rdcnt_i + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_r0_delayr9_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_r0_delayr9_rdcnt_i, 3)));

    -- u0_m0_wo0_wi0_r0_delayr9_rdmux(MUX,130)@14
    u0_m0_wo0_wi0_r0_delayr9_rdmux_s <= d_u0_m0_wo0_compute_q_14_q;
    u0_m0_wo0_wi0_r0_delayr9_rdmux_combproc: PROCESS (u0_m0_wo0_wi0_r0_delayr9_rdmux_s, u0_m0_wo0_wi0_r0_delayr9_wraddr_q, u0_m0_wo0_wi0_r0_delayr9_rdcnt_q)
    BEGIN
        CASE (u0_m0_wo0_wi0_r0_delayr9_rdmux_s) IS
            WHEN "0" => u0_m0_wo0_wi0_r0_delayr9_rdmux_q <= u0_m0_wo0_wi0_r0_delayr9_wraddr_q;
            WHEN "1" => u0_m0_wo0_wi0_r0_delayr9_rdmux_q <= u0_m0_wo0_wi0_r0_delayr9_rdcnt_q;
            WHEN OTHERS => u0_m0_wo0_wi0_r0_delayr9_rdmux_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr5_notEnable(LOGICAL,124)@14
    u0_m0_wo0_wi0_r0_delayr5_notEnable_q <= STD_LOGIC_VECTOR(not (d_u0_m0_wo0_compute_q_14_q));

    -- u0_m0_wo0_wi0_r0_delayr5_nor(LOGICAL,125)@14
    u0_m0_wo0_wi0_r0_delayr5_nor_q <= not (u0_m0_wo0_wi0_r0_delayr5_notEnable_q or u0_m0_wo0_wi0_r0_delayr5_sticky_ena_q);

    -- u0_m0_wo0_wi0_r0_delayr5_mem_last(CONSTANT,121)
    u0_m0_wo0_wi0_r0_delayr5_mem_last_q <= "0100";

    -- u0_m0_wo0_wi0_r0_delayr5_cmp(LOGICAL,122)@14
    u0_m0_wo0_wi0_r0_delayr5_cmp_b <= STD_LOGIC_VECTOR("0" & u0_m0_wo0_wi0_r0_delayr5_rdmux_q);
    u0_m0_wo0_wi0_r0_delayr5_cmp_q <= "1" WHEN u0_m0_wo0_wi0_r0_delayr5_mem_last_q = u0_m0_wo0_wi0_r0_delayr5_cmp_b ELSE "0";

    -- u0_m0_wo0_wi0_r0_delayr5_cmpReg(REG,123)@14 + 1
    u0_m0_wo0_wi0_r0_delayr5_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr5_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr5_cmpReg_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr5_cmp_q);
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr5_sticky_ena(REG,126)@14 + 1
    u0_m0_wo0_wi0_r0_delayr5_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr5_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_wi0_r0_delayr5_nor_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr5_sticky_ena_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr5_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr5_enaAnd(LOGICAL,127)@14
    u0_m0_wo0_wi0_r0_delayr5_enaAnd_q <= u0_m0_wo0_wi0_r0_delayr5_sticky_ena_q and d_u0_m0_wo0_compute_q_14_q;

    -- u0_m0_wo0_wi0_r0_delayr5_rdcnt(COUNTER,118)@14 + 1
    -- low=0, high=5, step=1, init=0
    u0_m0_wo0_wi0_r0_delayr5_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr5_rdcnt_i <= TO_UNSIGNED(0, 3);
            u0_m0_wo0_wi0_r0_delayr5_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                IF (u0_m0_wo0_wi0_r0_delayr5_rdcnt_i = TO_UNSIGNED(4, 3)) THEN
                    u0_m0_wo0_wi0_r0_delayr5_rdcnt_eq <= '1';
                ELSE
                    u0_m0_wo0_wi0_r0_delayr5_rdcnt_eq <= '0';
                END IF;
                IF (u0_m0_wo0_wi0_r0_delayr5_rdcnt_eq = '1') THEN
                    u0_m0_wo0_wi0_r0_delayr5_rdcnt_i <= u0_m0_wo0_wi0_r0_delayr5_rdcnt_i + 3;
                ELSE
                    u0_m0_wo0_wi0_r0_delayr5_rdcnt_i <= u0_m0_wo0_wi0_r0_delayr5_rdcnt_i + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_r0_delayr5_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_r0_delayr5_rdcnt_i, 3)));

    -- u0_m0_wo0_wi0_r0_delayr5_rdmux(MUX,119)@14
    u0_m0_wo0_wi0_r0_delayr5_rdmux_s <= d_u0_m0_wo0_compute_q_14_q;
    u0_m0_wo0_wi0_r0_delayr5_rdmux_combproc: PROCESS (u0_m0_wo0_wi0_r0_delayr5_rdmux_s, u0_m0_wo0_wi0_r0_delayr5_wraddr_q, u0_m0_wo0_wi0_r0_delayr5_rdcnt_q)
    BEGIN
        CASE (u0_m0_wo0_wi0_r0_delayr5_rdmux_s) IS
            WHEN "0" => u0_m0_wo0_wi0_r0_delayr5_rdmux_q <= u0_m0_wo0_wi0_r0_delayr5_wraddr_q;
            WHEN "1" => u0_m0_wo0_wi0_r0_delayr5_rdmux_q <= u0_m0_wo0_wi0_r0_delayr5_rdcnt_q;
            WHEN OTHERS => u0_m0_wo0_wi0_r0_delayr5_rdmux_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr1_notEnable(LOGICAL,113)@14
    u0_m0_wo0_wi0_r0_delayr1_notEnable_q <= STD_LOGIC_VECTOR(not (d_u0_m0_wo0_compute_q_14_q));

    -- u0_m0_wo0_wi0_r0_delayr1_nor(LOGICAL,114)@14
    u0_m0_wo0_wi0_r0_delayr1_nor_q <= not (u0_m0_wo0_wi0_r0_delayr1_notEnable_q or u0_m0_wo0_wi0_r0_delayr1_sticky_ena_q);

    -- u0_m0_wo0_wi0_r0_delayr1_mem_last(CONSTANT,110)
    u0_m0_wo0_wi0_r0_delayr1_mem_last_q <= "0100";

    -- u0_m0_wo0_wi0_r0_delayr1_cmp(LOGICAL,111)@14
    u0_m0_wo0_wi0_r0_delayr1_cmp_b <= STD_LOGIC_VECTOR("0" & u0_m0_wo0_wi0_r0_delayr1_rdmux_q);
    u0_m0_wo0_wi0_r0_delayr1_cmp_q <= "1" WHEN u0_m0_wo0_wi0_r0_delayr1_mem_last_q = u0_m0_wo0_wi0_r0_delayr1_cmp_b ELSE "0";

    -- u0_m0_wo0_wi0_r0_delayr1_cmpReg(REG,112)@14 + 1
    u0_m0_wo0_wi0_r0_delayr1_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr1_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr1_cmpReg_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr1_cmp_q);
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr1_sticky_ena(REG,115)@14 + 1
    u0_m0_wo0_wi0_r0_delayr1_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr1_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_wi0_r0_delayr1_nor_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr1_sticky_ena_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr1_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr1_enaAnd(LOGICAL,116)@14
    u0_m0_wo0_wi0_r0_delayr1_enaAnd_q <= u0_m0_wo0_wi0_r0_delayr1_sticky_ena_q and d_u0_m0_wo0_compute_q_14_q;

    -- u0_m0_wo0_wi0_r0_delayr1_rdcnt(COUNTER,107)@14 + 1
    -- low=0, high=5, step=1, init=0
    u0_m0_wo0_wi0_r0_delayr1_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr1_rdcnt_i <= TO_UNSIGNED(0, 3);
            u0_m0_wo0_wi0_r0_delayr1_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                IF (u0_m0_wo0_wi0_r0_delayr1_rdcnt_i = TO_UNSIGNED(4, 3)) THEN
                    u0_m0_wo0_wi0_r0_delayr1_rdcnt_eq <= '1';
                ELSE
                    u0_m0_wo0_wi0_r0_delayr1_rdcnt_eq <= '0';
                END IF;
                IF (u0_m0_wo0_wi0_r0_delayr1_rdcnt_eq = '1') THEN
                    u0_m0_wo0_wi0_r0_delayr1_rdcnt_i <= u0_m0_wo0_wi0_r0_delayr1_rdcnt_i + 3;
                ELSE
                    u0_m0_wo0_wi0_r0_delayr1_rdcnt_i <= u0_m0_wo0_wi0_r0_delayr1_rdcnt_i + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_r0_delayr1_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_r0_delayr1_rdcnt_i, 3)));

    -- u0_m0_wo0_wi0_r0_delayr1_rdmux(MUX,108)@14
    u0_m0_wo0_wi0_r0_delayr1_rdmux_s <= d_u0_m0_wo0_compute_q_14_q;
    u0_m0_wo0_wi0_r0_delayr1_rdmux_combproc: PROCESS (u0_m0_wo0_wi0_r0_delayr1_rdmux_s, u0_m0_wo0_wi0_r0_delayr1_wraddr_q, u0_m0_wo0_wi0_r0_delayr1_rdcnt_q)
    BEGIN
        CASE (u0_m0_wo0_wi0_r0_delayr1_rdmux_s) IS
            WHEN "0" => u0_m0_wo0_wi0_r0_delayr1_rdmux_q <= u0_m0_wo0_wi0_r0_delayr1_wraddr_q;
            WHEN "1" => u0_m0_wo0_wi0_r0_delayr1_rdmux_q <= u0_m0_wo0_wi0_r0_delayr1_rdcnt_q;
            WHEN OTHERS => u0_m0_wo0_wi0_r0_delayr1_rdmux_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_ra0_count1(COUNTER,26)@13
    -- low=0, high=3, step=1, init=0
    u0_m0_wo0_wi0_r0_ra0_count1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_ra0_count1_i <= TO_UNSIGNED(0, 2);
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_memread_q = "1" and u0_m0_wo0_wi0_r0_ra0_count1_run_q = "1") THEN
                u0_m0_wo0_wi0_r0_ra0_count1_i <= u0_m0_wo0_wi0_r0_ra0_count1_i + 1;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_r0_ra0_count1_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_r0_ra0_count1_i, 2)));

    -- u0_m0_wo0_wi0_r0_ra0_count1_lut(LOOKUP,22)@13
    u0_m0_wo0_wi0_r0_ra0_count1_lut_combproc: PROCESS (u0_m0_wo0_wi0_r0_ra0_count1_q)
    BEGIN
        -- Begin reserved scope level
        CASE (u0_m0_wo0_wi0_r0_ra0_count1_q) IS
            WHEN "00" => u0_m0_wo0_wi0_r0_ra0_count1_lut_q <= "000";
            WHEN "01" => u0_m0_wo0_wi0_r0_ra0_count1_lut_q <= "010";
            WHEN "10" => u0_m0_wo0_wi0_r0_ra0_count1_lut_q <= "010";
            WHEN "11" => u0_m0_wo0_wi0_r0_ra0_count1_lut_q <= "000";
            WHEN OTHERS => -- unreachable
                           u0_m0_wo0_wi0_r0_ra0_count1_lut_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_ra0_count1_lutreg(REG,23)@13
    u0_m0_wo0_wi0_r0_ra0_count1_lutreg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_ra0_count1_lutreg_q <= "000";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_memread_q = "1") THEN
                u0_m0_wo0_wi0_r0_ra0_count1_lutreg_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_ra0_count1_lut_q);
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_ra0_count0(COUNTER,21)@13
    -- low=0, high=1, step=1, init=0
    u0_m0_wo0_wi0_r0_ra0_count0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_ra0_count0_i <= TO_UNSIGNED(0, 1);
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_memread_q = "1") THEN
                u0_m0_wo0_wi0_r0_ra0_count0_i <= u0_m0_wo0_wi0_r0_ra0_count0_i + 1;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_r0_ra0_count0_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_r0_ra0_count0_i, 2)));

    -- u0_m0_wo0_wi0_r0_ra0_add_0_0(ADD,27)@13 + 1
    u0_m0_wo0_wi0_r0_ra0_add_0_0_a <= STD_LOGIC_VECTOR("00" & u0_m0_wo0_wi0_r0_ra0_count0_q);
    u0_m0_wo0_wi0_r0_ra0_add_0_0_b <= STD_LOGIC_VECTOR("0" & u0_m0_wo0_wi0_r0_ra0_count1_lutreg_q);
    u0_m0_wo0_wi0_r0_ra0_add_0_0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_ra0_add_0_0_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_wi0_r0_ra0_add_0_0_o <= STD_LOGIC_VECTOR(UNSIGNED(u0_m0_wo0_wi0_r0_ra0_add_0_0_a) + UNSIGNED(u0_m0_wo0_wi0_r0_ra0_add_0_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_r0_ra0_add_0_0_q <= u0_m0_wo0_wi0_r0_ra0_add_0_0_o(3 downto 0);

    -- u0_m0_wo0_wi0_r0_ra0_resize(BITSELECT,28)@14
    u0_m0_wo0_wi0_r0_ra0_resize_in <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_ra0_add_0_0_q(1 downto 0));
    u0_m0_wo0_wi0_r0_ra0_resize_b <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_ra0_resize_in(1 downto 0));

    -- d_xIn_0_14_notEnable(LOGICAL,178)@10
    d_xIn_0_14_notEnable_q <= STD_LOGIC_VECTOR(not (VCC_q));

    -- d_xIn_0_14_nor(LOGICAL,179)@10
    d_xIn_0_14_nor_q <= not (d_xIn_0_14_notEnable_q or d_xIn_0_14_sticky_ena_q);

    -- d_xIn_0_14_mem_last(CONSTANT,175)
    d_xIn_0_14_mem_last_q <= "01";

    -- d_xIn_0_14_cmp(LOGICAL,176)@10
    d_xIn_0_14_cmp_q <= "1" WHEN d_xIn_0_14_mem_last_q = d_xIn_0_14_rdcnt_q ELSE "0";

    -- d_xIn_0_14_cmpReg(REG,177)@10 + 1
    d_xIn_0_14_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_xIn_0_14_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            d_xIn_0_14_cmpReg_q <= STD_LOGIC_VECTOR(d_xIn_0_14_cmp_q);
        END IF;
    END PROCESS;

    -- d_xIn_0_14_sticky_ena(REG,180)@10 + 1
    d_xIn_0_14_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_xIn_0_14_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_xIn_0_14_nor_q = "1") THEN
                d_xIn_0_14_sticky_ena_q <= STD_LOGIC_VECTOR(d_xIn_0_14_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- d_xIn_0_14_enaAnd(LOGICAL,181)@10
    d_xIn_0_14_enaAnd_q <= d_xIn_0_14_sticky_ena_q and VCC_q;

    -- d_xIn_0_14_rdcnt(COUNTER,173)@10 + 1
    -- low=0, high=2, step=1, init=0
    d_xIn_0_14_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_xIn_0_14_rdcnt_i <= TO_UNSIGNED(0, 2);
            d_xIn_0_14_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_xIn_0_14_rdcnt_i = TO_UNSIGNED(1, 2)) THEN
                d_xIn_0_14_rdcnt_eq <= '1';
            ELSE
                d_xIn_0_14_rdcnt_eq <= '0';
            END IF;
            IF (d_xIn_0_14_rdcnt_eq = '1') THEN
                d_xIn_0_14_rdcnt_i <= d_xIn_0_14_rdcnt_i + 2;
            ELSE
                d_xIn_0_14_rdcnt_i <= d_xIn_0_14_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    d_xIn_0_14_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(d_xIn_0_14_rdcnt_i, 2)));

    -- d_xIn_0_14_wraddr(REG,174)@10 + 1
    d_xIn_0_14_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_xIn_0_14_wraddr_q <= "10";
        ELSIF (clk'EVENT AND clk = '1') THEN
            d_xIn_0_14_wraddr_q <= STD_LOGIC_VECTOR(d_xIn_0_14_rdcnt_q);
        END IF;
    END PROCESS;

    -- d_xIn_0_14_mem(DUALMEM,172)@10 + 2
    d_xIn_0_14_mem_ia <= STD_LOGIC_VECTOR(xIn_0);
    d_xIn_0_14_mem_aa <= d_xIn_0_14_wraddr_q;
    d_xIn_0_14_mem_ab <= d_xIn_0_14_rdcnt_q;
    d_xIn_0_14_mem_reset0 <= areset;
    d_xIn_0_14_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 16,
        widthad_a => 2,
        numwords_a => 3,
        width_b => 16,
        widthad_b => 2,
        numwords_b => 3,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => d_xIn_0_14_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => d_xIn_0_14_mem_reset0,
        clock1 => clk,
        address_a => d_xIn_0_14_mem_aa,
        data_a => d_xIn_0_14_mem_ia,
        wren_a => VCC_q(0),
        address_b => d_xIn_0_14_mem_ab,
        q_b => d_xIn_0_14_mem_iq
    );
    d_xIn_0_14_mem_q <= d_xIn_0_14_mem_iq(15 downto 0);

    -- d_in0_m0_wi0_wo0_assign_id1_q_14(DELAY,99)@11 + 3
    d_in0_m0_wi0_wo0_assign_id1_q_14 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => d_in0_m0_wi0_wo0_assign_id1_q_11_q, xout => d_in0_m0_wi0_wo0_assign_id1_q_14_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_wi0_r0_wa0(COUNTER,36)@14
    -- low=0, high=3, step=1, init=2
    u0_m0_wo0_wi0_r0_wa0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_wa0_i <= TO_UNSIGNED(2, 2);
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_id1_q_14_q = "1") THEN
                u0_m0_wo0_wi0_r0_wa0_i <= u0_m0_wo0_wi0_r0_wa0_i + 1;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_r0_wa0_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_r0_wa0_i, 2)));

    -- u0_m0_wo0_wi0_r0_memr0(DUALMEM,38)@14
    u0_m0_wo0_wi0_r0_memr0_ia <= STD_LOGIC_VECTOR(d_xIn_0_14_mem_q);
    u0_m0_wo0_wi0_r0_memr0_aa <= u0_m0_wo0_wi0_r0_wa0_q;
    u0_m0_wo0_wi0_r0_memr0_ab <= u0_m0_wo0_wi0_r0_ra0_resize_b;
    u0_m0_wo0_wi0_r0_memr0_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 16,
        widthad_a => 2,
        numwords_a => 4,
        width_b => 16,
        widthad_b => 2,
        numwords_b => 4,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK0",
        outdata_aclr_b => "NONE",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "FALSE",
        init_file => "UNUSED",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken0 => '1',
        clock0 => clk,
        address_a => u0_m0_wo0_wi0_r0_memr0_aa,
        data_a => u0_m0_wo0_wi0_r0_memr0_ia,
        wren_a => d_in0_m0_wi0_wo0_assign_id1_q_14_q(0),
        address_b => u0_m0_wo0_wi0_r0_memr0_ab,
        q_b => u0_m0_wo0_wi0_r0_memr0_iq
    );
    u0_m0_wo0_wi0_r0_memr0_q <= u0_m0_wo0_wi0_r0_memr0_iq(15 downto 0);

    -- u0_m0_wo0_wi0_r0_join1(BITJOIN,40)@14
    u0_m0_wo0_wi0_r0_join1_q <= u0_m0_wo0_wi0_r0_split1_d & u0_m0_wo0_wi0_r0_split1_c & u0_m0_wo0_wi0_r0_split1_b & u0_m0_wo0_wi0_r0_memr0_q;

    -- u0_m0_wo0_wi0_r0_delayr1_wraddr(REG,109)@14 + 1
    u0_m0_wo0_wi0_r0_delayr1_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr1_wraddr_q <= "101";
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_wi0_r0_delayr1_wraddr_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr1_rdmux_q);
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr1_mem(DUALMEM,106)@14 + 2
    u0_m0_wo0_wi0_r0_delayr1_mem_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_join1_q);
    u0_m0_wo0_wi0_r0_delayr1_mem_aa <= u0_m0_wo0_wi0_r0_delayr1_wraddr_q;
    u0_m0_wo0_wi0_r0_delayr1_mem_ab <= u0_m0_wo0_wi0_r0_delayr1_rdmux_q;
    u0_m0_wo0_wi0_r0_delayr1_mem_reset0 <= areset;
    u0_m0_wo0_wi0_r0_delayr1_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 64,
        widthad_a => 3,
        numwords_a => 6,
        width_b => 64,
        widthad_b => 3,
        numwords_b => 6,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => u0_m0_wo0_wi0_r0_delayr1_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => u0_m0_wo0_wi0_r0_delayr1_mem_reset0,
        clock1 => clk,
        address_a => u0_m0_wo0_wi0_r0_delayr1_mem_aa,
        data_a => u0_m0_wo0_wi0_r0_delayr1_mem_ia,
        wren_a => d_u0_m0_wo0_compute_q_14_q(0),
        address_b => u0_m0_wo0_wi0_r0_delayr1_mem_ab,
        q_b => u0_m0_wo0_wi0_r0_delayr1_mem_iq
    );
    u0_m0_wo0_wi0_r0_delayr1_mem_q <= u0_m0_wo0_wi0_r0_delayr1_mem_iq(63 downto 0);

    -- u0_m0_wo0_wi0_r0_split1(BITSELECT,41)@14
    u0_m0_wo0_wi0_r0_split1_b <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr1_mem_q(15 downto 0));
    u0_m0_wo0_wi0_r0_split1_c <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr1_mem_q(31 downto 16));
    u0_m0_wo0_wi0_r0_split1_d <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr1_mem_q(47 downto 32));
    u0_m0_wo0_wi0_r0_split1_e <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr1_mem_q(63 downto 48));

    -- u0_m0_wo0_wi0_r0_join5(BITJOIN,43)@14
    u0_m0_wo0_wi0_r0_join5_q <= u0_m0_wo0_wi0_r0_split5_d & u0_m0_wo0_wi0_r0_split5_c & u0_m0_wo0_wi0_r0_split5_b & u0_m0_wo0_wi0_r0_split1_e;

    -- u0_m0_wo0_wi0_r0_delayr5_wraddr(REG,120)@14 + 1
    u0_m0_wo0_wi0_r0_delayr5_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr5_wraddr_q <= "101";
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_wi0_r0_delayr5_wraddr_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr5_rdmux_q);
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr5_mem(DUALMEM,117)@14 + 2
    u0_m0_wo0_wi0_r0_delayr5_mem_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_join5_q);
    u0_m0_wo0_wi0_r0_delayr5_mem_aa <= u0_m0_wo0_wi0_r0_delayr5_wraddr_q;
    u0_m0_wo0_wi0_r0_delayr5_mem_ab <= u0_m0_wo0_wi0_r0_delayr5_rdmux_q;
    u0_m0_wo0_wi0_r0_delayr5_mem_reset0 <= areset;
    u0_m0_wo0_wi0_r0_delayr5_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 64,
        widthad_a => 3,
        numwords_a => 6,
        width_b => 64,
        widthad_b => 3,
        numwords_b => 6,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => u0_m0_wo0_wi0_r0_delayr5_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => u0_m0_wo0_wi0_r0_delayr5_mem_reset0,
        clock1 => clk,
        address_a => u0_m0_wo0_wi0_r0_delayr5_mem_aa,
        data_a => u0_m0_wo0_wi0_r0_delayr5_mem_ia,
        wren_a => d_u0_m0_wo0_compute_q_14_q(0),
        address_b => u0_m0_wo0_wi0_r0_delayr5_mem_ab,
        q_b => u0_m0_wo0_wi0_r0_delayr5_mem_iq
    );
    u0_m0_wo0_wi0_r0_delayr5_mem_q <= u0_m0_wo0_wi0_r0_delayr5_mem_iq(63 downto 0);

    -- u0_m0_wo0_wi0_r0_split5(BITSELECT,44)@14
    u0_m0_wo0_wi0_r0_split5_b <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr5_mem_q(15 downto 0));
    u0_m0_wo0_wi0_r0_split5_c <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr5_mem_q(31 downto 16));
    u0_m0_wo0_wi0_r0_split5_d <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr5_mem_q(47 downto 32));
    u0_m0_wo0_wi0_r0_split5_e <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr5_mem_q(63 downto 48));

    -- u0_m0_wo0_wi0_r0_delayr9_wraddr(REG,131)@14 + 1
    u0_m0_wo0_wi0_r0_delayr9_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr9_wraddr_q <= "101";
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_wi0_r0_delayr9_wraddr_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr9_rdmux_q);
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr9_mem(DUALMEM,128)@14 + 2
    u0_m0_wo0_wi0_r0_delayr9_mem_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_split5_e);
    u0_m0_wo0_wi0_r0_delayr9_mem_aa <= u0_m0_wo0_wi0_r0_delayr9_wraddr_q;
    u0_m0_wo0_wi0_r0_delayr9_mem_ab <= u0_m0_wo0_wi0_r0_delayr9_rdmux_q;
    u0_m0_wo0_wi0_r0_delayr9_mem_reset0 <= areset;
    u0_m0_wo0_wi0_r0_delayr9_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 16,
        widthad_a => 3,
        numwords_a => 6,
        width_b => 16,
        widthad_b => 3,
        numwords_b => 6,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => u0_m0_wo0_wi0_r0_delayr9_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => u0_m0_wo0_wi0_r0_delayr9_mem_reset0,
        clock1 => clk,
        address_a => u0_m0_wo0_wi0_r0_delayr9_mem_aa,
        data_a => u0_m0_wo0_wi0_r0_delayr9_mem_ia,
        wren_a => d_u0_m0_wo0_compute_q_14_q(0),
        address_b => u0_m0_wo0_wi0_r0_delayr9_mem_ab,
        q_b => u0_m0_wo0_wi0_r0_delayr9_mem_iq
    );
    u0_m0_wo0_wi0_r0_delayr9_mem_q <= u0_m0_wo0_wi0_r0_delayr9_mem_iq(15 downto 0);

    -- u0_m0_wo0_sym_add9(ADD,79)@14 + 1
    u0_m0_wo0_sym_add9_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_delayr9_mem_q(15)) & u0_m0_wo0_wi0_r0_delayr9_mem_q));
    u0_m0_wo0_sym_add9_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_memr10_q(15)) & u0_m0_wo0_wi0_r0_memr10_q));
    u0_m0_wo0_sym_add9_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add9_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add9_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add9_a) + SIGNED(u0_m0_wo0_sym_add9_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add9_q <= u0_m0_wo0_sym_add9_o(16 downto 0);

    -- u0_m0_wo0_cm8(LOOKUP,68)@14 + 1
    u0_m0_wo0_cm8_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm8_q <= "0011100011001001011";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca8_1_q) IS
                WHEN "0" => u0_m0_wo0_cm8_q <= "0011100011001001011";
                WHEN "1" => u0_m0_wo0_cm8_q <= "0000110100001010000";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm8_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr11_notEnable(LOGICAL,146)@14
    u0_m0_wo0_wi0_r0_delayr11_notEnable_q <= STD_LOGIC_VECTOR(not (d_u0_m0_wo0_compute_q_14_q));

    -- u0_m0_wo0_wi0_r0_delayr11_nor(LOGICAL,147)@14
    u0_m0_wo0_wi0_r0_delayr11_nor_q <= not (u0_m0_wo0_wi0_r0_delayr11_notEnable_q or u0_m0_wo0_wi0_r0_delayr11_sticky_ena_q);

    -- u0_m0_wo0_wi0_r0_delayr11_mem_last(CONSTANT,143)
    u0_m0_wo0_wi0_r0_delayr11_mem_last_q <= "0110";

    -- u0_m0_wo0_wi0_r0_delayr11_cmp(LOGICAL,144)@14
    u0_m0_wo0_wi0_r0_delayr11_cmp_b <= STD_LOGIC_VECTOR("0" & u0_m0_wo0_wi0_r0_delayr11_rdmux_q);
    u0_m0_wo0_wi0_r0_delayr11_cmp_q <= "1" WHEN u0_m0_wo0_wi0_r0_delayr11_mem_last_q = u0_m0_wo0_wi0_r0_delayr11_cmp_b ELSE "0";

    -- u0_m0_wo0_wi0_r0_delayr11_cmpReg(REG,145)@14 + 1
    u0_m0_wo0_wi0_r0_delayr11_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr11_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr11_cmpReg_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr11_cmp_q);
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr11_sticky_ena(REG,148)@14 + 1
    u0_m0_wo0_wi0_r0_delayr11_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr11_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_wi0_r0_delayr11_nor_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr11_sticky_ena_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr11_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr11_enaAnd(LOGICAL,149)@14
    u0_m0_wo0_wi0_r0_delayr11_enaAnd_q <= u0_m0_wo0_wi0_r0_delayr11_sticky_ena_q and d_u0_m0_wo0_compute_q_14_q;

    -- u0_m0_wo0_wi0_r0_delayr11_rdcnt(COUNTER,140)@14 + 1
    -- low=0, high=7, step=1, init=0
    u0_m0_wo0_wi0_r0_delayr11_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr11_rdcnt_i <= TO_UNSIGNED(0, 3);
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr11_rdcnt_i <= u0_m0_wo0_wi0_r0_delayr11_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_r0_delayr11_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_r0_delayr11_rdcnt_i, 3)));

    -- u0_m0_wo0_wi0_r0_delayr11_rdmux(MUX,141)@14
    u0_m0_wo0_wi0_r0_delayr11_rdmux_s <= d_u0_m0_wo0_compute_q_14_q;
    u0_m0_wo0_wi0_r0_delayr11_rdmux_combproc: PROCESS (u0_m0_wo0_wi0_r0_delayr11_rdmux_s, u0_m0_wo0_wi0_r0_delayr11_wraddr_q, u0_m0_wo0_wi0_r0_delayr11_rdcnt_q)
    BEGIN
        CASE (u0_m0_wo0_wi0_r0_delayr11_rdmux_s) IS
            WHEN "0" => u0_m0_wo0_wi0_r0_delayr11_rdmux_q <= u0_m0_wo0_wi0_r0_delayr11_wraddr_q;
            WHEN "1" => u0_m0_wo0_wi0_r0_delayr11_rdmux_q <= u0_m0_wo0_wi0_r0_delayr11_rdcnt_q;
            WHEN OTHERS => u0_m0_wo0_wi0_r0_delayr11_rdmux_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_join11(BITJOIN,47)@14
    u0_m0_wo0_wi0_r0_join11_q <= u0_m0_wo0_wi0_r0_split11_d & u0_m0_wo0_wi0_r0_split11_c & u0_m0_wo0_wi0_r0_split11_b & u0_m0_wo0_wi0_r0_memr10_q;

    -- u0_m0_wo0_wi0_r0_delayr11_wraddr(REG,142)@14 + 1
    u0_m0_wo0_wi0_r0_delayr11_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr11_wraddr_q <= "111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_wi0_r0_delayr11_wraddr_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr11_rdmux_q);
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr11_mem(DUALMEM,139)@14 + 2
    u0_m0_wo0_wi0_r0_delayr11_mem_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_join11_q);
    u0_m0_wo0_wi0_r0_delayr11_mem_aa <= u0_m0_wo0_wi0_r0_delayr11_wraddr_q;
    u0_m0_wo0_wi0_r0_delayr11_mem_ab <= u0_m0_wo0_wi0_r0_delayr11_rdmux_q;
    u0_m0_wo0_wi0_r0_delayr11_mem_reset0 <= areset;
    u0_m0_wo0_wi0_r0_delayr11_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 64,
        widthad_a => 3,
        numwords_a => 8,
        width_b => 64,
        widthad_b => 3,
        numwords_b => 8,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => u0_m0_wo0_wi0_r0_delayr11_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => u0_m0_wo0_wi0_r0_delayr11_mem_reset0,
        clock1 => clk,
        address_a => u0_m0_wo0_wi0_r0_delayr11_mem_aa,
        data_a => u0_m0_wo0_wi0_r0_delayr11_mem_ia,
        wren_a => d_u0_m0_wo0_compute_q_14_q(0),
        address_b => u0_m0_wo0_wi0_r0_delayr11_mem_ab,
        q_b => u0_m0_wo0_wi0_r0_delayr11_mem_iq
    );
    u0_m0_wo0_wi0_r0_delayr11_mem_q <= u0_m0_wo0_wi0_r0_delayr11_mem_iq(63 downto 0);

    -- u0_m0_wo0_wi0_r0_split11(BITSELECT,48)@14
    u0_m0_wo0_wi0_r0_split11_b <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr11_mem_q(15 downto 0));
    u0_m0_wo0_wi0_r0_split11_c <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr11_mem_q(31 downto 16));
    u0_m0_wo0_wi0_r0_split11_d <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr11_mem_q(47 downto 32));
    u0_m0_wo0_wi0_r0_split11_e <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr11_mem_q(63 downto 48));

    -- u0_m0_wo0_sym_add8(ADD,78)@14 + 1
    u0_m0_wo0_sym_add8_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split5_e(15)) & u0_m0_wo0_wi0_r0_split5_e));
    u0_m0_wo0_sym_add8_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split11_b(15)) & u0_m0_wo0_wi0_r0_split11_b));
    u0_m0_wo0_sym_add8_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add8_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add8_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add8_a) + SIGNED(u0_m0_wo0_sym_add8_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add8_q <= u0_m0_wo0_sym_add8_o(16 downto 0);

    -- u0_m0_wo0_cm7(LOOKUP,67)@14 + 1
    u0_m0_wo0_cm7_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm7_q <= "1110111110100001001";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca9_1_q) IS
                WHEN "0" => u0_m0_wo0_cm7_q <= "1110111110100001001";
                WHEN "1" => u0_m0_wo0_cm7_q <= "1110011010000111100";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm7_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_sym_add7(ADD,77)@14 + 1
    u0_m0_wo0_sym_add7_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split5_d(15)) & u0_m0_wo0_wi0_r0_split5_d));
    u0_m0_wo0_sym_add7_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split11_c(15)) & u0_m0_wo0_wi0_r0_split11_c));
    u0_m0_wo0_sym_add7_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add7_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add7_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add7_a) + SIGNED(u0_m0_wo0_sym_add7_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add7_q <= u0_m0_wo0_sym_add7_o(16 downto 0);

    -- u0_m0_wo0_cm6(LOOKUP,66)@14 + 1
    u0_m0_wo0_cm6_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm6_q <= "1111110010101101011";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca8_1_q) IS
                WHEN "0" => u0_m0_wo0_cm6_q <= "1111110010101101011";
                WHEN "1" => u0_m0_wo0_cm6_q <= "1110111000011100010";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm6_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_sym_add6(ADD,76)@14 + 1
    u0_m0_wo0_sym_add6_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split5_c(15)) & u0_m0_wo0_wi0_r0_split5_c));
    u0_m0_wo0_sym_add6_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split11_d(15)) & u0_m0_wo0_wi0_r0_split11_d));
    u0_m0_wo0_sym_add6_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add6_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add6_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add6_a) + SIGNED(u0_m0_wo0_sym_add6_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add6_q <= u0_m0_wo0_sym_add6_o(16 downto 0);

    -- u0_m0_wo0_cm5(LOOKUP,65)@14 + 1
    u0_m0_wo0_cm5_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm5_q <= "0000101111010010100";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca9_1_q) IS
                WHEN "0" => u0_m0_wo0_cm5_q <= "0000101111010010100";
                WHEN "1" => u0_m0_wo0_cm5_q <= "0000100001011000110";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm5_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_sym_add5(ADD,75)@14 + 1
    u0_m0_wo0_sym_add5_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split5_b(15)) & u0_m0_wo0_wi0_r0_split5_b));
    u0_m0_wo0_sym_add5_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split11_e(15)) & u0_m0_wo0_wi0_r0_split11_e));
    u0_m0_wo0_sym_add5_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add5_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add5_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add5_a) + SIGNED(u0_m0_wo0_sym_add5_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add5_q <= u0_m0_wo0_sym_add5_o(16 downto 0);

    -- u0_m0_wo0_cm4(LOOKUP,64)@14 + 1
    u0_m0_wo0_cm4_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm4_q <= "0000011111000010100";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca8_1_q) IS
                WHEN "0" => u0_m0_wo0_cm4_q <= "0000011111000010100";
                WHEN "1" => u0_m0_wo0_cm4_q <= "0000000010110100010";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm4_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr15_notEnable(LOGICAL,157)@14
    u0_m0_wo0_wi0_r0_delayr15_notEnable_q <= STD_LOGIC_VECTOR(not (d_u0_m0_wo0_compute_q_14_q));

    -- u0_m0_wo0_wi0_r0_delayr15_nor(LOGICAL,158)@14
    u0_m0_wo0_wi0_r0_delayr15_nor_q <= not (u0_m0_wo0_wi0_r0_delayr15_notEnable_q or u0_m0_wo0_wi0_r0_delayr15_sticky_ena_q);

    -- u0_m0_wo0_wi0_r0_delayr15_mem_last(CONSTANT,154)
    u0_m0_wo0_wi0_r0_delayr15_mem_last_q <= "0110";

    -- u0_m0_wo0_wi0_r0_delayr15_cmp(LOGICAL,155)@14
    u0_m0_wo0_wi0_r0_delayr15_cmp_b <= STD_LOGIC_VECTOR("0" & u0_m0_wo0_wi0_r0_delayr15_rdmux_q);
    u0_m0_wo0_wi0_r0_delayr15_cmp_q <= "1" WHEN u0_m0_wo0_wi0_r0_delayr15_mem_last_q = u0_m0_wo0_wi0_r0_delayr15_cmp_b ELSE "0";

    -- u0_m0_wo0_wi0_r0_delayr15_cmpReg(REG,156)@14 + 1
    u0_m0_wo0_wi0_r0_delayr15_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr15_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr15_cmpReg_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr15_cmp_q);
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr15_sticky_ena(REG,159)@14 + 1
    u0_m0_wo0_wi0_r0_delayr15_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr15_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_wi0_r0_delayr15_nor_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr15_sticky_ena_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr15_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr15_enaAnd(LOGICAL,160)@14
    u0_m0_wo0_wi0_r0_delayr15_enaAnd_q <= u0_m0_wo0_wi0_r0_delayr15_sticky_ena_q and d_u0_m0_wo0_compute_q_14_q;

    -- u0_m0_wo0_wi0_r0_delayr15_rdcnt(COUNTER,151)@14 + 1
    -- low=0, high=7, step=1, init=0
    u0_m0_wo0_wi0_r0_delayr15_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr15_rdcnt_i <= TO_UNSIGNED(0, 3);
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr15_rdcnt_i <= u0_m0_wo0_wi0_r0_delayr15_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_r0_delayr15_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_r0_delayr15_rdcnt_i, 3)));

    -- u0_m0_wo0_wi0_r0_delayr15_rdmux(MUX,152)@14
    u0_m0_wo0_wi0_r0_delayr15_rdmux_s <= d_u0_m0_wo0_compute_q_14_q;
    u0_m0_wo0_wi0_r0_delayr15_rdmux_combproc: PROCESS (u0_m0_wo0_wi0_r0_delayr15_rdmux_s, u0_m0_wo0_wi0_r0_delayr15_wraddr_q, u0_m0_wo0_wi0_r0_delayr15_rdcnt_q)
    BEGIN
        CASE (u0_m0_wo0_wi0_r0_delayr15_rdmux_s) IS
            WHEN "0" => u0_m0_wo0_wi0_r0_delayr15_rdmux_q <= u0_m0_wo0_wi0_r0_delayr15_wraddr_q;
            WHEN "1" => u0_m0_wo0_wi0_r0_delayr15_rdmux_q <= u0_m0_wo0_wi0_r0_delayr15_rdcnt_q;
            WHEN OTHERS => u0_m0_wo0_wi0_r0_delayr15_rdmux_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_join15(BITJOIN,50)@14
    u0_m0_wo0_wi0_r0_join15_q <= u0_m0_wo0_wi0_r0_split15_d & u0_m0_wo0_wi0_r0_split15_c & u0_m0_wo0_wi0_r0_split15_b & u0_m0_wo0_wi0_r0_split11_e;

    -- u0_m0_wo0_wi0_r0_delayr15_wraddr(REG,153)@14 + 1
    u0_m0_wo0_wi0_r0_delayr15_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr15_wraddr_q <= "111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_wi0_r0_delayr15_wraddr_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr15_rdmux_q);
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr15_mem(DUALMEM,150)@14 + 2
    u0_m0_wo0_wi0_r0_delayr15_mem_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_join15_q);
    u0_m0_wo0_wi0_r0_delayr15_mem_aa <= u0_m0_wo0_wi0_r0_delayr15_wraddr_q;
    u0_m0_wo0_wi0_r0_delayr15_mem_ab <= u0_m0_wo0_wi0_r0_delayr15_rdmux_q;
    u0_m0_wo0_wi0_r0_delayr15_mem_reset0 <= areset;
    u0_m0_wo0_wi0_r0_delayr15_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 64,
        widthad_a => 3,
        numwords_a => 8,
        width_b => 64,
        widthad_b => 3,
        numwords_b => 8,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => u0_m0_wo0_wi0_r0_delayr15_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => u0_m0_wo0_wi0_r0_delayr15_mem_reset0,
        clock1 => clk,
        address_a => u0_m0_wo0_wi0_r0_delayr15_mem_aa,
        data_a => u0_m0_wo0_wi0_r0_delayr15_mem_ia,
        wren_a => d_u0_m0_wo0_compute_q_14_q(0),
        address_b => u0_m0_wo0_wi0_r0_delayr15_mem_ab,
        q_b => u0_m0_wo0_wi0_r0_delayr15_mem_iq
    );
    u0_m0_wo0_wi0_r0_delayr15_mem_q <= u0_m0_wo0_wi0_r0_delayr15_mem_iq(63 downto 0);

    -- u0_m0_wo0_wi0_r0_split15(BITSELECT,51)@14
    u0_m0_wo0_wi0_r0_split15_b <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr15_mem_q(15 downto 0));
    u0_m0_wo0_wi0_r0_split15_c <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr15_mem_q(31 downto 16));
    u0_m0_wo0_wi0_r0_split15_d <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr15_mem_q(47 downto 32));
    u0_m0_wo0_wi0_r0_split15_e <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr15_mem_q(63 downto 48));

    -- u0_m0_wo0_sym_add4(ADD,74)@14 + 1
    u0_m0_wo0_sym_add4_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split1_e(15)) & u0_m0_wo0_wi0_r0_split1_e));
    u0_m0_wo0_sym_add4_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split15_b(15)) & u0_m0_wo0_wi0_r0_split15_b));
    u0_m0_wo0_sym_add4_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add4_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add4_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add4_a) + SIGNED(u0_m0_wo0_sym_add4_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add4_q <= u0_m0_wo0_sym_add4_o(16 downto 0);

    -- u0_m0_wo0_cm3(LOOKUP,63)@14 + 1
    u0_m0_wo0_cm3_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm3_q <= "1111101101111011011";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca9_1_q) IS
                WHEN "0" => u0_m0_wo0_cm3_q <= "1111101101111011011";
                WHEN "1" => u0_m0_wo0_cm3_q <= "1111101001101100100";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm3_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_sym_add3(ADD,73)@14 + 1
    u0_m0_wo0_sym_add3_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split1_d(15)) & u0_m0_wo0_wi0_r0_split1_d));
    u0_m0_wo0_sym_add3_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split15_c(15)) & u0_m0_wo0_wi0_r0_split15_c));
    u0_m0_wo0_sym_add3_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add3_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add3_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add3_a) + SIGNED(u0_m0_wo0_sym_add3_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add3_q <= u0_m0_wo0_sym_add3_o(16 downto 0);

    -- u0_m0_wo0_cm2(LOOKUP,62)@14 + 1
    u0_m0_wo0_cm2_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm2_q <= "0000000000010011101";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca8_1_q) IS
                WHEN "0" => u0_m0_wo0_cm2_q <= "0000000000010011101";
                WHEN "1" => u0_m0_wo0_cm2_q <= "1111110011000111001";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm2_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_sym_add2(ADD,72)@14 + 1
    u0_m0_wo0_sym_add2_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split1_c(15)) & u0_m0_wo0_wi0_r0_split1_c));
    u0_m0_wo0_sym_add2_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split15_d(15)) & u0_m0_wo0_wi0_r0_split15_d));
    u0_m0_wo0_sym_add2_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add2_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add2_a) + SIGNED(u0_m0_wo0_sym_add2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add2_q <= u0_m0_wo0_sym_add2_o(16 downto 0);

    -- u0_m0_wo0_cm1(LOOKUP,61)@14 + 1
    u0_m0_wo0_cm1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm1_q <= "0000001000110101011";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca9_1_q) IS
                WHEN "0" => u0_m0_wo0_cm1_q <= "0000001000110101011";
                WHEN "1" => u0_m0_wo0_cm1_q <= "0000001000011111011";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm1_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_sym_add1(ADD,71)@14 + 1
    u0_m0_wo0_sym_add1_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split1_b(15)) & u0_m0_wo0_wi0_r0_split1_b));
    u0_m0_wo0_sym_add1_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_split15_e(15)) & u0_m0_wo0_wi0_r0_split15_e));
    u0_m0_wo0_sym_add1_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add1_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add1_a) + SIGNED(u0_m0_wo0_sym_add1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add1_q <= u0_m0_wo0_sym_add1_o(16 downto 0);

    -- u0_m0_wo0_cm0(LOOKUP,60)@14 + 1
    u0_m0_wo0_cm0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cm0_q <= "0000000100001100111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (u0_m0_wo0_ca8_1_q) IS
                WHEN "0" => u0_m0_wo0_cm0_q <= "0000000100001100111";
                WHEN "1" => u0_m0_wo0_cm0_q <= "1111111111011000111";
                WHEN OTHERS => -- unreachable
                               u0_m0_wo0_cm0_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr19_notEnable(LOGICAL,168)@14
    u0_m0_wo0_wi0_r0_delayr19_notEnable_q <= STD_LOGIC_VECTOR(not (d_u0_m0_wo0_compute_q_14_q));

    -- u0_m0_wo0_wi0_r0_delayr19_nor(LOGICAL,169)@14
    u0_m0_wo0_wi0_r0_delayr19_nor_q <= not (u0_m0_wo0_wi0_r0_delayr19_notEnable_q or u0_m0_wo0_wi0_r0_delayr19_sticky_ena_q);

    -- u0_m0_wo0_wi0_r0_delayr19_mem_last(CONSTANT,165)
    u0_m0_wo0_wi0_r0_delayr19_mem_last_q <= "0110";

    -- u0_m0_wo0_wi0_r0_delayr19_cmp(LOGICAL,166)@14
    u0_m0_wo0_wi0_r0_delayr19_cmp_b <= STD_LOGIC_VECTOR("0" & u0_m0_wo0_wi0_r0_delayr19_rdmux_q);
    u0_m0_wo0_wi0_r0_delayr19_cmp_q <= "1" WHEN u0_m0_wo0_wi0_r0_delayr19_mem_last_q = u0_m0_wo0_wi0_r0_delayr19_cmp_b ELSE "0";

    -- u0_m0_wo0_wi0_r0_delayr19_cmpReg(REG,167)@14 + 1
    u0_m0_wo0_wi0_r0_delayr19_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr19_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr19_cmpReg_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr19_cmp_q);
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr19_sticky_ena(REG,170)@14 + 1
    u0_m0_wo0_wi0_r0_delayr19_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr19_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_wi0_r0_delayr19_nor_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr19_sticky_ena_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr19_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr19_enaAnd(LOGICAL,171)@14
    u0_m0_wo0_wi0_r0_delayr19_enaAnd_q <= u0_m0_wo0_wi0_r0_delayr19_sticky_ena_q and d_u0_m0_wo0_compute_q_14_q;

    -- u0_m0_wo0_wi0_r0_delayr19_rdcnt(COUNTER,162)@14 + 1
    -- low=0, high=7, step=1, init=0
    u0_m0_wo0_wi0_r0_delayr19_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr19_rdcnt_i <= TO_UNSIGNED(0, 3);
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                u0_m0_wo0_wi0_r0_delayr19_rdcnt_i <= u0_m0_wo0_wi0_r0_delayr19_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_wi0_r0_delayr19_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(u0_m0_wo0_wi0_r0_delayr19_rdcnt_i, 3)));

    -- u0_m0_wo0_wi0_r0_delayr19_rdmux(MUX,163)@14
    u0_m0_wo0_wi0_r0_delayr19_rdmux_s <= d_u0_m0_wo0_compute_q_14_q;
    u0_m0_wo0_wi0_r0_delayr19_rdmux_combproc: PROCESS (u0_m0_wo0_wi0_r0_delayr19_rdmux_s, u0_m0_wo0_wi0_r0_delayr19_wraddr_q, u0_m0_wo0_wi0_r0_delayr19_rdcnt_q)
    BEGIN
        CASE (u0_m0_wo0_wi0_r0_delayr19_rdmux_s) IS
            WHEN "0" => u0_m0_wo0_wi0_r0_delayr19_rdmux_q <= u0_m0_wo0_wi0_r0_delayr19_wraddr_q;
            WHEN "1" => u0_m0_wo0_wi0_r0_delayr19_rdmux_q <= u0_m0_wo0_wi0_r0_delayr19_rdcnt_q;
            WHEN OTHERS => u0_m0_wo0_wi0_r0_delayr19_rdmux_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr19_wraddr(REG,164)@14 + 1
    u0_m0_wo0_wi0_r0_delayr19_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_r0_delayr19_wraddr_q <= "111";
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_wi0_r0_delayr19_wraddr_q <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_delayr19_rdmux_q);
        END IF;
    END PROCESS;

    -- u0_m0_wo0_wi0_r0_delayr19_mem(DUALMEM,161)@14 + 2
    u0_m0_wo0_wi0_r0_delayr19_mem_ia <= STD_LOGIC_VECTOR(u0_m0_wo0_wi0_r0_split15_e);
    u0_m0_wo0_wi0_r0_delayr19_mem_aa <= u0_m0_wo0_wi0_r0_delayr19_wraddr_q;
    u0_m0_wo0_wi0_r0_delayr19_mem_ab <= u0_m0_wo0_wi0_r0_delayr19_rdmux_q;
    u0_m0_wo0_wi0_r0_delayr19_mem_reset0 <= areset;
    u0_m0_wo0_wi0_r0_delayr19_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 16,
        widthad_a => 3,
        numwords_a => 8,
        width_b => 16,
        widthad_b => 3,
        numwords_b => 8,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => u0_m0_wo0_wi0_r0_delayr19_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => u0_m0_wo0_wi0_r0_delayr19_mem_reset0,
        clock1 => clk,
        address_a => u0_m0_wo0_wi0_r0_delayr19_mem_aa,
        data_a => u0_m0_wo0_wi0_r0_delayr19_mem_ia,
        wren_a => d_u0_m0_wo0_compute_q_14_q(0),
        address_b => u0_m0_wo0_wi0_r0_delayr19_mem_ab,
        q_b => u0_m0_wo0_wi0_r0_delayr19_mem_iq
    );
    u0_m0_wo0_wi0_r0_delayr19_mem_q <= u0_m0_wo0_wi0_r0_delayr19_mem_iq(15 downto 0);

    -- u0_m0_wo0_sym_add0(ADD,70)@14 + 1
    u0_m0_wo0_sym_add0_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_memr0_q(15)) & u0_m0_wo0_wi0_r0_memr0_q));
    u0_m0_wo0_sym_add0_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((16 downto 16 => u0_m0_wo0_wi0_r0_delayr19_mem_q(15)) & u0_m0_wo0_wi0_r0_delayr19_mem_q));
    u0_m0_wo0_sym_add0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add0_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add0_a) + SIGNED(u0_m0_wo0_sym_add0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add0_q <= u0_m0_wo0_sym_add0_o(16 downto 0);

    -- GND(CONSTANT,0)@0
    GND_q <= "0";

    -- u0_m0_wo0_aseq(SEQUENCE,82)@14 + 1
    u0_m0_wo0_aseq_clkproc: PROCESS (clk, areset)
        variable u0_m0_wo0_aseq_c : SIGNED(4 downto 0);
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_aseq_c := "00000";
            u0_m0_wo0_aseq_q <= "0";
            u0_m0_wo0_aseq_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                IF (u0_m0_wo0_aseq_c = "11111") THEN
                    u0_m0_wo0_aseq_eq <= '1';
                ELSE
                    u0_m0_wo0_aseq_eq <= '0';
                END IF;
                IF (u0_m0_wo0_aseq_eq = '1') THEN
                    u0_m0_wo0_aseq_c := u0_m0_wo0_aseq_c + 3;
                ELSE
                    u0_m0_wo0_aseq_c := u0_m0_wo0_aseq_c - 1;
                END IF;
                u0_m0_wo0_aseq_q <= STD_LOGIC_VECTOR(u0_m0_wo0_aseq_c(4 downto 4));
            END IF;
        END IF;
    END PROCESS;

    -- d_u0_m0_wo0_compute_q_16(DELAY,103)@15 + 1
    d_u0_m0_wo0_compute_q_16 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => d_u0_m0_wo0_compute_q_15_q, xout => d_u0_m0_wo0_compute_q_16_q, clk => clk, aclr => areset );

    -- d_u0_m0_wo0_compute_q_15(DELAY,102)@14 + 1
    d_u0_m0_wo0_compute_q_15 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => d_u0_m0_wo0_compute_q_14_q, xout => d_u0_m0_wo0_compute_q_15_q, clk => clk, aclr => areset );

    -- u0_m0_wo0_cma0(CHAINMULTADD,80)@15 + 2
    u0_m0_wo0_cma0_reset <= areset;
    u0_m0_wo0_cma0_ena0 <= d_u0_m0_wo0_compute_q_15_q(0);
    u0_m0_wo0_cma0_ena1 <= d_u0_m0_wo0_compute_q_16_q(0);
    u0_m0_wo0_cma0_p(0) <= u0_m0_wo0_cma0_a0(0) * u0_m0_wo0_cma0_c0(0);
    u0_m0_wo0_cma0_p(1) <= u0_m0_wo0_cma0_a0(1) * u0_m0_wo0_cma0_c0(1);
    u0_m0_wo0_cma0_p(2) <= u0_m0_wo0_cma0_a0(2) * u0_m0_wo0_cma0_c0(2);
    u0_m0_wo0_cma0_p(3) <= u0_m0_wo0_cma0_a0(3) * u0_m0_wo0_cma0_c0(3);
    u0_m0_wo0_cma0_p(4) <= u0_m0_wo0_cma0_a0(4) * u0_m0_wo0_cma0_c0(4);
    u0_m0_wo0_cma0_p(5) <= u0_m0_wo0_cma0_a0(5) * u0_m0_wo0_cma0_c0(5);
    u0_m0_wo0_cma0_p(6) <= u0_m0_wo0_cma0_a0(6) * u0_m0_wo0_cma0_c0(6);
    u0_m0_wo0_cma0_p(7) <= u0_m0_wo0_cma0_a0(7) * u0_m0_wo0_cma0_c0(7);
    u0_m0_wo0_cma0_p(8) <= u0_m0_wo0_cma0_a0(8) * u0_m0_wo0_cma0_c0(8);
    u0_m0_wo0_cma0_p(9) <= u0_m0_wo0_cma0_a0(9) * u0_m0_wo0_cma0_c0(9);
    u0_m0_wo0_cma0_u(0) <= RESIZE(u0_m0_wo0_cma0_p(0),44);
    u0_m0_wo0_cma0_u(1) <= RESIZE(u0_m0_wo0_cma0_p(1),44);
    u0_m0_wo0_cma0_u(2) <= RESIZE(u0_m0_wo0_cma0_p(2),44);
    u0_m0_wo0_cma0_u(3) <= RESIZE(u0_m0_wo0_cma0_p(3),44);
    u0_m0_wo0_cma0_u(4) <= RESIZE(u0_m0_wo0_cma0_p(4),44);
    u0_m0_wo0_cma0_u(5) <= RESIZE(u0_m0_wo0_cma0_p(5),44);
    u0_m0_wo0_cma0_u(6) <= RESIZE(u0_m0_wo0_cma0_p(6),44);
    u0_m0_wo0_cma0_u(7) <= RESIZE(u0_m0_wo0_cma0_p(7),44);
    u0_m0_wo0_cma0_u(8) <= RESIZE(u0_m0_wo0_cma0_p(8),44);
    u0_m0_wo0_cma0_u(9) <= RESIZE(u0_m0_wo0_cma0_p(9),44);
    u0_m0_wo0_cma0_w(0) <= u0_m0_wo0_cma0_u(0);
    u0_m0_wo0_cma0_w(1) <= u0_m0_wo0_cma0_u(1);
    u0_m0_wo0_cma0_w(2) <= u0_m0_wo0_cma0_u(2);
    u0_m0_wo0_cma0_w(3) <= u0_m0_wo0_cma0_u(3);
    u0_m0_wo0_cma0_w(4) <= u0_m0_wo0_cma0_u(4);
    u0_m0_wo0_cma0_w(5) <= u0_m0_wo0_cma0_u(5);
    u0_m0_wo0_cma0_w(6) <= u0_m0_wo0_cma0_u(6);
    u0_m0_wo0_cma0_w(7) <= u0_m0_wo0_cma0_u(7);
    u0_m0_wo0_cma0_w(8) <= u0_m0_wo0_cma0_u(8);
    u0_m0_wo0_cma0_w(9) <= u0_m0_wo0_cma0_u(9);
    u0_m0_wo0_cma0_x(0) <= u0_m0_wo0_cma0_w(0);
    u0_m0_wo0_cma0_x(1) <= u0_m0_wo0_cma0_w(1);
    u0_m0_wo0_cma0_x(2) <= u0_m0_wo0_cma0_w(2);
    u0_m0_wo0_cma0_x(3) <= u0_m0_wo0_cma0_w(3);
    u0_m0_wo0_cma0_x(4) <= u0_m0_wo0_cma0_w(4);
    u0_m0_wo0_cma0_x(5) <= u0_m0_wo0_cma0_w(5);
    u0_m0_wo0_cma0_x(6) <= u0_m0_wo0_cma0_w(6);
    u0_m0_wo0_cma0_x(7) <= u0_m0_wo0_cma0_w(7);
    u0_m0_wo0_cma0_x(8) <= u0_m0_wo0_cma0_w(8);
    u0_m0_wo0_cma0_x(9) <= u0_m0_wo0_cma0_w(9);
    u0_m0_wo0_cma0_y(0) <= u0_m0_wo0_cma0_s(1) + u0_m0_wo0_cma0_x(0);
    u0_m0_wo0_cma0_y(1) <= u0_m0_wo0_cma0_s(2) + u0_m0_wo0_cma0_x(1);
    u0_m0_wo0_cma0_y(2) <= u0_m0_wo0_cma0_s(3) + u0_m0_wo0_cma0_x(2);
    u0_m0_wo0_cma0_y(3) <= u0_m0_wo0_cma0_s(4) + u0_m0_wo0_cma0_x(3);
    u0_m0_wo0_cma0_y(4) <= u0_m0_wo0_cma0_s(5) + u0_m0_wo0_cma0_x(4);
    u0_m0_wo0_cma0_y(5) <= u0_m0_wo0_cma0_s(6) + u0_m0_wo0_cma0_x(5);
    u0_m0_wo0_cma0_y(6) <= u0_m0_wo0_cma0_s(7) + u0_m0_wo0_cma0_x(6);
    u0_m0_wo0_cma0_y(7) <= u0_m0_wo0_cma0_s(8) + u0_m0_wo0_cma0_x(7);
    u0_m0_wo0_cma0_y(8) <= u0_m0_wo0_cma0_s(9) + u0_m0_wo0_cma0_x(8);
    u0_m0_wo0_cma0_y(9) <= u0_m0_wo0_cma0_x(9);
    u0_m0_wo0_cma0_z(0) <= u0_m0_wo0_cma0_z(1) WHEN u0_m0_wo0_cma0_anl(0) = '1' ELSE "00000000000000000000000000000000000000000000";
    u0_m0_wo0_cma0_chainmultadd_input: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cma0_a0 <= (others => (others => '0'));
            u0_m0_wo0_cma0_c0 <= (others => (others => '0'));
            u0_m0_wo0_cma0_anl(0) <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_cma0_ena0 = '1') THEN
                u0_m0_wo0_cma0_a0(0) <= RESIZE(SIGNED(u0_m0_wo0_sym_add0_q),17);
                u0_m0_wo0_cma0_a0(1) <= RESIZE(SIGNED(u0_m0_wo0_sym_add1_q),17);
                u0_m0_wo0_cma0_a0(2) <= RESIZE(SIGNED(u0_m0_wo0_sym_add2_q),17);
                u0_m0_wo0_cma0_a0(3) <= RESIZE(SIGNED(u0_m0_wo0_sym_add3_q),17);
                u0_m0_wo0_cma0_a0(4) <= RESIZE(SIGNED(u0_m0_wo0_sym_add4_q),17);
                u0_m0_wo0_cma0_a0(5) <= RESIZE(SIGNED(u0_m0_wo0_sym_add5_q),17);
                u0_m0_wo0_cma0_a0(6) <= RESIZE(SIGNED(u0_m0_wo0_sym_add6_q),17);
                u0_m0_wo0_cma0_a0(7) <= RESIZE(SIGNED(u0_m0_wo0_sym_add7_q),17);
                u0_m0_wo0_cma0_a0(8) <= RESIZE(SIGNED(u0_m0_wo0_sym_add8_q),17);
                u0_m0_wo0_cma0_a0(9) <= RESIZE(SIGNED(u0_m0_wo0_sym_add9_q),17);
                u0_m0_wo0_cma0_c0(0) <= RESIZE(SIGNED(u0_m0_wo0_cm0_q),19);
                u0_m0_wo0_cma0_c0(1) <= RESIZE(SIGNED(u0_m0_wo0_cm1_q),19);
                u0_m0_wo0_cma0_c0(2) <= RESIZE(SIGNED(u0_m0_wo0_cm2_q),19);
                u0_m0_wo0_cma0_c0(3) <= RESIZE(SIGNED(u0_m0_wo0_cm3_q),19);
                u0_m0_wo0_cma0_c0(4) <= RESIZE(SIGNED(u0_m0_wo0_cm4_q),19);
                u0_m0_wo0_cma0_c0(5) <= RESIZE(SIGNED(u0_m0_wo0_cm5_q),19);
                u0_m0_wo0_cma0_c0(6) <= RESIZE(SIGNED(u0_m0_wo0_cm6_q),19);
                u0_m0_wo0_cma0_c0(7) <= RESIZE(SIGNED(u0_m0_wo0_cm7_q),19);
                u0_m0_wo0_cma0_c0(8) <= RESIZE(SIGNED(u0_m0_wo0_cm8_q),19);
                u0_m0_wo0_cma0_c0(9) <= RESIZE(SIGNED(u0_m0_wo0_cm9_q),19);
                u0_m0_wo0_cma0_anl(0) <= not(u0_m0_wo0_aseq_q(0));
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_cma0_chainmultadd_output: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_cma0_z(1) <= (others => '0');
            u0_m0_wo0_cma0_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (u0_m0_wo0_cma0_ena1 = '1') THEN
                u0_m0_wo0_cma0_z(1) <= u0_m0_wo0_cma0_s(0);
                u0_m0_wo0_cma0_s(0) <= u0_m0_wo0_cma0_z(0) + u0_m0_wo0_cma0_y(0);
                u0_m0_wo0_cma0_s(1) <= u0_m0_wo0_cma0_y(1);
                u0_m0_wo0_cma0_s(2) <= u0_m0_wo0_cma0_y(2);
                u0_m0_wo0_cma0_s(3) <= u0_m0_wo0_cma0_y(3);
                u0_m0_wo0_cma0_s(4) <= u0_m0_wo0_cma0_y(4);
                u0_m0_wo0_cma0_s(5) <= u0_m0_wo0_cma0_y(5);
                u0_m0_wo0_cma0_s(6) <= u0_m0_wo0_cma0_y(6);
                u0_m0_wo0_cma0_s(7) <= u0_m0_wo0_cma0_y(7);
                u0_m0_wo0_cma0_s(8) <= u0_m0_wo0_cma0_y(8);
                u0_m0_wo0_cma0_s(9) <= u0_m0_wo0_cma0_y(9);
            END IF;
        END IF;
    END PROCESS;
    u0_m0_wo0_cma0_delay : dspba_delay
    GENERIC MAP ( width => 41, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(u0_m0_wo0_cma0_s(0)(40 downto 0)), xout => u0_m0_wo0_cma0_qq, clk => clk, aclr => areset );
    u0_m0_wo0_cma0_q <= STD_LOGIC_VECTOR(u0_m0_wo0_cma0_qq(40 downto 0));

    -- u0_m0_wo0_oseq(SEQUENCE,84)@14 + 1
    u0_m0_wo0_oseq_clkproc: PROCESS (clk, areset)
        variable u0_m0_wo0_oseq_c : SIGNED(4 downto 0);
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_oseq_c := "00010";
            u0_m0_wo0_oseq_q <= "0";
            u0_m0_wo0_oseq_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (d_u0_m0_wo0_compute_q_14_q = "1") THEN
                IF (u0_m0_wo0_oseq_c = "11111") THEN
                    u0_m0_wo0_oseq_eq <= '1';
                ELSE
                    u0_m0_wo0_oseq_eq <= '0';
                END IF;
                IF (u0_m0_wo0_oseq_eq = '1') THEN
                    u0_m0_wo0_oseq_c := u0_m0_wo0_oseq_c + 3;
                ELSE
                    u0_m0_wo0_oseq_c := u0_m0_wo0_oseq_c - 1;
                END IF;
                u0_m0_wo0_oseq_q <= STD_LOGIC_VECTOR(u0_m0_wo0_oseq_c(4 downto 4));
            END IF;
        END IF;
    END PROCESS;

    -- u0_m0_wo0_oseq_gated(LOGICAL,85)@15
    u0_m0_wo0_oseq_gated_q <= u0_m0_wo0_oseq_q and d_u0_m0_wo0_compute_q_15_q;

    -- u0_m0_wo0_oseq_gated_reg(REG,86)@15 + 1
    u0_m0_wo0_oseq_gated_reg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_oseq_gated_reg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_oseq_gated_reg_q <= STD_LOGIC_VECTOR(u0_m0_wo0_oseq_gated_q);
        END IF;
    END PROCESS;

    -- out0_m0_wo0_lineup_select_delay_0(DELAY,88)@16
    out0_m0_wo0_lineup_select_delay_0_q <= STD_LOGIC_VECTOR(u0_m0_wo0_oseq_gated_reg_q);

    -- out0_m0_wo0_assign_id3(DELAY,90)@16
    out0_m0_wo0_assign_id3_q <= STD_LOGIC_VECTOR(out0_m0_wo0_lineup_select_delay_0_q);

    -- outchan(COUNTER,91)@16 + 1
    -- low=0, high=1, step=1, init=1
    outchan_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            outchan_i <= TO_UNSIGNED(1, 1);
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (out0_m0_wo0_assign_id3_q = "1") THEN
                outchan_i <= outchan_i + 1;
            END IF;
        END IF;
    END PROCESS;
    outchan_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(outchan_i, 2)));

    -- d_out0_m0_wo0_assign_id3_q_17(DELAY,105)@16 + 1
    d_out0_m0_wo0_assign_id3_q_17 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => out0_m0_wo0_assign_id3_q, xout => d_out0_m0_wo0_assign_id3_q_17_q, clk => clk, aclr => areset );

    -- xOut(PORTOUT,92)@17 + 1
    xOut_v <= d_out0_m0_wo0_assign_id3_q_17_q;
    xOut_c <= STD_LOGIC_VECTOR("000000" & outchan_q);
    xOut_0 <= u0_m0_wo0_cma0_q;

END normal;
