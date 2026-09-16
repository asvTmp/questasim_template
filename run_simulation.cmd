@echo RUN SIM 
@REM set DIR_Q_SIM=C:/lscc/diamond/3.14/questasim
set DIR_Q_SIM=C:/questasim64_2024.1
@REM set DIR_Q_SIM=C:/lscc/propel/2024.1/questasim

set SIM_DIR=simulation
if exist "%SIM_DIR%" (
    rmdir /s /q "%SIM_DIR%"
    echo clear prj
)
mkdir "%SIM_DIR%"
cd %SIM_DIR%

@REM "%DIR_Q_SIM%/win64/questasim.exe" -do ../scripts/create_project.tcl
"%DIR_Q_SIM%/win64/questasim.exe" -do ../scripts/start.tcl
