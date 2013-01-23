;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TECHS COMMAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON 2:ACTION:goes *:#:{ 
  if ($3 != $null) { halt }
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  $set_chr_name($nick) 

  set %ignition.list $readini(ignitions.db, ignitions, list)
  if ($istok($2,%ignition.list,46) = $true) { unset %ignition.list | $ignition_cmd($nick, $2, $nick) | halt }
  else { $tech_cmd($nick , $2, $nick) | halt }
} 
ON 2:ACTION:uses * * on *:#:{ 
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  $set_chr_name($nick) | set %attack.target $5 | $covercheck($5, $3)
  $tech_cmd($nick , $3 , %attack.target, $7) | halt 
} 
ON 50:TEXT:*uses * * on *:*:{ 
  if ($1 = uses) { halt }
  if ($5 != on) { halt }
  else { $set_chr_name($1) | set %attack.target $6 | $covercheck($6, $3)
  $tech_cmd($1, $4, %attack.target) | halt }
}

alias tech_cmd {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target

  ; Make sure some old attack variables are cleared.
  unset %attack.damage | unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %drainsamba.on | unset %absorb
  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged

  $check_for_battle($1) 

  set %tech.type $readini(techniques.db, $2, Type) | $amnesia.check($1, tech) 
  if ($readini($char($1), techniques, $2) = $null) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoesNotKnowTech) | halt }

  if ((no-tech isin %battleconditions) || (no-techs isin %battleconditions)) { $set_chr_name($1) | query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition) | halt }

  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, CanNotAttackWhileUnconcious)  | unset %real.name | halt }
  if ($readini($char($3), Battle, Status) = dead) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, CanNotAttackSomeoneWhoIsDead) | unset %real.name | halt }
  if ($readini($char($3), Battle, Status) = RunAway) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, CanNotAttackSomeoneWhoFledTech) | unset %real.name | halt } 

  $person_in_battle($3) | $checkchar($3) 

  ; Get the weapon equipped
  $weapon_equipped($1)

  set %weapon.abilities $readini(weapons.db, %weapon.equipped, abilities)
  if ($istok(%weapon.abilities,$2,46) = $false) {  $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, Can'tPerformTechWithWeapon) | halt }
  unset %weapon.abilities 

  ; Make sure the user has enough TP to use this in battle..
  set %tp.needed $readini(techniques.db, $2, TP) | set %tp.have $readini($char($1), battle, tp)

  ; Check for ConserveTP
  if ($readini($char($1), skills, conservetp.on) = on) { set %tp.needed 0 | writeini $char($1) skills conserveTP.on off }

  if (%tp.needed = $null) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoesNotKnowTech) | halt }
  if (%tp.needed > %tp.have) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, NotEnoughTPforTech) | halt }

  if (%mode.pvp != on) {
    if (($3 = $1) && ($is_charmed($1) = false))  { 
      if (%tech.type !isin boost.finalgetsuga.heal.heal-AOE) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, Can'tAttackYourself) | unset %real.name | halt  }
    }
  }

  dec %tp.have %tp.needed | writeini $char($1) battle tp %tp.have | unset %tp.have | unset %tp.needed

  if (%tech.type = boost) { 
    if ($readini($char($1), status, virus) = yes) { query %battlechan $readini(translation.dat, errors, Can'tBoostHasVirus) | halt }

    $tech.boost($1, $2, $3)

  } 
  if (%tech.type = finalgetsuga) { $tech.finalgetsuga($1, $2, $3) } 

  var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($3), info, flag)

  if ($is_charmed($1) = true) { set %user.flag monster }
  if (%tech.type = heal) { set %user.flag monster }
  if (%tech.type = heal-aoe) { set %user.flag monster }

  if (%mode.pvp = on) { set %user.flag monster }

  if ((%user.flag != monster) && (%target.flag != monster)) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, CanOnlyAttackMonsters)  | halt }

  ; Let's do something based on the type of techniques it is.
  writeini $char($1) status conservetp.on off

  if (%tech.type = heal) { $tech.heal($1, $2, $3) }
  if (%tech.type = heal-aoe) { $tech.aoeheal($1, $2, $3) }
  if (%tech.type = single) { $tech.single($1, $2, $3) }
  if (%tech.type = suicide) { $tech.suicide($1, $2, $3) }
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
      ; Determine if it's players or monsters
      if (%user.flag = monster) { $tech.aoe($1, $2, $3, player) | halt }
      if ((%user.flag = $null) || (%user.flag = npc)) { $tech.aoe($1, $2, $3, monster) | halt }
    }
  }

  ; Time to go to the next turn
  if (%battleis = on)  {  $check_for_double_turn($1) }
}


alias tech.single {
  ; $3 = target

  var %tech.element $readini(techniques.db, $2, element)
  var %target.element.heal $readini($char($3), element, heal)

  if ($istok(%target.element.heal,%tech.element,46) = $true) { 
    $tech.heal($1, $2, $3, %absorb)
    return
  }

  if ($readini(techniques.db, $2, absorb) = yes) { set %absorb absorb }
  else { set %absorb none }
  $calculate_damage_techs($1, $2, $3)
  $deal_damage($1, $3, $2, %absorb)
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
      var %def.of.monster $readini($char($3), battle, def) | dec %def.of.monster 1 

      if (%def.of.monster < 1) { inc %def.of.monster 1 }
      writeini $char($3) battle def %def.of.monster
    }
    if (($istok(%target.element.strong,%tech.element,46) = $true)  || (%current.accessory.type = ElementalDefense)) {  
      %tech.base = $round($calc(%tech.base / 2), 0) 
      var %str.of.monster $readini($char($3), battle, str) | inc %str.of.monster 1 | writeini $char($3) battle str %str.of.monster
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
  var %int.bonus $round($calc($readini($char($3), battle, int) / 2),0)
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

  query %battlechan 3 $+ %user $+  $readini(techniques.db, $2, desc)
  $set_chr_name($1) | query %battlechan $readini(translation.dat, tech, StolenPower)

  unset %current.accessory.type
  return
}

alias tech.suicide {
  $set_chr_name($1)
  query %battlechan $readini(translation.dat, tech, SuicideUseAllHP)

  $calculate_damage_suicide($1, $2, $3)
  writeini $char($1) battle hp 0 | writeini $char($1) battle status dead | $set_chr_name($1)
  $deal_damage($1, $3, $2)
  $display_damage($1, $3, tech, $2)
  return
}

alias tech.heal {
  ; $1 = user
  ; $2 = tech
  ; $3 = target

  $calculate_damage_techs($1, $2, $3)

  if (%bloodmoon = on) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  var %mon.status $readini($char($3), status, zombie) | var %mon.type $readini($char($3), monster, type)
  var %target.element.heal $readini($char($3), element, heal)
  var %tech.element $readini(techniques.db, $2, element)

  if (($istok(%target.element.heal,%tech.element,46) = $false) || (%target.element.heal = $null)) { 
    if ((%mon.status = yes) || (%mon.type = undead)) {
      $deal_damage($1, $3, $2)
      $display_damage($1, $3, tech, $2)
      return
    } 
  }

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

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  if (%bloodmoon = on) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; In this bot we don't want the attack to ever be lower than 1.  
  if (%attack.damage <= 0) { set %attack.damage 1 }

  ; Display the tech description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($3) | set %enemy %real.name
  query %battlechan 3 $+ %user $+  $readini(techniques.db, $2, desc)

  var %caster.flag $readini($char($1), info, flag)
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
  query %battlechan $readini(translation.dat, tech, SuicideUseAllHP)

  ; Display the tech description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name
  query %battlechan 3 $+ %user  $+ $readini(techniques.db, $2, desc)

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
          $calculate_damage_suicide($1, $2, %who.battle)
          $deal_damage($1, %who.battle, $2)
          $display_aoedamage($1, %who.battle, $2)
          inc %battletxt.current.line 1 |  inc %aoe.turn 1
        } 
      }
    }
  }

  set %timer.time $calc(%number.of.hits * 1) 

  writeini $char($1) battle hp 0 | writeini $char($1) battle status dead | $set_chr_name($1)

  unset %aoe.turn 
  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt

}

alias tech.magic {
  $calculate_damage_magic($1, $2, $3)
  $deal_damage($1, $3, $2)
  $display_damage($1, $3, tech, $2)
  return
}

alias tech.boost {
  ; $1 = user
  ; $2 = tech
  ; $3 = target

  if ($readini($char($1), status, boosted) != no) { 
    $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, AlreadyBoosted)
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
  $set_chr_name($1) | query %battlechan 10 $+ %real.name  $+ $readini(techniques.db, $2, desc)
  writeini $char($1) status boosted yes

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
}

alias tech.finalgetsuga {
  ; $1 = user
  ; $2 = tech
  ; $3 = target

  if ($readini($char($1), status, FinalGetsuga) != no) { 
    $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, AlreadyUsedFinalGetsuga)
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

  $set_chr_name($1) | query %battlechan 10 $+ %real.name  $+ $readini(techniques.db, $2, desc)
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

  query %battlechan 3 $+ %user  $+ $readini(techniques.db, $2, desc)
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
        if ($1 = %who.battle) { inc %battletxt.current.line 1 }
        if ($1 != %who.battle) { 
          var %current.status $readini($char(%who.battle), battle, status)
          if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
          else { 
            inc %number.of.hits 1
            var %target.element.heal $readini($char(%who.battle), element, heal)
            if ($istok(%target.element.heal,%tech.element,46) = $true) { 
              $tech.heal($1, $2, %who.battle, %absorb)
              inc %battletxt.current.line 1 
            }

            if ($istok(%target.element.heal,%tech.element,46) = $false) { 
              $calculate_damage_techs($1, $2, %who.battle)
              $deal_damage($1, %who.battle, $2, %absorb)
              $display_aoedamage($1, %who.battle, $2, %absorb)
              inc %battletxt.current.line 1 
            }
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
          var %target.element.heal $readini($char(%who.battle), element, heal)
          if ($istok(%target.element.heal,%tech.element,46) = $true) { 
            $tech.heal($1, $2, %who.battle, %absorb)
          }
          if ($istok(%target.element.heal,%tech.element,46) = $false) { 
            $calculate_damage_techs($1, $2, %who.battle)
            $deal_damage($1, %who.battle, $2, %absorb)
            $display_aoedamage($1, %who.battle, $2, %absorb)
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

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt
}


alias display_aoedamage {
  unset %overkill
  unset %style.rating
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  ; Show the damage
  $calculate.stylepoints($1)

  if (%guard.message = $null) { query %battlechan $readini(translation.dat, tech, DisplayAOEDamage)  }
  if (%guard.message != $null) { query %battlechan %guard.message | unset %guard.message }

  if ($4 = absorb) { 
    ; Show how much the person absorbed back.
    var %absorb.amount $round($calc(%attack.damage / 2),0)
    query %battlechan $readini(translation.dat, tech, AbsorbHPBack)
  }

  if ($readini($char($2), battle, HP) > 0) {
    ; Check to see if the monster can be staggered..  
    var %stagger.check $readini($char($2), info, CanStagger)
    if ((%stagger.check = $null) || (%stagger.check = no)) { return }

    ; Do the stagger if the damage is above the threshold.
    var %stagger.amount.needed $readini($char($2), info, StaggerAmount)
    dec %stagger.amount.needed %attack.damage | writeini $char($2) info staggeramount %stagger.amount.needed
    if (%stagger.amount.needed <= 0) { writeini $char($2) status staggered yes |  writeini $char($2) info CanStagger no
      query %battlechan $readini(translation.dat, status, StaggerHappens)
    }
  }

  ; Did the person die?  If so, show the death message.
  if ($readini($char($2), battle, HP) <= 0) { 
    writeini $char($2) battle status dead 
    writeini $char($2) battle hp 0
    $check.clone.death($2)
    $increase_death_tally($2)
    $achievement_check($2, SirDiesALot)
    if (%attack.damage > $readini($char($2), basestats, hp)) { set %overkill 7<<OVERKILL>> }
    query %battlechan $readini(translation.dat, battle, EnemyDefeated)
    $goldorb_check($2) 
    $spawn_after_death($2)
  }

  unset %attack.damage
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

  if (%base.stat = str) { $strength_down_check($1) }

  set %base.stat $readini($char($1), battle, %base.stat.needed)

  var %tech.base $readini(techniques.db, $2, BasePower)
  var %user.tech.level $readini($char($1), Techniques, $2)

  inc %tech.base $round($calc(%user.tech.level * 1.5),0)

  ; Let's add in the base power of the weapon used..
  set %weapon.used $readini($char($1), weapons, equipped)
  set %base.power.wpn $readini(weapons.db, %weapon.used, basepower)

  if (%base.power.wpn = $null) { var %base.power 1 }

  set %weapon.base $readini($char($1), weapons, %weapon.used)
  inc %base.power.wpn $round($calc(%weapon.base * 1.9),0)

  unset %weapon.used

  ; Does the user have a mastery in the weapon?  We can add a bonus as well.
  $mastery_check($1, $readini($char($1),weapons,equipped))

  inc %base.power.wpn $round($calc(%mastery.bonus / 1.5),0)

  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
  if (%current.playerstyle = HitenMitsurugi-ryu) {
    set %weapon.name.used $readini($char($1),weapons,equipped)
    set %weapon.used.type $readini(weapons.db, %weapon.name.used, type)
    if (%weapon.used.type = Katana) {
      var %style.power.increase.amount $round($calc(1.5 * %current.playerstyle.level),0)
      inc %base.power.wpn %style.power.increase.amount
    }
  }
  unset %current.playerstyle | unset %current.playerstyle.level

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
      var %def.of.monster $readini($char($3), battle, def) | dec %def.of.monster $rand(5,10)

      if (%def.of.monster < 1) { inc %def.of.monster 1 }
      writeini $char($3) battle def %def.of.monster
    }
    if (($istok(%target.element.strong,%tech.element,46) = $true) || (%current.accessory.type = ElementalDefense)) { 
      %tech.base = $round($calc(%tech.base / 2), 0) 
      var %str.of.monster $readini($char($3), battle, str) | inc %str.of.monster 1 | writeini $char($3) battle str %str.of.monster
    }
  }

  inc %tech.base %user.tech.level
  inc %base.stat %tech.base

  inc %attack.damage %base.stat

  if ($augment.check($1, TechBonus) = true) { 
    var %augment.power.increase.amount $round($calc(.30 * %attack.damage),0)
    inc %attack.damage %augment.power.increase.amount
  }

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  ; Is the tech magic?  If so, we need to add some more stuff to it.
  if ($readini(techniques.db, $2, magic) = yes) { $calculate_damage_magic($1, $2, $3) }

  ;If the element is Light/fire and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if (%tech.element = light) {  inc %attack.damage $round($calc(%attack.damage * .110),0) } 
    if (%tech.element = fire) {  inc %attack.damage $round($calc(%attack.damage * .110),0) } 
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

  ; Now we're ready to calculate the enemy's defense..  
  var %enemy.defense $readini($char($3), battle, def)

  ; Because it's a tech, the enemy's int will play a small part too.
  var %int.bonus $round($calc($readini($char($3), battle, int) / 2),0)
  inc  %enemy.defense %int.bonus

  $guardian_style_check($3)
  $defense_down_check($3)

  ; And let's get the final attack damage..
  dec %attack.damage %enemy.defense

  $metal_defense_check($3)

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances..
  if (%attack.damage <= 0) { set %attack.damage 1 }

  unset %base.stat.needed | unset %base.stat | unset %current.accessory.type

  $trickster_dodge_check($3, $1)

  if (%guard.message = $null) {
    var %utsusemi.flag $readini($char($3), skills, utsusemi.on)
    if ((%utsusemi.flag = off) || (%utsusemi.flag = $null)) {
      ; does the target have ManaWall on?  If so, reduce the damage to 0.
      if (($readini($char($3), skills, manawall.on) = on) && ($readini(techniques.db, $2, magic) = yes)) { 
        if ($readini(techniques.db, $2, type) = heal) { return }
        writeini $char($3) skills manawall.on off | set %attack.damage 0 | $set_chr_name($3) | set %guard.message $readini(translation.dat, skill, ManaWallBlocked) | return 
      }
    }
    if (%utsusemi.flag = on) {
      if ($readini(techniques.db, $2, type) = heal) { return }
      var %number.of.shadows $readini($char($3), skills, utsusemi.shadows)
      dec %number.of.shadows 1 
      writeini $char($3) skills utsusemi.shadows %number.of.shadows
      if (%number.of.shadows <= 0) { writeini $char($3) skills utsusemi.on off }
      $set_chr_name($3) | set %guard.message $readini(translation.dat, skill, UtsusemiBlocked)  | set %attack.damage 0 | return 
    }

    if (($readini($char($3), status, ethereal) = yes) && ($readini(techniques.db, $2, magic) != yes)) {
      $set_chr_name($1) | set %guard.message $readini(translation.dat, status, EtherealBlocked) | set %attack.damage 0 | return
    }
  }

  var %status.type $readini(techniques.db, $2, StatusType)
  if (%status.type != $null) { $inflict_status($1, $3, %status.type, $2) }

  $first_round_dmg_chk($1, $3)
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

  ; If the target is weak to the element, increase the attack power of the base tech
  ; If the target is strong to the element, cut the attack of the tech by half.
  var %tech.element $readini(techniques.db, $2, element)
  if ((%weapon.element != $null) || (%tech.element != none)) {
    var %target.element.weak $readini($char($3), element, weakness)
    var %target.element.strong $readini($char($3), element, strong)

    if ($istok(%target.element.weak,%tech.element,46) = $true) { inc %tech.base $round($calc(%tech.base * 1.5),0)
      var %def.of.monster $readini($char($3), battle, def) | dec %def.of.monster 1 
      if (%def.of.monster < 1) { inc %def.of.monster 1 }
      writeini $char($3) battle def %def.of.monster
    }
    if ($istok(%target.element.strong,%tech.element,46) = $true) { %tech.base = $round($calc(%tech.base / 2), 0) 
      var %str.of.monster $readini($char($3), battle, str) | inc %str.of.monster 1 | writeini $char($3) battle str %str.of.monster
    }
  }

  inc %tech.base %user.tech.level
  inc %base.stat %tech.base

  inc %attack.damage %base.stat

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

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

  ; Is the target using the Guardian style?  If so, we need to decrease the damage done.
  $guardian_style_check($3)

  $defense_down_check($3)

  ; And let's get the final attack damage..
  dec %attack.damage %enemy.defense

  unset %enemy.defense

  $metal_defense_check($3)

  ; In this bot we don't want the attack to ever be lower than 1.  
  if (%attack.damage <= 0) { set %attack.damage 1 }

  $trickster_dodge_check($3, $1)

  if (%guard.message = $null) {
    var %utsusemi.flag $readini($char($3), skills, utsusemi.on)
    if ((%utsusemi.flag = off) || (%utsusemi.flag = $null)) {
      ; does the target have ManaWall on?  If so, reduce the damage to 0.
      if (($readini($char($3), skills, manawall.on) = on) && ($readini(techniques.db, $2, magic) = yes)) { 
        if ($readini(techniques.db, $2, type) = heal) { return }
        writeini $char($3) skills manawall.on off | set %attack.damage 0 | $set_chr_name($3) | set %guard.message $readini(translation.dat, skill, ManaWallBlocked) | return 
      }
    }
    if (%utsusemi.flag = on) {
      if ($readini(techniques.db, $2, type) = heal) { return }
      var %number.of.shadows $readini($char($3), skills, utsusemi.shadows)
      dec %number.of.shadows 1 
      writeini $char($3) skills utsusemi.shadows %number.of.shadows
      if (%number.of.shadows <= 0) { writeini $char($3) skills utsusemi.on off }
      $set_chr_name($3) | set %guard.message $readini(translation.dat, skill, UtsusemiBlocked)  | set %attack.damage 0 | return 
    }
  }

  $first_round_dmg_chk($1, $3)
}

alias calculate_damage_magic {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target

  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  set %magic.bonus.modifier 0.5

  if ($augment.check($1, MagicBonus) = true) { inc %magic.bonus.modifier .3 }

  if (%current.playerstyle = SpellMaster) { inc %magic.bonus.modifier $calc(%current.playerstyle.level * .115)
    if (%magic.bonus.modifier >= 1) { set %magic.bonus.modifier .90 }
  }

  unset %current.playerstyle | unset %current.playerstyle.level

  ; Check for certain skills that will enhance magic.
  ;check to see if skills are on that affect the spells.
  var %clear.mind.check $readini($char($1), skills, ClearMind) 
  if (%clear.mind.check > 0) { 
    var %enhance.value $readini($char($1), skills, ClearMind) * .065
    inc %magic.bonus.modifier %enhance.value
  }

  if ($readini($char($1), skills, elementalseal.on) = on) { 
    var %enhance.value $readini($char($1), skills, ElementalSeal) * .195
    inc %magic.bonus.modifier %enhance.value
  }

  ;  Check for the wizard's amulet accessory
  if ($readini($char($1), equipment, accessory) = wizard's-amulet) {
    var %accessory.amount $readini(items.db, wizard's-amulet, amount)
    inc %magic.bonus.modifier %accessory.amount
  }

  ; Elementals are weak to magic
  if ($readini($char($3), monster, type) = elemental) { inc %magic.bonus.modifier 1.3 } 
  if (%magic.bonus.modifier != 0) { inc %attack.damage $round($calc(%attack.damage * %magic.bonus.modifier),0) }

  ; Is the weather the right condition to enhance the spell?
  $spell.weather.check($1, $3, $2) 

  ; Let's add in the magic status effect
  if ($readini($char($3), skills, manawall.on) != on) {
    $magic.effect.check($1, $3, $2)  
  }

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

  unset %spell.element | unset %element.desc
  set %spell.element $readini(techniques.db, $3, element) | $set_chr_name($2) 
  var %target.element.heal $readini($char($2), element, heal)
  if ($istok(%target.element.heal,%spell.element,46) = $true) { return }

  if (%spell.element = $null) { return } 
  if (%spell.element  = light) { return }
  if (%spell.element  = dark) { return }
  if (%spell.element  = fire) { writeini $char($2) Status burning yes | set %element.desc $readini(translation.dat, element, fire) | return }
  if (%spell.element  = wind) { writeini $char($2) Status tornado yes | set %element.desc $readini(translation.dat, element, wind)  | return }
  if (%spell.element  = water) { writeini $char($2) Status drowning yes | set %element.desc $readini(translation.dat, element, water) | return }
  if (%spell.element  = ice) { writeini $char($2) Status frozen yes | set %element.desc $readini(translation.dat, element, ice) | return }
  if (%spell.element  = lightning) { writeini $char($2) Status shock yes | set %element.desc $readini(translation.dat, element, lightning) | return }
  if (%spell.element  = earth) { writeini $char($2) Status earth-quake yes | set %element.desc $readini(translation.dat, element, earth) | return }
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

  $check_for_battle($1) 
  $amnesia.check($1, ignition) 

  if ((no-ignition isin %battleconditions) || (no-ignitions isin %battleconditions)) { $set_chr_name($1) | query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition) | halt }
  if ($readini($char($1), status, virus) = yes) { query %battlechan $readini(translation.dat, errors, Can'tBoostHasVirus) | halt }


}
