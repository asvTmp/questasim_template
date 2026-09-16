proc external_editor {filename linenumber} { 
    exec {*}[auto_execok start] c:/progs/vscode/code.exe --goto $filename:$linenumber 
    return 
} 
set PrefSource(altEditor) external_editor 
