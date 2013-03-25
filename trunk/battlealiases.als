;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if it's a
; person's turn or not.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_for_battle { 
  if (%wait.your.turn = on) { $display.system.message($readini(translation.dat, errors, WaitYourTurn), private) | halt }
  if ((%battleis = on) && (%who = $1)) { return }
  if ((%battleis = on) && (%who != $1)) { $display.system.message($readini(translation.dat, errors, WaitYourTurn), private) | halt }
  else { return  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if someone
; is in the battle or not.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
person_in_battle {
  set %temp.battle.list $readini(battle2.txt, Battle, List)
  if ($istok(%temp.battle.list,$1,46) = $false) {  unset %temp.battle.list | $set_chr_name($1) 
    if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, errors, NotInbattle) }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($nick, $readini(translation.dat, errors, NotInbattle)) }
    unset %real.name | halt 
  }
  else { return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; These two functions are for
; Checking for Double Turns
; And randomly giving one
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_for_double_turn {  $set_chr_name($1)
  set %debug.location alias check_for_double_turn
  unset %wait.your.turn
  $random.doubleturn.chance($1)

  if ($readini($char($1), skills, doubleturn.on) = on) { 

    $battle.check.for.end

    if ($readini($char($1), battle, hp) <= 0) { $next | halt }

    $checkchar($1) | writeini $char($1) skills doubleturn.on off | $set_chr_name($1) 

    if ($readini(system.dat, system, botType) = IRC) {  /.timerDoubleTurn $+ $rand(1,1000) 1 1 /query %battlechan 12 $+ %real.name gets another turn. }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(12 $+ %real.name gets another turn.) }

    $aicheck($1) | halt 
  }

  else { $next | halt }
}

random.doubleturn.chance {
  set %debug.location alias doubleturn.chance
  if (%battleis = off) { return }
  if ($1 = demon_portal) { return }
  if ($1 = !use) { return }
  if (%multiple.wave.noaction = yes) { unset %multiple.wave.noaction | return }
  if ($readini($char($1), battle, hp) <= 0) { return }
  if ($readini($char($1), Status, cocoon) = yes) { return }

  $battle.check.for.end

  if ($readini($char($1), skills, doubleturn.on) != on) {
    var %double.turn.chance $rand(1,100)
    if ($augment.check($1, EnhanceDoubleTurnChance) = true) {  inc %double.turn.chance $calc(2 * %augment.strength) }

    if (%double.turn.chance >= 99) { writeini $char($1) skills doubleturn.on on | $set_chr_name($1) 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, system, RandomChanceGoesAgain) }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, system, RandomChanceGoesAgain)) }
    }
  }
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function boosts
; summons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
boost_summon_stats {
  set %debug.location alias boost_summon_stats
  ; $1 = person who used the summon
  ; $2 = bloodpact level
  ; $3 = original summon name

  var %summon.level 1
  inc %summon.level $2

  if ($augment.check($1, EnhanceSummons) = true) {  inc %summon.level $calc(%augment.strength * 10)    } 

  var %m.flag $readini($char($1), info, flag)

  if ((%m.flag = monster) || (%m.flag = npc)) { inc %summon.level $round($calc($get.level($1) / 2),0) }
  if (%m.flag = $null) { inc %summon.level $round($calc($get.level($1) / 1.5),0) }

  $monster_spend_points($1 $+ _summon, %summon.level, bloodpact, $3)
  $monster_boost_hp($1 $+ _summon, bloodpact, %summon.level, $3)

  var %tp $readini($char($1 $+ _summon), BaseStats, TP)
  inc %tp $round($calc(%tp * %summon.level),0) 
  writeini $char($1 $+ _summon) BaseStats TP %tp

  $fulls($1 $+ _summon)

  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function boosts
; monsters and npcs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
boost_monster_stats {
  set %debug.location alias boost_monster_stats
  ; $1 = monster
  ; $2 = type (rage, warmachine, demonwall, etc)

  if ($readini($char($1), info, BattleStats) = ignore) { return }

  var %hp $readini($char($1), BaseStats, HP)
  var %tp $readini($char($1), BaseStats, TP)
  var %str $readini($char($1), BaseStats, Str)
  var %def $readini($char($1), BaseStats, Def)
  var %int $readini($char($1), BaseStats, Int)
  var %spd $readini($char($1), BaseStats, Spd)

  var %winning.streak $readini(battlestats.dat, battle, winningstreak)
  var %level.boost $readini(battlestats.dat, battle, LevelAdjust)
  var %number.of.players.in.battle $readini(battle2.txt, battleinfo, players)
  var %difficulty $readini(battle2.txt, BattleInfo, Difficulty)
  var %current.player.levels $readini(battle2.txt, battleinfo, playerlevels)  
  var %monster.level 0

  var %boss.level $readini($char($1), info, bosslevel) 
  if (%boss.level != $null) { var %monster.level %boss.level }

  if (%number.of.players.in.battle = $null) { var %number.of.players.in.battle 1 }

  if (%winning.streak <= 0) { var %winning.streak $calc($readini(battlestats.dat, battle, losingstreak) * -1) }

  inc %monster.level %level.boost
  inc %monster.level %difficulty

  if (%monster.level <= 0) { var %monster.level 1 }

  if ($2 = warmachine) { 
    var %boss.level $readini($char($1), info, bosslevel) 
    if (%boss.level = $null) { var %boss.level %winning.streak }
    if (%winning.streak < %boss.level) { var %winning.streak %boss.level }
  }

  if ($2 = elderdragon) { 
    var %boss.level $readini($char($1), info, bosslevel) 
    if (%boss.level = $null) { var %boss.level %winning.streak }
    if (%winning.streak < %boss.level) { var %winning.streak %boss.level }
  }

  inc %monster.level %winning.streak

  ; $2 = portal is for the portal item boss fights.
  if ($2 = portal) { 
    var %boss.level $readini($char($1), info, bosslevel) 

    if (%boss.level = $null) { var %boss.level 500 }

    inc %boss.level $rand(0,3)
    var %monster.level %boss.level
  }

  ; $2 = monstersummon is for the monster summon special skill
  if ($2 = monstersummon) { 
    var %temp.level $get.level($3)
    var %monster.level $round($calc(%temp.level / 2),0)

    if (%monster.level <= 1) { var %monster.level 2 }
  }

  if (%mode.gauntlet.wave != $null) {  inc %monster.level %mode.gauntlet.wave | inc %winning.streak %mode.gauntlet.wave }

  if ($readini($char($1), info, BattleStats) = hp) {  $monster_boost_hp($1, $2, %monster.level) |  return }
  if ($1 = demon_portal) { $monster_boost_hp($1, $2, %monster.level) |  return }
  if ($1 = orb_fountain) { $monster_boost_hp($1, $2, %winning.streak) |  return }

  if ($2 = evolve) { 
    if ($isfile($boss($1)) = $false) { inc %monster.level $rand(5,10) }
    if ($isfile($boss($1)) = $true) { inc %monster.level $rand(10,20)  }
  }

  if ($2 = rage) { %monster.level = $calc(%monster.level * 10) }

  $monster_spend_points($1, %monster.level, $2) 
  $monster_boost_hp($1, $2, %monster.level)

  if ($2 != doppelganger) { 
    %tp = $round($calc(%tp + (%monster.level * 50)),0) 
    writeini $char($1) BaseStats TP %tp
  }

  if (($2 != doppelganger) && ($readini($char($1), info, IgnoreWeaponBoost) != true)) {
    ; Set the weapon's power based on the streak if it's higher than the monster's current weapon level
    set %current.monster.weapon $readini($char($1), weapons, equipped)
    set %current.monster.weapon.level $readini($char($1), weapons, %current.monster.weapon)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Formula 1
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ($readini(system.dat, system, BattleDamageFormula) = 1) { 
      if (%current.monster.weapon.level < %winning.streak) { set %current.monster.weapon.level $round($calc(%winning.streak / 2),0) | writeini $char($1) weapons %current.monster.weapon %current.monster.weapon.level }
    }
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Formula 2
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ($readini(system.dat, system, BattleDamageFormula) = 2) { 
      if (%current.monster.weapon.level < %winning.streak) { set %current.monster.weapon.level.temp $round($calc(%winning.streak / 5),0) 
        if (%current.monster.weapon.level.temp < %current.monster.weapon.level) { writeini $char($1) weapons %current.monster.weapon %current.monster.weapon.level }
        else { writeini $char($1) weapons %current.monster.weapon %current.monster.weapon.level.temp }
      }
    }


  }
  unset %increase.amount | unset %current.monster.weapon | unset %current.monster.weapon.level
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function is for boosting
; monster's/npcs's total hp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
monster_boost_hp {
  ; $1 = monster
  ; $2 = same as in the boost mon alias
  ; $3 = monster level
  ; $4 = used for summons (original summon's name)

  if ($readini($char($1), info, BattleStats) = ignoreHP) { return }

  set %hp $readini($char($1), BaseStats, HP)
  var %increase.amount 0

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; FORMULA 1
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if ($readini(system.dat, system, BattleDamageFormula) = 1) { 

    if ($2 = doppelganger) {  var %increase.amount $calc($3 * 2) }
    if ($2 = warmachine) {  var %increase.amount $calc($3 * 5) }
    if ($2 = demonwall) {  var %increase.amount $calc($3 * 3) }
    if ($2 = evolve) { var %increase.amount $calc($3 * 2) }
    if ($2 = bloodpact) { var %increase.amount $calc($3 * 15) }
    if ($2 = elderdragon) {  var %increase.amount $calc($3 * 15) }

    if (($2 = $null) || ($2 = monstersummon)) { 
      if ($isfile($boss($1)) = $true) {
        if ($3 <= 100) {  var %increase.amount $calc($3 * 30) }
        if (($3 > 100) && ($3 <= 300)) {  var %increase.amount $calc($3 * 35) }
        if (($3 > 300) && ($3 <= 600)) { var %increase.amount $calc($3 * 40) }
        if ($3 > 600) { var %increase.amount $calc($3 * 45) }

      }
      if ($isfile($boss($1)) = $false) {
        if ($3 <= 100) {  var %increase.amount $calc($3 * 10) }
        if (($3 > 100) && ($3 <= 300)) {  var %increase.amount $calc($3 * 15) }
        if (($3 > 300) && ($3 <= 600)) { var %increase.amount $calc($3 * 20) }
        if ($3 > 600) { var %increase.amount $calc($3 * 25) }
      }
      if ($isfile($npc($1)) = $true) {  var %increase.amount $calc($3 * 15) }
      if ($isfile($summon($4)) = $true) {   var %increase.amount $calc($3 * 15) }
    }


    if (%increase.amount = 0) { inc %increase.amount $rand(1,10) }

    %hp = $round($calc(%hp + %increase.amount),0)

    if (%hp > 100000) { %hp = 100000 }
    if (%hp <= 0) { %hp = 10 }

    if ($2 = portal) {
      var %boss.level $readini($char($1), info, bosslevel) 
      if (%boss.level = $null) { var %boss.level 500 }

      if (%boss.level <= 10) { inc %hp $rand(1000,2000) }
      if ((%boss.level > 10) && (%boss.level <= 50)) { inc %hp $rand(2500,5000) }
      if ((%boss.level > 50) && (%boss.level <= 100))  { inc %hp 10000 }
      if ((%boss.level > 100) && (%boss.level <= 200)) { inc %hp 15000 }
      if ((%boss.level > 200) && (%boss.level <= 500)) { inc %hp 40000 }
      if ((%boss.level > 500) && (%boss.level <= 800)) { inc %hp 50000 }
      if ((%boss.level > 800) && (%boss.level < 1000)) { inc %hp 80000 }
      if (%boss.level > 1000) { inc %hp 100000 }
    }

    %hp = $round($calc(%hp + %increase.amount),0)
  }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; FORMULA 2
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if ($readini(system.dat, system, BattleDamageFormula) = 2) { 

    if ($2 = doppelganger) {  var %increase.amount $calc($3 * 1.5) }
    if ($2 = warmachine) {  var %increase.amount $calc($3 * 2) }
    if ($2 = elderdragon) {  var %increase.amount $calc($3 * 3) }
    if ($2 = demonwall) {  var %increase.amount $calc($3 * 2) }
    if ($2 = evolve) { var %increase.amount $calc($3 * 1.5) }
    if ($2 = monstersummon) { var %increase.amount $calc($3 * 1.5) }

    if (($2 = $null) || ($2 = monstersummon)) { 
      if ($isfile($boss($1)) = $true) {
        if ($3 <= 100) {  var %increase.amount $calc($3 * 15) }
        if (($3 > 100) && ($3 <= 300)) {  var %increase.amount $calc($3 * 18) }
        if (($3 > 300) && ($3 <= 600)) { var %increase.amount $calc($3 * 19) }
        if ($3 > 600) { var %increase.amount $calc($3 * 20) }

        %hp = $round($calc(%hp + %increase.amount),0)

        ; Check for max HP
        if (%hp > 10000) { %hp = $rand(9999,10100) }
        if (%hp <= 0) { %hp = 10 }
      }

      if ($isfile($boss($1)) = $false) {
        if ($3 <= 100) {  var %increase.amount $calc($3 * 3) }
        if (($3 > 100) && ($3 <= 300)) {  var %increase.amount $calc($3 * 4) }
        if (($3 > 300) && ($3 <= 600)) { var %increase.amount $calc($3 * 5) }
        if ($3 > 600) { var %increase.amount $calc($3 * 6) }
        if (%increase.amount = 0) { inc %increase.amount $rand(1,10) }

        %hp = $round($calc(%hp + %increase.amount),0)

        ; Check for max HP
        if (%hp > 5000) { %hp = $rand(4800,5100) }
        if (%hp <= 0) { %hp = 10 }
      }
      if ($isfile($npc($1)) = $true) {  
        var %increase.amount $calc($3 * 5)
        %hp = $round($calc(%hp + %increase.amount),0)

        ; Check for max HP
        if (%hp > 10000) { %hp = 10000 }
        if (%hp <= 0) { %hp = 10 }
        %hp = $round($calc(%hp + %increase.amount),0)

      }
      if ($isfile($summon($4)) = $true) {   

        var %increase.amount $calc($3 * 3)
        %hp = $round($calc(%hp + %increase.amount),0)

        ; Check for max HP
        if (%hp > 8000) { %hp = 8000 }
        if (%hp <= 0) { %hp = 10 }
      }

    }

    if ($2 = bloodpact) { var %increase.amount $calc($3 * 5) 
      if (%increase.amount = 0) { inc %increase.amount $rand(1,10) }

      %hp = $round($calc(%hp + %increase.amount),0) 

      if (%hp > 8000) { %hp = 8000 }
      if (%hp <= 0) { %hp = 10 }
    }

    if ($2 = portal) {
      var %boss.level $readini($char($1), info, bosslevel) 
      if (%boss.level = $null) { var %boss.level 500 }

      if (%boss.level <= 10) { inc %hp $rand(300,400) }
      if ((%boss.level > 10) && (%boss.level <= 50)) { inc %hp $rand(500,800) }
      if ((%boss.level > 50) && (%boss.level <= 100))  { inc %hp 1000 }
      if ((%boss.level > 100) && (%boss.level <= 200)) { inc %hp 1200 }
      if ((%boss.level > 200) && (%boss.level <= 500)) { inc %hp 2000 }
      if ((%boss.level > 500) && (%boss.level <= 800)) { inc %hp 3000 }
      if ((%boss.level > 800) && (%boss.level < 1000)) { inc %hp 7000 }
      if (%boss.level > 1000) { inc %hp 10000 }

      %hp = $round($calc(%hp + %increase.amount),0)
    }
  }

  if ($2 = rage) { %hp = $rand(120000,150000) }

  writeini $char($1) BaseStats HP %hp  
  unset %hp
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function lets monsters
; and npcs spend points
; to make them be the right
; level.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
monster_spend_points {
  ; $1 = monster
  ; $2 = monster's level 
  ; $3 = type of battle
  ; $4 = is used for the original summon's name

  var %str $readini($char($1), basestats, str)
  var %def $readini($char($1), basestats, def)
  var %int $readini($char($1), basestats, int)
  var %spd $readini($char($1), basestats, spd)

  var %unspent.monster.points $get.unspentpoints($1, $2, $3, $4)

  if ($3 = rage) { inc %unspent.monster.points 9999999 }
  if ($3 = Doppelganger) { var %unspent.monster.points 200 }
  if ($3 = DemonWall) { inc %unspent.monster.points 200 }
  if ($3 = Warmachine) { inc %unspent.monster.points 200 }
  if ($3 = ElderDragon) { inc %unspent.monster.points 350 }
  if ($3 = evolve) { inc %unspent.monster.points $rand(100,500) } 
  if ($3 = monstersummon) { inc %unspent.monster.points $rand(20,50) } 


  if (%unspent.monster.points <= 0) { return }

  var %total.percent 100

  var %str.percent $rand(25,35)
  dec %total.percent %str.percent

  var %def.percent $rand(25,30)
  dec %total.percent %def.percent

  var %int.percent $rand(25,35)
  dec %total.percent %int.percent

  var %spd.percent %total.percent
  var %str.points $round($calc((%str.percent * .01) * %unspent.monster.points),0)
  dec %unspent.monster.points %str.points

  var %int.points $round($calc((%int.percent * .01) * %unspent.monster.points),0)
  dec %unspent.monster.points %int.points

  var %def.points $round($calc((%def.percent * .01) * %unspent.monster.points),0)
  dec %unspent.monster.points %def.points

  var %spd.points %unspent.monster.points
  dec %unspent.monster.points %spd.points

  %str = $round($calc(%str + %str.points),0) 
  %def = $round($calc(%def + %def.points),0) 
  %int = $round($calc(%int + %int.points),0) 
  %spd = $round($calc(%spd + %spd.points),0) 

  writeini $char($1) BaseStats Str %str
  writeini $char($1) BaseStats Def %def
  writeini $char($1) BaseStats Int %int
  if ($3 != doppelganger) { writeini $char($1) BaseStats Spd %spd }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function actually deals
; the damage to the target.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
deal_damage {
  ; $1 = person dealing damage
  ; $2 = target
  ; $3 = action that was done (tech name, item, etc)
  ; $4 = absorb or none

  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  set %attack.damage $round(%attack.damage, 0)

  if (%guard.message != $null) { set %attack.damage 0 }

  unset %absorb.message

  if ($3 != JustRelease) {
    if ($readini($char($2), Status, cocoon) = yes) { 
      set %attack.damage 0 
      $set_chr_name($2) | set %guard.message $readini(translation.dat, skill, CocoonBlock)
    }
  }

  ; Check for natural armor.

  if (%attack.damage > 0) {

    if ($readini($char($2), info, flag) != $null) {
      var %naturalArmorCurrent $readini($char($2), NaturalArmor, Current)

      if ((%naturalArmorCurrent != $null) && (%naturalArmorCurrent > 0)) {
        set %naturalArmorName $readini($char($2), NaturalArmor, Name) 
        set %difference $calc(%attack.damage - %naturalArmorCurrent)
        dec %naturalArmorCurrent %attack.damage | writeini $char($2) NaturalArmor Current %naturalArmorCurrent

        if (%naturalArmorCurrent <= 0) { set %attack.damage %difference | writeini $char($2) naturalarmor current 0
          if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, battle, NaturalArmorBroken) }
          if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, NaturalArmorBroken)) }
          unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
        }
        if (%naturalArmorCurrent > 0) { set %guard.message $readini(translation.dat, battle, NaturalArmorAbsorb) | set %attack.damage 0 }

        unset %difference
      }
    }

  }

  var %life.target $readini($char($2), Battle, HP)
  dec %life.target %attack.damage
  writeini $char($2) battle hp %life.target

  ; Add some style points to the user
  if ($3 != renkei) { $add.stylepoints($1, $2, %attack.damage, $3) }

  ; If it's an Absorb HP type, we need to add the hp to the person.
  if (($4 = absorb) || (%absorb = absorb)) { 

    if ($readini($char($2), info, IgnoreDrain) = true) { unset %absorb | unset %drainsamba.on | unset %absorb.amount }
    if ($readini($char($2), info, IgnoreDrain) != true) {

      if (%guard.message = $null) {
        if ($readini($char($2), monster, type) != undead) {
          var %absorb.amount $round($calc(%attack.damage / 3),0)
          if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.4),0) }

          set %current.accessory $readini($char($1), equipment, accessory) 
          set %current.accessory.type $readini(items.db, %current.accessory, accessorytype)

          if (%current.accessory.type = CurseAddDrain) {
            var %absorb.amount $round($calc(%attack.damage / 1.7),0)
          }

          unset %current.accessory | unset %current.accessory.type

          set %life.target $readini($char($1), Battle, HP) | set %life.max $readini($char($1), Basestats, HP)
          inc %life.target %absorb.amount
          if (%life.target >= %life.max) { set %life.target %life.max }
          writeini $char($1) battle hp %life.target
        }
        if ($readini($char($2), monster, type) = undead) { unset %absorb | unset %absorb.amount }
      }

    }
    if (%guard.message != $null) { unset %absorb | unset %absorb.amount }
  }

  if (($augment.check($1, AbsorbTP) = true) && (%guard.message = $null)) {
    var %tp.absorb.amount $calc(%augment.strength * 10) 
    set %tp.target $readini($char($2), battle, tp) 

    if (%tp.target > 0) {
      set %tp.user $readini($char($1), battle, tp) | set %tp.max $readini($char($1), basestats, tp) 
      inc %tp.user %tp.absorb.amount
      if (%tp.user >= %tp.max) { writeini $char($1) battle tp %tp.max }
      if (%tp.user < %tp.max) { writeini $char($1) battle tp %tp.user }

      $set_chr_name($1) | set %absorb.message 3 $+ %real.name absorbs %tp.absorb.amount TP from $set_chr_name($2) %real.name $+ !
      set %tp.max $readini($char($2), basestats, tp) 
      dec %tp.target %tp.absorb.amount
      if (%tp.target <= 0) { writeini $char($2) battle tp 0 }
      if (%tp.target > 0) { writeini $char($2) battle tp %tp.target }
    }
    unset %tp.user | unset %tp.target | unset %tp.max
  } 

  if (($augment.check($1, AbsorbIG) = true) && (%guard.message = $null)) {
    var %ig.absorb.amount $calc(%augment.strength * 10) 
    set %ig.target $readini($char($2), battle, IgnitionGauge)

    if (%ig.target > 0) { 
      set %ig.user $readini($char($1), battle, IgnitionGauge)
      set %ig.max $readini($char($1), basestats, IgnitionGauge) 
      inc %ig.user %ig.absorb.amount
      if (%ig.user >= %ig.max) { writeini $char($1) battle IgnitionGauge %ig.max }
      if (%ig.user < %ig.max) { writeini $char($1) battle IgnitionGauge %ig.user }

      $set_chr_name($1) | set %absorb.message 3 $+ %real.name absorbs %ig.absorb.amount Ignition Gauge from $set_chr_name($2) %real.name $+ !

      set %ig.max $readini($char($2), basestats, IgnitionGauge) 
      dec %ig.target %ig.absorb.amount
      if (%ig.target <= 0) { writeini $char($2) battle IgnitionGauge 0 }
      if (%ig.target > 0) { writeini $char($2) battle IgnitionGauge %ig.target }
    }
    unset %ig.user | unset %ig.target | unset %ig.max
  }

  if ($readini($char($2), battle, HP) <= 0) { 
    writeini $char($2) battle status dead 
    writeini $char($2) battle hp 0
    $check.clone.death($2)
    $battle.reward.ignitionGauge.single($2)
    $increase.death.tally($2) 
    if (($readini($char($1), info, flag) != monster) && ($readini($char($1), battle, hp) > 0)) {
      $inc_monster_kills($1)
      if (%battle.type = monster) {  $add.stylepoints($1, $2, mon_death, $3) | $add.style.orbbonus($1, monster, $2) }
      if (%battle.type = manual) {  $add.stylepoints($1, $2, mon_death, $3) | $add.style.orbbonus($1, monster, $2) }
      if (%battle.type = orbfountain) {  $add.stylepoints($1, $2, mon_death, $3) | $add.style.orbbonus($1, monster, $2) }
      if (%battle.type = boss) { $add.stylepoints($1, $2, boss_death, $3) | $add.style.orbbonus($1, boss, $2) }
    }
  }

  if (%guard.message = $null) { $renkei.calculate($1, $2, $3) }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function is for healing
; damage done to a target
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

heal_damage {
  ; $1 = person heal damage
  ; $2 = target
  ; $3 = action that was done (tech name, item, etc)

  ;  Check for the blessed-ankh accessory
  if ($readini($char($1), equipment, accessory) = blessed-ankh) { 
    var %accessory.amount $readini(items.db, blessed-ankh, amount)
    var %health.increase $round($calc(%attack.damage * %accessory.amount),0)
    inc %attack.damage %health.increase
  }

  $restore_hp($2, %attack.damage)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function actually shows
; the damage to the channel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display_damage {
  ; $1 = person attacking
  ; $2 = person defending
  ; $3 = type of display needs to be done
  ; $4 = weapon/tech/item name

  unset %overkill |  unset %style.rating | unset %target
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  ; Show a random attack description
  if ($3 = weapon) { 
    if (%counterattack != on ) {   var %weapon.type $readini(weapons.db, $4, type) |  var %attack.file attack_ $+ %weapon.type $+ .txt  }

    if (%counterattack = on) { 
      set %weapon.equipped $readini($char($2), weapons, equipped)
      set  %weapon.type $readini(weapons.db, %weapon.equipped, type)
      var %attack.file attack_ $+ %weapon.type $+ .txt
      unset %weapon.equipped | unset %weapon.type
      $display.system.message($readini(translation.dat, battle, MeleeCountered), battle)
      $set_chr_name($1) | set %enemy %real.name | set %target $1 | $set_chr_name($2) | set %user %real.name 
    }
  $display.system.message(3 $+ %user $+  $read %attack.file  $+ 3., battle)  }

  if ($3 = tech) {
    if (%showed.tech.desc != true) { $display.system.message(3 $+ %user $+  $readini(techniques.db, $4, desc), battle) }

    if ($readini(techniques.db, $4, magic) = yes) {
      ; Clear elemental seal
      if ($readini($char($1), skills, elementalseal.on) = on) {  writeini $char($1) skills elementalseal.on off   }
      if ($readini($char($2), status, reflect) = yes) { 
        if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, skill, MagicReflected) }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, skill, MagicReflected)) }

      $set_chr_name($1) | set %enemy %real.name | set %target $1 | writeini $char($2) status reflect no | writeini $char($2) status reflect.timer 0  }
    }
  }

  if ($3 = item) {
    $display.system.message(3 $+ %user $+  $readini(items.db, $4, desc), battle)
  }

  if ($3 = fullbring) { $display.system.message(3 $+ %user $+  $readini(items.db, $4, fullbringdesc), battle) } 

  if ($3 = renkei) { $display.system.message($readini(translation.dat, system, RenkeiPerformed) 3 $+ %renkei.description, battle) |  unset %style.rating  }

  ; Show the damage
  if ((($3 != item) && ($3 != renkei) && ($1 != battlefield))) { 
    if (($readini($char($1), info, flag) != monster) && (%target != $1)) { 
      if ($1 != $2) { $calculate.stylepoints($1)  }
    }
  }

  if (((((((%double.attack = $null) && (%triple.attack = $null) && (%fourhit.attack = $null) && (%fivehit.attack = $null) && (%sixhit.attack = $null) && (%sevenhit.attack = $null) && (%eighthit.attack = $null))))))) { 

    if ($3 != aoeheal) {
      if (%guard.message = $null) { 
        if ($readini(system.dat, system, botType) = IRC) { query %battlechan The attack did4 $bytes(%attack.damage,b) damage to %enemy %style.rating }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(The attack did4 $bytes(%attack.damage,b) damage to %enemy %style.rating) }
      }
      if (%guard.message != $null) { 
        if ($readini(system.dat, system, botType) = IRC) { query %battlechan %guard.message }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%guard.message) }
      }
      if (%element.desc != $null) {  
        if ($readini(system.dat, system, botType) = IRC) { query %battlechan %element.desc }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%element.desc) }
        unset %element.desc 
      }
    }
    if ($3 = aoeheal) { 
      if (%guard.message = $null) { 
        if ($readini(system.dat, system, botType) = IRC) { query %battlechan The attack did4 $bytes(%attack.damage,b) damage to %enemy %style.rating }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(The attack did4 $bytes(%attack.damage,b) damage to %enemy %style.rating) }
      }
      if (%guard.message != $null) { 
        if ($readini(system.dat, system, botType) = IRC) { query %battlechan %guard.message }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%guard.message) }
      }
      if (%element.desc != $null) {  
        if ($readini(system.dat, system, botType) = IRC) { query %battlechan %element.desc }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%element.desc) }
        unset %element.desc 
      }
    }
  }

  if (%double.attack = true) { 
    if (%guard.message = $null) {  var %damage.message 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %damage.message }
      if ($readini(system.dat, system, botType) = DCCchat) {  $dcc.battle.message(%damage.message) }
    }
    if (%guard.message != $null) { 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %guard.message }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%guard.message) }
    }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  }
  if (%triple.attack = true) {  
    if (%guard.message = $null) { var %damage.message 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage.  Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %damage.message }
    if ($readini(system.dat, system, botType) = DCCchat) {  $dcc.battle.message(%damage.message) }    }
    if (%guard.message != $null) { 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %guard.message }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%guard.message) }
    }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  }

  if (%fourhit.attack = true) { 
    if (%guard.message = $null) { var %damage.message 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage. The fourth attack did4 $bytes(%attack.damage4,b) damage. Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %damage.message }
      if ($readini(system.dat, system, botType) = DCCchat) {  $dcc.battle.message(%damage.message) }    
    }
    if (%guard.message != $null) { 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %guard.message }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%guard.message) }
    }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  }

  if (%fivehit.attack = true) { 
    if (%guard.message = $null) { var %damage.message 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage. The fourth attack did4 $bytes(%attack.damage4,b) damage. The fifth attack did4 $bytes(%attack.damage5,b) damage. Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %damage.message }
      if ($readini(system.dat, system, botType) = DCCchat) {  $dcc.battle.message(%damage.message) }
    }
    if (%guard.message != $null) { 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %guard.message }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%guard.message) }
    }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  }

  if (%sixhit.attack = true) { 
    if (%guard.message = $null) { var %damage.message 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage. The fourth attack did4 $bytes(%attack.damage4,b) damage. The fifth attack did4 $bytes(%attack.damage5,b) damage. The sixth attack did4 $bytes(%attack.damage6,b) damage.  Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %damage.message }
      if ($readini(system.dat, system, botType) = DCCchat) {  $dcc.battle.message(%damage.message) }
    }
    if (%guard.message != $null) { 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %guard.message }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%guard.message) }
    }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  }

  if (%sevenhit.attack = true) { 
    if (%guard.message = $null) { var %damage.message 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage. The fourth attack did4 $bytes(%attack.damage4,b) damage. The fifth attack did4 $bytes(%attack.damage5,b) damage. The sixth attack did4 $bytes(%attack.damage6,b) damage. The seventh attack did4 $bytes(%attack.damage7,b) damage.  Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %damage.message }
      if ($readini(system.dat, system, botType) = DCCchat) {  $dcc.battle.message(%damage.message) }
    }
    if (%guard.message != $null) { 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %guard.message }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%guard.message) }
    }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  }

  if (%eighthit.attack = true) { 
    if (%guard.message = $null) { var %damage.message 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage. The fourth attack did4 $bytes(%attack.damage4,b) damage. The fifth attack did4 $bytes(%attack.damage5,b) damage. The sixth attack did4 $bytes(%attack.damage6,b) damage. The seventh attack did4 $bytes(%attack.damage7,b) damage.  The eight attack did4 $bytes(%attack.damage8,b) damage. Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %damage.message }
      if ($readini(system.dat, system, botType) = DCCchat) {  $dcc.battle.message(%damage.message) }
    }
    if (%guard.message != $null) { 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %guard.message }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%guard.message) }
    }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  }

  if (%target = $null) { set %target $2 }

  if (%statusmessage.display != $null) { 
    if ($readini($char(%target), battle, hp) > 0) { 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %statusmessage.display }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%statusmessage.display) }
      unset %statusmessage.display 
    }
  }

  if (%absorb = absorb) {
    if (%guard.message = $null) {
      ; Show how much the person absorbed back.
      var %absorb.amount $round($calc(%attack.damage / 3),0)
      if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.5),0) }
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan 3 $+ %user absorbs $bytes(%absorb.amount,b) HP back from the damage. }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(3 $+ %user absorbs $bytes(%absorb.amount,b) HP back from the damage.) }
      unset %absorb
    }
  }

  if (%drainsamba.on = on) {
    if (%guard.message = $null) {
      if (($readini($char(%target), monster, type) != undead) && ($readini($char(%target), monster, type) != zombie)) { 
        var %absorb.amount $round($calc(%attack.damage / 3),0)
        if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.5),0) }
        if (%absorb.amount <= 0) { var %absorb.amount 1 }
        if ($readini(system.dat, system, botType) = IRC) {  query %battlechan 3 $+ %user absorbs $bytes(%absorb.amount,b) HP back from the damage. }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(3 $+ %user absorbs $bytes(%absorb.amount,b) HP back from the damage.) }
        set %life.target $readini($char($1), Battle, HP) | set %life.max $readini($char($1), Basestats, HP)
        inc %life.target %absorb.amount
        if (%life.target >= %life.max) { set %life.target %life.max }
        writeini $char($1) battle hp %life.target
        unset %life.target | unset %life.target | unset %absorb.amount 
      }
    }
  }

  if (%absorb.message != $null) { 
    if (%guard.message = $null) {
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %absorb.message }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%absorb.message) }
      unset %absorb.message
    }
  }

  unset %guard.message

  ; Did the person die?  If so, show the death message.
  if ($readini($char(%target), battle, HP) <= 0) { 
    $increase_death_tally(%target)
    $achievement_check(%target, SirDiesALot)
    $gemconvert_check($1, %target, $3, $4)
    if (%attack.damage > $readini($char(%target), basestats, hp)) { set %overkill 7<<OVERKILL>> }

    if ($readini(system.dat, system, botType) = IRC) { query %battlechan 4 $+ %enemy has been defeated by %user $+ !  %overkill }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(4 $+ %enemy has been defeated by %user $+ !  %overkill) }

    if ($readini($char(%target), info, flag) != $null) {  $random.healing.orb($1,%target)  }

    $goldorb_check(%target) 
    $spawn_after_death(%target)
    remini $char(%target) Renkei
  }

  if ($readini($char(%target), battle, HP) > 0) {

    ; Check to see if the monster can be staggered..  
    var %stagger.check $readini($char(%target), info, CanStagger)
    if (($stagger.check != $null) && (%stagger.check != no)) {

      ; Do the stagger if the damage is above the threshold.
      var %stagger.amount.needed $readini($char(%target), info, StaggerAmount)
      dec %stagger.amount.needed %attack.damage | writeini $char(%target) info staggeramount %stagger.amount.needed
      if (%stagger.amount.needed <= 0) { writeini $char(%target) status staggered yes |  writeini $char(%target) info CanStagger no
        if ($readini(system.dat, system, botType) = IRC) {  query %battlechan $readini(translation.dat, status, StaggerHappens) }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, status, StaggerHappens)) }
      }
    }

    if ($3 = tech) { unset %attack.damage | $renkei.check($1, %target) }
  }

  unset %target | unset %user | unset %enemy | unset %counterattack |  unset %statusmessage.display

  if ($readini($char($1), battle, hp) > 0) {
    $self.inflict_status($1, $4 , $3)
    if (%statusmessage.display != $null) { 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan %statusmessage.display }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%statusmessage.display) }
      unset %statusmessage.display
    }
  }

  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function displays the
; healing to the channel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display_heal {
  unset %style.rating
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  if (%user = %enemy ) { set %enemy $gender2($1) $+ self }

  if ($3 = tech) {
    if (%showed.tech.desc != true) {
      $set_chr_name($1)

      if ($readini(system.dat, system, botType) = IRC) { query %battlechan 3 $+ %real.name $+  $readini(techniques.db, $4, desc) }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(3 $+ %real.name $+  $readini(techniques.db, $4, desc)) }
    }
  }

  if ($3 = item) {
    if ($readini(system.dat, system, botType) = IRC) { query %battlechan 3 $+ %user $+  $readini(items.db, $4, desc) }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(3 $+ %user $+  $readini(items.db, $4, desc)) }
  }

  if ($3 = weapon) { 
    var %weapon.type $readini(weapons.db, $4, type) | var %attack.file attack_ $+ %weapon.type $+ .txt 

    if ($readini(system.dat, system, botType) = IRC) { query %battlechan 3 $+ %user $+  $read %attack.file  $+ 3. }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(3 $+ %user $+  $read %attack.file  $+ 3.) }
  }

  ; Show the damage healed
  if (%guard.message = $null) {  $set_chr_name($2) |  $set_chr_name($2)
    if ($readini(system.dat, system, botType) = IRC) { query %battlechan 3 $+ %real.name has been healed for $bytes(%attack.damage,b) health! }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(3 $+ %real.name has been healed for $bytes(%attack.damage,b) health!) }
  }
  if (%guard.message != $null) { 
    if ($readini(system.dat, system, botType) = IRC) { query %battlechan %guard.message }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(%guard.message) }
    unset %guard.message
  }

  ; Did the person die?  If so, show the death message.
  if ($readini($char($2), battle, HP) <= 0) { 
    $set_chr_name($2) 
    if ($readini(system.dat, system, botType) = IRC) { query %battlechan 4 $+ %enemy has been defeated by %user $+ !  %overkill }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(4 $+ %enemy has been defeated by %user $+ !  %overkill) }
  }

  return 
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function checks to see
; if enemies drop a random
; healing type of orb like in
; the Devil May Cry games
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.healing.orb {
  ; check to see if a random healing orb appears.
  if ($1 != $2) {
    var %healing.orb.chance $rand(0,100)

    if (%healing.orb.chance < 65) { return }

    if ((%healing.orb.chance >= 65) && (%healing.orb.chance <= 80)) {
      ; health orb
      var %orb.restored $rand(50,100)
      $restore_hp($1, %orb.restored)
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, battle, ObtainGreenOrb) }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, ObtainGreenOrb)) }
    }

    if ((%healing.orb.chance > 80) && (%healing.orb.chance < 98)) {
      ; TP orb
      var %orb.restored $rand(5,20)
      $restore_tp($1, %orb.restored)
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, battle, ObtainWhiteOrb) }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, ObtainWhiteOrb)) }
    }

    if (%healing.orb.chance >= 98) { 
      ; Ignition Orb
      var %max.ig $readini($char($1), basestats, IgnitionGauge)
      if (%max.ig > 0) {
        var %orb.restored $rand(1,2)
        $restore_ig($1, %orb.restored)
        if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, battle, ObtainOrangeOrb) }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, ObtainOrangeOrb)) }
      }
    }

  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function sees if 
; a gem is given to the user
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gemconvert_check { 
  ; $1 = user
  ; $2 = target
  ; $3 = what was used (check for "weapon")
  ; $4 = weapon name
  if ($3 != weapon) { return }
  if (($readini(weapons.db, $4, special) != gemconvert) && ($augment.check($1, GemConvert) = false)) { return }
  if ($readini($char($2), info, flag) != monster) { return }
  if ($readini($char($1), info, flag) != $null) { return }

  set %gem.list $readini(items.db, items, gems)

  ; pick a random gem
  set %total.gems $numtok(%gem.list, 46)
  set %random.gem $rand(1,%total.gems)
  set %gem $gettok(%gem.list, %random.gem, 46)

  if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, system, ConvertToGem) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, system, ConvertToGem)) }

  set %current.item.total $readini($char($1), Item_Amount, %gem) 
  if (%current.item.total = $null) { var %current.item.total 0 }
  inc %current.item.total 1 | writeini $char($1) Item_Amount %gem %current.item.total 

  var %monsters.converted $readini($char($1), stuff, MonstersToGems)
  if (%monsters.converted = $null) { var %monsters.converted 0 }
  inc %monsters.converted 1 | writeini $char($1) stuff MonstersToGems %monsters.converted

  $achievement_check($2, PrettyGemCollector)

  unset %gem.list | unset %total.gems | unset %random.gem | unset %gem
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Randomly pick the weather
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.weather.pick {
  if (%current.battlefield = Dead-End Hallway) { return }
  set %weather.list $readini(battlefields.lst, %current.battlefield, weather)
  set %random $rand(1, $numtok(%weather.list,46))
  if (%random = $null) { var %random 1 }
  set %new.weather $gettok(%weather.list,%random,46)
  writeini weather.lst weather current %new.weather

  if ($readini(system.dat, system, botType) = IRC) { query %battlechan 10The weather changes.  It is now %new.weather }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(10The weather changes.  It is now %new.weather) }

  unset %number.of.weather | unset %new.weather | unset %random | unset %weather.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if there's a
; battlefield curse.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.battlefield.curse {
  if ($readini(battlestats.dat, battle, WinningStreak) <= 50) { return }
  var %curse.chance $rand(1,105)
  if (%battle.type = boss) { var %curse.chance $rand(1,100) }
  if (%curse.chance <= 6) { 
    if ($readini(system.dat, system, botType) = IRC) {  /.timerCurseMessage 1 1 /query %battlechan $readini(translation.dat, Events, CurseNight) }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, Events, CurseNight)) }
    set %curse.night true
    ; curse everyone
    var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line battle.txt
      writeini $char(%who.battle) status curse yes
      writeini $char(%who.battle) battle tp 0
      inc %battletxt.current.line 1  
    }
  }
  if ((%curse.chance >= 95) && (%curse.chance <= 100)) {  
    if ($readini(system.dat, system, botType) = IRC) { /.timerCurseMessage 1 1 /query %battlechan $readini(translation.dat, Events, BloodMoon) }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, Events, BloodMoon)) }
    set %bloodmoon on 
  }
  if (%curse.chance > 100) { 
    set %battleconditions no-tech
    if ($readini(system.dat, system, botType) = IRC) {  /.timerCurseMessage 1 1 /query %battlechan $readini(translation.dat, Events, AncientMeleeOnlySeal) }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, Events, AncientMeleeOnlySeal)) }
  }

  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function checks to see
; if monsters go first in battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.surpriseattack {
  set %surpriseattack.chance $rand(1,105)
  $backguard.check
  if (%surpriseattack.chance >= 88) { set %surpriseattack on }
  if (%surpriseattack = on) { 
    if ($readini(system.dat, system, botType) = IRC) { /.timerSurpriseAttackMessage 1 .5 /query %battlechan $readini(translation.dat, Events, SurpriseAttack) }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, Events, SurpriseAttack)) }
  }
  unset %surpriseattack.chance
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function checks
; to see if players go first
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.playersgofirst {
  if (%surpriseattack = on) { return }
  set %playersfirst.chance $rand(1,100)

  if (%playersfirst.chance <= 8) { set %playersgofirst on }
  if (%playersgofirst = on) { 
    if ($readini(system.dat, system, botType) = IRC) { /.timerSurpriseAttackMessage 1 .5 /query %battlechan $readini(translation.dat, Events, PlayersGoFirst) }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, Events, PlayersGoFirst)) }
  }
  unset %playersfirst.chance
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; a random NPC 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.battlefield.ally {
  if (%battle.type = manual) { return }
  if (%battle.type = orbfountain) { return }
  var %npc.chance $rand(1,100) 
  var %losing.streak $readini(battlestats.dat, battle, LosingStreak)
  var %winning.streak $readini(battlestats.dat, battle, WinningStreak)

  if (%losing.streak >= 2) { var %npc.chance 1 }
  if ((%winning.streak >= 30) && (%number.of.players = 1)) { var %npc.chance $rand(1,45) }

  if (%npc.chance <= 10) { 
    $get_npc_list
    var %npcs.total $numtok(%npc.list,46)
    if ((%npcs.total = 0) || (%npc.list = $null)) { 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan 4Error: There are no NPCs in the NPC folder.. Have the bot admin check to make sure there are npcs there! | return }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(4Error: There are no NPCs in the NPC folder.. Have the bot admin check to make sure there are npcs there!) | return }
    }

    set %value 1
    while (%value <= 1) {
      if (%npc.list = $null) { inc %value 1 } 
      set %npcs.total $numtok(%npc.list,46)
      set %random.npc $rand(1, %npcs.total) 
      set %npc.name $gettok(%npc.list,%random.npc,46)

      if (%npcs.total = 0) { inc %value 1 }

      if ($isfile($char(%npc.name)) = $false) { 
        .copy -o $npc(%npc.name) $char(%npc.name) | set %curbat $readini(battle2.txt, Battle, List) | %curbat = $addtok(%curbat,%npc.name,46) |  writeini battle2.txt Battle List %curbat 
        $set_chr_name(%npc.name) 

        if ($readini(system.dat, system, botType) = IRC) {
          query %battlechan 4 $+ %real.name has entered the battle to help the forces of good! 
          query %battlechan 12 $+ %real.name  $+ $readini($char(%npc.name), descriptions, char)
        }
        if ($readini(system.dat, system, botType) = DCCchat) { 
          $dcc.battle.message(4 $+ %real.name has entered the battle to help the forces of good!)
          $dcc.battle.message(12 $+ %real.name  $+ $readini($char(%npc.name), descriptions, char))
        }

        set %npc.to.remove $findtok(%npc.list, %npc.name, 46)
        set %npc.list $deltok(%npc.list,%npc.to.remove,46)
        write battle.txt %npc.name
        $boost_monster_stats(%npc.name)
        $fulls(%npc.name) | var %battlenpcs $readini(battle2.txt, BattleInfo, npcs) | inc %battlenpcs 1 | writeini battle2.txt BattleInfo npcs %battlenpcs
        inc %value 1
      }
      else {  %npc.list = $deltok(%npc.list,%npc.name,46) | dec %value 1 }
    }
  }
  else { return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is the automatic-revival
; function.. it's named after the 
; Gold Orbs in Devil May Cry
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
goldorb_check {
  if ($readini($char($1), status, revive) = yes) {
    var %max.hp $readini($char($1), basestats, hp)
    set %revive.current.hp $round($calc(%max.hp / 2),0)
    if (%revive.current.hp <= 0) { set %revive.current.hp 1 }
    writeini $char($1) battle hp %revive.current.hp
    writeini $char($1) battle status normal
    writeini $char($1) status revive no
    if ($readini(system.dat, system, botType) = IRC) {  /.timerThrottleGoldOrb $+ $rand(1,100000) $+ $rand(a,z) 1 1 /query %battlechan $readini(translation.dat, battle, GoldOrbUsed) }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, GoldOrbUsed)) }

    writeini battle2.txt style $1 0
    unset %revive.current.hp

    var %number.of.revives $readini($char($1), stuff, RevivedTimes)
    if (%number.of.revives = $null) { var %number.of.revives 0 }
    inc %number.of.revives 1
    writeini $char($1) stuff RevivedTimes %number.of.revives
    $achievement_check($1, Can'tKeepAGoodManDown)

    writeini $char($1) Status poison no | writeini $char($1) Status HeavyPoison no | writeini $char($1) Status blind no
    writeini $char($1) Status Heavy-Poison no | writeini $char($1) status poison-heavy no | writeini $char($1) Status curse no 
    writeini $char($1) Status weight no | writeini $char($1) status virus no | writeini $char($1) status poison.timer 1 | writeini $char($1) status intimidate no
    writeini $char($1) Status drunk no | writeini $char($1) Status amnesia no | writeini $char($1) status paralysis no | writeini $char($1) status amnesia.timer 1 | writeini $char($1) status paralysis.timer 1 | writeini $char($1) status drunk.timer 1
    writeini $char($1) status zombie no | writeini $char($1) Status slow no | writeini $char($1) Status sleep no | writeini $char($1) Status stun no
    writeini $char($1) status boosted no  | writeini $char($1) status curse.timer 1 | writeini $char($1) status slow.timer 1 | writeini $char($1) status zombie.timer 1
    writeini $char($1) status zombieregenerating no | writeini $char($1) status charmer noOneThatIKnow | writeini $char($1) status charm.timer 1 | writeini $char($1) status charmed no 
    writeini $char($1) status charm no | writeini $char($1) status bored no | writeini $char($1) status bored.timer 1 | writeini $char($1) status confuse no 
    writeini $char($1) status confuse.timer 1 | writeini $char($1) status defensedown no | writeini $char($1) status defensedown.timer 0 | writeini $char($1) status strengthdown no 
    writeini $char($1) status strengthdown.timer 0 | writeini $char($1) status intdown no | writeini $char($1) status intdown.timer 1
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function checks for
; the guardian style
; and reduces damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
guardian_style_check {
  if ($augment.check($1, IgnoreGuardian) = true) { return }

  set %current.playerstyle $readini($char($1), styles, equipped)
  ; Is the target using the Guardian style?  If so, we need to decrease the damage done.
  if (%current.playerstyle = Guardian) { 
    set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
    var %block.value $calc(%current.playerstyle.level / 15.5)
    if (%block.value > .60) { var %block.value .60 }
    var %amount.to.block $round($calc(%attack.damage * %block.value),0)
    dec %attack.damage %amount.to.block
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; the evil doppelgangers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_evil_clones {
  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line battle.txt
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 
      .copy $char(%who.battle) $char(Evil_ $+ %who.battle)
      writeini $char(evil_ $+ %who.battle) info flag monster 
      writeini $char(evil_ $+ %who.battle) info clone yes
      writeini $char(evil_ $+ %who.battle) Basestats name Evil Doppelganger of %who.battle
      writeini $char(evil_ $+ %who.battle) info password .8V%N)W1T;W5C:'1H:7,`1__.154
      $boost_monster_stats(evil_ $+ %who.battle, doppelganger)
      $fulls(evil_ $+ %who.battle) 
      writeini $char(evil_ $+ %who.battle) status FinalGetsuga yes
      writeini $char(evil_ $+ %who.battle) info OrbBonus yes
      set %curbat $readini(battle2.txt, Battle, List) |  %curbat = $addtok(%curbat,evil_ $+ %who.battle,46) |  writeini battle2.txt Battle List %curbat | write battle.txt evil_ $+ %who.battle
      $set_chr_name(evil_ $+ %who.battle) 

      if ($readini(system.dat, system, botType) = IRC) {  query %battlechan $readini(translation.dat, battle, EnteredTheBattle) }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, EnteredTheBattle)) }

      var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
      inc %battletxt.current.line 1 
    }
  }

  set %boss.item $readini(items.db, items, foodItems) $+ . $+ $readini(items.db, items, runes) $+ . $readini(chests.lst, chests, green)
  writeini battle2.txt battle bonusitem %boss.item | unset %boss.item
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; the warmachine boss
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_monster_warmachine {
  set %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }

  if ((%current.battlestreak >= 1) && (%current.battlestreak <= 20)) { set %monster.name Small_Warmachine | set %monster.realname Small Warmachine }
  if ((%current.battlestreak > 20) && (%current.battlestreak <= 60)) { set %monster.name Medium_Warmachine | set %monster.realname Medium Warmachine | writeini $char(%monster.name) info OrbBonus yes  }
  if (%current.battlestreak > 60) { set %monster.name Large_Warmachine | set %monster.realname Large Warmachine | writeini $char(%monster.name) info OrbBonus yes }

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender its
  writeini $char(%monster.name) info gender2 its
  writeini $char(%monster.name) info bosslevel %current.battlestreak

  var %base.hp.tp $calc(7 * %current.battlestreak)
  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp
  var %base.stats $calc($rand(1,3) * %current.battlestreak)
  writeini $char(%monster.name) basestats str %base.stats
  inc %base.stats $rand(0,2)
  writeini $char(%monster.name) basestats def %base.stats
  inc %base.stats $rand(0,2)
  writeini $char(%monster.name) basestats int %base.stats
  inc %base.stats $rand(0,2)
  writeini $char(%monster.name) basestats spd %base.stats

  writeini $char(%monster.name) techniques FirajaII %current.battlestreak
  writeini $char(%monster.name) techniques Quake %current.battlestreak
  writeini $char(%monster.name) techniques Flare %current.battlestreak
  writeini $char(%monster.name) techniques Tornado %current.battlestreak
  writeini $char(%monster.name) techniques Poison %current.battlestreak
  writeini $char(%monster.name) techniques Blind %current.battlestreak
  writeini $char(%monster.name) techniques AsuranFists %current.battlestreak

  writeini $char(%monster.name) weapons equipped WarMachine
  writeini $char(%monster.name) weapons WarMachine %current.battlestreak
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) skills sugitekai 1
  writeini $char(%monster.name) skills RoyalGuard 1
  writeini $char(%monster.name) skills ManaWall 1
  writeini $char(%monster.name) skills Utsusemi 1

  $boost_monster_stats(%monster.name, warmachine)
  $fulls(%monster.name, warmachine) 

  set %curbat $readini(battle2.txt, Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini battle2.txt Battle List %curbat | write battle.txt %monster.name
  $set_chr_name(%monster.name) 
  if ($readini(system.dat, system, botType) = IRC) {  query %battlechan $readini(translation.dat, battle, EnteredTheBattle) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, EnteredTheBattle)) }
  var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname

  set %boss.item $readini(items.db, items, SummonItems) $+ . $+ $readini(items.db, items, Gems) $+ . $+ $readini(chests.lst, chests, green)
  writeini battle2.txt battle bonusitem %boss.item
  unset %boss.item
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; an elder dragon boss
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_elderdragon {
  var %surname The Fierce.The Destroyer.The Evil.The Berserk.The Chaos.Bloodspawn.Bloodtear.Bloodfang.The Fierce

  set %names.lines $lines(dragonnames.lst)
  if ((%names.lines = $null) || (%names.lines = 0)) { write dragonnames.lst Nasith | var %names.lines 1 }

  set %random.firstname $rand(1,%names.lines)
  set %first.name $read(dragonnames.lst, %random.firstname)
  set %lastnames.total $numtok(%surname,46)
  set %random.lastname $rand(1, %lastnames.total) 
  set %last.name $gettok(%surname,%random.lastname,46)

  var %elderdragon.name %first.name %last.name

  if ($readini(system.dat, system, botType) = IRC) {  query %battlechan $readini(translation.dat, events, ElderDragonFight) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, events, ElderDragonFight)) }

  set %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }

  var %monster.name %first.name
  .copy -o $char(new_chr) $char(%first.name)
  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %elderdragon.name
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info gender its
  writeini $char(%monster.name) info gender2 its
  writeini $char(%monster.name) info bosslevel %current.battlestreak
  writeini $char(%monster.name) info OrbBonus yes 
  writeini $char(%monster.name) descriptions char is a large and powerful Elder Dragon, recently awoken from its long slumber in the earth.

  var %base.hp.tp $calc(7 * %current.battlestreak)
  writeini $char(%monster.name) basestats hp %base.hp.tp
  writeini $char(%monster.name) basestats tp %base.hp.tp
  var %base.stats $calc($rand(3,6) * %current.battlestreak)
  writeini $char(%monster.name) basestats str %base.stats
  inc %base.stats $rand(1,2)
  writeini $char(%monster.name) basestats def %base.stats
  inc %base.stats $rand(1,2)
  writeini $char(%monster.name) basestats int %base.stats
  inc %base.stats $rand(1,2)
  writeini $char(%monster.name) basestats spd %base.stats

  writeini $char(%monster.name) techniques FangRush %current.battlestreak
  writeini $char(%monster.name) techniques SpikeFlail $calc(%current.battlestreak + 10)
  writeini $char(%monster.name) techniques AbsoluteTerror %current.battlestreak
  writeini $char(%monster.name) techniques DragonFire $calc(%current.battlestreak + 50) 

  writeini $char(%monster.name) weapons equipped DragonFangs
  writeini $char(%monster.name) weapons DragonFangs %current.battlestreak
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) skills sugitekai 1
  writeini $char(%monster.name) skills RoyalGuard 1
  writeini $char(%monster.name) skills ManaWall 1
  writeini $char(%monster.name) skills Utsusemi 1
  writeini $char(%monster.name) skills MonsterConsume 1
  writeini $char(%monster.name) skills resist-charm 100
  writeini $char(%monster.name) skills resist-stun 80
  writeini $char(%monster.name) skills Resist-blind 80
  writeini $char(%monster.name) skills Resist-poison 75
  writeini $char(%monster.name) skills Resist-slow 60
  writeini $char(%monster.name) skills Resist-Weaponlock 100

  set %current.battlefield Ancient Dragon Burial Site
  writeini weather.lst weather current Calm

  set %magic.types light.dark.fire.ice.water.lightning.wind.earth
  set %number.of.magic.types $numtok(%magic.types,46)

  writeini $char(%monster.name) modifiers light 100
  writeini $char(%monster.name) modifiers dark 100
  writeini $char(%monster.name) modifiers fire 100
  writeini $char(%monster.name) modifiers ice 100
  writeini $char(%monster.name) modifiers water 100
  writeini $char(%monster.name) modifiers lightning 100
  writeini $char(%monster.name) modifiers wind 100
  writeini $char(%monster.name) modifiers earth 100

  writeini $char(%monster.name) NaturalArmor Name Dragon Scales
  writeini $char(%monster.name) NaturalArmor Max $calc(%current.battlestreak * 5)
  writeini $char(%monster.name) NaturalArmor Current $calc(%current.battlestreak * 5)

  var %numberof.weaknesses 1

  var %value 1
  while (%value <= %numberof.weaknesses) {
    set %weakness.number $rand(1,%number.of.magic.types)
    %weakness = $gettok(%magic.types,%weakness.number,46)
    if (%weakness != $null) {  writeini $char(%monster.name) modifiers %weakness 120 }
    inc %value
  }

  var %numberof.strengths $rand(1,4)

  var %value 1
  while (%value <= %numberof.strengths) {
    set %strength.number $rand(1,%number.of.magic.types)
    %strengths = $gettok(%magic.types,%strength.number,46)
    if (%strengths != $null) {  writeini $char(%monster.name) modifiers %strengths 40 }
    inc %value
  }

  var %numberof.heal $rand(1,3)

  var %value 1
  while (%value <= %numberof.heal) {
    set %heal.number $rand(1,%number.of.magic.types)
    %heals = $addtok(%heals, $gettok(%magic.types,%heal.number,46),46)
    inc %value
  }

  if (%heals != $null) { writeini $char(%monster.name) modifiers Heal %heals }

  unset %heal.number | unset %heals
  unset %strengths | unset %strength.number
  unset %weakness | unset %weakness.number
  unset %number.of.magic.types | unset %magic.types

  writeini $char(%monster.name) modifiers HandToHand 20
  writeini $char(%monster.name) modifiers Whip 20
  writeini $char(%monster.name) modifiers sword 60
  writeini $char(%monster.name) modifiers gun 20
  writeini $char(%monster.name) modifiers rifle 30
  writeini $char(%monster.name) modifiers katana 60
  writeini $char(%monster.name) modifiers wand 10
  writeini $char(%monster.name) modifiers spear 70
  writeini $char(%monster.name) modifiers scythe 70
  writeini $char(%monster.name) modifiers GreatSword 70
  writeini $char(%monster.name) modifiers bow 10
  writeini $char(%monster.name) modifiers glyph 60

  $boost_monster_stats(%monster.name, elderdragon)
  $fulls(%monster.name, elderdragon) 

  set %curbat $readini(battle2.txt, Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini battle2.txt Battle List %curbat | write battle.txt %monster.name
  $set_chr_name(%monster.name)
  if ($readini(system.dat, system, botType) = IRC) {  query %battlechan $readini(translation.dat, battle, EnteredTheBattle) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, EnteredTheBattle)) }
  var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname
  unset %random.firstname | unset %first.name | unset %lastnames.total | unset %random.lastname | unset %last.name | unset %names.lines

  set %boss.item $readini(items.db, items, Fooditems) $+ . $+ $readini(items.db, items, Gems) $+ . $+ $readini(chests.lst, chests, silver)
  writeini battle2.txt battle bonusitem %boss.item
  unset %boss.item
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function generates
; the demon wall boss
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_demonwall {
  set %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }
  set %monster.name Demon_Wall | set %monster.realname Demon Wall

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info BattleStats ignoreHP
  writeini $char(%monster.name) info OrbBonus yes

  var %base.hp.tp $calc(7 * %current.battlestreak)
  writeini $char(%monster.name) basestats hp $rand(45000,50000)
  writeini $char(%monster.name) basestats tp %base.hp.tp
  writeini $char(%monster.name) basestats str $round($calc(%current.battlestreak / 1.2),0)
  writeini $char(%monster.name) basestats def $round($calc(%current.battlestreak / 7),0)
  writeini $char(%monster.name) basestats int $round($calc(%current.battlestreak / 6),0)
  var %base.stats $calc($rand(1,3) * %current.battlestreak)
  inc %base.stats $rand(0,2)
  writeini $char(%monster.name) basestats spd %base.stats

  writeini $char(%monster.name) techniques FirajaII %current.battlestreak
  writeini $char(%monster.name) techniques Poison %current.battlestreak
  writeini $char(%monster.name) techniques Slow %current.battlestreak
  writeini $char(%monster.name) techniques Blind %current.battlestreak
  writeini $char(%monster.name) techniques Petrify %current.battlestreak

  writeini $char(%monster.name) weapons equipped DemonWall
  writeini $char(%monster.name) weapons DemonWall %current.battlestreak
  remini $char(%monster.name) weapons Fists

  writeini $char(%monster.name) skills sugitekai 1
  writeini $char(%monster.name) skills RoyalGuard 1
  writeini $char(%monster.name) skills ManaWall 1
  writeini $char(%monster.name) skills manawall.on on
  writeini $char(%monster.name) skills royalguard.on on
  writeini $char(%monster.name) skills MagicMirror 10
  writeini $char(%monster.name) skills Resist-blind 100
  writeini $char(%monster.name) skills Resist-slow 100
  writeini $char(%monster.name) skills Resist-Weaponlock 100


  writeini $char(%monster.name) styles equipped Guardian
  writeini $char(%monster.name) styles guardian 5

  var %reflect.chance $rand(1,100)
  if (%reflect.chance <= 40) { writeini $char(%monster.name) status reflect yes | writeini $char(%monster.name) status reflect.timer 1 }


  $boost_monster_stats(%monster.name, demonwall)
  $fulls(%monster.name) 

  set %number.of.monsters.needed 0

  set %curbat $readini(battle2.txt, Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini battle2.txt Battle List %curbat | write battle.txt %monster.name
  $set_chr_name(%monster.name) 
  if ($readini(system.dat, system, botType) = IRC) {  query %battlechan $readini(translation.dat, battle, EnteredTheBattle) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, EnteredTheBattle)) }
  var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname

  set %current.battlefield Dead-End Hallway
  writeini weather.lst weather current Gloomy

  set %boss.item $readini(items.db, items, HealingItems) $+ . $+ $readini(items.db, items, Gems) $+ . $+ $readini(chests.lst, chests, green) $+ . $+ $readini(items.db, items, runes) $+ . $+ $readini(items.db, items, fooditems)
  writeini battle2.txt battle bonusitem %boss.item
  unset %boss.item
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate a demon portal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate_demonportal {
  set %current.battlestreak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.battlestreak <= 0) { set %current.battlestreak 1 }
  set %monster.name Demon_Portal | set %monster.realname Demon Portal

  .copy -o $char(new_chr) $char(%monster.name)
  writeini $char(%monster.name) info flag monster 
  writeini $char(%monster.name) Basestats name %monster.realname
  writeini $char(%monster.name) info password .8V%N)W1T;W5C:'1H:7,`1__.1134
  writeini $char(%monster.name) info BattleStats ignoreHP
  writeini $char(%monster.name) info ai_type portal
  writeini $char(%monster.name) info gender its
  writeini $char(%monster.name) info gender2 its

  var %base.hp.tp $calc(7 * %current.battlestreak)
  if (%portal.bonus = true) { set %current.battlestreak 400 }

  if (%current.battlestreak <= 100) {  writeini $char(%monster.name) basestats hp $rand(300,600) }
  if ((%current.battlestreak > 100) && (%current.battlestreak <= 300)) {  writeini $char(%monster.name) basestats hp $rand(600,1000) }
  if ((%current.battlestreak > 300) && (%current.battlestreak <= 500)) {  writeini $char(%monster.name) basestats hp $rand(1000,2000) }
  if ((%current.battlestreak > 500) && (%current.battlestreak <= 1000)) {  writeini $char(%monster.name) basestats hp $rand(3000,5000) }
  if (%current.battlestreak > 500) {   writeini $char(%monster.name) basestats hp $rand(5000,7000) }

  writeini $char(%monster.name) basestats tp 0
  writeini $char(%monster.name) basestats str 0
  writeini $char(%monster.name) basestats def 0
  writeini $char(%monster.name) basestats int 0
  writeini $char(%monster.name) basestats spd 0

  writeini $char(%monster.name) weapons equipped none
  writeini $char(%monster.name) weapons none %current.battlestreak
  remini $char(%monster.name) weapons none

  writeini $char(%monster.name) skills manawall.on on
  writeini $char(%monster.name) skills royalguard.on on
  writeini $char(%monster.name) skills resist-charm 100
  writeini $char(%monster.name) skills resist-poison 100
  writeini $char(%monster.name) skills resist-confuse 100
  writeini $char(%monster.name) skills resist-stun 100
  writeini $char(%monster.name) skills resist-bored 100
  writeini $char(%monster.name) skills resist-blind 100
  writeini $char(%monster.name) skills resist-paralyze 100

  writeini $char(%monster.name) styles equipped Guardian
  writeini $char(%monster.name) styles guardian $rand(6,10)

  if (%current.battlestreak > 300) {
    var %reflect.chance $rand(1,100)
    if (%reflect.chance <= 50) { writeini $char(%monster.name) status reflect yes | writeini $char(%monster.name) status reflect.timer 1 }
  }

  $fulls(%monster.name) 

  set %curbat $readini(battle2.txt, Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini battle2.txt Battle List %curbat | write battle.txt %monster.name
  $set_chr_name(%monster.name) 
  if ($readini(system.dat, system, botType) = IRC) {  query %battlechan $readini(translation.dat, battle, EnteredTheBattle) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, EnteredTheBattle)) }
  var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname

  if (%mode.gauntlet != on) { set %portal.multiple.wave on }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear dead monsters
; for portals.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
portal.clear.monsters {
  set %monsters.alive 0 | set %old.monster.total $readini(battle2.txt, battleinfo, monsters)

  var %waves.battletxt.lines $lines(battle.txt) | var %waves.battletxt.current.line 1 
  while (%waves.battletxt.current.line <= %waves.battletxt.lines) { 
    var %waves.who.battle $read -l $+ %waves.battletxt.current.line battle.txt
    var %waves.flag $readini($char(%waves.who.battle), info, flag)
    if (%waves.flag != monster) {  write battle3.txt %waves.who.battle | %waves.battle.list = $addtok(%waves.battle.list,%waves.who.battle,46)  }
    if ((%waves.flag = monster) && ($readini($char(%waves.who.battle), battle, hp) > 0)) { inc %monsters.alive 1 | write battle3.txt %waves.who.battle | %waves.battle.list = $addtok(%waves.battle.list,%waves.who.battle,46)  }

    inc %waves.battletxt.current.line 1
  }

  writeini battle2.txt battle list %waves.battle.list
  unset %waves.battle.list

  ; Erase the old battle.txt, erase the bat list out of battle2.txt.
  .remove battle.txt
  .rename battle3.txt battle.txt

  ; Set the # of monsters
  writeini battle2.txt battleinfo monsters %monsters.alive

  if (%monsters.alive < %old.monster.total) {

    ; Clear out the char folder of dead monsters
    var %value 1
    while ($findfile( $char_path , *.char, %value , 0) != $null) {
      set %file $nopath($findfile($char_path ,*.char,%value)) 
      set %name $remove(%file,.char)
      if ((%name = new_chr) || (%name = $null)) { inc %value 1 } 
      else { 
        var %monster.flag $readini($char(%name), Info, Flag)
        if ((%monster.flag = monster) && ($readini($char(%name), battle, hp) <= 0)) { .remove $char(%name) }
        else { inc %value 1 }    
      }
    }
  }

  var %turn.lines $lines(battle.txt) | var %current.turn.line 0
  while (%current.turn.line <= %turn.lines) { 
    var %turn.person $read -l $+ %current.turn.line battle.txt
    if (%turn.person = %who) { set %line %current.turn.line | inc %current.turn.line }
    else { inc %current.turn.line }
  }

  unset %monsters.alive | unset %old.monster.total
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Summon a monster
; For portals
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
portal.summon.monster {
  ; get a random monster and summon the monster to the battelfield

  set %number.of.monsters.needed 1
  set %multiple.wave.bonus yes

  var %bonus.orbs $readini(battle2.txt, battleinfo, portalbonus)
  if (%bonus.orbs = $null) { var %bonus.orbs 0 }
  inc %bonus.orbs 1
  writeini battle2.txt battleinfo portalbonus %bonus.orbs
  if ($readini(system.dat, system, botType) = IRC) {  query %battlechan $readini(translation.dat, system,PortalReinforcements) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, system,PortalReinforcements)) }
  set %number.of.monsters.needed 1
  $generate_monster(monster)

  if (%battleis = on)  { $check_for_double_turn($1) | halt }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function is for applying
; status effects on targets.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inflict_status {
  ; $1 = user
  ; $2 = target
  ; $3 = status type
  ; $4 = optional flag

  if (($readini($char($2), status, ethereal) = yes) && ($readini(techniques.db, $4, magic) != yes)) { return }
  if (%guard.message != $null) { return }

  if ($3 = random) { 
    var %random.status.type $rand(1,16)
    if (%random.status.type = 1) { set %status.type poison | var %status.grammar poisoned }
    if (%random.status.type = 2) { set %status.type stop | var %status.grammar frozen in time }
    if (%random.status.type = 3) { set %status.type blind | var %status.grammar blinded }
    if (%random.status.type = 4) { set %status.type virus | var %status.grammar inflicted with a virus }
    if (%random.status.type = 5) { set %status.type amnesia | var %status.grammar inflicted with amnesia }
    if (%random.status.type = 6) { set %status.type paralysis | var %status.grammar paralyzed }
    if (%random.status.type = 7) { set %status.type zombie | var %status.grammar a zombie }
    if (%random.status.type = 8) { set %status.type slow | var %status.grammar slowed }
    if (%random.status.type = 9) { set %status.type stun | var %status.grammar stunned }
    if (%random.status.type = 10) { set %status.type intimidate | var %status.grammar intimidated }
    if (%random.status.type = 11) { set %status.type defensedown | var %status.grammar inflicted with defense down }
    if (%random.status.type = 12) { set %status.type strengthdown | var %status.grammar inflicted with strength down }
    if (%random.status.type = 13) { set %status.type intdown | var %status.grammar inflicted with int down }
    if (%random.status.type = 14) { set %status.type petrify | var %status.grammar petrified }
    if (%random.status.type = 15) { set %status.type bored | var %status.grammar bored of the battle  }
    if (%random.status.type = 16) { set %status.type confuse | var %status.grammar confused  }
  }

  if ($3 = stop) { set %status.type stop | var %status.grammar frozen in time }
  if ($3 = poison) { set %status.type poison | var %status.grammar poisoned }
  if ($3 = silence) { set %status.type silence | var %status.grammar silenced }
  if ($3 = blind) { set %status.type blind | var %status.grammar blind }
  if ($3 = virus) { set %status.type virus | var %status.grammar inflicted with a virus }
  if ($3 = amnesia) { set %status.type amnesia | var %status.grammar inflicted with amnesia }
  if ($3 = paralysis) { set %status.type paralysis | var %status.grammar paralyzed }
  if ($3 = zombie) { set %status.type zombie | var %status.grammar a zombie }
  if ($3 = slow) { set %status.type slow | var %status.grammar slowed }
  if ($3 = stun) { set %status.type stun | var %status.grammar stunned }
  if ($3 = curse) { set %status.type curse | var %status.grammar cursed }
  if ($3 = charm) { set %status.type charm | var %status.grammar charmed }
  if ($3 = intimidate) { set %status.type intimidate | var %status.grammar intimidated }
  if ($3 = defensedown) { set %status.type defensedown | var %status.grammar inflicted with defense down }
  if ($3 = strengthdown) { set %status.type strengthdown | var %status.grammar inflicted with strength down }
  if ($3 = intdown) { set %status.type intdown | var %status.grammar inflicted with int down }
  if ($3 = petrify) { set %status.type petrify  | var %status.grammar petrified }
  if ($3 = bored) { set %status.type bored | var %status.grammar bored of the battle  }
  if ($3 = confuse) { set %status.type confuse  | var %status.grammar confused }


  var %chance $rand(1,140) | $set_chr_name($1) 
  if ($readini($char($2), skills, utsusemi.on) = on) { set %chance 0 } 

  if ($4 != IgnoreResistance) { 
    ; Check for resistance to that status type.
    set %resist.have resist- $+ %status.type
    set %resist.skill $readini($char($2), skills, %resist.have)

    set %current.style $readini($char($1), styles, equipped) 
    if (%current.style = Doppelganger) {
      if (($readini($char($2), info, clone) = yes) || ($readini($char($1), info, clone) = yes)) {
        set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
        set %decrease.skill.amount $calc(5 * %current.playerstyle.level)
        dec %resist.skill %decrease.skill.amount
        unset %current.playerstyle.level | unset %decrease.skill.amount
      }

    }
    unset %current.style 

    $ribbon.accessory.check($2)
  }

  if (%status.type != paralysis) {  var %enfeeble.timer $rand(0,1) }
  if (%status.type = paralysis) {  var %enfeeble.timer $rand(1,2) }

  if (%status.type = $null) { var %enfeeble.timer $rand(1,2) }

  if ($augment.check($1, EnhanceEnfeeble) = true) { 
    dec %enfeeble.timer %augment.strength
    inc %chance $calc(2 * %augment.strength)
  }

  if (%status.type = charm) {
    if ($readini($char($2), status, zombie) != no) { set %resist.skill 100 }
    if ($readini($char($2), monster, type) = undead) { set %resist.skill 100 }
  }

  if ((%resist.skill <= 100) || (%resist.skill = $null)) {
    if ((%resist.skill != $null) && (%resist.skill > 0)) { dec %chance %resist.skill }
  }

  if (%resist.skill >= 100) { $set_chr_name($2) 
    if (%statusmessage.display != $null) { set %statusmessage.display %statusmessage.display :: %real.name is immune to the %status.type status! }
    if (%statusmessage.display = $null) { set %statusmessage.display 4 $+ %real.name is immune to the %status.type status! }
  }
  if ((%resist.skill < 100) || (%resist.skill = $null)) {

    if (%chance <= 0) { $set_chr_name($2) 
      if (%statusmessage.display != $null) { set %statusmessage.display %statusmessage.display :: %real.name has resisted $set_chr_name($1) %real.name $+ 's $lower(%status.type) status effect! }
      if (%statusmessage.display = $null) { set %statusmessage.display 4 $+ %real.name has resisted $set_chr_name($1) %real.name $+ 's $lower(%status.type) status effect! }
    }
    if ((%chance > 0) && (%chance <= 45)) { $set_chr_name($1)
      if (%statusmessage.display != $null) { set %statusmessage.display %statusmessage.display :: %real.name $set_chr_name($1) %real.name $+ 's $lower(%status.type) status effect has failed }
      if (%statusmessage.display = $null) {  set %statusmessage.display 4 $+ %real.name $+ 's $lower(%status.type) status effect has failed against $set_chr_name($2) %real.name $+ ! }
    }
    if (%chance > 45) { $set_chr_name($2) 
      if (%statusmessage.display != $null) {  set %statusmessage.display %statusmessage.display :: $set_chr_name($2) %real.name is now %status.grammar $+ ! } 
      if (%statusmessage.display = $null) {   $set_chr_name($2) | set %statusmessage.display 4 $+ %real.name is now %status.grammar $+ ! }

      if (%status.type = poison) && ($readini($char($2), status, poison) = yes) { writeini $char($2) status poison no | writeini $char($2) status poison-heavy yes | writeini $char($2) status poison.timer %enfeeble.timer }
      if (%status.type = poison) && ($readini($char($2), status, poison-heavy) != yes) { writeini $char($2) status poison yes | writeini $char($2) status poison.timer %enfeeble.timer }
      if (%status.type = charm) { writeini $char($2) status charmed yes | writeini $char($2) status charmer $1 | writeini $char($2) status charm.timer %enfeeble.timer }
      if (%status.type = curse) { writeini $char($2) Status %status.type yes | writeini $char($2) battle tp 0 }
      if (%status.type = petrify) { writeini $char($2) status petrified yes }

      if (((%status.type != poison) && (%status.type != charm) && (%status.type != petrify))) { writeini $char($2) Status %status.type yes | writeini $char($2) status %status.type $+ .timer %enfeeble.timer   }
    }
  }

  ; If a monster, increase the resistance.
  if ($readini($char($2), info, flag) = monster) {
    if (%resist.skill = $null) { set %resist.skill 2 }
    else { inc %resist.skill 2 }
    writeini $char($2) skills %resist.have %resist.skill
  }
  unset %resist.have | unset %chance
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is for the selfstatus
; option for weapons/techs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
self.inflict_status {
  ; $1 = person
  ; $2 = weapon/technique name
  ; $3 = type (weapon / technique)

  if ($3 = weapon) {  var %self.status.type $readini(weapons.db, $2, selfstatus) }
  if ($3 = tech) {  var %self.status.type $readini(techniques.db, $2, selfstatus) }

  if (%self.status.type = $null) { return }
  if (%self.status.type = none) { return }
  if (%self.status.type = charm) { return }

  if (%self.status.type = stop) { set %status.type stop | var %status.grammar frozen in time }
  if (%self.status.type = poison) { set %status.type poison | var %status.grammar poisoned }
  if (%self.status.type = silence) { set %status.type silence | var %status.grammar silenced }
  if (%self.status.type = blind) { set %status.type blind | var %status.grammar blind }
  if (%self.status.type = virus) { set %status.type virus | var %status.grammar inflicted with a virus }
  if (%self.status.type = amnesia) { set %status.type amnesia | var %status.grammar inflicted with amnesia }
  if (%self.status.type = paralysis) { set %status.type paralysis | var %status.grammar paralyzed }
  if (%self.status.type = zombie) { set %status.type zombie | var %status.grammar a zombie }
  if (%self.status.type = slow) { set %status.type slow | var %status.grammar slowed }
  if (%self.status.type = stun) { set %status.type stun | var %status.grammar stunned }
  if (%self.status.type = curse) { set %status.type curse | var %status.grammar cursed }
  if (%self.status.type = intimidate) { set %status.type intimidate | var %status.grammar intimidated }
  if (%self.status.type = defensedown) { set %status.type defensedown | var %status.grammar inflicted with defense down }
  if (%self.status.type = strengthdown) { set %status.type strengthdown | var %status.grammar inflicted with strength down }
  if (%self.status.type = intdown) { set %status.type intdown | var %status.grammar inflicted with int down }
  if (%self.status.type = petrify) { set %status.type petrify  | var %status.grammar petrified }
  if (%self.status.type = bored) { set %status.type bored | var %status.grammar bored of the battle  }
  if (%self.status.type = confuse) { set %status.type confuse  | var %status.grammar confused }

  if (%statusmessage.display != $null) {  set %statusmessage.display %statusmessage.display :: $set_chr_name($1) %real.name is now %status.grammar $+ ! } 
  if (%statusmessage.display = $null) {   $set_chr_name($1) | set %statusmessage.display 4 $+ %real.name is now %status.grammar $+ ! }


  if (%status.type != paralysis) {  var %enfeeble.timer $rand(0,1) }
  if (%status.type = paralysis) {  var %enfeeble.timer $rand(1,2) }

  if (%status.type = poison) && ($readini($char($1), status, poison) = yes) { writeini $char($1) status poison no | writeini $char($1) status poison-heavy yes | writeini $char($1) status poison.timer %enfeeble.timer }
  if (%status.type = poison) && ($readini($char($1), status, poison-heavy) != yes) { writeini $char($1) status poison yes | writeini $char($1) status poison.timer %enfeeble.timer }
  if (%status.type = curse) { writeini $char($1) Status %status.type yes | writeini $char($1) battle tp 0 }
  if (%status.type = petrify) { writeini $char($1) status petrified yes }

  if (((%status.type != poison) && (%status.type != charm) && (%status.type != petrify))) { writeini $char($1) Status %status.type yes | writeini $char($1) status %status.type $+ .timer %enfeeble.timer   }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for stat-down effects
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
defense_down_check {
  if ($readini($char($1), status, defensedown) = yes) {
    %enemy.defense = $round($calc(%enemy.defense / 4),0)
  }
}

strength_down_check {
  if ($readini($char($1), status, strengthdown) = yes) {
    %base.stat = $round($calc(%base.stat / 4),0)
  }
}

int_down_check {
  if ($readini($char($1), status, intdown) = yes) {
    %base.stat = $round($calc(%base.stat / 4),0)
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Figure out how many monsters
; To add based on streak #.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
winningstreak.addmonster.amount {
  if (%battle.type = orbfountain) { return }
  if (%battle.type = demonwall) { return }
  if (%battle.type = doppelganger) { return }
  if (%battle.type = monster) { 
    ; If the players have been winning a lot then we need to make things more interesting/difficult for them.
    if ((%winning.streak >= 50) && (%winning.streak <= 300)) { inc %number.of.monsters.needed 1 }
    if ((%winning.streak > 300) && (%winning.streak <= 500)) { inc %number.of.monsters.needed 2 }
    if ((%winning.streak > 500) && (%winning.streak <= 1000)) { inc %number.of.monsters.needed 3 }
    if (%winning.streak > 1000) { inc %number.of.monsters.needed 4 }
  }

  if (%battle.type = boss) {
    if ((%winning.streak > 300) && (%winning.streak <= 500)) { inc %number.of.monsters.needed 1 }
    if (%winning.streak > 500) { inc %number.of.monsters.needed 2 }
  }
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if a monster
; would one-shot a player
; on the first round. If so,
; nerf the damage.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
first_round_dmg_chk {
  if ((%current.turn = 1) || (%first.round.protection = yes)) { 
    if (%attack.damage <= 5) { return }
    if (($readini($char($1), info, flag) = monster) && ($readini($char($2), info, flag) = $null)) {
      var %max.health $readini($char($2), basestats, hp) 

      if (%attack.damage >= %max.health) {
        set %attack.damage $round($calc(%max.health * .05),0)
      }
      if ((%weapon.howmany.hits > 1) && (%attack.damage < %max.health)) { 
        if (%attack.damage > 2000) { set %attack.damage $round($calc(%max.health * .05),0) }
      }
      if ((%weapon.howmany.hits > 1) && (%attack.damage >= %max.health)) { 
        set %attack.damage $round($calc(%max.health * .05),0) 
      }
    }
  }
  else { return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if someone
; dodges an attack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
trickster_dodge_check {
  if ($2 = $1) { return }
  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  if (((%current.playerstyle != Trickster) && ($augment.check($1, EnhanceDodge) = false) && ($readini($char($1), skills, thirdeye.on) != on))) { unset %current.playerstyle | unset %current.playerstyle.level | return }
  if (%guard.message != $null) { return }

  var %dodge.chance $rand(1,110)

  if ($augment.check($1, EnhanceDodge) = true) { inc %current.playerstyle.level $calc(20* %augment.strength) | dec %dodge.chance 5
    if (%current.playerstyle.level > 65) { set %current.playerstyle.level 65 }
  }

  if ($readini($char($1), skills, thirdeye.on) = on) {
    var %thirdeye.turns $readini($char($1), status, thirdeye.turn)
    if (%thirdeye.turns = $null) { var %thirdeye.turns 1 }
    dec %thirdeye.turns 1
    writeini $char($1) status thirdeye.turn %thirdeye.turns
    if (%thirdeye.turns <= 0) { writeini $char($1) skills thirdeye.on off | writeini $char($1) status thirdeye.turn 0 }
    var %dodge.chance 0
  }

  if (%current.playerstyle.level = $null) { var %current.playerstyle.level 0 }

  if (%dodge.chance <= %current.playerstyle.level) {
    set %attack.damage 0 | $set_chr_name($1)
    unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %critical.hit.chance | unset %absorb

    ; Add some style to the person who dodged.
    set %stylepoints.to.add $rand(50,80)
    %stylepoints.to.add = $calc((10 * %current.playerstyle.level) + %stylepoints.to.add) 

    $add.stylepoints($1, $2, %stylepoints.to.add,dodge)  
    unset %stylepoints.to.add 

    $calculate.stylepoints($1)

    if (%current.playerstyle = Trickster) {  set %guard.message $readini(translation.dat, battle, TricksterDodged) }
    if (%current.playerstyle != Trickster) { set %guard.message $readini(translation.dat, battle, NormalDodge) }

    unset %current.playerstyle | unset %current.playerstyle.level
    set %trickster.dodged on

    remini battle2.txt style $1 $+ .lastaction

    var %number.of.dodges $readini($char($1), stuff, TimesDodged)
    if (%number.of.dodges = $null) { var %number.of.dodges 0 }
    inc %number.of.dodges 1
    writeini $char($1) stuff TimesDodged %number.of.dodges
    $achievement_check($1, Can'tTouchThis)
  }

  unset %current.playerstyle | unset %current.playerstyle.level | return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if someone
; parries an attack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
weapon_parry_check {
  ; $1 = defending target (the one who will parry)
  ; $2 = attacker
  ; $3 = weapon used

  var %parry.weapon $readini($char($1), weapons, equipped)
  $mastery_check($1, %parry.weapon)
  var %parry.chance $rand(1,100)

  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  if ($augment.check($1, EnhanceParry) = true) { set %mastery.bonus 100 | inc %current.playerstyle.level $calc(10* %augment.strength) | dec %parry.chance %current.playerstyle.level }

  if ((%mastery.bonus = $null) || (%mastery.bonus < 100)) {  unset %current.playerstyle | unset %current.playerstyle.level  | return }

  if (%current.playerstyle = WeaponMaster) { 
    dec %parry.chance %current.playerstyle.level
  }
  unset %current.playerstyle | unset %current.playerstyle.level 

  if (%parry.chance >= 3) { return }

  set %attack.damage 0 | $set_chr_name($1) 
  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %critical.hit.chance | set %attack.damage 0 | unset %absorb

  ; Add some style to the person who dodged.
  set %stylepoints.to.add $rand(70,100)
  %stylepoints.to.add = $calc(%stylepoints.to.add) 

  $add.stylepoints($1, $2, %stylepoints.to.add,parry)  
  unset %stylepoints.to.add 

  remini battle2.txt style $1 $+ .lastaction

  $calculate.stylepoints($1)
  $set_chr_name($1) | set %guard.message $readini(translation.dat, battle, WeaponParry)

  var %number.of.parries $readini($char($1), stuff, TimesParried)
  if (%number.of.parries = $null) { var %number.of.parries 0 }
  inc %number.of.parries 1
  writeini $char($1) stuff TimesParried %number.of.parries
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if someone
; counters an attack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
counter_melee {
  ; $1 = attacker
  ; $2 = defender
  ; $3 = weapon name

  if ($readini($char($1), status, ethereal) = yes) { return }
  if (%guard.message != $null) { return }
  if ($2 = orb_fountain) { return }

  if ($is_charmed($2) = true) { return }
  if ($is_confused($2) = true) { return }

  ; Is the attacker immune to the defender's weapon type? If so, return.
  var %weapon.name $readini($char($2), weapons, equipped)
  set %weapon.type $readini(weapons.db, %weapon.name, type)
  if (%weapon.type != $null) { 
    set %target.weapon.null $readini($char($1), modifiers, %weapon.type)
    if (%target.weapon.null <= 0) { unset %weapon.type | return }
  }

  ; If the counter would normally heal the defender, return.
  set %wpn.element $readini(weapons.db, %weapon.name, element)
  if ((%wpn.element != none) && (%wpn.element != $null)) { 
    var %target.element.heal $readini($char($1), modifiers, heal)
    if ($istok(%target.element.heal,%wpn.element,46) = $true) { unset %wpn.element | unset %weapon.type | return }
  }

  var %counter.chance 2

  ; Check for the CounterStance style
  set %current.playerstyle $readini($char($2), styles, equipped)
  set %current.playerstyle.level $readini($char($2), styles, %current.playerstyle)
  if (%current.playerstyle = CounterStance) { inc %counter.chance %current.playerstyle.level }

  unset %current.playerstyle | unset %current.playerstyle.level 

  ; Check for the EnhanceCounter augment.
  if ($augment.check($2, EnhanceCounter) = true) { inc %counter.chance $calc(2 * %augment.strength)  }

  ; If we have a skill that sets the chance to 100%, check it here.
  ; this is to be added later. :P

  ; Now let's see if we countered.
  var %random.chance $rand(1,100)

  if ($readini($char($2), skills, PerfectCounter.on) = on) { var %random.chance 1 | writeini $char($2) skills PerfectCounter.on off }

  if (%random.chance <= %counter.chance) { 
    set %counterattack on 
    ; Counters will be single-hits.
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %weapon.howmany.hits
    unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %drainsamba.on | unset %absorb | unset %wpn.element 

    set %weapon.element $readini(weapons.db, %weapon.name, element)
    if ((%weapon.element != $null) && (%weapon.element != none)) {
      $modifer_adjust($1, %weapon.element)
    }

    unset %weapon.element

    ; Check for weapon type weaknesses.
    set %weapon.type $readini(weapons.db, %weapon.name, type)
    $modifer_adjust($1, %weapon.type)

    unset %weapon.type


    if ($readini($char($2), info, flag) = $null) { 
      if (($readini($char($1), info, flag) = npc) || ($readini($char($1), info, flag) = monster)) {
      %attack.damage = $round($calc(%attack.damage * 100),0) }
      inc %attack.damage $rand(1,25)
      if (%attack.damage >= 999) { set %attack.damage $rand(900,1500) }
    }

    if ($readini($char($2), info, flag) = monster) { 
      if (($readini($char($1), info, flag) = npc) || ($readini($char($1), info, flag) = $null)) {
        if (%attack.damage >= 999) { set %attack.damage $rand(900,1500) }
      }
    }

    var %number.of.counters $readini($char($2), stuff, TimesCountered)
    if (%number.of.counters = $null) { var %number.of.counters 0 }
    inc %number.of.counters 1
    writeini $char($2) stuff TimesCountered %number.of.counters

    unset %weapon.type
    return
  }

  unset %weapon.type
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for a multiple wave
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
multiple_wave_check {
  if (%multiple.wave = yes) { return }
  if (%battleis = off) { return }
  if (%demonwall.fight = on) { return } 
  if (%portal.bonus = true) { return }
  if (%portal.multiple.wave = on) { return }

  unset %number.of.monsters.needed

  var %winning.streak $readini(battlestats.dat, battle, WinningStreak)
  if (%winning.streak <= 0) { return }

  if (%winning.streak <= 100) { var %multiple.wave.chance $rand(1,2) }
  if ((%winning.streak > 100) && (%winning.streak <= 200)) { var %multiple.wave.chance $rand(2,5) }
  if ((%winning.streak > 200) && (%winning.streak <= 400)) { var %multiple.wave.chance $rand(5,10) }
  if ((%winning.streak > 400) && (%winning.streak <= 700)) { var %multiple.wave.chance $rand(10,15) }
  if (%winning.streak > 700) { var %multiple.wave.chance $rand(11,20) }

  var %random.wave.chance $rand(1,100)
  if (%mode.gauntlet = on) { var %random.wave.chance 1 | inc %mode.gauntlet.wave 1 }
  if (%random.wave.chance > %multiple.wave.chance) { return }

  set %multiple.wave yes |  set %multiple.wave.bonus yes | set %multiple.wave.noaction yes

  ; Clear out the old monsters.
  $multiple_wave_clearmonsters

  ; Create the next wave
  if (%mode.gauntlet = $null) {  
    if ($readini(system.dat, system, botType) = IRC) {  query %battlechan $readini(translation.dat, system,AnotherWaveArrives) }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, system,AnotherWaveArrives)) }
  }
  set %number.of.monsters.needed $rand(2,3)

  set %first.round.protection yes
  set %first.round.protection.turn $calc(%current.turn + 1)

  if ($readini(battle2.txt, battleinfo, players) > 1) { inc %number.of.monsters.needed 1 }
  if (%mode.gauntlet = $null) { $winningstreak.addmonster.amount | $generate_monster(monster) }
  if (%mode.gauntlet != $null) { 

    if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, system,AnotherWaveArrives) [Gauntlet Round: %mode.gauntlet.wave $+ ] | set %number.of.monsters.needed 2  }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, system, AnotherWaveArrives) [Gauntlet Round: %mode.gauntlet.wave $+ ]) | set %number.of.monsters.needed $rand(2,3)  }

    var %m.boss.chance $rand(1,100)
    if (%m.boss.chance > 15) { $generate_monster(monster) }
    if (%m.boss.chance <= 15) { $generate_monster(boss) }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear out old dead monsters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
multiple_wave_clearmonsters {
  ; Get a list of players and store them
  var %waves.battletxt.lines $lines(battle.txt) | var %waves.battletxt.current.line 1 
  while (%waves.battletxt.current.line <= %waves.battletxt.lines) { 
    var %waves.who.battle $read -l $+ %waves.battletxt.current.line battle.txt
    var %waves.flag $readini($char(%waves.who.battle), info, flag)
    if (%waves.flag != monster) {
      write battle3.txt %waves.who.battle
      %waves.battle.list = $addtok(%waves.battle.list,%waves.who.battle,46) 
    }
    inc %waves.battletxt.current.line 1
  }
  writeini battle2.txt battle list %waves.battle.list
  unset %waves.battle.list

  ; Erase the old battle.txt, erase the bat list out of battle2.txt.
  .remove battle.txt
  .rename battle3.txt battle.txt

  ; Set the # of monsters to 0.
  writeini battle2.txt battleinfo monsters 0

  ; Clear out the char folder of dead monsters
  var %value 1
  while ($findfile( $char_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($char_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_chr) || (%name = $null)) { inc %value 1 } 
    else { 
      var %monster.flag $readini($char(%name), Info, Flag)
      if (%monster.flag = monster) { .remove $char(%name) }
      else { inc %value 1 }    
    }
  }

  var %turn.lines $lines(battle.txt) | var %current.turn.line 0
  while (%current.turn.line <= %turn.lines) { 
    var %turn.person $read -l $+ %current.turn.line battle.txt
    if (%turn.person = %who) { set %line %current.turn.line | inc %current.turn.line }
    else { inc %current.turn.line }
  }


  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spawn another monster
; after one dies.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spawn_after_death {
  set %monster.to.spawn $readini($char($1), info, SpawnAfterDeath)

  if (%monster.to.spawn = $null) { return }

  var %isboss $isfile($boss(%monster.to.spawn))
  var %ismonster $isfile($mon(%monster.to.spawn))

  if ((%isboss != $true) && (%ismonster != $true)) { return }  

  if ($isfile($boss(%monster.to.spawn)) = $true) {  .copy -o $boss(%monster.to.spawn) $char(%monster.to.spawn)  }
  if ($isfile($mon(%monster.to.spawn)) = $true) {  .copy -o $mon(%monster.to.spawn) $char(%monster.to.spawn)  }

  ; increase the total # of monsters
  set %battlelist.toadd $readini(battle2.txt, Battle, List) | %battlelist.toadd = $addtok(%battlelist.toadd,%monster.to.spawn,46) | writeini battle2.txt Battle List %battlelist.toadd | unset %battlelist.toadd
  write battle.txt %monster.to.spawn
  var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters

  ; display the description of the spawned monster
  $set_chr_name(%monster.to.spawn) 

  var %bossquote $readini($char(%monster.to.spawn), descriptions, bossquote)

  if ($readini(system.dat, system, botType) = IRC) {
    /.timerThrottle $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,100000) 1 1 /query %battlechan $readini(translation.dat, battle, EnteredTheBattle)
    /.timerThrottle $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,100000) 1 1 /query %battlechan 12 $+ %real.name  $+ $readini($char(%monster.to.spawn), descriptions, char)
    if (%bossquote != $null) {   /.timerThrottle $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,100000) 1 1 /query %battlechan 2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.to.spawn), descriptions, BossQuote) $+ " }
  }
  if ($readini(system.dat, system, botType) = DCCchat) {
    $dcc.battle.message($readini(translation.dat, battle, EnteredTheBattle))
    $dcc.battle.message(12 $+ %real.name  $+ $readini($char(%monster.to.spawn), descriptions, char))
    $dcc.battle.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.to.spawn), descriptions, BossQuote) $+ ")
  }

  ; Boost the monster
  $boost_monster_stats(%monster.to.spawn) 
  $fulls(%monster.to.spawn)

  set %multiple.wave.bonus yes
  set %first.round.protection yes
}

metal_defense_check {
  if ($augment.check($2, IgnoreMetalDefense) = true) { return }
  else { 
    if ($readini($char($1), info, MetalDefense) = true) {  set %attack.damage 0  }
    return
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RENKEI functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
renkei.check {
  var %renkei.techs.total $readini($char($2), renkei, NumberOfTechs)
  if ((%renkei.techs.total <= 1) || (%renkei.techs.total = $null)) { return }

  var %renkei.tech.value $readini($char($2), renkei, TotalRenkeiValue)  

  if (%renkei.techs.total > 2) { inc %renkei.tech.value $rand(5,10) }

  writeini $char($2) renkei NumberOfTechs 0

  var %renkei.tech.damage $readini($char($2), renkei, TotalTechDamage)

  if (%renkei.tech.value < 3) { set %renkei.tech.percent .10 | set %renkei.name Impaction | $set_chr_name($2) | set %renkei.description The techniques combine together to create a large vaccum of air that sucks %real.name inwards before exploding with energy! }
  if ((%renkei.tech.value >= 3) && (%renkei.tech.value <= 5)) { set %renkei.tech.percent .15 | set %renkei.name Scission | $set_chr_name($2) | set %renkei.description The techniques combine together to create a large cut across %real.name $+ 's chest! }
  if ((%renkei.tech.value >= 5) && (%renkei.tech.value < 10)) { set %renkei.tech.percent .20 | set %renkei.name Distortion | $set_chr_name($2) | set %renkei.description The techniques combine together to create a large amount of green energy that surrounds and then slams into %real.name $+ ! }
  if ((%renkei.tech.value >= 10) && (%renkei.tech.value < 15)) { set %renkei.tech.percent .25 | set %renkei.name Fragmentation | $set_chr_name($2) | set %renkei.description The techniques combine together and cause large silver crystals to grow out of %real.name $+ 's body.  The crystals then explode, dealing damage. }
  if ((%renkei.tech.value >= 15) && (%renkei.tech.value <= 20)) { set %renkei.tech.percent .35 | set %renkei.name Darkness | $set_chr_name($2) | set %renkei.description The techniques combine together and the sky grows dark. A huge orb of dark energy appears above %real.name $+ 's head.  The orb grows bigger and bigger before exploding violently ontop of %real.name dealing damage. }
  if (%renkei.tech.value > 20)  { set %renkei.tech.percent .40 | set %renkei.name Light | $set_chr_name($2) | set %renkei.description The techniques combine together and the sky grows bright. A huge orb of pure light energy appears above %real.name $+ 's head.  The orb grows bigger and bigger before exploding violently ontop of %real.name dealing damage. }

  if (%renkei.tech.damage < 100) { inc %renkei.tech.percent .05 }

  set %attack.damage $round($calc(%renkei.tech.damage * %renkei.tech.percent),0) 

  $deal_damage($1, $2, renkei)
  $display_damage($1,$2, renkei)
}

renkei.calculate {
  if ($readini(techniques.db, $3, magic) = yes) { return }
  var %renkei.tech.value $readini($char($2), renkei, TotalRenkeiValue)  
  var %renkei.tech.amount $readini(techniques.db, $3, Renkei)

  if ((%renkei.tech.amount = $null) || (%renkei.tech.amount = 0)) { return }

  if ($augment.check($1, RenkeiBonus) = true) { 
    var %bonus $calc(%augment.strength * 2)
    %renkei.tech.amount = $calc(%renkei.tech.amount * %bonus)
  }

  if (%renkei.tech.value = $null) { writeini $char($2) renkei TotalRenkeiValue %renkei.tech.amount }
  if (%renkei.tech.value != $null) { inc %renkei.tech.value %renkei.tech.amount | writeini $char($2) renkei TotalRenkeiValue %renkei.tech.value }

  var %renkei.techs.total $readini($char($2), renkei, NumberOfTechs)
  if (%renkei.techs.total = $null) { var %renkei.techs.total 0 }

  if ($readini($char($1), skills, konzen-ittai.on) = on) { inc %renkei.techs.total 2 | writeini $char($1) skills konzen-ittai.on off }
  if ($readini($char($1), skills, konzen-ittai.on) != on) { inc %renkei.techs.total 1 }

  writeini $char($2) renkei NumberOfTechs %renkei.techs.total 

  var %renkei.tech.damage $readini($char($2), renkei, TotalTechDamage)
  if (%renkei.tech.damage = $null) { writeini $char($2) renkei TotalTechDamage %attack.damage }
  if (%renkei.tech.damage != $null) { inc %renkei.tech.damage %attack.damage | writeini $char($2) renkei TotalTechDamage %renkei.tech.damage }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BATTLEFIELD stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random.battlefield.pick {
  if (%current.battlefield != $null) { return }
  var %battlefields.list $readini(battlefields.lst, battlefields, list)
  set %random $rand(1, $numtok(%battlefields.list,46))
  if (%random = $null) { var %random 1 }
  set %current.battlefield $gettok(%battlefields.list,%random,46)
  unset %random 
}

battlefield.event {
  set %debug.location alias battlefield.event
  if ($readini(battlestats.dat, battle, winningstreak) < 15) { return }
  if ($readini(system.dat, system, EnableBattlefieldEvents) != true) { return }

  set %number.of.events $readini(battlefields.lst, %current.battlefield, NumberOfEvents)

  if ((%number.of.events = $null) || (%number.of.events = 0)) { unset %number.of.events | return }

  set %battlefield.event.number $rand(1,%number.of.events)

  var %random.chance $rand(1,100)

  if (%random.chance > $readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ chance)) { unset %battlefield.event.number | unset %number.of.events | return }

  set %battlefield.event.target $readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ target)
  if ($readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ statusType) != $null) { set %event.status.type $readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ statusType) }

  if (%battlefield.event.target = all) {
    $display.system.message(4 $+ $readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ desc), battle)

    var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      var %who.battle $read -l $+ %battletxt.current.line battle.txt
      if ($readini($char(%who.battle), battle, status) = dead) { inc %battletxt.current.line }
      else {
        if (%event.status.type != $null) { writeini $char(%who.battle) status %event.status.type yes }
        if ($readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number) = damage) { 

          var %number.of.bfevents $readini($char(%who.battle), stuff, TimesHitByBattlefieldEvent)
          if (%number.of.bfevents = $null) { var %number.of.bfevents 0 }
          inc %number.of.bfevents 1
          writeini $char(%who.battle) stuff TimesHitByBattlefieldEvent %number.of.bfevents
          $achievement_check(%who.battle, NeverAskedForThis)
          set %attack.damage $readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ amount)
          $metal_defense_check(%who.battle, battlefield)
          if (%attack.damage <= 0) { set %attack.damage 1 }
          $deal_damage(battlefield, %who.battle, battlefield)
          $display_aoedamage(battlefield, %who.battle, battlefield)
        }
        if ($readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number) = heal) {
          $heal_damage($1, %who.battle, $2)
          $display_heal(battlefield, %who.battle ,aoeheal, battlefield)
        }
        inc %battletxt.current.line
      }
    }
  }

  if (%battlefield.event.target = random) {
    var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      var %who.battle $read -l $+ %battletxt.current.line battle.txt
      if (($readini($char(%who.battle), battle, hp) <= 0) || ($readini($char(%who.battle), battle, status) = runaway)) { inc %battletxt.current.line }
      else {  %alive.members = $addtok(%alive.members, %who.battle, 46)  }
      inc %battletxt.current.line
    }

    set %number.of.members $numtok(%alive.members, 46)

    if (%number.of.members = $null) { unset %number.of.members | unset %alive.members | return }

    set %random.member $rand(1,%number.of.members)
    set %member $gettok(%alive.members,%random.member,46)

    unset %random.member | unset %alive.members | unset %number.of.members

    if ($readini($char(%member), battle, hp) = $null) { halt }

    $set_chr_name(%member) 
    $display.system.message(4 $+ $readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ desc), battle)

    if (%event.status.type != $null) { writeini $char(%member) status %event.status.type yes }
    if ($readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number) = damage) { 
      var %number.of.bfevents $readini($char(%member), stuff, TimesHitByBattlefieldEvent)
      if (%number.of.bfevents = $null) { var %number.of.bfevents 0 }
      inc %number.of.bfevents 1
      writeini $char(%member) stuff TimesHitByBattlefieldEvent %number.of.bfevents
      $achievement_check(%member, NeverAskedForThis)
      set %attack.damage $readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ amount)
      $metal_defense_check(%member, battlefield)
      if (%attack.damage <= 0) { set %attack.damage 1 }
      $deal_damage(battlefield, %member, battlefield)
      $display_aoedamage(battlefield, %member, battlefield)
    }
    if ($readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number) = heal) {
      set %attack.damage $readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ amount)
      $heal_damage($1, %member, $2)
      $display_heal(battlefield, %member, aoeheal, battlefield)
    }

    unset %member
  }

  if (%battlefield.event.target = monsters) {
    $display.system.message(4 $+ $readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ desc), battle)
    var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      var %who.battle $read -l $+ %battletxt.current.line battle.txt
      if ($readini($char(%who.battle), battle, hp) <= 0)  { inc %battletxt.current.line }
      else if (($readini($char(%who.battle), info, flag) = $null) || ($readini($char(%who.battle), info, flag) = npc)) { inc %battletxt.current.line }
      else if ($readini($char(%who.battle), battle, status) = runaway) { inc %battletxt.current.line }
      else {
        if (%event.status.type != $null) { writeini $char(%who.battle) status %event.status.type yes }
        if ($readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number) = damage) { 
          set %attack.damage $readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ amount)

          $metal_defense_check(%who.battle, battlefield)
          if (%attack.damage <= 0) { set %attack.damage 1 }

          $deal_damage(battlefield, %who.battle, battlefield)
          $display_aoedamage(battlefield, %who.battle, battlefield)
        }
        if ($readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number) = heal) {
          set %attack.damage $readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ amount)
          $heal_damage($1, %who.battle, $2)
          $display_heal(battlefield, %who.battle ,aoeheal, battlefield)
        }
        inc %battletxt.current.line
      }
    }
  }

  if (%battlefield.event.target = players) {
    $display.system.message(4 $+ $readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ desc), battle)
    var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      var %who.battle $read -l $+ %battletxt.current.line battle.txt
      if (($readini($char(%who.battle), battle, hp) <= 0) || ($readini($char(%who.battle), info, flag) = monster)) { inc %battletxt.current.line }
      else if ($readini($char(%who.battle), battle, status) = runaway) { inc %battletxt.current.line }
      else {

        if (%event.status.type != $null) { writeini $char(%who.battle) status %event.status.type yes }
        if ($readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number) = damage) { 

          var %number.of.bfevents $readini($char(%who.battle), stuff, TimesHitByBattlefieldEvent)
          if (%number.of.bfevents = $null) { var %number.of.bfevents 0 }
          inc %number.of.bfevents 1
          writeini $char(%who.battle) stuff TimesHitByBattlefieldEvent %number.of.bfevents
          $achievement_check(%who.battle, NeverAskedForThis)

          set %attack.damage $readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ amount)
          $metal_defense_check(%who.battle, battlefield)
          if (%attack.damage <= 0) { set %attack.damage 1 }

          $deal_damage(battlefield, %who.battle, battlefield)
          $display_aoedamage(battlefield, %who.battle, battlefield)
        }

        if ($readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number) = heal) {
          set %attack.damage $readini(battlefields.lst, %current.battlefield, event $+ %battlefield.event.number $+ amount)
          $heal_damage(battlefield, %who.battle, battlefield)
          $display_heal(battlefield, %who.battle, aoeheal, battlefield)
        }
        inc %battletxt.current.line
      }
    }
  }

  unset %battlefield.event.number | unset %number.of.events | unset %battlefield.event.target
  unset %battlefield.event.target | unset %event.status.type
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for boosts to
; attack damage based on
; several offensive styles.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
offensive.style.check {
  ; $1 = attacker
  ; $2 = weapon/tech name
  ; $3 = flag: melee, tech, magic
  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  if (%current.playerstyle = WeaponMaster) { 
    if (($3 = melee) || ($3 = tech)) {
      $mastery_check($1, $2)

      var %amount.to.increase $calc(.05 * %current.playerstyle.level)
      if (%amount.to.increase >= .70) { var %amount.to.increase .70 }
      var %wpnmst.increase $round($calc(%amount.to.increase * %attack.damage),0)
      inc %attack.damage %wpnmst.increase
      var %playerstyle.bonus $round($calc(%current.playerstyle.level * 1.5),0)
      inc %mastery.bonus %playerstyle.bonus
      inc %attack.damage %mastery.bonus
    }
  }

  if (($3 = melee) || ($3 = tech)) {
    if (%current.playerstyle = HitenMitsurugi-ryu) {
      if ($readini(weapons.db, $2, type) = Katana) {
        var %amount.to.increase $calc(.05 * %current.playerstyle.level)
        if (%amount.to.increase >= .80) { var %amount.to.increase .80 }
        var %hmr.increase $round($calc(%amount.to.increase * %attack.damage),0)
        inc %attack.damage %hmr.increase
      }    
    }
  }

  if ($3 = magic) {
    if (%current.playerstyle = SpellMaster) { inc %magic.bonus.modifier $calc(%current.playerstyle.level * .115)
      if (%magic.bonus.modifier >= 1) { set %magic.bonus.modifier .90 }
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if an
; Ethereal monster can be
; hurt.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
melee.ethereal.check {
  if ($readini($char($3), status, ethereal) = yes) {
    if (($readini(weapons.db, $2, HurtEthereal) != true) && ($augment.check($1, HurtEthereal) = false)) {
      $set_chr_name($1) | set %guard.message $readini(translation.dat, status, EtherealBlocked) | set %attack.damage 0 | return
    }
  }
}

magic.ethereal.check {
  ; $1 = attacker
  ; $2 = technique
  ; $3 = target

  if (($readini($char($3), status, ethereal) = yes) && ($readini(techniques.db, $2, magic) != yes)) {
    $set_chr_name($1) | set %guard.message $readini(translation.dat, status, EtherealBlocked) | set %attack.damage 0 | return
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if Utsusemi 
; is on
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
utsusemi.check {
  ; $1 = attacker
  ; $2 = weapon/tech
  ; $3 = target

  if (%guard.message != $null) { return }
  if ($readini(techniques.db, $2, type) = heal) { return }

  var %utsusemi.flag $readini($char($3), skills, utsusemi.on)

  if (%utsusemi.flag = on) {
    var %number.of.shadows $readini($char($3), skills, utsusemi.shadows)
    dec %number.of.shadows 1 
    writeini $char($3) skills utsusemi.shadows %number.of.shadows
    if (%number.of.shadows <= 0) { writeini $char($3) skills utsusemi.on off }
    $set_chr_name($3) | set %guard.message $readini(translation.dat, skill, UtsusemiBlocked) | set %attack.damage 0 | return 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if Royal
; Guard is on.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
royalguard.check {
  ; $1 = attacker
  ; $2 = weapon/tech
  ; $3 = target

  if (%guard.message != $null) { return }
  ; does the target have RoyalGuard on?  If so, reduce the damage to 0.
  if ($readini($char($3), skills, royalguard.on) = on) { 
    writeini $char($3) skills royalguard.on off 
    var %total.blocked.damage $readini($char($3), skills, royalguard.dmgblocked)
    if (%total.blocked.damage = $null) { var %total.blocked.damage 0 }
    inc %total.blocked.damage %attack.damage
    writeini $char($3) skills royalguard.dmgblocked %total.blocked.damage
    set %attack.damage 0 | $set_chr_name($3) | set %guard.message $readini(translation.dat, skill, RoyalGuardBlocked) | return 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if Mana Wall
; is on
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
manawall.check {
  ; $1 = attacker
  ; $2 = weapon/tech
  ; $3 = target

  if (%guard.message != $null) { return }
  if ($readini(techniques.db, $2, type) = heal) { return }

  if (($readini($char($3), skills, manawall.on) = on) && ($readini(techniques.db, $2, magic) = yes)) { 
    writeini $char($3) skills manawall.on off | set %attack.damage 0 | $set_chr_name($3) | set %guard.message $readini(translation.dat, skill, ManaWallBlocked) | return 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function checks to
; see if someone is being
; protected by someone else.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
covercheck {
  ; $3 = AOE for AOE stuff
  var %cover.target $readini($char($1), skills, CoverTarget)
  if ((%cover.target = none) || (%cover.target = $null)) { set %attack.target $1 | return } 

  var %cover.status $readini($char(%cover.target), battle, status)
  if ((%cover.status = dead) || (%cover.status = runaway)) { writeini $char($1) skills CoverTarget none | set %attack.target $1 | return } 

  if ($readini(techniques.db, $2, Type) = heal) { set %attack.target $1 | return }
  if ($readini(techniques.db, $2, Type) = heal-AOE) { set %attack.target $1 | return }

  if ($3 != AOE) {  set %attack.target %cover.target 
    set %covering.someone on
  }
  if ($3 = AOE) { set %who.battle %cover.target }
  writeini $char($1) skills CoverTarget none

  if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, battle, TargetCovered) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, TargetCovered)) }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; These functions are for
; Battle Formula 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate_pDIF {
  ; $1 = attacker
  ; $2 = defender
  ; $3 = melee, tech, magic

  %cRatio = $calc(%attack.damage / %enemy.defense)

  var %attacker.level $get.level($1)
  var %defender.level $get.level($2)
  var %level.difference $calc(%attacker.level - %defender.level)

  if (%level.difference >= 50) { var %level.difference 50 }
  if (%level.difference <= -50) { var %level.difference -50 }

  var %cRatio.modifier $calc(0.05 * %level.difference)

  inc %cRatio %cRatio.modifier

  if (%cRatio > 2) { %cRatio = 2 }
  else { %cRatio = $round(%cRatio, 3) }

  $calculate_maxpDIF
  $calculate_minpDIF

  set %pDIF.max $round($calc(10 * %maxpDIF),0)
  set %pDIF.min $round($calc(10 * %minpDIF),0)
  set %pDIF $rand(%pDIF.min, %pDIF.max)

  %pDIF = $round($calc(%pDIF / 10),3)

  if (%pDIF <= 0) { 
    if ($isfile($boss($1)) = $true) { %pDIF = .005 }
    if (%battle.type = boss) { %pDIF = .005 }
  }

  unset %pDIF.max | unset %pDIF.min | unset %cRatio
  unset %maxpDIF | unset %minpDIF 

  if ($3 = melee) {
    if ($mighty_strike_check($1) = true) {
      if (%pDIF > 0) {  inc %pDIF .8 }
      if (%pDIF <= 0) { set %pDIF .5 }
    }
  }

  if ($3 = magic) {
    if ($readini($char($1), skills, elementalseal.on) = on) { 
      if (%pDIF > 0) {  inc %pDIF .8 }
      if (%pDIF <= 0) { set %pDIF .5 }
    }
  }

  if (%enemy.defense = 1) {
    if (%pDIF > 0) {  inc %pDIF .5 }
    if (%pDIF <= 0) { set %pDIF .5 }
  }
}

calculate_maxPDIF {
  if (%cRatio <= 0.5) { set %maxpDIF $calc(0.4 + (1.2 * %cRatio)) }
  if ((%cRatio > 0.5) && (%cRatio <= 0.833)) { set %maxpDIF 1 }
  if ((%cRatio > 0.833) && (%cRatio <= 2)) { set %maxpDIF $calc(1 + (1.2 * (%cRatio - .833))) }
}

calculate_minPDIF {
  if (%cRatio <= 1.25) { set %minpDIF $calc(-.5 + (%cRatio * 1.2)) }
  if ((%cRatio > 1.25) && (%cRatio <= 1.5)) {  set %minpDIF 1 }
  if ((%cRatio > 1.5) && (%cRatio <= 2)) { set %minpDIF $calc(-.8 + (1.2 * %cRatio)) }

  if (%minpDIF <= 0) { set %minpDIF 1 }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Boost a Demon Wall's
; attack based on time
; remaining in the timer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

demon.wall.boost {
  if (%battle.rage.darkness = $null) { 
    set %total.darkness.timer.dw $calc(300-$timer(battlerage).secs)

    if (%total.darkness.timer.dw <= 30) { set %attack.damage %attack.damage }
    if ((%total.darkness.timer.dw > 30) && (%total.darkness.timer.dw <= 60)) { set %attack.damage $round($calc(%attack.damage * 1.5),0)) }
    if ((%total.darkness.timer.dw > 60) && (%total.darkness.timer.dw <= 90)) { set %attack.damage $round($calc(%attack.damage * 2),0)) }
    if ((%total.darkness.timer.dw > 90) && (%total.darkness.timer.dw <= 120)) { set %attack.damage $round($calc(%attack.damage * 2.5),0)) }
    if ((%total.darkness.timer.dw > 120) && (%total.darkness.timer.dw <= 180)) { set %attack.damage $round($calc(%attack.damage * 3),0)) }
    if ((%total.darkness.timer.dw > 180) && (%total.darkness.timer.dw <= 240)) { set %attack.damage $round($calc(%attack.damage * 3.5),0)) }
    if ((%total.darkness.timer.dw > 240) && (%total.darkness.timer.dw <= 270)) { set %attack.damage $round($calc(%attack.damage * 4),0)) }
    if (%total.darkness.timer.dw > 270) { set %attack.damage $round($calc(%attack.damage * 5),0)) }
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Multiple Hits Calculations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
double.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %original.attackdmg %attack.damage

  set %double.attack.chance $3
  if (%double.attack.chance >= 90) { set %double.attack true

    set %attack.damage1 %attack.damage
    set %attack.damage2 $abs($round($calc(%original.attackdmg  / 3),0))

    if (%attack.damage2 <= 0) { set %attack.damage2 1 }

    var %attack.damage3 $calc(%attack.damage1 + %attack.damage2)
    if (%attack.damage3 > 0) {   
      set %attack.damage %attack.damage3 | $set_chr_name($1) 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, battle, PerformsADoubleAttack) }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, PerformsADoubleAttack)) }
    } 
    unset %double.attack.chance | unset %original.attackdmg 
  }
  else { unset %double.attack.chance | return }
}
triple.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %triple.attack true

  set %original.attackdmg %attack.damage

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%original.attackdmg / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 2.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage %attack.damage.total | $set_chr_name($1) 

  if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, battle, PerformsATripleAttack) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, PerformsATripleAttack)) }

  unset %original.attackdmg
}
fourhit.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %fourhit.attack true

  set %original.attackdmg %attack.damage

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%original.attackdmg / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 3.9),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage %attack.damage.total | $set_chr_name($1) 

  if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, battle, PerformsA4HitAttack) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, PerformsA4HitAttack)) }

  unset %original.attackdmg
}
fivehit.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %fivehit.attack true

  set %original.attackdmg %attack.damage

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%original.attackdmg / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 4.1),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage5 $abs($round($calc(%original.attackdmg / 4.9),0))
  if (%attack.damage5 <= 0) { set %attack.damage5 1 }
  var %attack.damage.total $calc(%attack.damage5 + %attack.damage.total)
  set %attack.damage %attack.damage.total | $set_chr_name($1)

  if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, battle, PerformsA5HitAttack) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, PerformsA5HitAttack)) }
  unset %original.attackdmg
}
sixhit.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total  set %sixhit.attack true

  set %original.attackdmg %attack.damage

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%original.attackdmg / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 4.1),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage5 $abs($round($calc(%original.attackdmg / 4.9),0))
  if (%attack.damage5 <= 0) { set %attack.damage5 1 }
  var %attack.damage.total $calc(%attack.damage5 + %attack.damage.total)

  set %attack.damage6 $abs($round($calc(%original.attackdmg / 6.9),0))
  if (%attack.damage6 <= 0) { set %attack.damage6 1 }
  var %attack.damage.total $calc(%attack.damage6 + %attack.damage.total)

  set %attack.damage %attack.damage.total | $set_chr_name($1)
  if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, battle, PerformsA6HitAttack) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, PerformsA6HitAttack)) }

  unset %original.attackdmg
}
sevenhit.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %sevenhit.attack true

  set %original.attackdmg %attack.damage

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%original.attackdmg / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 4.1),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage5 $abs($round($calc(%original.attackdmg / 4.9),0))
  if (%attack.damage5 <= 0) { set %attack.damage5 1 }
  var %attack.damage.total $calc(%attack.damage5 + %attack.damage.total)

  set %attack.damage6 $abs($round($calc(%original.attackdmg / 6.9),0))
  if (%attack.damage6 <= 0) { set %attack.damage6 1 }
  var %attack.damage.total $calc(%attack.damage6 + %attack.damage.total)

  set %attack.damage7 $abs($round($calc(%original.attackdmg / 8.9),0))
  if (%attack.damage7 <= 0) { set %attack.damage7 1 }
  var %attack.damage.total $calc(%attack.damage7 + %attack.damage.total)

  set %attack.damage %attack.damage.total | $set_chr_name($1) 

  if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, battle, PerformsA7HitAttack) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, PerformsA7HitAttack)) }

  unset %original.attackdmg
}
eighthit.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  set %eighthit.attack true

  set %original.attackdmg %attack.damage

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%original.attackdmg / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%original.attackdmg / 3.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%original.attackdmg / 4.1),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage5 $abs($round($calc(%original.attackdmg / 4.9),0))
  if (%attack.damage5 <= 0) { set %attack.damage5 1 }
  var %attack.damage.total $calc(%attack.damage5 + %attack.damage.total)

  set %attack.damage6 $abs($round($calc(%original.attackdmg / 6.9),0))
  if (%attack.damage6 <= 0) { set %attack.damage6 1 }
  var %attack.damage.total $calc(%attack.damage6 + %attack.damage.total)

  set %attack.damage7 $abs($round($calc(%original.attackdmg / 8.9),0))
  if (%attack.damage7 <= 0) { set %attack.damage7 1 }
  var %attack.damage.total $calc(%attack.damage7 + %attack.damage.total)

  set %attack.damage8 $abs($round($calc(%original.attackdmg / 9.9),0))
  if (%attack.damage8 <= 0) { set %attack.damage8 1 }
  var %attack.damage.total $calc(%attack.damage8 + %attack.damage.total)

  set %attack.damage %attack.damage.total | $set_chr_name($1) 
  if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, battle, PerformsA8HitAttack) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, PerformsA8HitAttack)) }

  unset %original.attackdmg
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Modifier Checks for
; elements and weapon types
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
modifer_adjust {
  ; $1 = target
  ; $2 = element or weapon type

  if (%guard.message != $null) { return }

  ; Let's get the adjust value.
  var %modifier.adjust.value $readini($char($1), modifiers, $2)
  if (%modifier.adjust.value = $null) { var %modifier.adjust.value 100 }

  ; Turn it into a deciminal
  var %modifier.adjust.value $calc(%modifier.adjust.value / 100) 

  ; If it's over 1, then it means the target is weak to the element/weapon so we can adjust the target's def a little as an extra bonus.
  if (%modifier.adjust.value > 1) {
    var %mon.temp.def $readini($char($1), battle, def)
    var %mon.temp.def = $round($calc(%mon.temp.def - (%mon.temp.def * .10)),0)
    if (%mon.temp.def < 0) { var %mon.temp.def 0 }
    writeini $char($1) battle def %mon.temp.def
  }

  ; If it's under 1, it means the target is resistant to the element/weapon.  Let's make the monster stronger for using something it's resistant to.

  if (%modifier.adjust.value < 1) {
    var %mon.temp.str $readini($char($1), battle, str)
    var %mon.temp.str = $round($calc(%mon.temp.str + (%mon.temp.str * .10)),0)
    if (%mon.temp.str < 0) { var %mon.temp.str 0 }
    writeini $char($1) battle str %mon.temp.str
  }

  ; Adjust the attack damage.
  set %attack.damage $round($calc(%attack.damage * %modifier.adjust.value),0)

}
