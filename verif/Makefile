#
#
#

IVERILOG=iverilog
VERILOG=cver

all: crun

#RTL = ../rtl/caddr.v \
#	../rtl/74181.v ../rtl/74182.v ../rtl/memory.v \
#	../rtl/rom.v ../rtl/busint.v

RTL = $(wildcard ../rtl/*.v)

rtl.o: $(RTL)
	$(VERILOG) -o rtl.o $(RTL)

irun: $(RTL) run.v 
	$(IVERILOG) -o run run.v

#CPLI = +loadvpi=../pli/busint/pli_busint.so:vpi_compat_bootstrap
CPLI = +loadvpi=../pli/ide/pli_ide.so:vpi_compat_bootstrap
COPTS = +change_port_type $(CPLI) +cycles=500


#crun: $(RTL) run.v
#	$(VERILOG) $(COPTS) run.v

crun: $(RTL) run-disk.v
	$(VERILOG) $(COPTS) run-disk.v

display:
	./maketraces.sh >traces.sav
	gtkwave caddr.vcd traces.sav &

snapshot:
	(suffix=`date +%y%m%d`; tar cfz caddr_verilog_$$suffix.tar.gz *.v Makefile)
	mv cadfr_verilog* ~/html/unlambda/html/download/cadr