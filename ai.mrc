;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; AI COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias aicheck { 
  ; Determine if the current person in battle is a monster or not.  If so, they need to do a turn.  If not, return.
  if ($is_charmed($1) = true) { /.timerAIthink $+ $rand(a,z) $+ $rand(1,1000) 1 8 /ai_turn $1 | halt }
  if ($readini($char($1), info, flag) = monster) { /.timerAIthink $+ $rand(a,z) $+ $rand(1,1000) 1 8 /ai_turn $1 | halt }
  if ($readini($char($1), info, flag) = npc) { /.timerAIthink $+ $rand(a,z) $+ $rand(1,1000) 1 8 /ai_turn $1 | halt }
  else { return }
}

alias ai_turn {
  ; Is it the AI's turn?  This is to prevent some bugs showing up..
  if (%who != $1) { return }

  ; For now the AI will be very, very basic and random.  Later on I'll try to make it more complicated.
  unset %ai.target | unset %ai.targetlist | unset %ai.tech | unset %opponent.flag

  ; First off, let's figure out how much TP the monster has.  If it's less than 15, it's going to do an attack
  var %tp.have $readini($char($1), battle, tp) 
  if (%tp.have < 15) { set %action attack }

  ; Get the type of opponent we need to search for
  if ($readini($char($1), info, flag) = monster) { set %opponent.flag player }
  if ($readini($char($1), info, flag) = npc) { set %opponent.flag monster }

  if ($readini($char($1), status, charmed) = yes) { 
    if ($readini($char($1), info, flag) = monster) { set %opponent.flag monster } 
    else { set %opponent.flag player }
  }
  ; If the monster is under amnesia, just attack.
  if ($readini($char($1), status, amnesia) = yes) { set %action attack }

  ; Else we need to choose a random action.
  else { set %action random }

  ; For now, let's just have the monster do something.
  if (%action = attack) { $ai_gettarget | $attack_cmd($1 , %ai.target) | halt  }
  if (%action = random) {
    var %random.action $rand(1,100)
    if (%random.action <= 45) { $ai_gettech($1) | $ai_gettarget | $tech_cmd($1, %ai.tech, %ai.target) | halt }
    if ((%random.action > 45) && (%random.action <= 55)) { $ai_gettarget |  $taunt($1 , %ai.target) | halt } 
    else {  $ai_gettarget | $attack_cmd($1 , %ai.target)  | halt  }
  }
}

alias ai_gettarget {
  unset %ai.targetlist

  if ($readini(techniques.db, %ai.tech, type) = heal) {
    if (%opponent.flag = player) { set %opponent.flag monster | goto gettarget }
    if (%opponent.flag = monster) { set %opponent.flag player | goto gettarget }
  }
  else { goto gettarget }

  ; As much as I hate using the goto command, it's the only way I can think of to make the above flag change work right so that healing techs work right.

  :gettarget
  set %battletxt.lines $lines(battle.txt) | set %battletxt.current.line 1

  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line battle.txt

    if (%opponent.flag = player) {
      if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }
      else { $add_target }
    }
    if (%opponent.flag = monster) {
      if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
      else { $add_target }
    }
  }

  set %total.targets $numtok(%ai.targetlist, 46)
  set %random.target $rand(1,%total.targets)
  set %ai.target $gettok(%ai.targetlist,%random.target,46)
  unset %random.target | unset %total.targets
}

alias add_target {
  var %current.status $readini($char(%who.battle), battle, status)
  if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
  else { 
    %ai.targetlist = $addtok(%ai.targetlist, %who.battle, 46)
    inc %battletxt.current.line 1 
  }
  return
}

alias ai_gettech {
  unset %ai.tech | unset %tech.list | unset %techs | unset %number.of.techs
  $weapon_equipped($1)
  set %techs $readini(techniques.db, techs, %weapon.equipped)
  set  %number.of.techs $numtok(%techs, 46)
  var %value 1
  while (%value <= %number.of.techs) {
    set %tech.name $gettok(%techs, %value, 46)
    set %tech_level $readini($char($1), techniques, %tech.name)
    if ((%tech_level != $null) && (%tech_level >= 1)) { 
      ; add the tech level to the tech list
      %tech.list = $addtok(%tech.list,%tech.name,46)
    }
    inc %value 1 
  }

  $ai_choosetech

  if (($readini(techniques.db, %ai.tech, Type) = boost)  && ($readini($char($1), status, boosted) = yes)) {
    ; The monster is already boosted, so let's remove that tech from the list and get another tech.
    set %tech.to.remove $findtok(%tech.list, %ai.tech, 46)
    set %tech.list $deltok(%tech.list,%tech.to.remove,46)
    $ai_choosetech
  }

  if (($readini(techniques.db, %ai.tech, Type) = FinalGetsuga)  && ($readini($char($1), status, FinalGetsuga) = yes)) {
    ; The monster is already boosted, so let's remove that tech from the list and get another tech.
    set %tech.to.remove $findtok(%tech.list, %ai.tech, 46)
    set %tech.list $deltok(%tech.list,%tech.to.remove,46)
    $ai_choosetech
  }

  ; As a note, if it manages to pick it again (somehow) it will go ahead and boost anyway.

  ; Does the monster have enough TP to use that tech?  If not, just move on to an attack
  set %tp.have $readini($char($1), battle, tp) | set %tp.needed $readini(techniques.db, %ai.tech, tp)
  if (%tp.have < %tp.needed) {  unset %ai.tech | unset %tp.have | unset %tp.needed | $ai_gettarget | $attack_cmd($1 , %ai.target) | halt  }

  if (%ai.tech = $null) { 
    ; If, for whatever reason, it can't find a tech.. it'll revert back to attacking normally.
    unset %ai.tech | unset %ai.target
    write debug.txt ai_tech is null..  getting a new target.

    $ai_gettarget 
    write debug.txt ai target: %ai.target
    write debug.txt ai tech: %ai.tech

    $attack_cmd($1 , %ai.target) | halt 
  }

  unset %random.tech | unset %total.techs | unset %weapon.equipped | unset %techs
}

alias ai_choosetech {
  set %total.techs $numtok(%tech.list, 46)
  set %random.tech $rand(1,%total.techs)
  set %ai.tech $gettok(%tech.list,%random.tech,46)
}
