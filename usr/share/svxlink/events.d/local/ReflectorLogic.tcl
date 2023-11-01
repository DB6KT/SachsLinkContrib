###############################################################################
#
# ReflectorLogic event handlers
#
###############################################################################

#
# This is the namespace in which all functions below will exist. The name
# must match the corresponding section "[ReflectorLogic]" in the configuration
# file. The name may be changed but it must be changed in both places.
#
namespace eval ReflectorLogic {

# Interval für Repeaterkennung
variable talker_start_time 0
variable talker_stop_time 0
variable lastspeak 0
variable last_callsign "?"
variable callsign_liste {}

# The currently selected TG. Variable set from application.
variable selected_tg 0

# The previously selected TG. Variable set from application.
variable previous_tg 0

# Timestamp for previous TG announcement
variable prev_announce_time 0

# The previously announced TG
variable prev_announce_tg 0

# The minimum time between announcements of the same TG.
# Change through ANNOUNCE_REMOTE_MIN_INTERVAL config variable.
variable announce_remote_min_interval 0

#
# Checking to see if this is the correct logic core
#
if {$logic_name != [namespace tail [namespace current]]} {
  return;
}


#
# Executed when an unknown command is received
#   cmd - The command string
#
proc unknown_command {cmd} {
  Logic::unknown_command $cmd;
}


#
# Executed when a received command fails
#
proc command_failed {cmd} {
  Logic::command_failed $cmd;
}


#
# Executed when manual TG announcement is triggered
#
proc report_tg_status {} {
  variable selected_tg
  variable previous_tg
  variable prev_announce_time
  variable prev_announce_tg
  playSilence 100
  if {$selected_tg > 0} {
    set prev_announce_time [clock seconds]
    set prev_announce_tg $selected_tg
    playMsg "Core" "talk_group"
    spellNumber $selected_tg
  } else {
    playMsg "Core" "previous"
    playMsg "Core" "talk_group"
    spellNumber $previous_tg
  }
}


#
# Executed when a TG has been selected due to local activity
#
#   new_tg -- The talk group that has been activated
#   old_tg -- The talk group that was active
#
proc tg_local_activation {new_tg old_tg} {
  variable prev_announce_time
  variable prev_announce_tg
  variable selected_tg

  #puts "### tg_local_activation"
  if {$new_tg != $old_tg} {
#    set prev_announce_time [clock seconds]
#    set prev_announce_tg $new_tg
#    playSilence 250
#    playMsg "Core" "talk_group"
#    spellNumber $new_tg
#  }
}


#
# Executed when a TG has been selected due to remote activity
#
#   new_tg -- The talk group that has been activated
#   old_tg -- The talk group that was active
#
proc tg_remote_activation {new_tg old_tg} {
  variable prev_announce_time
  variable prev_announce_tg
  variable announce_remote_min_interval

  #puts "### tg_remote_activation"
  set now [clock seconds];
  if {($new_tg == $prev_announce_tg) && \
      ($now - $prev_announce_time < $announce_remote_min_interval)} {
    return;
  }
  if {$new_tg != $old_tg} {
#    set prev_announce_time $now
#    set prev_announce_tg $new_tg
#    playSilence 100
#    playMsg "Core" "talk_group"
#    spellNumber $new_tg
#  }
}


#
# Executed when a TG has been selected due to remote activity on a prioritized
# monitored talk group while a lower prio talk group is selected
#
#   new_tg -- The talk group that has been activated
#   old_tg -- The talk group that was active
#
proc tg_remote_prio_activation {new_tg old_tg} {
  tg_remote_activation $new_tg $old_tg
}


#
# Executed when a TG has been selected by DTMF command
#
#   new_tg -- The talk group that has been activated
#   old_tg -- The talk group that was active
#
proc tg_command_activation {new_tg old_tg} {
  variable prev_announce_time
  variable prev_announce_tg

  #puts "### tg_command_activation"
#  set prev_announce_time [clock seconds]
#  set prev_announce_tg $new_tg
#  playSilence 100
#  playMsg "Core" "talk_group"
#  spellNumber $new_tg
}


#
# Executed when a TG has been selected due to DEFAULT_TG configuration
#
#   new_tg -- The talk group that has been activated
#   old_tg -- The talk group that was active
#
proc tg_default_activation {new_tg old_tg} {
  #variable prev_announce_time
  #variable prev_announce_tg
  #variable selected_tg
  #puts "### tg_default_activation"
  #if {$new_tg != $old_tg} {
  #  set prev_announce_time [clock seconds]
  #  set prev_announce_tg $new_tg
  #  playSilence 100
  #  playMsg "Core" "talk_group"
  #  spellNumber $new_tg
  #}
}


#
# Executed when a TG QSY request have been acted upon
#
#   new_tg -- The talk group that has been activated
#   old_tg -- The talk group that was active
#
proc tg_qsy {new_tg old_tg} {
  variable prev_announce_time
  variable prev_announce_tg

  #puts "### tg_qsy"
  set prev_announce_time [clock seconds]
  set prev_announce_tg $new_tg
  playSilence 100
  playMsg "Core" "qsy"
  #playMsg "Core" "talk_group"
  spellNumber $new_tg
}


#
# Executed when a TG QSY request fails
#
# A TG QSY may fail for primarily two reasons, either no talk group is
# currently active or there is no connection to the reflector server.
#
proc tg_qsy_failed {} {
  #puts "### tg_qsy_idle"
  playSilence 100
  playMsg "Core" "qsy"
  playSilence 200
  playMsg "Core" "operation_failed"
}


#
# Executed when a TG QSY request is ignored
#
# tg -- The talk group requested in the QSY
#
proc tg_qsy_ignored {tg} {
  #puts "### tg_qsy_ignored"
  playSilence 100
  playMsg "Core" "qsy"
  spellNumber $tg
  playMsg "Core" "ignored"
}


#
# Executed when a TG selection has timed out
#
#   new_tg -- Always 0
#   old_tg -- The talk group that was active
#
proc tg_selection_timeout {new_tg old_tg} {
  #puts "### tg_selection_timeout"
#variable last_callsign
#set last_callsign "?"
  
#  if {$old_tg != 0} {
#    playSilence 250
#    playTone 880 200 50
#    playTone 659 200 50
#    playTone 440 200 50
#    playSilence 100
#  }
}


#
# Executed on talker start
#
#   tg        -- The talk group
#   callsign  -- The callsign of the talker node
#
proc talker_start {tg callsign} {
  #puts "### Talker start on TG #$tg: $callsign"
  variable talker_start_time
  set talker_start_time [clock seconds]
}


#
# Executed on talker stop
#
#   tg        -- The talk group
#   callsign  -- The callsign of the talker node
#
proc talker_stop {tg callsign} {
  variable talker_start_time
  variable talker_stop_time
  variable last_callsign
  variable selected_tg
  variable ::Logic::CFG_CALLSIGN
  
  variable lastspeak
  variable call_position -1
  variable call_count 0
  variable call_stop_time 0
  variable callsign_liste
  variable X_time 0
  
  
#puts "### Talker stop on TG #$tg: $callsign"
   if {($tg == $selected_tg) && ($callsign != $::Logic::CFG_CALLSIGN)} {

    set now [clock seconds]
    if { ($now - $talker_stop_time) >= 4 } {
	
	foreach {call count time} $callsign_liste {
	  if { ($now - $time) > 600 } {
	    set call_position [lsearch $callsign_liste $call]
		set callsign_liste [lreplace $callsign_liste $call_position [expr $call_position+2]]
		if { $call == $last_callsign } {set last_callsign "?"}
	  }
	}
	
	set call_position [lsearch $callsign_liste $callsign]
    if {$call_position != -1} {
	  set call_count [lindex $callsign_liste [expr $call_position+1]]
      set call_stop_time [lindex $callsign_liste [expr $call_position+2]]
      #Wenn letzte Ansage älter als 3 Minuten, dann alle aktiven counter auf 4 setzen (Zwangsansage)
      if {(($now - $lastspeak) > 180) && ($call_count != 0)} {
	    foreach {call count time} $callsign_liste {
	      set call_position2 [lsearch $callsign_liste $call]
		  set callsign_liste [lreplace $callsign_liste [expr $call_position2+1] [expr $call_position2+1] 4]
	    }
		set call_count 4
	  }	  
	  if {$call_count < 4} {
	    if {(($now - $talker_start_time) >= 8) || ($call_count == 0)} {
		  set call_count [expr $call_count + 1]
		}
		if {$call_count == 1} {
		  set X_time 30
		} else {
		  set X_time 180
		}
	  } else {
	    set call_count 1
		set X_time 0
	  }
	  set callsign_liste [lreplace $callsign_liste [expr $call_position+1] [expr $call_position+2] $call_count $now]
    } else {
      set call_count 0
      set call_stop_time 0
      lappend callsign_liste $callsign 0 $now
    }
	
	
    variable suffix_callsign "?"
	variable shortcallsign "?"
	variable rx_location ""
	
	switch $callsign {
	DB0ERZ {set rx_location "A_Auersberg"}
	DM0RLB {set rx_location "A_Rochlitz"}
        DB0FBG {set rx_location "A_Freiberg"}
        DB0SLK {set rx_location "A_Schoenebeck"}
        DM0LEI {set rx_location "A_Leipzig"}
        DM0STR {set rx_location "A_Strehla"}
        DB0FIB {set rx_location "A_Fichtelberg"}
        DB0DD {set rx_location "A_Dresden"}
	DB0PIB {set rx_location "A_Pichoberg"}
        DB0KUH {set rx_location "A_Kuhberg"}
	DB0CHE {set rx_location "A_Chemnitz"}
	DB0ABL {set rx_location "A_AltenburgerLand"}
    }

	if {[string index $callsign 2] == "0"} {
	  set suffix_callsign [string range $callsign 3 end]
	  if {[llength [lsearch -all $callsign_liste *[string range $callsign 2 3]*]] <= 1} {
	    set shortcallsign [string range $callsign 3 3]
	  } else {
	    set shortcallsign [string range $callsign 3 4]
	  }
	}

 
	playSilence 200

puts "Liste: $callsign_liste"
puts "X-Time: $X_time"


	if { $last_callsign != $callsign } {
	  if {(($now - $talker_start_time) >= 5) && (($now - $call_stop_time) >= $X_time) || ($X_time == 0)} {
	    if {$call_count == 0} {playMsg "RX_Location" "A_Empfaenger"}
		if {$rx_location != ""} {
	      #if {$call_count == 0} {playMsg "RX_Location" "A_Empfaenger"}
		  set lastspeak $now
		  puts "Ausgabe: Ansage anderer RX $rx_location"
		  playMsg "RX_Location" $rx_location
	    } else {
          set lastspeak $now
		  set suffix_callsign [string map {"-" " "} $suffix_callsign]
		  puts "Ausgabe: buchstabiere suffix anderer RX $suffix_callsign"
		  playSuffix $suffix_callsign
		  #puts "Ausgabe: CW anderer RX $suffix_callsign"
		  #CW::play $suffix_callsign 150 800 -18
        }
	  } else {
        if {($now - $talker_start_time) >= 1} {
		  puts "Ausgabe: CW ShortCallsign $shortcallsign"
		  CW::play $shortcallsign 150 800 -18
		}
	  }
	} else {
	  if {(($now - $talker_start_time) >= 15) && (($now - $call_stop_time) >= $X_time) || ($X_time == 0)} {
	    if {$rx_location != ""} {
	      set lastspeak $now
		  puts "Ausgabe: Ansage gleicher RX $rx_location"
		  playMsg "RX_Location" $rx_location
	    } else {
          set lastspeak $now
		  set suffix_callsign [string map {"-" " "} $suffix_callsign]
		  puts "Ausgabe: buchstabiere suffix gleicher RX $suffix_callsign"
		  playSuffix $suffix_callsign
		  #puts "Ausgabe: CW gleicher RX $suffix_callsign"
		  #CW::play $suffix_callsign 150 800 -18
        }
	  } else {
	    playTone 440 167 40
        playTone 659 167 40
        playTone 880 167 40
		puts "Ausgabe: Dreiklang"
	  }
	}
  }
  set last_callsign $callsign
  set talker_stop_time [clock seconds]
 }
}


#
# A talk group was added for temporary monitoring
#
#   tg -- The added talk group
#
proc tmp_monitor_add {tg} {
  #puts "### tmp_monitor_add: $tg"
  playSilence 100
  playMsg "Core" "monitor"
  spellNumber $tg
}


#
# A talk group was removed from temporary monitoring
#
#   tg -- The removed talk group
#
proc tmp_monitor_remove {tg} {
  #puts "### tmp_monitor_remove: $tg"
}


if [info exists ::Logic::CFG_ANNOUNCE_REMOTE_MIN_INTERVAL] {
  set announce_remote_min_interval $::Logic::CFG_ANNOUNCE_REMOTE_MIN_INTERVAL
}


# end of namespace
}


#
# This file has not been truncated
#
