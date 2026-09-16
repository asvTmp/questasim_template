#=============================================================================
# create_project.tcl - Creates a QuestaSim project (.mpf) from a file list
# Usage: vsim -c -do "do scripts/create_project.tcl; quit -f"
#=============================================================================

#=============================================================================
# proc for create project 
#=============================================================================

# Delete all files and directories in the current directory,
# except the file named "transcript"
proc clean_dir {{keep "transcript"}} {
    set cwd [pwd]
    foreach item [glob -nocomplain -directory $cwd *] {
        set name [file tail $item]
        if {$name eq $keep} { continue }
        if {[catch {file delete -force $item} err]} {
            puts "  ! failed to delete $name: $err"
        } else {
            puts "  - removed $name"
        }
    }
}


#-----------------------------------------------------------------------------
# Read file list and filter by extension (.v, .sv, .vhd)
# Returns dict: {files {f1 f2 ...} exts {ext1 ext2 ...}}
#-----------------------------------------------------------------------------
proc read_filtered_filelist {path {allowed {.v .sv .vhd}}} {
    set result [dict create files {} exts {}]

    if {![file exists $path]} {
        puts "ERROR: file list not found: $path"
        return $result
    }

    set fh [open $path r]
    while {[gets $fh line] >= 0} {
        # Strip comments
        set idx [string first "#" $line]
        if {$idx >= 0} { set line [string range $line 0 [expr {$idx-1}]] }
        set line [string trim $line]
        if {$line eq ""} { continue }

        # Get extension in lowercase
        set ext [string tolower [file extension $line]]

        # Skip if extension not allowed
        if {[lsearch -exact $allowed $ext] < 0} { continue }

        dict lappend result files $line
        dict lappend result exts  $ext
    }
    close $fh

    return $result
}

#-----------------------------------------------------------------------------
# Print file list line by line with its extension
#-----------------------------------------------------------------------------
proc print_filelist {data} {
    set files [dict get $data files]
    set exts  [dict get $data exts]

    if {[llength $files] == 0} {
        puts "  (empty)"
        return
    }

    set i 0
    foreach f $files {
        set e [lindex $exts $i]
        puts [format "  %2d. %-40s %s" [incr i] $f $e]
    }
}

#-----------------------------------------------------------------------------
# Add files to project
#-----------------------------------------------------------------------------
proc add_files_to_prj {data} {
    set files [dict get $data files]
    set exts  [dict get $data exts]

    if {[llength $files] == 0} {
        puts "  (empty)"
        return
    }

    set i 0
    foreach f $files {
        set e [lindex $exts $i]
        project addfile $f
    }
}

#=============================================================================
# create_project
#=============================================================================

proc create_project {prj_name} {
    # Stop the simulation first
    catch {quit -sim}
    # Then close the project
    catch {project close}

    clean_dir

    set PROJ_NAME prj_name
    set DEFAULT_LIB "work"
    set PROJ_ROOT [file normalize [file join [file dirname [info script]] .]]
    set PROJ_FILE [file join $PROJ_ROOT ${PROJ_NAME}.mpf]

    project new . $PROJ_NAME

    set files_list [read_filtered_filelist "../scripts/files.f"]

    add_files_to_prj $files_list

}

