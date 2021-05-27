copy ..\\..\\..\\..\\rtl\\cpu\\rom_adr_bin.txt rom_adr_bin.txt
copy ..\\..\\..\\..\\rtl\\cpu\\rom_dep_bin.txt rom_dep_bin.txt
copy ..\\..\\..\\..\\rtl\\cpu\\rom_ucd_bin.txt rom_ucd_bin.txt

copy ..\\..\\..\\..\\rtl\\peri\\rom_font_bin.txt rom_font_bin.txt

add wave *
view structure
view signals
run 10 ms
