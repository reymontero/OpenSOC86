copy ..\\..\\..\\..\\rtl\\cpu\\rom_adr_bin.txt rom_adr_bin.txt
copy ..\\..\\..\\..\\rtl\\cpu\\rom_dep_bin.txt rom_dep_bin.txt
copy ..\\..\\..\\..\\rtl\\cpu\\rom_ucd_bin.txt rom_ucd_bin.txt

add wave *
view structure
view signals



force /testbench/tmpID 10#1
run 50 us

restart -force

force /testbench/tmpID 10#2
run 50 us

restart -force

force /testbench/tmpID 10#3
run 50 us

restart -force

force /testbench/tmpID 10#4
run 50 us

restart -force

force /testbench/tmpID 10#5
run 50 us

restart -force

force /testbench/tmpID 10#6
run 50 us

restart -force

force /testbench/tmpID 10#7
run 50 us

restart -force

force /testbench/tmpID 10#8
run 50 us

restart -force

force /testbench/tmpID 10#10
run 50 us

restart -force

force /testbench/tmpID 10#11
run 50 us

restart -force

force /testbench/tmpID 10#12
run 50 us

restart -force

force /testbench/tmpID 10#13
run 50 us

restart -force

force /testbench/tmpID 10#14
run 50 us

restart -force

force /testbench/tmpID 10#15
run 50 us

restart -force

force /testbench/tmpID 10#16
run 50 us

restart -force

force /testbench/tmpID 10#17
run 50 us

restart -force

force /testbench/tmpID 10#18
run 70 us

restart -force

force /testbench/tmpID 10#19
run 50 us


