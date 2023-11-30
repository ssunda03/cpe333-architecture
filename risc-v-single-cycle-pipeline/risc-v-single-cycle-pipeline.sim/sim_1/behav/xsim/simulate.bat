@echo off
REM ****************************************************************************
REM Vivado (TM) v2020.2 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Sat Nov 18 18:31:44 -0800 2023
REM SW Build 3064766 on Wed Nov 18 09:12:45 MST 2020
REM
REM Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim testbench_behav -key {Behavioral:sim_1:Functional:testbench} -tclbatch testbench.tcl -view C:/Users/srini/Documents/Vivado/CPE333/cpe333-architecture/risc-v-single-cycle-pipeline/risc-v-single-cycle-pipeline.srcs/sim_1/imports/risc-v-single-cycle-pipeline-no-hazard/testbench_behav1.wcfg -log simulate.log"
call xsim  testbench_behav -key {Behavioral:sim_1:Functional:testbench} -tclbatch testbench.tcl -view C:/Users/srini/Documents/Vivado/CPE333/cpe333-architecture/risc-v-single-cycle-pipeline/risc-v-single-cycle-pipeline.srcs/sim_1/imports/risc-v-single-cycle-pipeline-no-hazard/testbench_behav1.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
