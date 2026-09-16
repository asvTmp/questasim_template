do ../scripts/alt_editor.tcl 
do ../scripts/create_project.tcl 
set view_wave on
set clean_main on

set top_module tb_top 
set PROJ_NAME "project"

add button REP {create_project $PROJ_NAME} 
add button SIM {do ../scripts/sim.tcl} 

create_project $PROJ_NAME
