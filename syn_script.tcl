# Load RTL design
read_file -format verilog processor.v 
read_file -format verilog branch.v
read_file -format verilog ifetch.v
read_file -format verilog dof.v
read_file -format verilog execute.v
read_file -format verilog register_file.v
read_file -format verilog adder.v
read_file -format verilog decoder.v
read_file -format verilog constant_unit.v
read_file -format verilog function_unit.v
read_file -format verilog two_to_one_mux.v
read_file -format verilog three_to_one_mux.v
read_file -format verilog four_to_one_mux.v
read_file -format verilog comp.v

current_design processor
# Set clock information
create_clock "clk" -period 10 -waveform {0 5} 
#set_input_delay 2 -clock clk[remove_from_collection [all_inputs] [get_ports clk] ]
set_dont_touch_network      clk
set_fix_hold      clk

#check_design
#compile

set_max_area 0
set_max_fanout 50 [get_designs *]

remove_unconnected_ports -blast_buses [get_cells -hierarchical *]
check_design
compile -area_effort high -map_effort high -boundary_optimization -incremental_mapping -gate_clock -no_design_rule 

#Save your gate level netlist
write_file -format verilog -hierarchy -output processor_syn.v

#Save sdf file which will be used during gate level simulation
write_sdf -version 1.0 -context verilog processor_syn.sdf

#Report Area, Timing, and Power information we need
report_area -hierarchy > Area.txt
report_timing > Timing.txt
report_power > Power.txt

exit





