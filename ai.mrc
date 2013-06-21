;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; AI COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias aicheck { 
  set %debug.location aicheck
  unset %statusmessage.display
  remini $char($1) renkei

  ; Determine if the current person in battle is a monster or not.  If so, they need to do a turn.  If not, return.
  if (($is_charmed($1) = true) || ($is_confused($1) = true)) { /.timerAIthink $+ $rand(a,z) $+ $rand(1,1000) 1 6 /ai_turn $1 | halt }


  ; Is the person a shadow clone? If so, is the original user using doppelganger style? If not, continue onto the AI..but if so, stop it.

  if ($readini($char($1), info, clone) = yes) {
    var %cloneowner $readini($char($1), info, cloneowner)
    var %style.equipped $readini($char(%cloneowner), styles, equipped)
    if (%style.equipped = doppelganger) {  return  }
  }

  ; Now we check for the AI system to see if it's turned on or not.
  var %ai.system $readini(system.dat, system, aisystem)
  if ((%ai.system = $null) || (%ai.system = on)) {
    if ($readini($char($1), info, flag) = monster) { /.timerAIthink $+ $rand(a,z) $+ $rand(1,1000) 1 6 /ai_turn $1 | halt }
    if ($readini($char($1), info, flag) = npc) { /.timerAIthink $+ $rand(a,z) $+ $rand(1,1000) 1 6 /ai_turn $1 | halt }
    else { return }
  }
  else { return }
}

alias ai_turn {
  set %debug.location ai_turn
  ; Is it the AI's turn?  This is to prevent some bugs showing up..
  if (%who != $1) { return }

  ; If it's an AI's turn, give the AI 45 seconds to make an action.. in case it hangs up.
  /.timerBattleNext 1 45 /next

  ; For now the AI will be very, very basic and random.  Later on I'll try to make it more complicated.
  unset %ai.target | unset %ai.targetlist | unset %ai.tech | unset %opponent.flag | unset %ai.skill | unset %ai.skilllist | unset %ai.type

  set %ai.type $readini($char($1), info, ai_type) 

  if (%ai.type = portal) { 
    $portal.clear.monsters

    if ($readini(system.dat, system, botType) = IRC) { 
      var %max.number.of.mons $readini(system.dat, system, MaxNumberOfMonsInBattle)
      if (%max.number.of.mons = $null) { var %max.number.of.mons 6 }
    }
    if ($readini(system.dat, system, botType) = DCCchat) { var %max.number.of.mons 30 }

    if ($readini(battle2.txt, battleinfo, Monsters) >= %max.number.of.mons) { 
      $display.system.message(12The Demon Portal glows quietly., battle)
      $check_for_double_turn($1) | halt 

    }
    else {  $portal.summon.monster($1) |  halt }
  }

  if (($readini($char($1), info, flag) = NPC) || ($readini($char($1), info, flag) = monster)) { 
    ; Release snatched targets, if any
    var %cover.target $readini($char($1), skills, CoverTarget)
    if ((%cover.target != none) && (%cover.target != $null)) {
      if ($readini($char($1), info, flag) = monster) { 
        remini $char($1) skills covertarget
        $set_chr_name($1) 
        $display.system.message($readini(translation.dat, battle, ReleaseSnatchedTarget), battle)
      }
    }

    ; Possibly change weapons.
    $ai.changeweapon($1) 
  }

  ; If a monster has the skill "magicshift" it can use it here at random.
  $ai.magicshift($1)

  ;  If a monster can build a demon portal, then it can use it here at random.
  if (%curse.night != true) {  $ai.buildportal($1) }

  $ai.monstersummon($1)

  ; Get the type of opponent we need to search for
  if ($readini($char($1), info, flag) = monster) { set %opponent.flag player }
  if ($readini($char($1), info, flag) = npc) { set %opponent.flag monster }

  if ($readini($char($1), status, charmed) = yes) { 
    if ($readini($char($1), info, flag) = monster) { set %opponent.flag monster } 
    else { set %opponent.flag player }
  }
  if ($readini($char($1), status, confuse) = yes) { 
    var %random.target $rand(1,2)
    if (%random.target = 1) { set %opponent.flag monster }
    if (%random.target = 2) { set %opponent.flag player }
  }

  if (%mode.pvp = on) { set %opponent.flag player }

  ; Now that we have the target type, we need to figure out what kind of action to do.
  set %action random

  ; If the monster is under amnesia, just attack.
  if ($readini($char($1), status, amnesia) = yes) { set %action attack }

  ; First off, let's figure out how much TP the monster has.  If it's less than 20, it's going to do an attack
  var %tp.have $readini($char($1), battle, tp) 
  if (%tp.have < 20) { set %action attack }

  ; If techs aren't allowed, we'll force monsters to attack.
  if ((no-tech isin %battleconditions) || (no-techs isin %battleconditions)) { set %action attack }


  ; For now, let's just have the monster do something.
  if (%action = attack) { $ai_gettarget($1) | $attack_cmd($1 , %ai.target) | halt  }
  if (%action = random) {
    $ai_skillcheck($1)

    if (%ai.skilllist = $null) {
      if ($readini($char($1), info, CanFlee) = true) { var %random.action $rand(1,110) }
      if ($readini($char($1), info, CanFlee) != true) { var %random.action $rand(1,99) }

      if (%random.action <= 45) { $ai_gettech($1) | $ai_gettarget($1) | $tech_cmd($1, %ai.tech, %ai.target) | halt }
      if ((%random.action > 45) && (%random.action <= 55)) { set %taunt.action true | $ai_gettarget($1) | $taunt($1 , %ai.target) | halt } 
      if ((%random.action > 55) && (%random.action <= 99)) { $ai_gettarget($1) | $attack_cmd($1 , %ai.target) | halt  }
      if (%random.action >= 100) { $ai.flee($1) | halt }
    }
    if (%ai.skilllist != $null) {
      if ($readini($char($1), info, CanFlee) = true) { var %random.action $rand(1,110) }
      if ($readini($char($1), info, CanFlee) != true) { var %random.action $rand(1,99) }

      if (%random.action <= 45) { $ai_gettech($1) | $ai_gettarget($1) | $tech_cmd($1, %ai.tech, %ai.target) | halt }
      if ((%random.action > 45) && (%random.action <= 50)) { set %taunt.action true | $ai_gettarget($1) |  $taunt($1 , %ai.target) | halt } 
      if ((%random.action > 50) && (%random.action <= 65)) { $ai_chooseskill($1) | halt }
      if ((%random.action > 65) && (%random.action <= 99)) { $ai_gettarget($1) | $attack_cmd($1 , %ai.target) | halt  }
      if (%random.action >= 100) { $ai.flee($1) | halt }
    }

  }
}
alias ai.flee {
  set %debug.location alias ai.flee
  var %flee.chance $rand(1,100)
  if (%flee.chance <= 60) { $flee($1) | halt }
  if (%flee.chance > 60) {  
    $set_chr_name($1)

    $display.system.message($readini(translation.dat, battle, CannotFleeBattle), battle)

    /.timerCheckForDoubleTurnWait 1 1 /check_for_double_turn $1 | halt 
  }
}

alias ai_gettarget {
  set %debug.location alias ai.gettarget
  unset %ai.targetlist
  var %provoke.target $readini($char($1), skills, provoke.target)
  set %tech.type $readini(techniques.db, %ai.tech, type)

  if (((%tech.type = heal) || (%tech.type = aoeheal) || (%tech.type = buff))) {
    unset %provoke.target
    if (%opponent.flag = player) { set %opponent.flag monster | goto gettarget }
    if (%opponent.flag = monster) { set %opponent.flag player | goto gettarget }
  }
  else { goto gettarget }

  ; As much as I hate using the goto command, it's the only way I can think of to make the above flag change work right so that healing techs work right.

  :gettarget

  if (%provoke.target != $null) { 
    set %ai.target %provoke.target
    remini $char($1) skills provoke.target
    return
  }

  set %battletxt.lines $lines(battle.txt) | set %battletxt.current.line 1 | unset %tech.type

  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle.ai $read -l $+ %battletxt.current.line battle.txt

    if (%ai.type != berserker) { 
      if (%opponent.flag = player) {
        if ($readini($char(%who.battle.ai), info, flag) = monster) { inc %battletxt.current.line }
        else { $add_target }
      }
      if (%opponent.flag = monster) {
        if ($readini($char(%who.battle.ai), info, flag) != monster) { inc %battletxt.current.line }
        else { $add_target }
      }
    }

    if (%ai.type = berserker) { 
      if (%who.battle.ai != $1) { $add_target }
      if (%who.battle.ai = $1) { inc %battletxt.current.line }
    } 
  }

  set %total.targets $numtok(%ai.targetlist, 46)
  set %random.target $rand(1,%total.targets)
  set %ai.target $gettok(%ai.targetlist,%random.target,46)

  if (%ai.target = $null) { 
    ; Try a second time.
    set %total.targets $numtok(%ai.targetlist, 46)
    set %random.target $rand(1,%total.targets)
    set %ai.target $gettok(%ai.targetlist,%random.target,46)
  }

  if (%taunt.action != true) { 
    $covercheck(%ai.target) 
    set %ai.target %attack.target
  }

  unset %random.target | unset %total.targets | unset %taunt.action
}

alias ai_getmontarget {
  set %debug.location alias ai_getmontarget
  ; $1 = AI user

  unset %ai.targetlist

  set %battletxt.lines $lines(battle.txt) | set %battletxt.current.line 1

  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle.ai $read -l $+ %battletxt.current.line battle.txt

    if (($readini($char(%who.battle.ai), battle, status) != runaway) && ($readini($char(%who.battle.ai), battle, hp) > 0)) {
      if (($readini($char(%who.battle.ai), info, flag) = monster) && (%who.battle.ai != $1)) {

        if ($isfile($boss(%who.battle.ai)) != $true) {  $add_target }

      }
    }

    inc %battletxt.current.line 
  } 
}

alias add_target {
  if (%who.battle.ai = $null) { return }

  var %current.status $readini($char(%who.battle.ai), battle, status)
  if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }

  else { 
    %ai.targetlist = $addtok(%ai.targetlist, %who.battle.ai, 46)
    inc %battletxt.current.line 1 
  }
  return
}

alias ai_gettech {
  unset %ai.tech | unset %tech.list | unset %techs | unset %number.of.techs | unset %ignition.name
  $weapon_equipped($1)
  set %techs $readini(techniques.db, techs, %weapon.equipped)
  set  %number.of.techs $numtok(%techs, 46)
  var %value 1
  while (%value <= %number.of.techs) {
    set %tech.name $gettok(%techs, %value, 46)
    set %tech_level $readini($char($1), techniques, %tech.name)
    if ((%tech_level != $null) && (%tech_level >= 1)) { 
      ; add the tech level to the tech list
      var %flag $readini($char($1), info, flag)

      if (%flag != $null) { %tech.list = $addtok(%tech.list,%tech.name,46) }
      if (%flag = $null) {
        if ($readini(techniques.db, %tech.name, Type) != FinalGetsuga) { %tech.list = $addtok(%tech.list,%tech.name,46) }
      }
    }
    inc %value 1 
  }

  if ($readini($char($1), status, ignition.on) = on) {
    set %ignition.name $readini($char($1), status, ignition.name)
    set %techs $readini(ignitions.db, %ignition.name, techs)
    var %number.of.techs $numtok(%techs, 46)
    var %value 1
    if (%techs != $null) {
      while (%value <= %number.of.techs) {
        set %tech.name $gettok(%techs, %value, 46)
        %tech.list = $addtok(%tech.list,%tech.name,46)
        inc %value 1
      }
    }
  }

  unset %ignition.name | unset %techs

  if (($readini($char($1), info, flag) = monster) || ($readini($char($1), info, flag) = npc)) { 
    if (($readini($char($1), status, ignition.on) != on) && ($readini($char($1), battle, IgnitionGauge) >= 100)) {
      if (($readini($char($1), status, virus) != yes) && ($readini($char($1), status, boosted) != yes))  {

        if ((no-ignition !isin %battleconditions) && (no-ignitions !isin %battleconditions)) {

          ; Get Ignition list and check it

          unset %ignitions.list | unset %ignitions | unset %number.of.ignitions
          var %value 1 | var %items.lines $lines(ignitions.lst)

          while (%value <= %items.lines) {
            set %item.name $read -l $+ %value ignitions.lst
            set %item_amount $readini($char($1), ignitions, %item.name)

            if (%item_amount = 0) { remini $char($1) ignitions %item.name }
            if ((%item_amount != $null) && (%item_amount >= 1)) { 
              var %flag $readini($char($1), info, clone)  
              if (%flag = $null) { %tech.list = $addtok(%tech.list,%item.name,46) }
            }

            unset %item.name | unset %item_amount
            inc %value 1 
          }

        }
      }

      unset %ignitions | unset %number.of.ignitions | unset %ignition.name | unset %ignition.level
    }
  }


  $ai_choosetech

  if ($readini(techniques.db, %ai.tech, type) = boost) {
    if ((($readini($char($1), status, virus) = yes) || ($readini($char($1), status, boosted) = yes) || ($readini($char($1), status, ignition.on) = on))) {
      ; The monster is already boosted or has a virus and can't boost, so let's remove that tech from the list and get another tech.
      set %tech.to.remove $findtok(%tech.list, %ai.tech, 46)
      set %tech.list $deltok(%tech.list,%tech.to.remove,46)
      $ai_choosetech
    }
  }

  if ($readini(techniques.db, %ai.tech, Type) = FinalGetsuga)  {
    if (($readini($char($1), status, virus) = yes) || ($readini($char($1), status, FinalGetsuga) = yes)) {
      ; The monster is already boosted or has a virus and can't boost, so let's remove that tech from the list and get another tech.
      set %tech.to.remove $findtok(%tech.list, %ai.tech, 46)
      set %tech.list $deltok(%tech.list,%tech.to.remove,46)
      $ai_choosetech
    }
  }

  ; As a note, if it manages to pick it again (somehow) it will go ahead and boost anyway.

  ; Does the monster have enough TP to use that tech?  If not, just move on to an attack
  set %tp.have $readini($char($1), battle, tp) | set %tp.needed $readini(techniques.db, %ai.tech, tp)
  if (%tp.have < %tp.needed) {  unset %ai.tech | unset %tp.have | unset %tp.needed | $ai_gettarget($1) | $attack_cmd($1 , %ai.target) | halt  }

  ; Another check for no-techs in the battle conditions..
  if ((no-tech isin %battleconditions) || (no-techs isin %battleconditions)) { unset %ai.tech | unset %tp.have | unset %tp.needed | $ai_gettarget($1) | $attack_cmd($1 , %ai.target) | halt  }

  if (%ai.tech = $null) { 
    ; If, for whatever reason, it can't find a tech.. it'll revert back to attacking normally.
    unset %ai.tech | unset %ai.target
    $ai_gettarget($1) 
    $attack_cmd($1 , %ai.target) 
    halt 
  }

  unset %random.tech | unset %total.techs | unset %weapon.equipped | unset %techs
}

alias ai_choosetech {
  set %total.techs $numtok(%tech.list, 46)
  set %random.tech $rand(1,%total.techs)
  set %ai.tech $gettok(%tech.list,%random.tech,46)
}

alias ai_skillcheck {
  if ($readini($char($1), info, flag) = $null) { return }
  if ((no-skill isin %battleconditions) || (no-skills isin %battleconditions)) { return }

  ; Check to see if a monster knows certain skills..
  if ($readini($char($1), skills, royalguard) != $null) { 
    if ($readini($char($1), skills, royalguard.on) != on) {
      writeini $char($1) skills royalguard.time 0 | %ai.skilllist = $addtok(%ai.skilllist, royalguard, 46) 
    }
  }
  if ($readini($char($1), skills, manawall) != $null) { 
    if ($readini($char($1), skills, manawall.on) != on) {
      writeini $char($1) skills manawall.time 0 | %ai.skilllist  = $addtok(%ai.skilllist, manawall, 46) 
    }
  }
  if ($readini($char($1), skills, bloodboost) != $null) { writeini $char($1) skills bloodboost.time 0 | %ai.skilllist  = $addtok(%ai.skilllist, bloodboost, 46) }
  if ($readini($char($1), skills, bloodspirit) != $null) { writeini $char($1) skills bloodspirit.time 0 | %ai.skilllist  = $addtok(%ai.skilllist, bloodspirit, 46) }
  if ($readini($char($1), skills, sugitekai) != $null) { 
    if ($readini($char($1), skills, doubleturn.on) != on) { writeini $char($1) skills doubleturn.time 0 | %ai.skilllist  = $addtok(%ai.skilllist, sugitekai, 46) }
  }
  if ($readini($char($1), skills, mightystrike) != $null) { 
    if ($readini($char($1), skills, mightystrike.on) != on) {
      writeini $char($1) skills mightystrike.time 0 | %ai.skilllist  = $addtok(%ai.skilllist, mightystrike, 46) 
    }
  }
  if ($readini($char($1), skills, konzen-ittai) != $null) { 
    if ($readini($char($1), skills, konzen-ittai.on) != on) {
      writeini $char($1) skills konzen-ittai.time 0 | %ai.skilllist  = $addtok(%ai.skilllist, konzen-ittai, 46) 
    }
  }
  if ($readini($char($1), skills, elementalseal) != $null) { 
    if ($readini($char($1), skills, elementalseal.on) != on) {
      writeini $char($1) skills elementalseal.time 0 | %ai.skilllist  = $addtok(%ai.skilllist, elementalseal, 46) 
    }
  }
  if ($readini($char($1), skills, drainsamba) != $null) {
    ; check to make sure drain samba isn't already on
    if ($readini($char($1), skills, drainsamba.on) != on) {
      writeini $char($1) skills drainsamba.turn 0 | %ai.skilllist  = $addtok(%ai.skilllist, drainsamba, 46)
    }
  }
  if ($readini($char($1), skills, utsusemi) != $null) { 
    if ($readini($char($1), skills, utsusemi.shadows) <= 1) {
      writeini $char($1) skills utsusemi.time 0 | writeini $char($1) item_amount shihei 100 | %ai.skilllist  = $addtok(%ai.skilllist, utsusemi, 46) 
    }
  }
  if ($readini($char($1), skills, shadowcopy) >= 1) {
    if ($isfile($char($1 $+ _clone)) = $false) { %ai.skilllist  = $addtok(%ai.skilllist, shadowcopy, 46)  }
  }
  if ($readini($char($1), skills, cocoonevolve) >= 1) { 
    %ai.skilllist  = $addtok(%ai.skilllist,cocoonevolve, 46) 
  }
  if ($readini($char($1), skills, magicmirror) != $null) { 
    if ($readini($char($1), status, reflect) != yes) {
      writeini $char($1) skills magicmirror.time 0 | writeini $char($1) item_amount mirrorshard 100 | %ai.skilllist  = $addtok(%ai.skilllist, magicmirror, 46) 
    }
  }
  if ($readini($char($1), skills, bloodpact) != $null) { 
    if ($readini($char($1), skills, Summon) != $null) {
      %ai.skilllist  = $addtok(%ai.skilllist, bloodpact, 46) 
    }
  }
  if ($readini($char($1), skills, snatch) != $null) { 
    var %cover.target $readini($char($1), skills, CoverTarget)
    if ((%cover.target = none) || (%cover.target = $null)) {
      writeini $char($1) skills snatch.time 0 | %ai.skilllist  = $addtok(%ai.skilllist, snatch, 46) 
    }
  }
  if ($readini($char($1), skills, MonsterConsume) != $null) { 
    $ai_getmontarget($1)
    if (($numtok(%ai.targetlist, 46) = 0) || ($numtok(%ai.targetlist, 46) = $null)) { return }
    else { %ai.skilllist  = $addtok(%ai.skilllist, monsterconsume, 46) }
  }

  if ($readini($char($1), skills, JustRelease) >= 1) {
    if ($readini($char($1), skills, royalguard.dmgblocked) >= 100) { 
      var %flag $readini($char($1), info, clone)  
      if (%flag = $null) { %ai.skilllist  = $addtok(%ai.skilllist, justrelease, 46) }
    }
  }
  if ($readini($char($1), skills, Cover) >= 1) { 
    if ($readini($char($1), info, flag) != monster) { return }


    %ai.skilllist  = $addtok(%ai.skilllist, cover, 46) 
  }
}

alias ai_chooseskill {
  set %total.skills $numtok(%ai.skilllist, 46)
  set %random.skill $rand(1,%total.skills)
  set %ai.skill $gettok(%ai.skilllist,%random.skill,46)
  unset %total.skills | unset %random.skill | unset %ai.skilllist
  if (%ai.skill = royalguard) { $skill.royalguard($1) }
  if (%ai.skill = manawall) { $skill.manawall($1) }
  if (%ai.skill = bloodboost) { $skill.bloodboost($1) }
  if (%ai.skill = sugitekai) { $skill.doubleturn($1)  }
  if (%ai.skill = mightystrike) { $skill.mightystrike($1) }
  if (%ai.skill = konzen-ittai) { $skill.konzen-ittai($1) }
  if (%ai.skill = elementalseal) { $skill.elementalseal($1) }
  if (%ai.skill = drainsamba) { $skill.drainsamba($1) } 
  if (%ai.skill = utsusemi) { $skill.utsusemi($1)  }
  if (%ai.skill = magicmirror) { $skill.magicmirror($1)  }
  if (%ai.skill = cocoonevolve) { $skill.cocoon.evolve($1) }
  if (%ai.skill = bloodpact) { $skill.bloodpact($1, $readini($char($1), skills, summon)) | $check_for_double_turn($1)  }
  if (%ai.skill = shadowcopy) {  
    var %shadowcopy.name $readini($char($1), skills, shadowcopy_name)
    if (%shadowcopy.name != $null) { $skill.clone($1, %shadowcopy.name) }
    if (%shadowcopy.name = $null) { $skill.clone($1) } 
  }

  if (%ai.skill = snatch) { 
    ; Get target
    $ai_gettarget($1) 
    $set_chr_name(%ai.target) | set %enemy %real.name
    $set_chr_name($1) | set %user %real.name

    ; Show description
    if ($readini($char($1), descriptions, snatch) = $null) { set %skill.description grabs onto %enemy and tries to use $gender2(%ai.target) as a shield! }
    else { set %skill.description $readini($char($1), descriptions, snatch) }
    $set_chr_name($1) 

    $display.system.message(12 $+ %real.name  $+ %skill.description, battle)

    ; Try to grab the target.
    $do.snatch($1 , %ai.target) 

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  if (%ai.skill = monsterconsume) {
    set %debug.location ai.skill.monsterconsume
    $ai_getmontarget$1)
    set %total.targets $numtok(%ai.targetlist, 46)
    set %random.target $rand(1,%total.targets)
    set %ai.target $gettok(%ai.targetlist,%random.target,46)

    if (%ai.target = $null) { 
      ; Try a second time.
      set %total.targets $numtok(%ai.targetlist, 46)
      set %random.target $rand(1,%total.targets)
      set %ai.target $gettok(%ai.targetlist,%random.target,46)

      ; If it's still null, let's just taunt someone at random.
      if (%ai.target = $null) {
        unset %random.target | unset %total.targets 
        set %taunt.action true | $ai_gettarget($1) |  $taunt($1 , %ai.target) | halt 
      } 
    }
    unset %random.target | unset %total.targets | unset %taunt.action
    $skill.monster.consume($1, %ai.target)
    halt
  }

  if (%ai.skill = JustRelease) {
    $ai_gettarget($1)

    ; If it's still null, let's just taunt someone at random.
    if (%ai.target = $null) {
      unset %random.target | unset %total.targets 
      set %taunt.action true | $ai_gettarget($1) |  $taunt($1 , %ai.target) | halt 
    } 
  }

  if (%ai.skill = cover) {
    remini $char($1) skills cover
    var %monster.master $readini($char($1), info, master) 
    set %ai.target %monster.master

    if (((%monster.master = $null) || ($readini($char(%monster.master), battle, status) = dead) || ($readini($char(%monsters.master), battle, status) = runaway))) {
      $ai_getmontarget($1)
      set %total.targets $numtok(%ai.targetlist, 46)
      set %random.target $rand(1,%total.targets)
      set %ai.target $gettok(%ai.targetlist,%random.target,46)

      if (%ai.target = $null) { 
        ; Try a second time.
        set %total.targets $numtok(%ai.targetlist, 46)
        set %random.target $rand(1,%total.targets)
        set %ai.target $gettok(%ai.targetlist,%random.target,46)
      }

      ; If it's still null, let's just taunt someone at random.
      if (%ai.target = $null) {
        unset %random.target | unset %total.targets 
        set %taunt.action true | $ai_gettarget($1) |  $taunt($1 , %ai.target) | halt 
      } 
    }
    unset %random.target | unset %total.targets | unset %taunt.action
    $skill.cover($1, %ai.target)
    halt
  }

  unset %random.target | unset %total.targets | unset %taunt.action
  $skill.justrelease($1, %ai.target, !justrelease)
  halt
}

alias ai.changeweapon {
  if ($readini($char($1), status, weapon.locked) != $null) { return }

  if ($readini($char($1), info, clone) = yes) { return }
  if ($readini($char($1), info, clone) != yes) {
    var %changeweapon.chance $rand(1,100)
    if (%changeweapon.chance > 70) { unset %changeweapon.chance | return }
  }

  $weapons.get.list($1)

  if (%base.weapon.list = $null) { return }

  if ($readini($char($1), weapons, fists) = $null) {   %base.weapon.list = $deltok(%base.weapon.list,Fists,46) }


  var %current.weapon $readini($char($1), weapons, equipped)
  set %weapons.total $numtok(%base.weapon.list,46)
  set %random.weapon $rand(1, %weapons.total) 
  set %weapon.name $gettok(%base.weapon.list,%random.weapon,46)

  unset %weapons.total | unset %random.weapon | unset %base.weapon.list

  if (%weapon.name = %current.weapon) { unset %weapon.name | return }

  writeini $char($1) weapons equipped %weapon.name | $set_chr_name($1) 

  $display.system.message($readini(translation.dat, system, EquipWeaponMonster), battle)

  unset %weapon.name
}

alias ai.magicshift {
  set %debug.location ai.magicshift 
  if ($is_charmed($1) = true) { return }
  if ($readini($char($1), skills, magicshift) >= 1) { 
    var %magicshift.chance $rand(1,100)
    if (%magicshift.chance <= 45) { $skill.magic.shift($1) }
  }
}

alias ai.buildportal {
  set %debug.location ai.buildportal
  if ($is_charmed($1) = true) { return }
  if ($readini($char($1), skills, demonportal) >= 1) { 
    var %portal.chance $rand(1,110)
    if (%portal.chance <= 25) { $skill.demonportal($1) }
  }
}

alias ai.monstersummon {
  set %debug.location ai.monstersummon
  if ($is_charmed($1) = true) { return }
  if ($readini($char($1), skills, monstersummon) >= 1) { 
    $portal.clear.monsters
    var %summon.chance $rand(1,100)
    if (%summon.chance <= $readini($char($1), skills, monstersummon.chance)) {

      if ($readini(system.dat, system, botType) = IRC) { 
        var %max.number.of.mons $readini(system.dat, system, MaxNumberOfMonsInBattle)
        if (%max.number.of.mons = $null) { var %max.number.of.mons 6 }
      }

      if ($readini(system.dat, system, botType) = DCCchat) { var %max.number.of.mons 50 }

      var %current.number.of.mons $readini(battle2.txt, battleinfo, Monsters)
      var %number.of.monsters.to.spawn $readini($char($1), skills, monstersummon.numberspawn)
      inc %current.number.of.mons %number.of.monsters.to.spawn

      if (%current.number.of.mons < %max.number.of.mons) { 
        var %monster.name $readini($char($1), skills, monstersummon.monster)
        if (%monster.name != $null) { $skill.monstersummon($1, %monster.name) }
      }
    }
  }
}


alias ai.learncheck {
  if ($readini($char($1), info, flag) = $null) { return }
  if ($readini($char($1), monster, techlearn) != true) { return }
  if ($readini(techniques.db, $2, type) = $null) { return }
  writeini $char($1) modifiers $2 0
}
