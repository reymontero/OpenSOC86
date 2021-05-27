copy ..\\..\\..\\..\\rtl\\cpu\\rom_adr_bin.txt rom_adr_bin.txt
copy ..\\..\\..\\..\\rtl\\cpu\\rom_dep_bin.txt rom_dep_bin.txt
copy ..\\..\\..\\..\\rtl\\cpu\\rom_ucd_bin.txt rom_ucd_bin.txt

add wave *
view structure
view signals
run 70 us
