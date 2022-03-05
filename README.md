# NVDLA Open Source Hardware
---

## NVDLA

The NVIDIA Deep Learning Accelerator (NVDLA) is a free and open architecture that promotes
a standard way to design deep learning inference accelerators. With its modular architecture,
NVDLA is scalable, highly configurable, and designed to simplify integration and portability.
Learn more about NVDLA on the project web page.

<http://nvdla.org/>

## Online Documentation

NVDLA documentation is located [here](http://nvdla.org/contents.html).  Hardware specific 
documentation is located at the following pages.
* [Hardware Architecture](http://nvdla.org/hwarch.html).
* [Integrator's Manual](http://nvdla.org/integration_guide.html).

This README file contains only basic information.

## Directory Structure

This repository contains the RTL, C-model, and testbench code associated with the NVDLA hardware 
release.  In this repository, you will find:

  * vmod/ -- RTL model, including:
    * vmod/nvdla/ -- Verilog implementation of NVDLA
    * vmod/vlibs/ -- library and cell models
    * vmod/rams/ -- behavioral models of RAMs used by NVDLA
  * syn/ -- example synthesis scripts for NVDLA
  * perf/ -- performance estimator spreadsheet for NVDLA
  * verif/ -- trace-player testbench for basic sanity validation
    * ral -- rigister abstract level in systemverilog
    * verilator -- verilator related file include top c file
    * tests -- tests related files
        * nvdla_tests -- the basic model in python to generate the register sequence
        * python_tests -- same example to generate the register sequence
        * trace_tests -- the output file of register sequence which include .cfg (sequence) and .dat (data to move into memory)
    * vip -- the agent of cmodel for simulator
  * tools -- tools used for building the RTL and running simulation/synthesis/etc.
  * spec -- RTL configuration option settings.

## Building the NVDLA Hardware

See the [integrator's manual](http://nvdla.org/integration_guide.html) for more information on 
the setup and other build commands and options.  The basic build command to compile the design
and run a short sanity simulation is:

    ./tools/bin/tmake -build ${TARGET}

see TARGET list and the dependent relationship of them in tools/etc/build.conf

### to build the verilog

    ./tools/bin/tmake -build vmod

### to build the files which needed by the virtual platform and firmware

    ./tools/bin/tmake -build cmod_top

### build flow internel

to build the hardware, firstly translate the hardware spec to certain file needed by the next step
to build the finally verilog for each config, this project use the plugins lays in vmod/plugins to help to generate

for example, the eperl::pipe will call the pipe.pm in vmod/nvdla/cdma/NV_NVDLA_CDMA_IMG_pack.v:1382 like below to generate final code

```verilog
//: my $dw = DP_OUT_DW;
//: &eperl::pipe("-is -wid $dw -do sdp2pdp_pd -vo sdp2pdp_valid -ri sdp2pdp_ready -di core2pdp_pd -vi core2pdp_vld -ro core2pdp_rdy");
```

the final code look likes as below

```verilog
//: my $dw = 8*1;
//: &eperl::pipe("-is -wid $dw -do sdp2pdp_pd -vo sdp2pdp_valid -ri sdp2pdp_ready -di core2pdp_pd -vi core2pdp_vld -ro core2pdp_rdy");
//| eperl: generated_beg (DO NOT EDIT BELOW)
// Reg
reg core2pdp_rdy;
reg skid_flop_core2pdp_rdy;
reg skid_flop_core2pdp_vld;
reg [8-1:0] skid_flop_core2pdp_pd;
reg pipe_skid_core2pdp_vld;
reg [8-1:0] pipe_skid_core2pdp_pd;
// Wire
wire skid_core2pdp_vld;
wire [8-1:0] skid_core2pdp_pd;
wire skid_core2pdp_rdy;
wire pipe_skid_core2pdp_rdy;
wire sdp2pdp_valid;
wire [8-1:0] sdp2pdp_pd;
// Code
// SKID READY
always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
   if (!nvdla_core_rstn) begin
       core2pdp_rdy <= 1'b1;
       skid_flop_core2pdp_rdy <= 1'b1;
   end else begin
       core2pdp_rdy <= skid_core2pdp_rdy;
       skid_flop_core2pdp_rdy <= skid_core2pdp_rdy;
   end
end

// SKID VALID
always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if (!nvdla_core_rstn) begin
        skid_flop_core2pdp_vld <= 1'b0;
    end else begin
        if (skid_flop_core2pdp_rdy) begin
            skid_flop_core2pdp_vld <= core2pdp_vld;
        end
   end
end
assign skid_core2pdp_vld = (skid_flop_core2pdp_rdy) ? core2pdp_vld : skid_flop_core2pdp_vld;

// SKID DATA
always @(posedge nvdla_core_clk) begin
    if (skid_flop_core2pdp_rdy & core2pdp_vld) begin
        skid_flop_core2pdp_pd[8-1:0] <= core2pdp_pd[8-1:0];
    end
end
assign skid_core2pdp_pd[8-1:0] = (skid_flop_core2pdp_rdy) ? core2pdp_pd[8-1:0] : skid_flop_core2pdp_pd[8-1:0];


// PIPE READY
assign skid_core2pdp_rdy = pipe_skid_core2pdp_rdy || !pipe_skid_core2pdp_vld;

// PIPE VALID
always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if (!nvdla_core_rstn) begin
        pipe_skid_core2pdp_vld <= 1'b0;
    end else begin
        if (skid_core2pdp_rdy) begin
            pipe_skid_core2pdp_vld <= skid_core2pdp_vld;
        end
    end
end

// PIPE DATA
always @(posedge nvdla_core_clk) begin
    if (skid_core2pdp_rdy && skid_core2pdp_vld) begin
        pipe_skid_core2pdp_pd[8-1:0] <= skid_core2pdp_pd[8-1:0];
    end
end


// PIPE OUTPUT
assign pipe_skid_core2pdp_rdy = sdp2pdp_ready;
assign sdp2pdp_valid = pipe_skid_core2pdp_vld;
assign sdp2pdp_pd = pipe_skid_core2pdp_pd;

//| eperl: generated_end (DO NOT EDIT ABOVE)
```

## Building the Simulator and run test

### to build simulator using verilator

    ./tools/bin/tmake -build verilator

to build the verilator with vcd dump,
uncomment the verif/verilator/Makefile:16 to make the VNV_nvdla(the simulator name) build with trace enable

### to run test using verilator

    ./tools/bin/tmake -only verilator -opt_m "TEST=${TESTCASE_NAME} run"

the TESTCASE_NAME is same as the directory name in verif/tests/trace_tests/${PROJECT}/
for example, if current PROJECT is nv_small, then cdp_1x1x1_lrn3_int8_0 is a vaild TESTCASE_NAME

### to add a new trace for simulation

1. write a test trace generate in python locate in verif/tests/python_tests/ for example called rubik_santiy_test_int8 just sees the example like cc_8x8x32_32x1x1x32_pack_all_zero_int8.py does

2. run this python script to generate the .cfg and .dat file in the directory which has same name as the python script, you will see the rubik_santiy_test_int8 and rubik_santiy_test_int8_scev

```shell
    $ python rubik_santiy_test_int8.py
    $ ls
    rubik_santiy_test_int8
    rubik_santiy_test_int8_scev
```

3. copy the directory to the trace_test to the project nv_small for example

    cp -r rubik_santiy_test_int8 ../trace_tests/nv_small

4. back up to the top of hw, and run

    ./tools/bin/tmake -only verilator -opt_m "TEST=rubik_santiy_test run"

5. if you already build the verilator with trace enable, you will see trace.vcd in outdir/nv_small/verilator/tests/rubik_santiy_test
