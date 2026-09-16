# Очищаем лог перед новым запуском

if {$clean_main == "on"} {
    .main clear
}

quit -sim 
project compileoutofdate

###### start sim #################3
vsim -voptargs=+acc -t 1ns -L work $top_module 

##########################################
if {$view_wave == "on"} {
    view wave 
    view structure 
    view signals 
    do ../scripts/wave.tcl
}

run -all 
# run 15000ns

if {$view_wave == "on"} {
    wave zoom full 
}
# 
