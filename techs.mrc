;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TECHS COMMAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON 2:ACTION:goes *:#:{ 
  if ($3 != $null) { halt }
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  $set_chr_name($nick) | $tech_cmd($nick , $2, $nick) | halt
} 
ON 2:ACTION:uses * * on *:#:{ 
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  $set_chr_name($nick) | $tech_cmd($nick , $3 , $5, $7) | halt 
} 
ON 50:TEXT:*uses * * on *:*:{ 
  if ($1 = uses) { halt }
  if ($5 != on) { halt }
  else { $set_chr_name($1) | $tech_cmd($1, $4, $6) | halt }
}

alias tech_cmd {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target

  ; Make sure some old attack variables are cleared.
  unset %attack.damage | unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %drainsamba.on | unset %absorb
  unset %element.desc | unset %spell.element | unset %real.name  |   unset %user.flag | unset %target.flag

  $check_for_battle($1) 

  set %tech.type $readini(techniques.db, $2, Type) | $amnesia.check($1, tech) 
  if ($readini($char($1), techniques, $2) = $null) { $set_chr_name($1) | query %battlechan 4 $+ %real.name does not know how to perform the $2 $+ ! | halt }

  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | query %battlechan 4 $+ %real.name cannot attack while unconcious! | unset %real.name | halt }
  if ($readini($char($3), Battle, Status) = dead) { $set_chr_name($1) | query %battlechan 4 $+ %real.name cannot attack someone who is dead! | unset %real.name | halt }
  if ($readini($char($3), Battle, Status) = RunAway) { $set_chr_name($1) | query %battlechan 4 $+ %real.name cannot attack $set_chr_name($3) %real.name $+ , because %real.name has run away from the fight! | unset %real.name | halt } 

  $person_in_battle($3) | $checkchar($3) 

  ; Get the weapon equipped
  $weapon_equipped($1)

  if ($2 !isin $readini(weapons.db,%weapon.equipped,Abilities)) { $set_chr_name($1) | query %battlechan 4 $+ %real.name cannot perform that technique using $gender($1) %weapon.equipped | halt }

  ; Make sure the user has enough TP to use this in battle..
  set %tp.needed $readini(techniques.db, $2, TP) | set %tp.have $readini($char($1), battle, tp)

  ; Check for ConserveTP
  if ($readini($char($1), skills, conservetp.on) = on) { set %tp.needed 0 | writeini $char($1) skills conserveTP.on off }

  if (%tp.needed = $null) { $set_chr_name($1) | query %battlechan 4 $+ %real.name does not know the $2 technique! | halt }
  if (%tp.needed > %tp.have) { $set_chr_name($1) | query %battlechan  4 $+ %real.name does not have enough TP to perform this technique! | halt }

  if (($3 = $1) && ($is_charmed($1) = false))  { 
    if (%tech.type !isin boost.finalgetsuga.heal.heal-AOE) { $set_chr_name($1) | query %battlechan 4 $+ %real.name cannot attack $gender2($1) $+ self with $2 $+ ! | unset %real.name | halt  }
  }

  dec %tp.have %tp.needed | writeini $char($1) battle tp %tp.have | unset %tp.have | unset %tp.needed

  if (%tech.type = boost) { $tech.boost($1, $2, $3) } 
  if (%tech.type = finalgetsuga) { $tech.finalgetsuga($1, $2, $3) } 

  var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($3), info, flag)

  if ($is_charmed($1) = true) { set %user.flag monster }
  if (%tech.type = heal) { set %user.flag monster }
  if (%tech.type = heal-aoe) { set %user.flag monster }

  if ((%user.flag != monster) && (%target.flag != monster)) { $set_chr_name($1) | query %battlechan 4 $+ %real.name can only attack monsters! | halt }

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

  if (%tech.type = status) { $tech.status($1, $2, $3) } 

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
  if (%battleis = on)  {  /.timerCheckForDoubleTurnWait 1 1 /check_for_double_turn $1 }
}


alias tech.single {
  ; $3 = target

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

  ; If the target is weak to the element, increase the attack power of the base tech
  ; If the target is strong to the element, cut the attack of the tech by half.
  var %tech.element $readini(techniques.db, $2, element)
  if ((%weapon.element != $null) || (%tech.element != none)) {
    var %target.element.weak $readini($char($3), element, weakness)
    var %target.element.strong $readini($char($3), element, strong)

    if (%tech.element isin %target.element.weak) { inc %tech.base $round($calc(%tech.base * 1.2),0)
      var %def.of.monster $readini($char($3), battle, def) | dec %def.of.monster 1 

      if (%def.of.monster < 1) { inc %def.of.monster 1 }
      writeini $char($3) battle def %def.of.monster
    }
    if (%tech.element isin %target.element.strong) { %tech.base = $round($calc(%tech.base / 2), 0) 
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
  $set_chr_name($1) | query %battlechan 3 $+ %real.name has stolen and absorbs %amount.of.str strength, %amount.of.def defense, %amount.of.int intelligence and %amount.of.spd speed from $set_chr_name($3) %real.name $+ !

  return
}

alias tech.suicide {
  $set_chr_name($1)
  query %battlechan 4 $+ %real.name uses all of $gender($1) health to perform this technique!

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

  ;If the target is a zombie, do damage instead of healing it.
  if ($readini($char($3), status, zombie) = yes) { 
    $deal_damage($1, $3, $2)
    $display_damage($1, $3, tech, $2)
    return
  } 

  ; If the target is a zombie, do damage instead of healing
  if ($readini($char($3), monster, type) = undead) { 
    $deal_damage($1, $3, $2)
    $display_damage($1, $3, tech, $2)
    return
  } 

  else {   
    $heal_damage($1, $3, $2)
    $display_heal($1, $3, tech, $2)
  }

  return
}

alias tech.aoeheal {
  ; $1 = user
  ; $2 = tech
  ; $3 = target

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
    if ($readini($char(%who.battle), status, zombie) = yes) { 
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

  unset %who.battle | set %number.of.hits 0

  $set_chr_name($1)
  query %battlechan 4 $+ %real.name uses all of $gender($1) health to perform this technique!

  ; Display the tech description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name
  query %battlechan 3 $+ %user  $+ $readini(techniques.db, $2, desc)

  ; If it's player, search out remaining players that are alive and deal damage and display damage
  if ($4 = player) {
    var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line battle.txt
      if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }

      else { 
        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
        else { 
          inc %number.of.hits 1
          $calculate_damage_suicide($1, $2, %who.battle)
          $deal_damage($1, %who.battle, $2)
          $display_aoedamage($1, %who.battle, $2)
          inc %battletxt.current.line 1 
        } 
      }
    }
  }


  ; If it's monster, search out remaining monsters that are alive and deal damage and display damage.
  if ($4 = monster) { 
    var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
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
          inc %battletxt.current.line 1 
        } 
      }
    }
  }

  set %timer.time $calc(%number.of.hits * 1) 

  writeini $char($1) battle hp 0 | writeini $char($1) battle status dead | $set_chr_name($1)

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
    $set_chr_name($1) | query %battlechan 4 $+ %real.name is already powered up and cannot do so again until next round. 
    if ($readini($char($1), info, flag) = monster) { $check_for_double_turn($1) | halt }
    else { halt }
  }

  ; Get the battle stats
  var %str $readini($char($1), Battle, Str)
  var %def $readini($char($1), Battle, Def)
  var %int $readini($char($1), Battle, Int)
  var %spd $readini($char($1), Battle, Spd)

  var %boost.base.amount $readini(techniques.db, $2, BasePower)
  var %player.level.amount $round($calc($readini($char($1), techniques, $2) * .5),0)

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
    $set_chr_name($1) | query %battlechan 4 $+ %real.name has already used this technique and cannot do so again. 
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

alias tech.status {
  ; $1 = user
  ; $2 = tech
  ; $3 = target
  var %tech.status.type $readini(techniques.db, $2, StatusType) 

  if (%tech.status.type = random) { 
    var %random.status.type $rand(1,8)
    if (%random.status.type = 1) { set %tech.status.type poison | var %tech.status.grammar poisoned }
    if (%random.status.type = 2) { set %tech.status.type stop | var %tech.status.grammar frozen in time }
    if (%random.status.type = 3) { set %tech.status.type silence | var %tech.status.grammar silenced }
    if (%random.status.type = 4) { set %tech.status.type blind | var %tech.status.grammar blinded }
    if (%random.status.type = 5) { set %tech.status.type virus | var %tech.status.grammar inflicted with a virus }
    if (%random.status.type = 6) { set %tech.status.type amnesia | var %tech.status.grammar inflicted with amnesia }
    if (%random.status.type = 7) { set %tech.status.type paralysis | var %tech.status.grammar paralyzed }
    if (%random.status.type = 8) { set %tech.status.type zombie | var %tech.status.grammar a zombie }
    if (%random.status.type = 9) { set %tech.status.type slow | var %tech.status.grammar slowed }
    if (%random.status.type = 10) { set %tech.status.type stun | var %tech.status.grammar stunned }
  }

  if (%tech.status.type = stop) { var %tech.status.grammar frozen in time }
  if (%tech.status.type = poison) { var %tech.status.grammar poisoned }
  if (%tech.status.type = silence) { var %tech.status.grammar silenced }
  if (%tech.status.type = blind) { var %tech.status.grammar blind }
  if (%tech.status.type = virus) { var %tech.status.grammar inflicted with a virus }
  if (%tech.status.type = amnesia) { var %tech.status.grammar inflicted with amnesia }
  if (%tech.status.type = paralysis) { var %tech.status.grammar paralyzed }
  if (%tech.status.type = zombie) { var %tech.status.grammar a zombie }
  if (%tech.status.type = slow) { var %tech.status.grammar slowed }
  if (%tech.status.type = stun) { var %tech.status.grammar stunned }
  if (%tech.status.type = curse) { var %tech.status.grammar cursed }
  if (%tech.status.type = charm) { var %tech.status.grammar charmed }

  var %chance $rand(1,100) | $set_chr_name($1) 
  if ($readini($char($3), skills, utsusemi.on) = on) { set %chance 0 } 

  $calculate_damage_techs($1, $2, $3)
  $deal_damage($1, $3, $2)

  ; Check for resistance to that status type.

  set %resist.have resist- $+ %tech.status.type
  set %resist.skill $readini($char($3), skills, %resist.have)

  if (%tech.status.type = charm) {
    if ($readini($char($3), status, zombie) != no) { set %resist.skill 100 }
    if ($readini($char($3), monster, type) = undead) { set %resist.skill 100 }
  }

  if ((%resist.skill <= 100) || (%resist.skill = $null)) {
    if ((%resist.skill != $null) && (%resist.skill > 0)) { dec %chance %resist.skill }
  }

  if (%chance >= 50) {
    if ((%chance = 50) && (%tech.status.type = poison)) { $set_chr_name($3) | set %statusmessage.display 4 $+ %real.name is now %tech.status.grammar $+ !  | writeini $char($3) Status poison-heavy yes }
    if ((%chance = 50) && (%tech.status.type != poison)) { $set_chr_name($3) | set %statusmessage.display 4 $+ %real.name is now %tech.status.grammar $+ !  | writeini $char($3) Status %tech.status.type yes }
    else { $set_chr_name($3) | set %statusmessage.display 4 $+ %real.name is now %tech.status.grammar $+ !  | writeini $char($3) Status %tech.status.type yes 
      if (%tech.status.type = charm) { writeini $char($3) status charmed yes | writeini $char($3) status charmer $1 | writeini $char($3) status charm.timer $rand(2,3) }
      if (%tech.status.type = curse) { writeini $char($3) battle tp 0 }
    }
  }
  else {
    if (%resist.skill >= 100) { $set_chr_name($3) | set %statusmessage.display 4 $+ %real.name is immune to the %tech.status.type status! }
    if ((%resist.skill  >= 1) && (%resist.skill < 100)) { $set_chr_name($3) | set %statusmessage.display 4 $+ %real.name has resisted $set_chr_name($1) %real.name $+ 's $lower(%tech.status.type) status effect! }
    if ((%resist.skill <= 0) || (%resist.skill = $null)) {  $set_chr_name($1) | set %statusmessage.display 4 $+ %real.name $+ 's $lower(%tech.status.type) status effect has failed against $set_chr_name($3) %real.name $+ ! }
  }

  ; If a monster, increase the resistance.
  if ($readini($char($3), info, flag) = monster) {
    if (%resist.skill = $null) { set %resist.skill 2 }
    else { inc %resist.skill 2 }
    writeini $char($3) skills %resist.have %resist.skill
  }
  unset %resist.have | unset %chance

  $display_Statusdamage($1, $3, tech, $2) 
  return
}

alias tech.aoe {
  ; $1 = user
  ; $2 = tech
  ; $3 = target
  ; $4 = type, either player or monster 

  unset %who.battle | set %number.of.hits 0
  unset %absorb  | unset %element.desc

  ; Display the tech description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name
  query %battlechan 3 $+ %user  $+ $readini(techniques.db, $2, desc)
  if ($readini(techniques.db, $2, absorb) = yes) { set %absorb absorb }

  ; If it's player, search out remaining players that are alive and deal damage and display damage
  if ($4 = player) {
    var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line battle.txt
      if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }

      else { 
        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
        else { 
          inc %number.of.hits 1
          $calculate_damage_techs($1, $2, %who.battle)
          $deal_damage($1, %who.battle, $2, %absorb)
          $display_aoedamage($1, %who.battle, $2, %absorb)
          inc %battletxt.current.line 1 
        } 
      }
    }
  }


  ; If it's monster, search out remaining monsters that are alive and deal damage and display damage.
  if ($4 = monster) { 
    var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line battle.txt
      if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
      else { 
        inc %number.of.hits 1
        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
        else { 
          $calculate_damage_techs($1, $2, %who.battle)
          $deal_damage($1, %who.battle, $2, %absorb)
          $display_aoedamage($1, %who.battle, $2, %absorb)
          inc %battletxt.current.line 1 
        } 
      }
    }
  }

  unset %element.desc
  set %timer.time $calc(%number.of.hits * 1.5) 
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
  query %battlechan The attack did4 $bytes(%attack.damage,b) damage to %enemy $+ ! %element.desc  $+ %style.rating

  if ($4 = absorb) { 
    ; Show how much the person absorbed back.
    var %absorb.amount $round($calc(%attack.damage / 2),0)
    query %battlechan 3 $+ %user absorbs $bytes(%absorb.amount,b) HP back from the damage.
  }

  unset %attack.damage
  ; Did the person die?  If so, show the death message.
  if ($readini($char($2), battle, HP) <= 0) { 
    writeini $char($2) battle status dead 
    writeini $char($2) battle hp 0
    $check.clone.death($2)
    $increase_death_tally($2)
    if (%attack.damage > $readini($char($2), basestats, hp)) { set %overkill 7<<OVERKILL>> }
    query %battlechan 4 $+ %enemy has been defeated by %user $+ !  %overkill
    if ($readini($char($1), info, flag) != monster) {
      if (%battle.type = monster) {  $add.stylepoints($1, $2, mon_death, $3) | $add.style.orbbonus($1, monster) }
      if (%battle.type = boss) { $add.stylepoints($1, $2, boss_death, $3) | $add.style.orbbonus($1, boss) }
    }
  }
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

  var %tech.base $readini(techniques.db, $2, BasePower)
  var %user.tech.level $readini($char($1), Techniques, $2)

  inc %tech.base $round($calc(%user.tech.level * 1.5),0)

  ; Let's add in the base power of the weapon used..
  var %base.power.wpn $readini(weapons.db, $readini($char($1),weapons,equipped), basepower)
  if (%base.power.wpn = $null) { var %base.power 1 }

  var %weapon.base $readini($char($1), weapons, $2)
  inc %base.power.wpn $round($calc(%weapon.base * 1.5),0)


  ; Does the user have a mastery in the weapon?  We can add a bonus as well.
  $mastery_check($1, $readini($char($1),weapons,equipped))

  inc %base.power.wpn %mastery.bonus

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

  ; If the target is weak to the element, increase the attack power of the base tech
  ; If the target is strong to the element, cut the attack of the tech by half.
  var %tech.element $readini(techniques.db, $2, element)
  if ((%weapon.element != $null) || (%tech.element != none)) {
    var %target.element.weak $readini($char($3), element, weakness)
    var %target.element.strong $readini($char($3), element, strong)

    if (%tech.element isin %target.element.weak) { inc %tech.base $round($calc(%tech.base * 1.2),0)
      var %def.of.monster $readini($char($3), battle, def) | dec %def.of.monster 1 

      if (%def.of.monster < 1) { inc %def.of.monster 1 }
      writeini $char($3) battle def %def.of.monster
    }
    if (%tech.element isin %target.element.strong) { %tech.base = $round($calc(%tech.base / 2), 0) 
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

  if ($readini(techniques.db, $2, type) != heal) {
    ; Now we're ready to calculate the enemy's defense..  
    var %enemy.defense $readini($char($3), battle, def)

    ; Because it's a tech, the enemy's int will play a small part too.
    var %int.bonus $round($calc($readini($char($3), battle, int) / 2),0)
    inc  %enemy.defense %int.bonus

    set %current.playerstyle $readini($char($3), styles, equipped)
    set %current.playerstyle.level $readini($char($3), styles, %current.playerstyle)
    ; Is the target using the Guardian style?  If so, we need to decrease the damage done.
    if (%current.playerstyle = Guardian) { 
      var %block.value $calc(%current.playerstyle.level / 15.5)
      if (%block.value > .60) { var %block.value .60 }
      var %amount.to.block $round($calc(%attack.damage * %block.value),0)
      dec %attack.damage %amount.to.block
    }

    ; And let's get the final attack damage..
    dec %attack.damage %enemy.defense
  }

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances..
  if (%attack.damage <= 0) { set %attack.damage 1 }


  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  set %current.weapon.used $readini($char($1), weapons, equipped)
  if ($readini(weapons.db, %current.weapon.used, cost) = 0) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %attack.damage 0 }
  }
  unset %current.weapon.used

  unset %base.stat.needed | unset %base.stat


  if ($readini($char($3), skills, utsusemi.on) = off) {
    ; does the target have ManaWall on?  If so, reduce the damage to 0.
    if (($readini($char($3), skills, manawall.on) = on) && ($readini(techniques.db, $2, magic) = yes)) { 
      if ($readini(techniques.db, $2, type) = heal) { return }
      writeini $char($3) skills manawall.on off | set %attack.damage 0 | $set_chr_name($3) | query %battlechan 7 $+ %real.name $+ 's Mana Wall has absorbed the spell! | return 
    }
  }
  if ($readini($char($3), skills, utsusemi.on) = on) {
    if ($readini(techniques.db, $2, type) = heal) { return }
    var %number.of.shadows $readini($char($3), skills, utsusemi.shadows)
    dec %number.of.shadows 1 
    writeini $char($3) skills utsusemi.shadows %number.of.shadows
    if (%number.of.shadows <= 0) { writeini $char($3) skills utsusemi.on off }
    $set_chr_name($3) | query %battlechan 7One of %real.name $+ 's shadows absorbs the attack and disappears! | set %attack.damage 0 | return 
  }
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

    if (%tech.element isin %target.element.weak) {  inc %tech.base $round($calc(%tech.base * 1.5),0)
      var %def.of.monster $readini($char($3), battle, def) | dec %def.of.monster 1 
      if (%def.of.monster < 1) { inc %def.of.monster 1 }
      writeini $char($3) battle def %def.of.monster
    }
    if (%tech.element isin %target.element.strong) { %tech.base = $round($calc(%tech.base / 2), 0) 
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
    if (%attack.damage >= 1000) { set %attack.damage 500 }
  }


  ; Now we're ready to calculate the enemy's defense..  
  var %enemy.defense $readini($char($3), battle, def)

  ; Because it's a tech, the enemy's int will play a small part too.
  var %int.bonus $round($calc($readini($char($3), battle, int) / 2),0)
  inc  %enemy.defense %int.bonus

  ; Is the target using the Guardian style?  If so, we need to decrease the damage done.
  set %current.playerstyle $readini($char($3), styles, equipped)
  set %current.playerstyle.level $readini($char($3), styles, %current.playerstyle)
  if (%current.playerstyle = Guardian) { 
    var %block.value $calc(%current.playerstyle.level / 15.5)
    if (%block.value > .60) { var %block.value .60 }
    var %amount.to.block $round($calc(%attack.damage * %block.value),0)
    dec %attack.damage %amount.to.block
  }

  ; And let's get the final attack damage..
  dec %attack.damage %enemy.defense

  ; In this bot we don't want the attack to ever be lower than 1.  
  if (%attack.damage <= 0) { set %attack.damage 1 }
}


alias display_Statusdamage {
  unset %overkill
  unset %style.rating
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  query %battlechan 3 $+ %user $+  $readini(techniques.db, $4, desc)

  ; Show the damage
  $calculate.stylepoints($1)
  query %battlechan The attack did4 $bytes(%attack.damage,b) damage %style.rating

  ; Did the person die?  If so, show the death message.
  if ($readini($char($2), battle, HP) <= 0) { 
    writeini $char($2) battle status dead 
    writeini $char($2) battle hp 0
    $check.clone.death($2)
    $increase_death_tally($2)
    if (%attack.damage > $readini($char($2), basestats, hp)) { set %overkill 7<<OVERKILL>> }
    query %battlechan 4 $+ %enemy has been defeated by %user $+ !  %overkill
    if ($readini($char($1), info, flag) != monster) {
      if (%battle.type = monster) {  $add.stylepoints($1, $2, mon_death, $3) | $add.style.orbbonus($1, monster) }
      if (%battle.type = boss) { $add.stylepoints($1, $2, boss_death, $3) | $add.style.orbbonus($1, boss) }
    }
  }

  ; If the person isn't dead, display the status message.
  if ($readini($char($2), battle, hp) >= 1) {  
    var %utsusemi.check $readini($char($2), skills, utsusemi.on)
    if (%utsusemi.check != on) { query %battlechan %statusmessage.display } 
  }
  unset %statusmessage.display
  return 
}


alias calculate_damage_magic {
  ; $1 = user
  ; $2 = technique used
  ; $3 = target


  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  set %magic.bonus.modifier 0

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
    writeini $char($1) skills elementalseal.on off 
    var %enhance.value $readini($char($1), skills, ElementalSeal) * .110
    inc %magic.bonus.modifier %enhance.value
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

  unset %spell.element | unset %element.desc
  set %spell.element $readini(techniques.db, $3, element) | $set_chr_name($2) 

  if (%spell.element = $null) { return } 
  if (%spell.element  = light) { return }
  if (%spell.element  = dark) { return }
  if (%spell.element  = fire) { writeini $char($2) Status burning yes | set %element.desc 4Flames encase around %real.name $+ 's body! | return }
  if (%spell.element  = wind) { writeini $char($2) Status tornado yes | set %element.desc 4A mini tornado encases around %real.name $+ 's body causing cuts! | return }
  if (%spell.element  = water) { writeini $char($2) Status drowning yes | set %element.desc 4Water encases around %real.name $+ 's body preventing breathing! | return }
  if (%spell.element  = ice) { writeini $char($2) Status frozen yes | set %element.desc 4Ice crystals begin to form on %real.name $+ 's body! | return }
  if (%spell.element  = lightning) { writeini $char($2) Status shock yes | set %element.desc 4Lightning bolts shoot into %real.name causing shock! | return }
  if (%spell.element  = earth) { writeini $char($2) Status earth-quake yes | set %element.desc 4The ground begins to shake under %real.name $+ !  | return }
}
