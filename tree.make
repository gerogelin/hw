## ================================================================
## NVDLA Open Source Project
##
## Copyright(c) 2016 - 2017 NVIDIA Corporation.  Licensed under the
## NVDLA Open Hardware License; Check LICENSE which comes with
## this distribution for more information.
## ================================================================


##=======================
## Project Name Setup, multiple projects supported
##=======================
PROJECTS := nv_small

##=======================
##Linux Environment Setup
##=======================

USE_DESIGNWARE  := 0
DESIGNWARE_DIR  := /home/tools/synopsys/syn_2011.09/dw/sim_ver
CPP  := /usr/local/Cellar/gcc/11.2.0_3/bin/cpp-11
GCC  := /usr/local/Cellar/gcc/11.2.0_3/bin/gcc-11
CXX  := /usr/local/Cellar/gcc/11.2.0_3/bin/g++-11
PERL := /usr/local/bin/perl
JAVA := /usr/bin/java
SYSTEMC := /usr/local/Cellar/systemc/2.3.2
PYTHON := /usr/bin/python
VCS_HOME := /home/tools/vcs/mx-2016.06-SP2-4
NOVAS_HOME := /home/tools/debussy/verdi3_2016.06-SP2-9
VERDI_HOME := /home/tools/debussy/verdi3_2016.06-SP2-9
VERILATOR := verilator
CLANG := /usr/bin/clang
