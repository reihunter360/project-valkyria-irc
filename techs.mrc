;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TECHS COMMAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON 3:ACTION:goes *:#:{ 
  if ($3 != $null) { halt }
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, status, CurrentlyConfused), private) | halt }
  $set_chr_name($nick) 

  set %ignition.list $readini(ignitions.db, ignitions, list)
  if ($istok(%ignition.list, $2, 46) = $true) { unset %ignition.list | $ignition_cmd($nick, $2, $nick) | halt }
  else { $tech_cmd($nick , $2, $nick) | halt }
} 

ON 3:ACTION:reverts*:#: {
  $check_for_battle($nick) 
  if ($3 = $null) { halt }
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, status, CurrentlyConfused), private) | halt }
  $set_chr_name($nick) 

  var %ignition.name $readini($char($nick), status, ignition.name)
  if (%ignition.name = $3) {   
    $revert($nick, $3) 
    query %battlechan $readini(translation.dat, system, IgnitionReverted) 
    halt
  }
  else { query %battlechan $readini(translation.dat, errors, NotUsingThatIgnition) | halt }
} 
ON 50:TEXT:*reverts from *:*:{ 
  $check_for_battle($1) 
  if ($4 = $null) { halt }
  if ($is_charmed($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused), private) | halt }
  $set_chr_name($1) 
  var %ignition.name $readini($char($1), status, ignition.name)
  if (%ignition.name = $4) {   
    $revert($1, $4) 
    query %battlechan $readini(translation.dat, system, IgnitionReverted) 
    halt
  }
  else { query %battlechan $readini(translation.dat, errors, NotUsingThatIgnition) | halt }
}

ON 3:ACTION:uses * * on *:#:{ 
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, status, CurrentlyConfused), private) | halt }
  $set_chr_name($nick) | set %attack.target $5 
  $tech_cmd($nick , $3 , %attack.target, $7) | halt 
} 
ON 50:TEXT:*uses * * on *:*:{ 
  if ($1 = uses) { halt }
  if ($3 = item) { halt }
  if ($5 != on) { halt }
  else { $set_chr_name($1) | set %attack.target $6
  $tech_cmd($1, $4, %attack.target) | halt }
}

alias tech_cmd {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target

  ; Make sure some old attack variables are cleared.
  unset %attack.damage | unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %drainsamba.on | unset %absorb
  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged | unset %covering.someone

  $check_for_battle($1) 

  set %ignition.list $readini(ignitions.db, ignitions, list)
  if ($istok(%ignition.list, $2, 46) = $true) { unset %ignition.list | $ignition_cmd($1, $2, $1) | halt }

  set %tech.type $readini(techniques.db, $2, Type) | $amnesia.check($1, tech) 
  if ($readini($char($1), techniques, $2) = $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoesNotKnowTech),private) | halt }

  if ((no-tech isin %battleconditions) || (no-techs isin %battleconditions)) { $set_chr_name($1) | $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }

  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, CanNotAttackWhileUnconcious),private)  | unset %real.name | halt }
  if ($readini($char($3), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoIsDead),private) | unset %real.name | halt }
  if ($readini($char($3), Battle, Status) = RunAway) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoFledTech),private) | unset %real.name | halt } 

  $person_in_battle($3) | $checkchar($3) 

  ; Get the weapon equipped
  $weapon_equipped($1)

  set %weapon.abilities $readini(techniques.db, Techs, %weapon.equipped)
  if ($istok(%weapon.abilities,$2,46) = $false) {  $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, Can'tPerformTechWithWeapon),private) | halt }
  unset %weapon.abilities 

  ; Make sure the user has enough TP to use this in battle..
  set %tp.needed $readini(techniques.db, p, $2, TP) | set %tp.have $readini($char($1), battle, tp)

  ; Check for ConserveTP
  if ($readini($char($1), status, conservetp) = yes) { set %tp.needed 0 | writeini $char($1) status conserveTP no }

  if (%tp.needed = $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoesNotKnowTech), private) | halt }
  if (%tp.needed > %tp.have) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, NotEnoughTPforTech),private) | halt }

  if (%covering.someone != on) {
    if (%mode.pvp != on) {
      if ($3 = $1) {
        if (($is_confused($1) = false) && ($is_charmed($1) = false))  { 
          if (%tech.type !isin boost.finalgetsuga.heal.heal-AOE.buff) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, Can'tAttackYourself),private) | unset %real.name | halt  }
        }
      }
    }
  }

  dec %tp.have %tp.needed | writeini $char($1) battle tp %tp.have | unset %tp.have | unset %tp.needed

  if (%tech.type = boost) { 
    if ($readini($char($1), status, virus) = yes) { $display.system.message($readini(translation.dat, errors, Can'tBoostHasVirus),private) | halt }
    if (($readini($char($1), status, boosted) = yes) || ($readini($char($1), status, ignition.on) = on)) { 
      if ($readini($char($1), info, flag) = $null) {
        $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, AlreadyBoosted), private) | halt 
      }
    }


    $tech.boost($1, $2, $3)

  } 
  if (%tech.type = finalgetsuga) { $tech.finalgetsuga($1, $2, $3) } 

  if (%tech.type = buff) {  $tech.buff($1, $2, $3) }

  var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($3), info, flag)

  if ($is_charmed($1) = true) { set %user.flag monster }
  if (%tech.type = heal) { set %user.flag monster }
  if (%tech.type = heal-aoe) { set %user.flag monster }

  if (%mode.pvp = on) { set %user.flag monster }
  if ($readini($char($1), status, confuse) = yes) { set %user.flag monster }

  if (%covering.someone = on) { var %user.flag monster }

  if ((%user.flag != monster) && (%target.flag != monster)) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, CanOnlyAttackMonsters),private)  | halt }

  if (%tech.type = heal) { $tech.heal($1, $2, $3) }
  if (%tech.type = heal-aoe) { $tech.aoeheal($1, $2, $3) }
  if (%tech.type = single) {  $covercheck($3, $2) | $tech.single($1, $2, $3)  }
  if (%tech.type = suicide) { $covercheck($3, $2) | $tech.suicide($1, $2, $3)  }

  if (%tech.type = suicide-AOE) { 
    if ($is_charmed($1) = true) { 
      var %current.flag $readini($char($1), info, flag)
      if ((%current.flag = $null) || (%current.flag = npc)) { $tech.suicideaoe($1, $2, $3, player) | halt }
      if (%current.flag = monster) { $tech.suicideaoe($1, $2, $3, monster) | halt }
    }
    else {
      ; Determine if it's players or monsters
      if (%user.flag = monster) { $tech.suicideaoe($1, $2, $3, player) | halt }
      if ((%user.flag = $null) || (%user.flag = npc)) { $tech.suicideaoe($1, $2, $3, monster) | halt }
    }
  }

  if (%tech.type = status) { $tech.single($1, $2, $3) } 
  if (%tech.type = stealPower) { $tech.stealPower($1, $2, $3) }

  if (%tech.type = AOE) { 
    if ($is_charmed($1) = true) { 
      var %current.flag $readini($char($1), info, flag)
      if ((%current.flag = $null) || (%current.flag = npc)) { $tech.aoe($1, $2, $3, player) | halt }
      if (%current.flag = monster) { $tech.aoe($1, $2, $3, monster) | halt }
    }
    else {
      ; check for confuse.
      if ($is_confused($1) = true) { 
        var %random.target.chance $rand(1,2)
        if (%random.target.chance = 1) { var %user.flag monster }
        if (%random.target.chance = 2) { unset %user.flag }
      }

      ; Determine if it's players or monsters
      if (%user.flag = monster) { $tech.aoe($1, $2, $3, player) | halt }
      if ((%user.flag = $null) || (%user.flag = npc)) { $tech.aoe($1, $2, $3, monster) | halt }
    }
  }

  ; Time to go to the next turn
  if (%battleis = on)  {  $check_for_double_turn($1) | halt }
}

alias tech.buff {
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($3) | set %enemy %real.name

  var %buff.type $readini(techniques.db, $2, status)

  ; If the user is a player and isn't confused or charmed, we should check to see if the target already has the buff on.  If so, why apply it again?
  if ($readini($char($1), info, flag) = $null) {
    if (($is_charmed($1) != true) && ($is_confused($1) != true))  { 
      if ($readini($char($3), status, %buff.type) = yes) { $set_chr_name($3) | $display.system.message($readini(translation.dat, errors, AlreadyHasThisBuff), private)
        var %tp.required $readini(techniques.db, $2, tp)  
        $restore_tp($1, %tp.required)
        halt 
      }
    }
  }

  $display.system.message(3 $+ %user $+  $readini(techniques.db, $2, desc), battle)

  writeini $char($3) status %buff.type yes
  writeini $char($3) status %buff.type $+ .timer 0

  if ($readini(techniques.db, $2, modifier) != $null) {
    ; This buff adds resistances to the target's file.
    var %modifier.type $readini(techniques.db, $2, modifier)
    set %target.modifier $readini($char($3), modifiers, %modifier.type)
    if (%target.modifier = $null) { var %target.modifier 100 }
    dec %target.modifier 30 
    if (%target.modifier < 0) { var %target.modifier 0 }
    writeini $char($3) modifiers %modifier.type %target.modifier
    unset %target.modifier
  }

  $display.system.message($readini(translation.dat, status, GainedBuff), battle)

  ; Time to go to the next turn
  if (%battleis = on)  {  $check_for_double_turn($1) | halt }
}

alias tech.single {
  ; $3 = target

  var %tech.element $readini(techniques.db, $2, element)
  var %target.element.heal $readini($char($3), modifiers, heal)
  if ((%tech.element != none) && (%tech.element != $null)) {
    if ($istok(%target.element.heal,%tech.element,46) = $true) { 
      $tech.heal($1, $2, $3, %absorb)
      return
    }
  }

  if ($readini(techniques.db, $2, absorb) = yes) { set %absorb absorb }
  else { set %absorb none }

  if (($readini($char($3), status, reflect) = yes) && ($readini(techniques.db, $2, magic) = yes)) {
    $calculate_damage_techs($1, $2, $1)
    if (%attack.damage >= 4000) { set %attack.damage $rand(2800,3500) }
    unset %absorb
    $deal_damage($1, $1, $2, %absorb)
  }
  else { 
    $calculate_damage_techs($1, $2, $3)
    $deal_damage($1, $3, $2, %absorb)
  }

  $display_damage($1, $3, tech, $2, %absorb)
  return
}

alias tech.stealPower {
  ; $3 = target

  set %attack.damage 0

  ; First things first, let's find out the base power.  This tech type doesn't use INT or the base weapon.
  var %tech.base $readini(techniques.db, $2, BasePower)
  var %user.tech.level $readini($char($1), Techniques, $2)

  inc %tech.base %base.power.wpn

  set %current.accessory $readini($char($3), equipment, accessory) 
  set %current.accessory.type $readini(items.db, %current.accessory, accessorytype)

  ; If the target is weak to the element, increase the attack power of the base tech
  ; If the target is strong to the element, cut the attack of the tech by half.
  var %tech.element $readini(techniques.db, $2, element)
  if ((%weapon.element != $null) || (%tech.element != none)) {
    var %target.element.weak $readini($char($3), element, weakness)
    var %target.element.strong $readini($char($3), element, strong)

    if ($istok(%target.element.weak,%tech.element,46) = $true) { inc %tech.base $round($calc(%tech.base * 1.2),0)
      var %mon.temp.def $readini($char($3), battle, def)
      var %mon.temp.def = $round($calc(%mon.temp.def - (%mon.temp.def * .10)),0)
      if (%mon.temp.def < 0) { var %mon.temp.def 0 }
      writeini $char($3) battle def %mon.temp.def
    }
    if (($istok(%target.element.strong,%tech.element,46) = $true)  || (%current.accessory.type = ElementalDefense)) {  
      %tech.base = $round($calc(%tech.base / 2), 0) 
      var %mon.temp.str $readini($char($3), battle, str)
      var %mon.temp.str = $round($calc(%mon.temp.str + (%mon.temp.str * .10)),0)
      if (%mon.temp.str < 0) { var %mon.temp.str 0 }
      writeini $char($3) battle str %mon.temp.str
    }
  }

  inc %tech.base %user.tech.level
  inc %attack.damage %tech.base

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,5)

  ; Is the tech magic?  If so, we need to add some more stuff to it.
  if ($readini(techniques.db, $2, magic) = yes) { $calculate_damage_magic($1, $2, $3) }

  ;If the element is Light/Fire and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if (%tech.element = light) {  inc %attack.damage $round($calc(%attack.damage * .110),0) } 
    if (%tech.element = fire) {  inc %attack.damage $round($calc(%attack.damage * .110),0) } 
  } 

  ; Now we're ready to calculate the enemy's defense..  
  var %enemy.defense $readini($char($3), battle, def)

  ; Because it's a tech, the enemy's int will play a small part too.
  var %int.bonus $round($calc($readini($char($3), battle, int) / 3.5),0)
  inc  %enemy.defense %int.bonus

  ; And let's get the final attack damage..
  dec %attack.damage %enemy.defense

  ; If it's the blood moon, increase the amount by a random amount.
  if (%bloodmoon = on) { inc %attack.damage $rand(1,100) }

  if (%attack.damage <= 0) { set %attack.damage 5 }
  if (%attack.damage >= 100) { set %attack.damage 100 }

  var %attacker.str $readini($char($1), battle, str)
  var %attacker.def $readini($char($1), battle, def)
  var %attacker.int $readini($char($1), battle, int)
  var %attacker.spd $readini($char($1), battle, spd)

  if ($calc($readini($char($3), battle, str) - %attack.damage) <= 1) { var %amount.of.str $readini($char($3), battle, str) | inc %attacker.str $readini($char($3), battle, str) | writeini $char($3) battle str 1 }
  if ($calc($readini($char($3), battle, str) - %attack.damage) >= 1) { var %amount.of.str %attack.damage | inc %attacker.str %attack.damage | writeini $char($3) battle str $calc($readini($char($3), battle, str) - %amount.of.str) }

  inc %attack.damage $rand(0,2)
  if ($calc($readini($char($3), battle, def) - %attack.damage) <= 1) { var %amount.of.def $readini($char($3), battle, def) | inc %attacker.def $readini($char($3), battle, def) | writeini $char($3) battle def 1 }
  if ($calc($readini($char($3), battle, def) - %attack.damage) >= 1) { var %amount.of.def %attack.damage | inc %attacker.def %attack.damage | writeini $char($3) battle def $calc($readini($char($3), battle, def) - %amount.of.def) }

  inc %attack.damage $rand(0,3)
  if ($calc($readini($char($3), battle, int) - %attack.damage) <= 1) { var %amount.of.int $readini($char($3), battle, int) | inc %attacker.int $readini($char($3), battle, int) | writeini $char($3) battle int 1 }
  if ($calc($readini($char($3), battle, int) - %attack.damage) >= 1) { var %amount.of.int %attack.damage | inc %attacker.int %attack.damage | writeini $char($3) battle int $calc($readini($char($3), battle, int) - %amount.of.int) }

  inc %attack.damage $rand(0,1)
  if ($calc($readini($char($3), battle, spd) - %attack.damage) <= 1) { var %amount.of.spd $readini($char($3), battle, spd) | inc %attacker.spd $readini($char($3), battle, spd) | writeini $char($3) battle spd 1 }
  if ($calc($readini($char($3), battle, spd) - %attack.damage) >= 1) { var %amount.of.spd %attack.damage | inc %attacker.spd %attack.damage | writeini $char($3) battle spd $calc($readini($char($3), battle, spd) - %amount.of.spd) }

  writeini $char($1) battle str %attacker.str | writeini $char($1) battle def %attacker.def | writeini $char($1) battle int %attacker.int | writeini $char($1) battle spd %attacker.spd

  $set_chr_name($1) | set %user %real.name
  $set_chr_name($3) | set %enemy %real.name

  $display.system.message(3 $+ %user $+  $readini(techniques.db, $2, desc), battle)
  $set_chr_name($1) | $display.system.message($readini(translation.dat, tech, StolenPower), battle)

  unset %current.accessory.type
  return
}

alias tech.suicide {
  $set_chr_name($1)
  $display.system.message($readini(translation.dat, tech, SuicideUseAllHP), battle)

  $calculate_damage_suicide($1, $2, $3)
  writeini $char($1) battle hp 0 | writeini $char($1) battle status dead | $increase.death.tally($1) | $set_chr_name($1) 
  $deal_damage($1, $3, $2)
  $display_damage($1, $3, tech, $2)
  return
}

alias tech.heal {
  ; $1 = user
  ; $2 = tech
  ; $3 = target

  $calculate_damage_techs($1, $2, $3)

  if ($augment.check($1, CuringBonus) = true) {
    set %healing.increase $calc(%augment.strength * .30)
    inc %attack.damage $round($calc(%attack.damage * %healing.increase),0) 
    unset %healing.increase
  }

  if (%bloodmoon = on) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  var %mon.status $readini($char($3), status, zombie) | var %mon.type $readini($char($3), monster, type)
  var %target.element.heal $readini($char($3), modifiers, heal)
  var %tech.element $readini(techniques.db, $2, element)

  if (($istok(%target.element.heal,%tech.element,46) = $false) || (%target.element.heal = $null)) { 
    if ((%mon.status = yes) || (%mon.type = undead)) {
      $deal_damage($1, $3, $2)
      $display_damage($1, $3, tech, $2)
      return
    } 
  }

  if ($readini(system.dat, system, IgnoreDmgCap) != true) { 
    if (%attack.damage > 2000) { set %attack.damage $calc(2000 + (%attack.damage / 100)),0) }
  }

  %attack.damage = $round(%attack.damage,0)

  $heal_damage($1, $3, $2)
  $display_heal($1, $3, tech, $2)

  return
}

alias tech.aoeheal {
  ; $1 = user
  ; $2 = tech
  ; $3 = target
  set %wait.your.turn on

  unset %who.battle | set %number.of.hits 0
  set %attack.damage 0

  ; First things first, let's find out the base power.
  $calculate_damage_techs($1, $2, $3)
  inc %attack.damage %item.base

  if ($augment.check($1, CuringBonus) = true) { 
    set %healing.increase $calc(%augment.strength * .30)
    inc %attack.damage $round($calc(%attack.damage * %healing.increase),0) 
    unset %healing.increase
  }

  if (%attack.damage > 2000) { set %attack.damage $calc(2000 + (%attack.damage / 100)),0) }


  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  if (%bloodmoon = on) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; In this bot we don't want the attack to ever be lower than 1.  
  if (%attack.damage <= 0) { set %attack.damage 1 }

  ; Display the tech description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($3) | set %enemy %real.name
  $display.system.message(3 $+ %user $+  $readini(techniques.db, $2, desc), battle)

  var %caster.flag $readini($char($1), info, flag)
  if ($readini($char($1), status, confuse) = yes) { var %caster.flag monster }

  if (%caster.flag = $null) { set %target.flag player }
  if (%caster.flag = npc) { set %target.flag player }
  if (%caster.flag = monster) { set %target.flag monster }

  ; If it's player, search out remaining players that are alive and deal damage and display damage
  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line battle.txt
    set %who.battle.flag $readini($char(%who.battle), info, flag)
    if ((%target.flag = player) && (%who.battle.flag = $null)) { $do_aoe_heal($1, $2, $3) }
    if ((%target.flag = player) && (%who.battle.flag = npc)) { $do_aoe_heal($1, $2, $3) }
    if ((%target.flag = monster) && (%who.battle.flag = monster)) { $do_aoe_heal($1, $2, $3) }

    inc %battletxt.current.line 1 
  }


  unset %statusmessage.display
  if ($readini($char($1), battle, hp) > 0) {
    $self.inflict_status($1, $4 , $3)
    if (%statusmessage.display != $null) { $display.system.message(%statusmessage.display, battle) | unset %statusmessage.display }
  }

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 5 /check_for_double_turn $1
  halt
}

alias do_aoe_heal {
  var %current.status $readini($char(%who.battle), battle, status)
  if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 | return }
  else { 
    inc %number.of.hits 1

    ;If the target is a zombie, do damage instead of healing it.
    var %mon.status $readini($char(%who.battle), status, zombie) | var %mon.type $readini($char(%who.battle), monster, type)
    if ((%mon.status = yes) || (%mon.type = undead)) {
      $deal_damage($1, %who.battle, $2)
      $display_damage($1, %who.battle, aoeheal, $2)
    } 

    else {   
      $heal_damage($1, %who.battle, $2)
      $display_heal($1, %who.battle ,aoeheal, $2)
    }
  }
}

alias tech.suicideaoe {
  ; $1 = user
  ; $2 = tech
  ; $3 = target
  ; $4 = type, either player or monster 

  set %wait.your.turn on

  unset %who.battle | set %number.of.hits 0

  $set_chr_name($1)
  $display.system.message($readini(translation.dat, tech, SuicideUseAllHP), battle)

  ; Display the tech description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($3) | set %enemy %real.name
  $display.system.message(3 $+ %user  $+ $readini(techniques.db, $2, desc), battle)

  ; If it's player, search out remaining players that are alive and deal damage and display damage
  if ($4 = player) {
    var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 | set %aoe.turn 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line battle.txt
      if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }

      else { 
        if ($1 = %who.battle) { inc %battletxt.current.line }
        if ($1 != %who.battle) { 
          var %current.status $readini($char(%who.battle), battle, status)
          if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
          else { 
            inc %number.of.hits 1
            $covercheck(%who.battle, $2, AOE)

            $calculate_damage_suicide($1, $2, %who.battle)
            $deal_damage($1, %who.battle, $2)
            $display_aoedamage($1, %who.battle, $2)
            inc %battletxt.current.line 1 |  inc %aoe.turn 1
          } 
        }
      }
    }
  }

  ; If it's monster, search out remaining monsters that are alive and deal damage and display damage.
  if ($4 = monster) { 
    var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 | set %aoe.turn 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line battle.txt
      if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
      else { 
        inc %number.of.hits 1
        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
        else { 
          $covercheck(%who.battle, $2, AOE)

          $calculate_damage_suicide($1, $2, %who.battle)
          $deal_damage($1, %who.battle, $2)
          $display_aoedamage($1, %who.battle, $2)
          inc %battletxt.current.line 1 |  inc %aoe.turn 1
        } 
      }
    }
  }

  set %timer.time $calc(%number.of.hits * 1) 

  writeini $char($1) battle hp 0 | writeini $char($1) battle status dead | $set_chr_name($1) |  $increase.death.tally($1) 

  unset %aoe.turn 
  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt

}

alias tech.magic {

  if (($readini($char($3), status, reflect) = yes) && ($readini(techniques.db, $2, magic) = yes)) {
    $calculate_damage_magic($1, $2, $1)
    if (%attack.damage >= 4000) { set %attack.damage $rand(2800,3500) }
    unset %absorb
    $deal_damage($1, $1, $2)
  }
  else { 
    $calculate_damage_magic($1, $2, $3)
    $deal_damage($1, $3, $2)
  }

  $display_damage($1, $3, tech, $2)
  return
}

alias tech.boost {
  ; $1 = user
  ; $2 = tech
  ; $3 = target

  if ($readini($char($1), status, boosted) != no) { 
    $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, AlreadyBoosted), battle)
    if ($readini($char($1), info, flag) = monster) { $check_for_double_turn($1) | halt }
    else { halt }
  }

  ; Get the battle stats
  var %str $readini($char($1), Battle, Str)
  var %def $readini($char($1), Battle, Def)
  var %int $readini($char($1), Battle, Int)
  var %spd $readini($char($1), Battle, Spd)

  var %boost.base.amount $readini(techniques.db, $2, BasePower)
  var %player.level.amount $round($calc($readini($char($1), techniques, $2) * .7),0)

  inc %boost.base.amount %player.level.amount


  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  set %current.weapon.used $readini($char($1), weapons, equipped)
  if ($readini(weapons.db, %current.weapon.used, cost) = 0) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set boost.base.amount 0 }
  }
  unset %current.weapon.used


  inc %str %boost.base.amount
  inc %def %boost.base.amount
  inc %int %boost.base.amount
  inc %spd %boost.base.amount

  writeini $char($1) Battle Str %str
  writeini $char($1) Battle Def %def
  writeini $char($1) Battle Int %int
  writeini $char($1) Battle Spd %spd

  $set_chr_name($1) | set %user %real.name
  $set_chr_name($1) | $display.system.message(10 $+ %real.name  $+ $readini(techniques.db, $2, desc), battle)
  writeini $char($1) status boosted yes

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
}

alias tech.finalgetsuga {
  ; $1 = user
  ; $2 = tech
  ; $3 = target

  if ($readini($char($1), status, FinalGetsuga) != no) { 
    $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, AlreadyUsedFinalGetsuga), battle)
    if ($readini($char($1), info, flag) = monster) { $check_for_double_turn($1) | halt }
    else { halt }
  }

  ; Get the battle stats
  var %str $readini($char($1), Battle, Str)
  var %def $readini($char($1), Battle, Def)
  var %int $readini($char($1), Battle, Int)
  var %spd $readini($char($1), Battle, Spd)

  var %boost.base.amount $readini(techniques.db, $2, BasePower)
  var %player.level.amount $round($calc($readini($char($1), techniques, $2) * 10),0)

  inc %boost.base.amount %player.level.amount
  inc %boost.base.amount $rand(25,50)

  if ($readini($char($1), info, flag) = $null) {
    inc %str $round($calc(%str * %boost.base.amount),0)
    inc %def $round($calc(%def * %boost.base.amount),0)
    inc %int $round($calc(%int * %boost.base.amount),0)
    inc %spd $round($calc(%spd * %boost.base.amount),0)
  }
  if ($readini($char($1), info, flag) != $null) {
    set %boost.base.amount $round($calc(%boost.base.amount / 2),0)
    inc %str $round($calc(%str + %boost.base.amount),0)
    inc %def $round($calc(%def + %boost.base.amount),0)
    inc %int $round($calc(%int + %boost.base.amount),0)
    inc %spd $round($calc(%spd + %boost.base.amount),0)
  }

  writeini $char($1) Battle Str %str
  writeini $char($1) Battle Def %def
  writeini $char($1) Battle Int %int
  writeini $char($1) Battle Spd %spd

  $set_chr_name($1) | $display.system.message(10 $+ %real.name  $+ $readini(techniques.db, $2, desc), battle)
  writeini $char($1) status FinalGetsuga yes

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) | halt }

}

alias tech.aoe {
  ; $1 = user
  ; $2 = tech
  ; $3 = target
  ; $4 = type, either player or monster 

  set %wait.your.turn on

  unset %who.battle | set %number.of.hits 0
  unset %absorb  | unset %element.desc

  ; Display the tech description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  var %enemy all targets

  $display.system.message(3 $+ %user  $+ $readini(techniques.db, $2, desc), battle)
  set %showed.tech.desc true

  if ($readini(techniques.db, $2, absorb) = yes) { set %absorb absorb }

  var %tech.element $readini(techniques.db, $2, element)

  ; If it's player, search out remaining players that are alive and deal damage and display damage
  if ($4 = player) {
    var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line battle.txt
      if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }
      else { 

        if (($readini($char($1), status, confuse) != yes) && ($1 = %who.battle)) { inc %battletxt.current.line 1 }

        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
        else { 

          if ($readini($char($1), battle, hp) > 0) {
            inc %number.of.hits 1
            var %target.element.heal $readini($char(%who.battle), modifiers, heal)
            if ((%tech.element != none) && (%tech.element != $null)) {
              if ($istok(%target.element.heal,%tech.element,46) = $true) { 
                $tech.heal($1, $2, %who.battle, %absorb)
                inc %battletxt.current.line 1 
              }
            }

            if (($istok(%target.element.heal,%tech.element,46) = $false) || (%tech.element = none)) { 

              $covercheck(%who.battle, $2, AOE)

              if (($readini($char(%who.battle), status, reflect) = yes) && ($readini(techniques.db, $2, magic) = yes)) {
                $calculate_damage_techs($1, $2, $1)
                if (%attack.damage >= 4000) { set %attack.damage $rand(2800,3500) }
                unset %absorb
                $deal_damage($1, $1, $2, %absorb)
              }
              else {
                $calculate_damage_techs($1, $2, %who.battle)
                $deal_damage($1, %who.battle, $2, %absorb)
              }

              $display_aoedamage($1, %who.battle, $2, %absorb)

            }
          }

          inc %battletxt.current.line 1 
        } 
      }
    }
  }


  ; If it's monster, search out remaining monsters that are alive and deal damage and display damage.
  if ($4 = monster) { 
    var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 | set %aoe.turn 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line battle.txt
      if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
      else { 
        inc %number.of.hits 1
        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
        else { 
          if ($readini($char($1), battle, hp) > 0) {

            var %target.element.heal $readini($char(%who.battle), modifiers, heal)
            if ((%tech.element != none) && (%tech.element != $null)) {
              if ($istok(%target.element.heal,%tech.element,46) = $true) { 
                $tech.heal($1, $2, %who.battle, %absorb)
              }
            }

            if (($istok(%target.element.heal,%tech.element,46) = $false) || (%tech.element = none)) { 
              $covercheck(%who.battle, $2, AOE)
              if (($readini($char(%who.battle), status, reflect) = yes) && ($readini(techniques.db, $2, magic) = yes)) {
                $calculate_damage_techs($1, $2, $1)
                if (%attack.damage >= 4000) { set %attack.damage $rand(2800,3500) }
                unset %absorb
                $deal_damage($1, $1, $2, %absorb)
                $display_aoedamage($1, %who.battle, $2, %absorb)
              }
              else {
                $calculate_damage_techs($1, $2, %who.battle)
                $deal_damage($1, %who.battle, $2, %absorb)
                $display_aoedamage($1, %who.battle, $2, %absorb)
              }
            }
          }

          inc %battletxt.current.line 1 | inc %aoe.turn 1
        } 
      }
    }
  }

  unset %element.desc | unset %showed.tech.desc | unset %aoe.turn
  set %timer.time $calc(%number.of.hits * 1.5) 

  if ($readini(techniques.db, $2, magic) = yes) {
    ; Clear elemental seal
    if ($readini($char($1), skills, elementalseal.on) = on) { 
      writeini $char($1) skills elementalseal.on off 
    }
  }

  unset %statusmessage.display
  if ($readini($char($1), battle, hp) > 0) {
    $self.inflict_status($1, $4 , $3)
    if (%statusmessage.display != $null) { $display.system.message(%statusmessage.display, battle) | unset %statusmessage.display }
  }

  if (%timer.time > 20) { %timer.time = 20 }

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt
}


alias display_aoedamage {
  unset %overkill | unset %target |  unset %style.rating
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  ; Show the damage

  if (($readini($char($2), status, reflect) = yes) && ($readini(techniques.db, $3, magic) = yes)) { $display.system.message($readini(translation.dat, skill, MagicReflected), battle) | $set_chr_name($1) | set %enemy %real.name | set %target $1 | writeini $char($2) status reflect no | writeini $char($2) status reflect.timer 1  }

  if ($3 != battlefield) {
    if (($readini($char($1), info, flag) != monster) && (%target != $1)) { $calculate.stylepoints($1) }
  }

  if (%guard.message = $null) { $display.system.message($readini(translation.dat, tech, DisplayAOEDamage), battle)  }
  if (%guard.message != $null) { $display.system.message(%guard.message, battle) | unset %guard.message }

  if (%target = $null) { set %target $2 }

  if ($4 = absorb) { 
    ; Show how much the person absorbed back.
    var %absorb.amount $round($calc(%attack.damage / 2),0)
    $display.system.message($readini(translation.dat, tech, AbsorbHPBack), battle)
  }

  set %target.hp $readini($char(%target), battle, hp)


  if (%target.hp > 0) {
    ; Check to see if the monster can be staggered..  
    var %stagger.check $readini($char(%target), info, CanStagger)
    if ((%stagger.check = $null) || (%stagger.check = no)) { return }

    ; Do the stagger if the damage is above the threshold.
    var %stagger.amount.needed $readini($char(%target), info, StaggerAmount)
    dec %stagger.amount.needed %attack.damage | writeini $char(%target) info staggeramount %stagger.amount.needed
    if (%stagger.amount.needed <= 0) { writeini $char(%target) status staggered yes |  writeini $char(%target) info CanStagger no
      $display.system.message($readini(translation.dat, status, StaggerHappens), battle)
    }
  }

  ; Did the person die?  If so, show the death message.
  if (%target.hp  <= 0) { 
    writeini $char(%target) battle status dead 
    writeini $char(%target) battle hp 0
    $check.clone.death(%target)
    $increase_death_tally(%target)
    $achievement_check(%target, SirDiesALot)
    $increase.death.tally(%target) 
    if (%attack.damage > $readini($char(%target), basestats, hp)) { set %overkill 7<<OVERKILL>> }
    $display.system.message($readini(translation.dat, battle, EnemyDefeated), battle)
    $goldorb_check(%target) 
    $spawn_after_death(%target)
  }

  unset %attack.damage | unset %target
  return 
}

alias calculate_damage_techs {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target

  set %attack.damage 0

  ; First things first, let's find out the base power.
  set %base.stat.needed $readini(techniques.db, $2, stat)
  if (%base.stat.needed = $null) { set %base.stat.needed int }

  set %base.stat $readini($char($1), battle, %base.stat.needed)

  if (%base.stat = str) { $strength_down_check($1) }
  if (%base.stat = int) {  $int_down_check($1) }

  set %true.base.stat  %base.stat

  if ($readini(system.dat, system, BattleDamageFormula) = 1) {
    if (%base.stat > 10) {  
      if ($readini($char($1), info, flag) = $null) {  set %base.stat $round($calc(%base.stat / 1.151),0) }
      if ($readini($char($1), info, flag) != $null) { set %base.stat $round($calc(%base.stat / 2),0) }
    }
  }

  if ($readini(system.dat, system, BattleDamageFormula) = 2) {
    if (%base.stat > 999) {  
      if ($readini($char($1), info, flag) = $null) {  set %base.stat $round($calc(999 + %base.stat / 10),0) }
      if ($readini($char($1), info, flag) != $null) { set %base.stat $round($calc(999 + %base.stat / 5),0) }
    }
  }

  var %tech.base $readini(techniques.db, p, $2, BasePower)
  var %user.tech.level $readini($char($1), Techniques, $2)

  inc %tech.base $round($calc(%user.tech.level * 1.6),0)

  ; Let's add in the base power of the weapon used..
  set %weapon.used $readini($char($1), weapons, equipped)
  set %base.power.wpn $readini(weapons.db, %weapon.used, basepower)

  if (%base.power.wpn = $null) { var %base.power 1 }

  set %weapon.base $readini($char($1), weapons, %weapon.used)
  inc %base.power.wpn $round($calc(%weapon.base * 1.5),0)

  unset %weapon.used

  ; Does the user have a mastery in the weapon?  We can add a bonus as well.
  $mastery_check($1, $readini($char($1),weapons,equipped))

  inc %base.power.wpn $round($calc(%mastery.bonus / 1.5),0)
  inc %tech.base %base.power.wpn

  set %current.accessory $readini($char($3), equipment, accessory) 
  set %current.accessory.type $readini(items.db, %current.accessory, accessorytype)

  inc %tech.base %user.tech.level
  inc %base.stat %tech.base

  inc %attack.damage %base.stat

  ; Let's check for some offensive style enhancements
  $offensive.style.check($1, $2, tech)

  if ($augment.check($1, TechBonus) = true) { 
    set %tech.bonus.augment $calc(%augment.strength * .25)
    var %augment.power.increase.amount $round($calc(%tech.bonus.augment * %attack.damage),0)
    inc %attack.damage %augment.power.increase.amount
    unset %tech.bonus.augment
  }

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  ; Is the tech magic?  If so, we need to add some more stuff to it.
  if ($readini(techniques.db, $2, magic) = yes) { $calculate_damage_magic($1, $2, $3) }

  ;If the element is Light/fire and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if ($istok(light.fire,$readini(techniques.db, $2, element),46) = $true) { inc %attack.damage $round($calc(%attack.damage * .110),0)
    } 
  }

  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  set %current.weapon.used $readini($char($1), weapons, equipped)
  if ($readini(weapons.db, %current.weapon.used, cost) = 0) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %attack.damage 0 }
  }
  unset %current.weapon.used | unset %base.power.wpn

  var %tech.type $readini(techniques.db, $2, type)
  if ((%tech.type = heal-aoe) || (%tech.type = heal)) { return }

  ; Now we're ready to calculate the enemy's defense.
  set %enemy.defense $readini($char($3), battle, def)

  ; Because it's a tech, the enemy's int will play a small part too.
  var %int.bonus $round($calc($readini($char($3), battle, int) / 3.5),0)
  if ($readini($char($3), status, intdown) = yes) { var %int.bonus $round($calc(%int.bonus / 4),0) }

  inc %enemy.defense %int.bonus

  $defense_down_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini(techniques.db, $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
  }

  ; Check for the modifier adjustments.
  var %tech.element $readini(techniques.db, $2, element)
  if ((%tech.element != $null) && (%tech.element != none)) {
    $modifer_adjust($3, %tech.element)
  }

  ; Check to see if the target is resistant/weak to the tech itself
  $modifer_adjust($3, $2)


  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL DAMAGE.
  ;;; FORMULA 1
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if ($readini(system.dat, system, BattleDamageFormula) = 1) {
    ; Set the level ratio
    var %flag $readini($char($1), info, flag) 
    if (%flag = monster) { 
      set %temp.strength %base.stat
      if (%temp.strength > 900) { set %temp.strength $calc(900 + (%temp.strength / 25)) | set %level.ratio $calc(%temp.strength / %enemy.defense)    }
      if (%temp.strength <= 900) {  set %level.ratio $calc($readini($char($1), battle, %base.stat.needed) / %enemy.defense) }
    }

    if ((%flag = $null) || (%flag = npc)) { 
      set %temp.strength %base.stat
      if (%temp.strength > 5000) { set %temp.strength $calc(5000 + (%temp.strength / 5)) | set %level.ratio $calc(%temp.strength / %enemy.defense)  }
      if (%temp.strength <= 5000) {  set %level.ratio $calc($readini($char($1), battle, %base.stat.needed) / %enemy.defense) }
    }

    unset %temp.strength

    var %attacker.level $get.level($1)
    var %defender.level $get.level($3)

    if (%attacker.level > %defender.level) { inc %level.ratio .3 }
    if (%attacker.level < %defender.level) { dec %level.ratio .3 }

    if (%level.ratio > 2) { set %level.ratio 2 }
    if (%level.ratio <= .02) { set %level.ratio .02 }

    ; And let's get the final attack damage..
    %attack.damage = $round($calc(%attack.damage * %level.ratio),0)
  }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL DAMAGE.
  ;;; FORMULA 2
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if ($readini(system.dat, system, BattleDamageFormula) = 2) { 

    if ($readini(techniques.db, $2, magic) = yes) {  
      $calculate_pDIF($1, $3, magic)  
      set %attack.damage $round($calc(%attack.damage / 4.5),0) 
    }
    else { 
      $calculate_pDIF($1, $3, tech) 
      set %attack.damage $round($calc(%attack.damage / 1.5),0) 
    }

    %attack.damage = $round($calc(%attack.damage  * %pDIF),0)
    unset %pdif 
  }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  var %flag $readini($char($1), info, flag)

  if (%flag = $null) { 
    if ($readini(system.dat, system, IgnoreDmgCap) != true) { 
      if (%attack.damage > 40000)  { 
        set %temp.damage $round($calc(%attack.damage / 75),0)
        set %attack.damage $calc(40000 + %temp.damage)
        unset %temp.damage
        if (%attack.damage >= 60000) { set %attack.damage $rand(57000,60000) }
      }
    }

    if (%attack.damage <= 1) {
      var %max.damage $round($calc(%true.base.stat / 10),0)
      set %attack.damage $rand(1, %max.damage)
    }
  }

  if ((%flag = monster) && ($readini($char($3), info, flag) = $null)) {
    var %min.damage $round($calc(%true.base.stat / 15),0)

    if (%attack.damage = 0) { 

      var %base.tech $readini(techniques.db, $2, BasePower)
      var %int.increase.amount $round($calc(%true.base.stat * .02),0)
      inc %base.tech %int.increase.amount
      var %min.damage %base.tech
      set %attack.damage $readini(techniques.db, $2, BasePower)

      var %attacker.level $get.level($1)
      var %defender.level $get.level($3)
      var %level.difference $calc(%defender.level - %attacker.level)

      if (%level.difference >= 300) { 
        set %attack.damage 1
        set %min.damage $round($calc(%min.damage / 2),0)
      }
    }

    set %attack.damage $rand(%attack.damage, %min.damage)
    if ($readini(battlestats.dat, battle, winningstreak) <= 0) { %attack.damage = $round($calc(%attack.damage / 2),0) }
  }

  if ((%attack.damage > 2500) && (%flag = monster)) { 
    if ($readini(system.dat, system, IgnoreDmgCap) != true) { 
      if (%battle.rage.darkness != on) { set %attack.damage $rand(1000,2100) }
    }
  }

  inc %attack.damage $rand(1,5)
  unset %true.base.stat

  ; Check for the Guardian style
  $guardian_style_check($3)

  ; To be fair to players, we'll limit the damage if it has the ability to ignore guardian.
  if ($augment.check($1, IgnoreGuardian) = true) { 
    var %user.flag $readini($char($1), info, flag)
    if (%user.flag = monster) { 
      if ($readini($char($3), info, flag) = $null) {
        if (%attack.damage > 2500) { set %attack.damage 2000 } 
      }
    }
  }

  ; Check for the Metal Defense flag
  $metal_defense_check($3)

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances..
  if (%guard.message = $null) {
    if (%attack.damage <= 0) { set %attack.damage 1 }
  }

  unset %base.stat | unset %current.accessory.type | unset %base.stat.needed

  $trickster_dodge_check($3, $1)
  $manawall.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)
  $magic.ethereal.check($1, $2, $3)

  unset %statusmessage.display
  set %status.type.list $readini(techniques.db, $2, StatusType)

  if (%status.type.list != $null) { 
    set %number.of.statuseffects $numtok(%status.type.list, 46) 

    if (%number.of.statuseffects = 1) { $inflict_status($1, $3, %status.type.list, $2) | unset %number.of.statuseffects | unset %status.type.list }
    if (%number.of.statuseffects > 1) {
      var %status.value 1
      while (%status.value <= %number.of.statuseffects) { 
        set %current.status.effect $gettok(%status.type.list, %status.value, 46)
        $inflict_status($1, $3, %current.status.effect, $2)
        inc %status.value 1
      }  
      unset %number.of.statuseffects | unset %current.status.effect
    }
  }
  unset %status.type.list

  ; Is the tech a multi-hit weapon?  
  set %tech.howmany.hits $readini(techniques.db, $2, hits)


  if ($1 = demon_wall) {  $demon.wall.boost($1) }

  $first_round_dmg_chk($1, $3)


  var %current.element $readini(techniques.db, $2, element)
  if ((%current.element != $null) && (%tech.element != none)) {
    set %target.element.null $readini($char($3), modifiers, %current.element)
    if (%target.element.null <= 0) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 
    }
    unset %target.element.null
  }

  set %target.tech.null $readini($char($3), modifiers, $2)
  if (%target.tech.null <= 0) { $set_chr_name($3)
    set %guard.message $readini(translation.dat, battle, ImmuneToTechName) 
    set %attack.damage 0 
  }
  unset %target.element.null

  if (%guard.message = $null) {
    if ($readini(techniques.db, $2, magic) = yes) { 
      $magic.effect.check($1, $3, $2)
    }
  }

  ; If the target has Shell on, it will cut magic damage in half.
  if (($readini($char($3), status, shell) = yes) && ($readini(techniques.db, $2, magic) = yes)) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; Check for multiple hits now.
  if (%tech.howmany.hits = 2) {  $double.attack.check($1, $3, 100) }
  if (%tech.howmany.hits = 3) { $triple.attack.check($1, $3, 100) }
  if (%tech.howmany.hits = 4) { set %tech.howmany.hits 4 | $fourhit.attack.check($1, $3, 100) }
  if (%tech.howmany.hits = 5) { set %tech.howmany.hits 5 | $fivehit.attack.check($1, $3, 100) }
  if (%tech.howmany.hits = 6) { set %tech.howmany.hits 6 | $sixhit.attack.check($1, $3, 100) }
  if (%tech.howmany.hits = 7 ) { set %tech.howmany.hits 7 | $sevenhit.attack.check($1, $3, 100) }
  if (%tech.howmany.hits >= 8 ) { set %tech.howmany.hits 8 | $eighthit.attack.check($1, $3, 100) }

  unset %tech.howmany.hits |  unset %enemy.defense
}

alias calculate_damage_suicide {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target

  set %attack.damage 0

  ; First things first, let's find out the base power.
  var %base.stat $readini($char($1), battle, hp)
  var %tech.base $readini(techniques.db, $2, BasePower)
  var %user.tech.level $readini($char($1), Techniques, $2)

  ; Let's add in the base power of the weapon used..
  var %base.power.wpn $readini(weapons.db, $readini($char($1),weapons,equipped), basepower)
  if (%base.power.wpn = $null) { var %base.power 1 }

  inc %tech.base %base.power.wpn

  inc %tech.base %user.tech.level
  inc %base.stat %tech.base

  inc %attack.damage %base.stat

  ; Let's check for some offensive style enhancements
  $offensive.style.check($1, $2, melee)

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  ; If the target is weak to the element, double the attack power of the weapon. 
  ; If the target is strong to the element, cut the attack of the weapon by half.
  var %tech.element $readini(techniques.db, $2, element)
  if ((%tech.element != $null) && (%tech.element != none)) {
    $modifer_adjust($3, %tech.element)
  }

  ; Is the tech magic?  If so, we need to add some more stuff to it.
  if ($readini(techniques.db, $2, magic) = yes) { $calculate_damage_magic($1, $2, $3) }

  ;If the element is Light/fire and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if (%tech.element = light) {  inc %attack.damage $round($calc(%attack.damage * .110),0) } 
    if (%tech.element = fire) {  inc %attack.damage $round($calc(%attack.damage * .110),0) } 
  } 

  ; If it's the blood moon, increase the amount.
  if (%bloodmoon = on) { inc %attack.damage $rand(10,50) } 

  var %current.flag $readini($char($1), info, flag)
  if (%current.flag = $null) {  set %attack.damage $round($calc(%attack.damage / 10),0)
    if (%attack.damage <= 0) { set %attack.damage 1 }
    if (%attack.damage >= 500) { set %attack.damage 500 }
  }
  if (%current.flag = npc) {  set %attack.damage $round($calc(%attack.damage / 10),0)
    if (%attack.damage <= 0) { set %attack.damage 1 }
    if (%attack.damage >= 750) { set %attack.damage 750 }
  }

  ; Now we're ready to calculate the enemy's defense..  
  set  %enemy.defense $readini($char($3), battle, def)

  ; Because it's a tech, the enemy's int will play a small part too.
  var %int.bonus $round($calc($readini($char($3), battle, int) / 2),0)
  inc  %enemy.defense %int.bonus

  %enemy.defense = $round($calc(%enemy.defense / 5),0)

  ; Is the target using the Guardian style?  If so, we need to decrease the damage done.
  $guardian_style_check($3)

  $defense_down_check($3)

  ; And let's get the final attack damage..
  if (%enemy.defense <= 0) { set %enemy.defense 1 }
  dec %attack.damage %enemy.defense

  unset %enemy.defense

  $metal_defense_check($3)

  ; In this bot we don't want the attack to ever be lower than 1.  
  if (%attack.damage <= 0) { set %attack.damage 1 }

  $trickster_dodge_check($3, $1)
  $manawall.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)
  $magic.ethereal.check($1, $2, $3)

  $first_round_dmg_chk($1, $3)

  var %current.element $readini(techniques.db, $2, element)
  if ((%current.element != $null) && (%tech.element != none)) {
    var %target.element.null $readini($char($3), element, null)
    if ($istok(%target.element.null,%current.element,46) = $true) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 
    }
  }

  if (%guard.message = $null) {
    if ($readini(techniques.db, $2, magic) = yes) { 
      $magic.effect.check($1, $3, $2)
    }
  }

}

alias calculate_damage_magic {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target

  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  set %magic.bonus.modifier 0.5

  if ($augment.check($1, MagicBonus) = true) { 
    set %magic.bonus.augment $calc(%augment.strength * .2)
    inc %magic.bonus.modifier %magic.bonus.augment
    unset %magic.bonus.augment
  }

  ; Let's check for some offensive style enhancements
  $offensive.style.check($1, $2, magic)

  unset %current.playerstyle | unset %current.playerstyle.level

  ; Check for certain skills that will enhance magic.
  ;check to see if skills are on that affect the spells.
  var %clear.mind.check $readini($char($1), skills, ClearMind) 
  if (%clear.mind.check > 0) { 
    var %enhance.value $readini($char($1), skills, ClearMind) * .065
    inc %magic.bonus.modifier %enhance.value
  }

  if ($readini($char($1), skills, elementalseal.on) = on) { 

    if ($readini(system.dat, system, BattleDamageFormula) = 1) {   var %enhance.value $readini($char($1), skills, ElementalSeal) * .40 }
    if ($readini(system.dat, system, BattleDamageFormula) = 2) { var %enhance.value $readini($char($1), skills, ElementalSeal) * .195 }
    inc %magic.bonus.modifier %enhance.value
  }

  ;  Check for the wizard's amulet accessory
  if ($readini($char($1), equipment, accessory) = wizard's-amulet) {
    var %accessory.amount $readini(items.db, wizard's-amulet, amount)
    inc %magic.bonus.modifier %accessory.amount
  }

  ; Elementals are weak to magic
  if ($readini($char($3), monster, type) = elemental) { inc %magic.bonus.modifier 1.3 } 

  ; Increase the attack damage now.

  if (%magic.bonus.modifier != 0) { inc %attack.damage $round($calc(%attack.damage * %magic.bonus.modifier),0) }

  ; Is the weather the right condition to enhance the spell?
  $spell.weather.check($1, $3, $2) 

  unset %magic.bonus.modifier
}

alias spell.weather.check { 
  var %spell.element $readini(techniques.db, $3, element)
  if (%spell.element = $null) { return }
  var %current.weather $readini(weather.lst, weather, current)
  if ((%current.weather = calm) || (%current.weather = $null)) { return }
  if ((%spell.element = fire) && (%current.weather = hot)) { $spell.weather.increase }
  if ((%spell.element = water) && (%current.weather = rainy)) { $spell.weather.increase }
  if (%spell.element = ice) && (%current.weather = snowy) { $spell.weather.increase }
  if (%spell.element = lightning) && (%current.weather = stormy) { $spell.weather.increase }
  if (%spell.element = light) && (%current.weather = bright) { $spell.weather.increase }
  if (%spell.element = earth) && (%current.weather = dry) { $spell.weather.increase }
  if (%spell.element = wind) && (%current.weather = windy) { $spell.weather.increase }
  if (%spell.element = dark) && (%current.weather = gloomy) { $spell.weather.increase }
  else { return }
}

alias spell.weather.increase {
  var %weather.increase = $readini weather.lst weather boost
  if ((%weather.increase = $null) || (%weather.increase < 0)) { %increase = .25 }
  var %new.attack.damage = $round($calc(%attack.damage * %weather.increase),0)
  inc %attack.damage %new.attack.damage
}

alias magic.effect.check {
  if ($readini($char($2), skills, utsusemi.on) = on) { return }
  if (%guard.message != $null) { return }

  var %attacker.level $get.level($1)
  var %defender.level $get.level($2)
  var %level.difference $calc(%attacker.level - %defender.level)

  if ((%level.difference <= 20) && ($readini($char($1), info, flag) = $null)) { return }

  set %current.element $readini(techniques.db, $3, element)
  if ((%current.element != $null) && (%tech.element != none)) {
    set %target.element.null $readini($char($2), modifiers, %current.element)
    unset %current.element
    if (%target.element.null <= 0) { unset %target.element.null | return }
  }

  unset %spell.element | unset %element.desc | unset %current.element
  set %spell.element $readini(techniques.db, $3, element) | $set_chr_name($2) 
  var %target.element.heal $readini($char($2), element, heal)
  if ($istok(%target.element.heal,%spell.element,46) = $true) { return }

  var %resist-element $readini($char($2), status, resist- $+ %spell.element)

  if (%spell.element = $null) { return } 
  if (%spell.element  = light) {
    var %total.spell $readini($char($1), stuff, LightSpellsCasted) 
    if (%total.spell = $null) { var %total.spell 0 }
    inc %total.spell 1 
    writeini $char($1) stuff LightSpellsCasted %total.spell
    $achievement_check($1, BlindedByTheLight)
    return 
  }
  if (%spell.element  = dark) { 
    var %total.spell $readini($char($1), stuff, DarkSpellsCasted) 
    if (%total.spell = $null) { var %total.spell 0 }
    inc %total.spell 1 
    writeini $char($1) stuff DarkSpellsCasted %total.spell
    $achievement_check($1, It'sAllDoomAndGloom)
    return 
  }
  if (%spell.element  = fire) { 
    if ((%resist-element = no) || (%resist-element = $null)) { writeini $char($2) Status burning yes | set %element.desc $readini(translation.dat, element, fire) }

    var %total.spell $readini($char($1), stuff, FireSpellsCasted) 
    if (%total.spell = $null) { var %total.spell 0 }
    inc %total.spell 1 
    writeini $char($1) stuff FireSpellsCasted %total.spell
    $achievement_check($1, DiscoInferno)
    return 
  }
  if (%spell.element  = wind) { 
    if ((%resist-element = no) || (%resist-element = $null)) {  writeini $char($2) Status tornado yes | set %element.desc $readini(translation.dat, element, wind) }
    var %total.spell $readini($char($1), stuff, WindSpellsCasted) 
    if (%total.spell = $null) { var %total.spell 0 }
    inc %total.spell 1 
    writeini $char($1) stuff WindSpellsCasted %total.spell
    $achievement_check($1, RockYouLikeAHurricane)
    return 

  }
  if (%spell.element  = water) { 
    if ((%resist-element = no) || (%resist-element = $null)) { writeini $char($2) Status drowning yes | set %element.desc $readini(translation.dat, element, water) }
    var %total.spell $readini($char($1), stuff, WaterSpellsCasted) 
    if (%total.spell = $null) { var %total.spell 0 }
    inc %total.spell 1 
    writeini $char($1) stuff WaterSpellsCasted %total.spell
    $achievement_check($1, TimeToBuildAnArk)
    return 
  }
  if (%spell.element  = ice) { 
    if ((%resist-element = no) || (%resist-element = $null)) { writeini $char($2) Status frozen yes | set %element.desc $readini(translation.dat, element, ice) }
    var %total.spell $readini($char($1), stuff, IceSpellsCasted) 
    if (%total.spell = $null) { var %total.spell 0 }
    inc %total.spell 1 
    writeini $char($1) stuff IceSpellsCasted %total.spell
    $achievement_check($1, IceIceBaby)
    return 
  }
  if (%spell.element  = lightning) { 
    if ((%resist-element = no) || (%resist-element = $null)) {  writeini $char($2) Status shock yes | set %element.desc $readini(translation.dat, element, lightning) }
    var %total.spell $readini($char($1), stuff, LightningSpellsCasted) 
    if (%total.spell = $null) { var %total.spell 0 }
    inc %total.spell 1 
    writeini $char($1) stuff LightningSpellsCasted %total.spell
    $achievement_check($1, 1.21gigawatts)
    return
  }
  if (%spell.element  = earth) { 
    if ((%resist-element = no) || (%resist-element = $null)) { writeini $char($2) Status earth-quake yes | set %element.desc $readini(translation.dat, element, earth) }
    var %total.spell $readini($char($1), stuff, EarthSpellsCasted) 
    if (%total.spell = $null) { var %total.spell 0 }
    inc %total.spell 1 
    writeini $char($1) stuff EarthSpellsCasted %total.spell
    $achievement_check($1, InTuneWithMotherEarth)
    return
  }
}

; ======================
; Ribbon type accessory check
; ======================
alias ribbon.accessory.check { 
  set %current.accessory $readini($char($1), equipment, accessory) 
  if ($readini(items.db, %current.accessory, accessorytype) = BlockAllStatus) {
    set %resist.skill 100
  }
  unset %current.accessory
}

; ======================
; Ignition Aliases
; ======================

alias ignition_cmd { 
  ; $1 = user
  ; $2 = boost name

  if (%battleis = off) { $display.system.message($readini(translation.dat, errors, NoBattleCurrently), battle) | halt }
  $check_for_battle($1) 
  $amnesia.check($1, ignition) 

  if ((no-ignition isin %battleconditions) || (no-ignitions isin %battleconditions)) { $set_chr_name($1) | $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition), battle) | halt }
  if ($readini($char($1), status, virus) = yes) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, Can'tBoostHasVirus), battle) | halt }
  if (($readini($char($1), status, boosted) = yes) || ($readini($char($1), status, ignition.on) = on)) {  $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, AlreadyBoosted), battle) | halt }

  ; Does the user know that ignition?
  var %ignition.level $readini($char($1), ignitions, $2)
  if (($2 = $null) || ($2 <= 0)) {  $set_chr_name($1) | $display.system.message(readini(translation.dat, Errors, DoNotKnowThatIgnition), battle) |  halt }


  ; Check to see if the user has enough Ignition Gauge to boost
  set %ignition.cost $readini(ignitions.db, $2, IgnitionTrigger)
  set %player.current.ig $readini($char($1), battle, ignitionGauge)

  if (%player.current.ig < %ignition.cost) { $display.system.message($readini(translation.dat, Errors, NotEnoughIgnitionGaugeToBoost), battle) | unset %ignition.cost | unset %player.current.ig | halt }

  ; Decrease the ignition gauge the initial cost. 
  dec %player.current.ig %ignition.cost
  writeini $char($1) Battle IgnitionGauge %player.current.ig

  ; Display the description
  $set_chr_name($1)

  if ($readini($char($1), descriptions, $2) = $null) { set %ignition.description $readini(ignitions.db, $2, desc) }
  else { set %ignition.description $readini($char($1), descriptions, $2) }
  $set_chr_name($1) | $display.system.message(10 $+ %real.name  $+ %ignition.description, battle)

  ; Increase the stats
  var %hp $round($calc($readini($char($1), Battle, Hp) * $readini(ignitions.db, $2, hp)),0)
  var %str $round($calc($readini($char($1), Battle, Str) * $readini(ignitions.db, $2, str)),0)
  var %def $round($calc($readini($char($1), Battle, def) * $readini(ignitions.db, $2, def)),0)
  var %int $round($calc($readini($char($1), Battle, int) * $readini(ignitions.db, $2, int)),0)
  var %spd $round($calc($readini($char($1), Battle, spd) * $readini(ignitions.db, $2, spd)),0)

  writeini $char($1) Battle Hp %hp
  writeini $char($1) Battle Str %str
  writeini $char($1) Battle Def %def
  writeini $char($1) Battle Int %int
  writeini $char($1) Battle Spd %spd

  ; Turn on the Augment and perform the trigger effect
  writeini $char($1) status ignition.on on
  writeini $char($1) status ignition.name $2
  var %ignition.augment $readini(ignitions.db, $2, augment)
  writeini $char($1) status ignition.augment %ignition.augment

  $ignition.triggereffect($1, $2)


  var %number.of.ignitions $readini($char($1), stuff, IgnitionsUsed)
  if (%number.of.ignitions = $null) { var %number.of.ignitions 0 }
  inc %number.of.ignitions 1
  writeini $char($1) stuff IgnitionsUsed %number.of.ignitions
  $achievement_check($1, PartyIsGettingCrazy)


  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
}

alias ignition.triggereffect {
  ; $1 = user
  ; $2 = ignition
  if ($readini(ignitions.db, $2, Effect) = none) { return }

  if ($readini(ignitions.db, $2, Effect) = status) { 
    var %status.target $readini(ignitions.db, $2, StatusTarget)
    if (%status.target = self) {  writeini $char($1) status $readini(ignitions.db, $2, StatusType) yes | return }

    if (%status.target = enemy) { 
      var %current.flag $readini($char($1), info, flag)
      var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1
      while (%battletxt.current.line <= %battletxt.lines) { 
        var %who.battle $read -l $+ %battletxt.current.line battle.txt
        var %flag $readini($char(%who.battle), info, flag)

        if ((%current.flag = $null) && (%flag = monster)) {
          writeini $char(%who.battle) status $readini(ignitions.db, $2, StatusType) yes
        }
        if ((%current.flag = monster) && (%flag = $null)) {
          writeini $char(%who.battle) status $readini(ignitions.db, $2, StatusType) yes
        }
        if ((%current.flag = monster) && (%flag = npc)) {
          writeini $char(%who.battle) status $readini(ignitions.db, $2, StatusType) yes
        }

        inc %battletxt.current.line 1
      }
    }
    if (%status.target = allies) { 
      var %current.flag $readini($char($1), info, flag)
      var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1
      while (%battletxt.current.line <= %battletxt.lines) { 
        var %who.battle $read -l $+ %battletxt.current.line battle.txt
        var %flag $readini($char(%who.battle), info, flag)

        if ((%current.flag = $null) && (%flag = $null)) {
          writeini $char(%who.battle) status $readini(ignitions.db, $2, StatusType) yes
        }
        if ((%current.flag = monster) && (%flag = monster)) {
          writeini $char(%who.battle) status $readini(ignitions.db, $2, StatusType) yes
        }
        if ((%current.flag = $null) && (%flag = npc)) {
          writeini $char(%who.battle) status $readini(ignitions.db, $2, StatusType) yes
        }

        inc %battletxt.current.line 1
      }
    }
  }
  return
}

alias revert {
  ; $1 = person
  ; $2 = ignition name

  ; Decrease the stats
  var %hp $round($calc($readini($char($1), Battle, hp) / $readini(ignitions.db, $2, hp)),0)
  var %str $round($calc($readini($char($1), Battle, Str) / $readini(ignitions.db, $2, str)),0)
  var %def $round($calc($readini($char($1), Battle, def) / $readini(ignitions.db, $2, def)),0)
  var %int $round($calc($readini($char($1), Battle, int) / $readini(ignitions.db, $2, int)),0)
  var %spd $round($calc($readini($char($1), Battle, spd) / $readini(ignitions.db, $2, spd)),0)

  if (%hp <= 5) { var %hp5 }
  if (%str <= 5) { var %str 5 }
  if (%def <= 5) { var %def 5 }
  if (%int <= 5) { var %int 5 }
  if (%spd <= 5) { var %spd 5 }

  writeini $char($1) Battle Hp %hp
  writeini $char($1) Battle Str %str
  writeini $char($1) Battle Def %def
  writeini $char($1) Battle Int %int
  writeini $char($1) Battle Spd %spd

  remini $char($1) status ignition.name
  remini $char($1) status ignition.augment
  writeini $char($1) status ignition.on off
}
