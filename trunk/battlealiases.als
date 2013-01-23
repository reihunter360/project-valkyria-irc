check_for_battle { 
  if (%wait.your.turn = on) { query %battlechan $readini(translation.dat, errors, WaitYourTurn) | halt }
  if ((%battleis = on) && (%who = $1)) { return }
  if ((%battleis = on) && (%who != $1)) { query %battlechan $readini(translation.dat, errors, WaitYourTurn) | halt }
  else { return  }
}

boost_summon_stats {
  var %hp $readini($char($1 $+ _summon), BaseStats, HP)
  var %tp $readini($char($1 $+ _summon), BaseStats, TP)
  var %str $readini($char($1 $+ _summon), BaseStats, Str)
  var %def $readini($char($1 $+ _summon), BaseStats, Def)
  var %int $readini($char($1 $+ _summon), BaseStats, Int)
  var %spd $readini($char($1 $+ _summon), BaseStats, Spd)

  set %increase.amount $calc(.505 * $2) 
  inc %increase.amount $calc($rand(1,5) / 100)

  if ($augment.check($1, EnhanceSummons) = true) { inc %increase.amount 1 } 

  inc %hp $round($calc(%hp * %increase.amount),0) 
  inc %tp $round($calc(%tp * %increase.amount),0) 
  inc %str $round($calc(%str * %increase.amount),0) 
  inc %def $round($calc(%def * %increase.amount),0) 
  inc %int $round($calc(%int * %increase.amount),0) 
  inc %spd $round($calc(%spd * %increase.amount),0) 

  ; Increase some of the summon's stats based on the user's stats..

  inc %str $round($calc($readini($char($1), basestats, str) * (0.025 * $2)),0)
  inc %def $round($calc($readini($char($1), basestats, def) * (0.025 * $2)),0)
  inc %int $round($calc($readini($char($1), basestats, int) *  (0.025 * $2)),0)
  inc %spd $round($calc($readini($char($1), basestats, spd) * (0.025 * $2)),0)

  writeini $char($1 $+ _summon) BaseStats HP %hp
  writeini $char($1 $+ _summon) BaseStats TP %tp
  writeini $char($1 $+ _summon) BaseStats Str %str
  writeini $char($1 $+ _summon) BaseStats Def %def
  writeini $char($1 $+ _summon) BaseStats Int %int
  writeini $char($1 $+ _summon) BaseStats Spd %spd

  $fulls($1 $+ _summon)
}

boost_monster_stats {
  if ($readini($char($1), info, BattleStats) = ignore) { return }

  var %hp $readini($char($1), BaseStats, HP)
  var %tp $readini($char($1), BaseStats, TP)
  var %str $readini($char($1), BaseStats, Str)
  var %def $readini($char($1), BaseStats, Def)
  var %int $readini($char($1), BaseStats, Int)
  var %spd $readini($char($1), BaseStats, Spd)

  var %shop.level $readini(battle2.txt, BattleInfo, ShopLevel)
  var %winning.streak $readini(battlestats.dat, battle, winningstreak)
  var %level.boost $readini(battlestats.dat, battle, LevelAdjust)
  var %number.of.players.in.battle $readini(battle2.txt, battleinfo, players)
  var %difficulty $readini(battle2.txt, BattleInfo, Difficulty)

  if (%number.of.players.in.battle = $null) { var %number.of.players.in.battle 1 }
  if (%shop.level = $null) { var %shop.level $rand(1,5) } 


  if (%number.of.players.in.battle = 1) {  %shop.level = $round($calc(%shop.level / (%number.of.players.in.battle + 2)),0) }
  if (%number.of.players.in.battle >= 2) { 
    %shop.level = $round($calc(%shop.level / (%number.of.players.in.battle + 3)),0)
  }

  if (%winning.streak <= 0) { var %winning.streak $calc($readini(battlestats.dat, battle, losingstreak) * -1) }

  var %monster.level 0
  inc %monster.level %winning.streak
  inc %monster.level %level.boost
  inc %monster.level %shop.level
  inc %monster.level %difficulty

  if (%mode.gauntlet.wave != $null) {  inc %monster.level %mode.gauntlet.wave | inc %winning.streak %mode.gauntlet.wave }

  if ((%winning.streak > 20) && (%winning.streak <= 100)) {
    if ($isfile($boss($1)) = $true) { inc %monster.level $rand(1,2) | inc %hp $rand(25,150)  }
    if ($isfile($boss($1)) = $false) { inc %hp $rand(20,50) }
  }

  if (%winning.streak > 100) {
    if ($isfile($boss($1)) = $true) { inc %monster.level $rand(1,2) | inc %hp $rand(25,150)  }
    if ($isfile($boss($1)) = $false) { inc %hp $rand(30,70) }
  }

  if ($2 = rage) { set %increase.amount 1000 }
  if ($2 = doppelganger) {
    if (%winning.streak < 100) {  set %increase.amount $calc(%monster.level * .012275) }
    if ((%winning.streak >= 100) && (%winning.streak < 200)) {  set %increase.amount $calc(%monster.level * .006075) }
    if ((%winning.streak >= 200) && (%winning.streak < 300)) {  set %increase.amount $calc(%monster.level * .007075) }
    if (%winning.streak >= 300) {  set %increase.amount $calc(%monster.level * .0005075) }
    if ($readini($char($1), styles, equipped) = Doppelganger) { dec %increase.amount 1.505 }
  }
  if ($2 = warmachine) {  set %increase.amount $calc(%monster.level * .0575)  }
  if ($2 = $null) { 
    if ($isfile($boss($1)) = $true) {
      set %increase.amount $calc(%monster.level * .16355)
    }
    if ($isfile($boss($1)) = $false) {
      set %increase.amount $calc(%monster.level * .248255)
    }
    if ($isfile($npc($1)) = $true) {
      set %increase.amount $calc(%monster.level * .05355)
    }
  }

  if ($2 = evolve) { set %increase.amount .5114 }

  inc %increase.amount 1

  if (%increase.amount <= 0) { set %increase.amount .01 }

  if ($readini($char($1), info, BattleStats) = hp) { %hp = $round($calc(%hp * %increase.amount),0) | writeini $char($1) BaseStats HP %hp  | return }
  if ($readini($char($1), info, BattleStats) != ignorehp) { 
    %hp = $round($calc(%hp * %increase.amount),0) 
    if (%hp > 50000) { %hp = 50000 }
  }

  %tp = $round($calc(%tp * %increase.amount),0) 
  %str = $round($calc(%str * %increase.amount),0) 
  %def = $round($calc(%def * %increase.amount),0) 
  %int = $round($calc(%int * %increase.amount),0) 
  %spd = $round($calc(%spd * %increase.amount),0) 

  writeini $char($1) BaseStats HP %hp
  writeini $char($1) BaseStats TP %tp
  writeini $char($1) BaseStats Str %str
  writeini $char($1) BaseStats Def %def
  writeini $char($1) BaseStats Int %int
  if ($2 != doppelganger) {
    writeini $char($1) BaseStats Spd %spd
  }

  if (($2 != doppelganger) && ($readini($char($1), info, IgnoreWeaponBoost) != true)) {
    ; Set the weapon's power based on the streak if it's higher than the monster's current weapon level
    set %current.monster.weapon $readini($char($1), weapons, equipped)
    set %current.monster.weapon.level $readini($char($1), weapons, %current.monster.weapon)
    if (%current.monster.weapon.level < %winning.streak) { writeini $char($1) weapons %current.monster.weapon %winning.streak }
  }
  unset %increase.amount | unset %current.monster.weapon | unset %current.monster.weapon.level
}

loses_nerf { 
  if ($readini($char($1), info, BattleStats) = ignore) { return }
  ; The players have lost battles, so we need to nerf the monsters.  The more times the players lose, the weaker monsters become to help them win one.
  var %str $readini($char($1), BaseStats, Str)
  var %def $readini($char($1), BaseStats, Def)
  var %int $readini($char($1), BaseStats, Int)
  var %spd $readini($char($1), BaseStats, Spd)

  var %losing.streak $readini(battlestats.dat, battle, LosingStreak)

  if (%losing.streak <= 5) {   var %decrease.amount $calc(.2 * %losing.streak) }
  else { var %decrease.amount $calc(.5 * %losing.streak) }
  inc %decrease.amount 1

  %str = $round($calc(%str / %decrease.amount),0) 
  %def = $round($calc(%def / %decrease.amount),0) 
  %int = $round($calc(%int / %decrease.amount),0) 
  %spd = $round($calc(%spd / %decrease.amount),0) 

  writeini $char($1) BaseStats Str %str
  writeini $char($1) BaseStats Def %def
  writeini $char($1) BaseStats Int %int
  writeini $char($1) BaseStats Spd %spd
}

person_in_battle {
  set %temp.battle.list $readini(battle2.txt, Battle, List)
  if ($istok(%temp.battle.list,$1,46) = $false) {  unset %temp.battle.list | query %battlechan $set_chr_name($1) $readini(translation.dat, errors, NotInbattle) | unset %real.name | halt }
  else { return }
}

check_for_double_turn {  $set_chr_name($1)
  unset  %wait.your.turn
  if ($readini($char($1), skills, doubleturn.on) = on) { 

    ; Are all the monsters defeated?  If so, we need to end the battle as a victory.
    if ($battle.monster.death.check = true) { /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle victory | halt }

    ; Are all the players defeated?  If so, we need to end the battle as a loss.
    if ($battle.player.death.check = true) { /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle defeat | halt } 

    $checkchar($1) | writeini $char($1) skills doubleturn.on off | /.timerDoubleTurn $+ $rand(1,1000) 1 1 /query %battlechan 12 $+ %real.name gets another turn. | $aicheck($1) | halt 
  }
  else { $next | halt }
}

covercheck {
  var %cover.target $readini($char($1), skills, CoverTarget)
  if ((%cover.target = none) || (%cover.target = $null)) { set %attack.target $1 | return } 

  var %cover.status $readini($char(%cover.target), battle, status)
  if ((%cover.status = dead) || (%cover.status = runaway)) { writeini $char($1) skills CoverTarget none | set %attack.target $1 | return } 

  if ($readini(techniques.db, $2, Type) = heal) { set %attack.target $1 | return }
  if ($readini(techniques.db, $2, Type) = heal-AOE) { set %attack.target $1 | return }

  set %attack.target %cover.target
  writeini $char($1) skills CoverTarget none
  query %battlechan $readini(translation.dat, battle, TargetCovered)
}

deal_damage {
  ; $1 = person dealing damage
  ; $2 = target
  ; $3 = action that was done (tech name, item, etc)
  ; $4 = absorb or none

  if ($readini($char($2), Status, cocoon) = yes) { 

    set %attack.damage 0 
    $set_chr_name($2) | set %guard.message $readini(translation.dat, skill, CocoonBlock)
  }


  var %life.target $readini($char($2), Battle, HP)
  dec %life.target %attack.damage
  writeini $char($2) battle hp %life.target

  ; Add some style points to the user
  if ($3 != renkei) { $add.stylepoints($1, $2, %attack.damage, $3) }

  ; If it's an Absorb HP type, we need to add the hp to the person.
  if ($4 = absorb) { 

    var %absorb.amount $round($calc(%attack.damage / 2.3),0)
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

  if ($readini($char($2), battle, HP) <= 0) { 
    writeini $char($2) battle status dead 
    writeini $char($2) battle hp 0
    $check.clone.death($2)
    if ($readini($char($1), info, flag) != monster) {
      $inc_monster_kills($1)
      if (%battle.type = monster) {  $add.stylepoints($1, $2, mon_death, $3) | $add.style.orbbonus($1, monster, $2) }
      if (%battle.type = orbfountain) {  $add.stylepoints($1, $2, mon_death, $3) | $add.style.orbbonus($1, monster, $2) }
      if (%battle.type = boss) { $add.stylepoints($1, $2, boss_death, $3) | $add.style.orbbonus($1, boss, $2) }
    }
  }

  if (%guard.message = $null) { $renkei.calculate($1, $2, $3) }

}

inc_monster_kills {
  var %monster.kills $readini($char($1), stuff, MonsterKills)
  if (%monster.kills = $null) { var %monster.kills 0 }
  inc %monster.kills 1 
  writeini $char($1) stuff MonsterKills %monster.kills
  $achievement_check($1, MonsterSlayer)
}

check.clone.death {
  if ($isfile($char($1 $+ _clone)) = $true) { 
    if ($readini($char($1 $+ _clone), battle, status) != dead) { writeini $char($1 $+ _clone) battle status dead | writeini $char($1 $+ _clone) battle hp 0 | $set_chr_name($1 $+ _clone) | /.timerCloneDeath $+ $1 1 1 /query %battlechan 4 $+ %real.name disappears back into $set_chr_name($1) %real.name $+ 's shadow. }
  }
  if ($isfile($char($1 $+ _summon)) = $true) { 
    if ($readini($char($1 $+ _summon), battle, status) != dead) { writeini $char($1 $+ _summon) battle status dead | writeini $char($1 $+ _summon) battle hp 0 | $set_chr_name($1 $+ _summon) | /.timerSummonDeath $+ $1 1 1 /query %battlechan 4 $+ %real.name fades away. }
  }
}

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

  set %life.target $readini($char($2), Battle, HP) | set %life.max $readini($char($2), Basestats, HP)
  inc %life.target %attack.damage

  if (%life.target >= %life.max) { set %life.target %life.max }
  writeini $char($2) battle hp %life.target
  unset %life.target
}

display_damage {
  unset %overkill |  unset %style.rating
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  ; Show a random attack description
  if ($3 = weapon) { var %weapon.type $readini(weapons.db, $4, type)
    var %attack.file attack_ $+ %weapon.type $+ .txt
    query %battlechan 3 $+ %user $+  $read %attack.file  $+ 3. 
  }

  if ($3 = tech) {
    if (%showed.tech.desc != true) { query %battlechan 3 $+ %user $+  $readini(techniques.db, $4, desc) }

    if ($readini(techniques.db, $4, magic) = yes) {
      ; Clear elemental seal
      if ($readini($char($1), skills, elementalseal.on) = on) { 
        writeini $char($1) skills elementalseal.on off 
      }
    }

  }

  if ($3 = item) {
    query %battlechan 3 $+ %user $+  $readini(items.db, $4, desc)
  }

  if ($3 = fullbring) {
    query %battlechan 3 $+ %user $+  $readini(items.db, $4, fullbringdesc)
  } 

  if ($3 = renkei) {
    query %battlechan $readini(translation.dat, system, RenkeiPerformed)  3 $+ %renkei.description
    unset %style.rating
  }

  ; Show the damage
  if (($3 != item) && ($3 != renkei)) { $calculate.stylepoints($1) }

  if (((((%double.attack = $null) && (%triple.attack = $null) && (%fourhit.attack = $null) && (%fivehit.attack = $null) && (%sixhit.attack = $null))))) { 

    if ($3 != aoeheal) {
      if (%guard.message = $null) { query %battlechan The attack did4 $bytes(%attack.damage,b) damage %style.rating }
      if (%guard.message != $null) { query %battlechan %guard.message | unset %guard.message }
      if (%element.desc != $null) {  query %battlechan %element.desc | unset %element.desc }
    }
    if ($3 = aoeheal) { 
      if (%guard.message = $null) { query %battlechan The attack did4 $bytes(%attack.damage,b) damage to %enemy $+ ! %style.rating }
      if (%guard.message != $null) { query %battlechan %guard.message | unset %guard.message }
      if (%element.desc != $null) {  query %battlechan %element.desc | unset %element.desc }
    }
  }

  if (%double.attack = true) { 
    if (%guard.message = $null) { query %battlechan 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating }
    if (%guard.message != $null) { query %battlechan %guard.message | unset %guard.message }
    unset %attack.damage1 | unset %attack.damage2

  }
  if (%triple.attack = true) {  
    if (%guard.message = $null) { query %battlechan 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage.  Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating }
    if (%guard.message != $null) { query %battlechan %guard.message | unset %guard.message }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3
  }

  if (%fourhit.attack = true) { 
    if (%guard.message = $null) { query %battlechan 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage. The fourth attack did4 $bytes(%attack.damage4,b) damage. Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating }
    if (%guard.message != $null) { query %battlechan %guard.message | unset %guard.message }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %fourhit.attack
  }

  if (%fivehit.attack = true) { 
    if (%guard.message = $null) { query %battlechan 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage. The fourth attack did4 $bytes(%attack.damage4,b) damage. The fifth attack did4 $bytes(%attack.damage5,b) damage. Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating }
    if (%guard.message != $null) { query %battlechan %guard.message | unset %guard.message }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %fourhit.attack | unset %fivehit.attack
  }

  if (%sixhit.attack = true) { 
    if (%guard.message = $null) { query %battlechan 1The first attack did4 $bytes(%attack.damage1,b) damage.  The second attack did4 $bytes(%attack.damage2,b) damage.  The third attack did4 $bytes(%attack.damage3,b) damage. The fourth attack did4 $bytes(%attack.damage4,b) damage. The fifth attack did4 $bytes(%attack.damage5,b) damage. The sixth attack did4 $bytes(%attack.damage6,b) damage.  Total physical damage:4 $bytes(%attack.damage,b)  $+ %style.rating }
    if (%guard.message != $null) { query %battlechan %guard.message | unset %guard.message }
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack
  }

  if (%statusmessage.display != $null) { 
    if ($readini($char($2), battle, hp) > 0) { query %battlechan %statusmessage.display | unset %statusmessage.display }
  }

  if (%absorb = absorb) {
    ; Show how much the person absorbed back.
    var %absorb.amount $round($calc(%attack.damage / 2.3),0)
    if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.5),0) }
    query %battlechan 3 $+ %user absorbs $bytes(%absorb.amount,b) HP back from the damage.
    unset %absorb
  }

  if (%drainsamba.on = on) {
    if (($readini($char($2), monster, type) != undead) && ($readini($char($2), monster, type) != zombie)) { 
      var %absorb.amount $round($calc(%attack.damage / 3),0)
      if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.5),0) }
      if (%absorb.amount <= 0) { var %absorb.amount 1 }
      query %battlechan 3 $+ %user absorbs $bytes(%absorb.amount,b) HP back from the damage.
      set %life.target $readini($char($1), Battle, HP) | set %life.max $readini($char($1), Basestats, HP)
      inc %life.target %absorb.amount
      if (%life.target >= %life.max) { set %life.target %life.max }
      writeini $char($1) battle hp %life.target
      unset %life.target | unset %life.target | unset %absorb.amount 
    }
  }


  ; Did the person die?  If so, show the death message.
  if ($readini($char($2), battle, HP) <= 0) { 
    $increase_death_tally($2)
    $achievement_check($2, SirDiesALot)
    $gemconvert_check($1, $2, $3, $4)
    if (%attack.damage > $readini($char($2), basestats, hp)) { set %overkill 7<<OVERKILL>> }
    query %battlechan 4 $+ %enemy has been defeated by %user $+ !  %overkill
    $goldorb_check($2) 
    $spawn_after_death($2)
    remini $char($2) Renkei
  }


  if ($readini($char($2), battle, HP) > 0) {

    ; Check to see if the monster can be staggered..  
    var %stagger.check $readini($char($2), info, CanStagger)
    if (($stagger.check != $null) && (%stagger.check != no)) {

      ; Do the stagger if the damage is above the threshold.
      var %stagger.amount.needed $readini($char($2), info, StaggerAmount)
      dec %stagger.amount.needed %attack.damage | writeini $char($2) info staggeramount %stagger.amount.needed
      if (%stagger.amount.needed <= 0) { writeini $char($2) status staggered yes |  writeini $char($2) info CanStagger no
        query %battlechan $readini(translation.dat, status, StaggerHappens)
      }
    }

    if ($3 = tech) { unset %attack.damage | $renkei.check($1, $2) }
  }

  return 
}

display_heal {
  unset %style.rating
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  if (%user = %enemy ) { set %enemy $gender2($1) $+ self }

  if ($3 = tech) {
    if (%showed.tech.desc != true) {
      $set_chr_name($1) | query %battlechan 3 $+ %real.name $+  $readini(techniques.db, $4, desc)
    }
  }

  if ($3 = item) {
    $set_chr_name($1) | query %battlechan 3 $+ %real.name $+  $readini(items.db, $4, desc)
  }
  ; Show the damage healed
  if (%guard.message = $null) {  $set_chr_name($2) |  $set_chr_name($2) | query %battlechan 3 $+ %real.name has been healed for %attack.damage health! }
  if (%guard.message != $null) { query %battlechan %guard.message | unset %guard.message }

  ; Did the person die?  If so, show the death message.
  if ($readini($char($2), battle, HP) <= 0) { 
    $set_chr_name($2) | query %battlechan 4 $+ %enemy has been defeated by %user $+ !  
  }

  return 
}



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

  query %battlechan $readini(translation.dat, system, ConvertToGem)

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

random.battlefield.pick {
  var %battlefields.list $readini(battlefields.lst, battlefields, list)
  set %random $rand(1, $numtok(%battlefields.list,46))
  if (%random = $null) { var %random 1 }
  set %current.battlefield $gettok(%battlefields.list,%random,46)
  unset %random 
}

random.weather.pick {
  set %weather.list $readini(battlefields.lst, %current.battlefield, weather)
  set %random $rand(1, $numtok(%weather.list,46))
  if (%random = $null) { var %random 1 }
  set %new.weather $gettok(%weather.list,%random,46)
  writeini weather.lst weather current %new.weather
  query %battlechan 10The weather changes.  It is now %new.weather
  unset %number.of.weather | unset %new.weather | unset %random | unset %weather.list
}

random.battlefield.curse {
  var %curse.chance $rand(1,105)
  if (%curse.chance <= 6) {  /.timerCurseMessage 1 1 /query %battlechan $readini(translation.dat, Events, CurseNight)
    ; curse everyone
    var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line battle.txt
      writeini $char(%who.battle) status curse yes
      writeini $char(%who.battle) battle tp 0
      inc %battletxt.current.line 1 
    }
  }
  if ((%curse.chance >= 95) && (%curse.chance <= 100)) {  /.timerCurseMessage 1 1 /query %battlechan $readini(translation.dat, Events, BloodMoon) | set %bloodmoon on  }
  if (%curse.chance > 100) { 
    set %battleconditions no-tech
    /.timerCurseMessage 1 1 /query %battlechan $readini(translation.dat, Events, AncientMeleeOnlySeal)
  }

  return
}

random.surpriseattack {
  var %surpriseattack.chance $rand(1,100)
  if (%surpriseattack.chance >= 90) { set %surpriseattack on }
  if (%surpriseattack = on) { /.timerSurpriseAttackMessage 1 .5 /query %battlechan $readini(translation.dat, Events, SurpriseAttack) }
  return
}

random.battlefield.ally {

  var %npc.chance $rand(1,100) 
  var %losing.streak $readini(battlestats.dat, battle, LosingStreak)
  var %winning.streak $readini(battlestats.dat, battle, WinningStreak)

  if (%losing.streak >= 2) { var %npc.chance 1 }
  if ((%winning.streak >= 30) && (%number.of.players = 1)) { var %npc.chance $rand(1,45) }

  if (%npc.chance <= 10) { 
    $get_npc_list
    var %npcs.total $numtok(%npc.list,46)
    if ((%npcs.total = 0) || (%npc.list = $null)) { query %battlechan 4Error: There are no NPCs in the NPC folder.. Have the bot admin check to make sure there are npcs there! | return }


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
        query %battlechan 4 $+ %real.name has entered the battle to help the forces of good! 
        query %battlechan 12 $+ %real.name  $+ $readini($char(%npc.name), descriptions, char)
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

increase_death_tally {
  if ($readini($char($1), info, flag) = npc) { return }
  var %deaths $readini($char($1), stuff, TotalDeaths)
  if (%deaths = $null) { var %deaths 0 } 
  inc %deaths 1
  writeini $char($1) stuff TotalDeaths %deaths
}

; This is the automatic-revival function.. it's named after the Gold Orbs in Devil May Cry
goldorb_check {
  if ($readini($char($1), status, revive) = yes) {
    var %max.hp $readini($char($1), basestats, hp)
    set %revive.current.hp $round($calc(%max.hp / 2),0)
    if (%revive.current.hp <= 0) { set %revive.current.hp 1 }
    writeini $char($1) battle hp %revive.current.hp
    writeini $char($1) battle status normal
    writeini $char($1) status revive no
    query %battlechan $readini(translation.dat, battle, GoldOrbUsed)
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

  }
}

guardian_style_check {
  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
  ; Is the target using the Guardian style?  If so, we need to decrease the damage done.
  if (%current.playerstyle = Guardian) { 
    var %block.value $calc(%current.playerstyle.level / 15.5)
    if (%block.value > .60) { var %block.value .60 }
    var %amount.to.block $round($calc(%attack.damage * %block.value),0)
    dec %attack.damage %amount.to.block
  }
}
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
      $set_chr_name(evil_ $+ %who.battle) | query %battlechan $readini(translation.dat, battle, EnteredTheBattle)
      var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
      inc %battletxt.current.line 1 
    }
  }

  set %boss.item $readini(items.db, items, foodItems) $+ . $+ $readini(items.db, items, runes) $+ . $+ $readini(items.db, items, BattleItems)
  writeini battle2.txt battle bonusitem %boss.item | unset %boss.item
}

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
  $fulls(%monster.name) 

  set %curbat $readini(battle2.txt, Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini battle2.txt Battle List %curbat | write battle.txt %monster.name
  $set_chr_name(%monster.name) | query %battlechan $readini(translation.dat, battle, EnteredTheBattle)
  var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
  inc %battletxt.current.line 1 
  unset %current.battlestreak | unset %monster.name | unset %monster.realname

  set %boss.item $readini(items.db, items, SummonItems) $+ . $+ $readini(items.db, items, Gems) $+ . $+ $readini(items.db, items, BattleItems)
  writeini battle2.txt battle bonusitem %boss.item
  unset %boss.item
}


inflict_status {
  ; $1 = user
  ; $2 = target
  ; $3 = status type

  if (($readini($char($2), status, ethereal) = yes) && ($readini(techniques.db, $4, magic) != yes)) { return }
  if (%guard.message != $null) { return }

  if ($3 = random) { 
    var %random.status.type $rand(1,13)
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
    if (%random.status.type = 13) { set %status.type petrify | var %status.grammar petrified }
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
  if ($3 = petrify) { set %status.type petrify  | var %status.grammar petrified }

  var %chance $rand(1,140) | $set_chr_name($1) 
  if ($readini($char($2), skills, utsusemi.on) = on) { set %chance 0 } 

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

  if (%status.type = charm) {
    if ($readini($char($2), status, zombie) != no) { set %resist.skill 100 }
    if ($readini($char($2), monster, type) = undead) { set %resist.skill 100 }
  }

  if ((%resist.skill <= 100) || (%resist.skill = $null)) {
    if ((%resist.skill != $null) && (%resist.skill > 0)) { dec %chance %resist.skill }
  }

  if (%resist.skill >= 100) { $set_chr_name($2) | set %statusmessage.display 4 $+ %real.name is immune to the %status.type status! }
  if ((%resist.skill < 100) || (%resist.skill = $null)) {

    if (%chance <= 0) { $set_chr_name($2) | set %statusmessage.display 4 $+ %real.name has resisted $set_chr_name($1) %real.name $+ 's $lower(%status.type) status effect! }
    if ((%chance > 0) && (%chance <= 45)) { $set_chr_name($1) | set %statusmessage.display 4 $+ %real.name $+ 's $lower(%status.type) status effect has failed against $set_chr_name($2) %real.name $+ ! }
    if (%chance > 45) {
      $set_chr_name($2) | set %statusmessage.display 4 $+ %real.name is now %status.grammar $+ ! 
      if (%status.type = poison) && ($readini($char($2), status, poison) = yes) { writeini $char($2) status poison no | writeini $char($2) status poison-heavy yes }
      if (%status.type = poison) && ($readini($char($2), status, poison-heavy) != yes) { writeini $char($2) status poison yes }
      if (%status.type = charm) { writeini $char($2) status charmed yes | writeini $char($2) status charmer $1 | writeini $char($2) status charm.timer $rand(2,3) }
      if (%status.type = curse) { writeini $char($2) Status %status.type yes | writeini $char($2) battle tp 0 }
      if (%status.type = petrify) { writeini $char($2) status petrified yes }
      else { writeini $char($2) Status %status.type yes  }
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

winningstreak.addmonster.amount {
  if (%battle.type = orbfountain) { return }
  if (%battle.type = monster) { 
    ; If the players have been winning a lot then we need to make things more interesting/difficult for them.
    if ((%winning.streak > 35) && (%winning.streak <= 50)) { inc %number.of.monsters.needed 1 }
    if ((%winning.streak > 50) && (%winning.streak <= 100)) { inc %number.of.monsters.needed 2 }
    if ((%winning.streak > 100) && (%winning.streak <= 300)) { inc %number.of.monsters.needed 3 }
    if (%winning.streak > 300) { inc %number.of.monsters.needed 4 }
  }

  if (%battle.type = boss) {
    if ((%winning.streak > 100) && (%winning.streak <= 120)) { inc %number.of.monsters.needed 1 }
    if (%winning.streak > 120) { inc %number.of.monsters.needed 2 }
  }

  return
}

first_round_dmg_chk {
  if ((%current.turn != 1) && (%first.round.protection = $null)) { return }

  if (($readini($char($1), info, flag) = monster) && ($readini($char($2), info, flag) = $null)) {
    var %max.health $readini($char($2), basestats, hp) 
    if (%attack.damage >= %max.health) { 
      set %attack.damage $round($calc(%max.health * .20),0)
      unset %first.round.protection
    }
  }
}

trickster_dodge_check {
  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
  if (%current.playerstyle != Trickster) { return }
  if (%guard.message != $null) { return }

  var %dodge.chance $rand(1,100)
  if (%dodge.chance <= %current.playerstyle.level) {
    unset %current.playerstyle | unset %current.playerstyle.level
    set %attack.damage 0 | $set_chr_name($1)
    unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %critical.hit.chance

    ; Add some style to the person who dodged.
    set %stylepoints.to.add $rand(50,80)
    %stylepoints.to.add = $calc((10 * %current.playerstyle.level) + %stylepoints.to.add) 

    $add.stylepoints($1, $2, %stylepoints.to.add,dodge)  
    unset %stylepoints.to.add 

    $calculate.stylepoints($1)
    set %guard.message $readini(translation.dat, battle, TricksterDodged)
    set %trickster.dodged on

  }

  unset %current.playerstyle | unset %current.playerstyle.level | return 
}

weapon_parry_check {
  var %parry.weapon $readini($char($1), weapons, equipped)
  $mastery_check($1, %parry.weapon)
  if ((%mastery.bonus = $null) || (%mastery.bonus < 100)) { return }

  var %parry.chance $rand(1,100)

  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
  if (%current.playerstyle = WeaponMaster) { 
    dec %parry.chance %current.playerstyle.level
  }
  unset %current.playerstyle | unset %current.playerstyle.level


  if (%parry.chance > 3) { return }

  set %attack.damage 0 | $set_chr_name($1) 
  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %critical.hit.chance

  ; Add some style to the person who dodged.
  set %stylepoints.to.add $rand(70,100)
  %stylepoints.to.add = $calc(%stylepoints.to.add) 

  $add.stylepoints($1, $2, %stylepoints.to.add,parry)  
  unset %stylepoints.to.add 

  $calculate.stylepoints($1)
  set %guard.message $readini(translation.dat, battle, WeaponParry)
}

multiple_wave_check {
  if (%multiple.wave = yes) { return }
  unset %number.of.monsters.needed

  var %winning.streak $readini(battlestats.dat, battle, WinningStreak)
  if (%winning.streak <= 0) { return }

  if (%winning.streak <= 100) { var %multiple.wave.chance $rand(1,2) }
  if ((%winning.streak > 100) && (%winning.streak <= 200)) { var %multiple.wave.chance $rand(2,5) }
  if ((%winning.streak > 200) && (%winning.streak <= 400)) { var %multiple.wave.chance $rand(5,10) }
  if (%winning.streak > 400) { var %multiple.wave.chance $rand(10,20) }

  var %random.wave.chance $rand(1,100)
  if (%mode.gauntlet = on) { var %random.wave.chance 1 | inc %mode.gauntlet.wave 1 }

  if (%random.wave.chance > %multiple.wave.chance) { return }

  set %multiple.wave yes |  set %multiple.wave.bonus yes

  ; Clear out the old monsters.
  $multiple_wave_clearmonsters

  ; Create the next wave
  if (%mode.gauntlet = $null) {  query %battlechan $readini(translation.dat, system,AnotherWaveArrives) }
  set %number.of.monsters.needed $rand(2,3)

  set %first.round.protection yes

  if ($readini(battle2.txt, battleinfo, players) > 1) { inc %number.of.monsters.needed 1 }
  if (%mode.gauntlet = $null) { $winningstreak.addmonster.amount | $generate_monster(monster) }
  if (%mode.gauntlet != $null) { 
    query %battlechan $readini(translation.dat, system,AnotherWaveArrives) [Gauntlet Round: %mode.gauntlet.wave $+ ] | set %number.of.monsters.needed 2 
    var %m.boss.chance $rand(1,100)
    if (%m.boss.chance > 15) { $generate_monster(monster) }
    if (%m.boss.chance <= 15) { $generate_monster(boss) }
  }
}

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

  return
}

spawn_after_death {
  set %monster.to.spawn $readini($char($1), info, SpawnAfterDeath)

  if (%monster.to.spawn = $null) { return }

  var %isboss $isfile($boss(%monster.to.spawn))
  var %ismonster $isfile($mon(%monster.to.spawn))

  if ((%isboss = $false) && (%ismon = $false)) { return }  

  if ($isfile($boss(%monster.to.spawn)) = $true) {  .copy -o $boss(%monster.to.spawn) $char(%monster.to.spawn)  }
  if ($isfile($mon(%monster.to.spawn)) = $true) {  .copy -o $mon(%monster.to.spawn) $char(%monster.to.spawn)  }

  ; increase the total # of monsters
  set %battlelist.toadd $readini(battle2.txt, Battle, List) | %battlelist.toadd = $addtok(%battlelist.toadd,%monster.to.spawn,46) | writeini battle2.txt Battle List %battlelist.toadd | unset %battlelist.toadd
  write battle.txt %monster.to.spawn
  var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters

  ; display the description of the spawned monster
  $set_chr_name(%monster.to.spawn) 
  query %battlechan $readini(translation.dat, battle, EnteredTheBattle)
  query %battlechan 12 $+ %real.name  $+ $readini($char(%monster.to.spawn), descriptions, char)
  var %bossquote $readini($char(%monster.to.spawn), descriptions, bossquote)
  if (%bossquote != $null) { query %battlechan 2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.to.spawn), descriptions, BossQuote) $+ " }

  ; Boost the monster
  $boost_monster_stats(%monster.to.spawn) 
  $fulls(%monster.to.spawn)

  set %multiple.wave.bonus yes
  set %first.round.protection yes
}

metal_defense_check {
  if ($augment.check($2, IgnoreMetalDefense) = true) { return true }
  else { 
    if ($readini($char($1), info, MetalDefense) = true) {  set %attack.damage 0  }
    return
  }
}


renkei.check {
  var %renkei.techs.total $readini($char($2), renkei, NumberOfTechs)
  if ((%renkei.techs.total <= 1) || (%renkei.techs.total = $null)) { return }
  writeini $char($2) renkei NumberOfTechs 0

  var %renkei.tech.damage $readini($char($2), renkei, TotalTechDamage)
  var %renkei.tech.value $readini($char($2), renkei, TotalRenkeiValue)  

  if (%renkei.tech.value < 3) { set %attack.damage $round($calc(%renkei.tech.damage * .05),0) | set %renkei.name Impaction | $set_chr_name($2) | set %renkei.description The techniques combine together to create a large vaccum of air that sucks %real.name inwards before exploding with energy! }
  if ((%renkei.tech.value >= 3) && (%renkei.tech.value <= 5)) { set %attack.damage $round($calc(%renkei.tech.damage * .10),0) | set %renkei.name Scission | $set_chr_name($2) | set %renkei.description The techniques combine together to create a large cut across %real.name $+ 's chest! }
  if ((%renkei.tech.value >= 5) && (%renkei.tech.value < 10)) { set %attack.damage $round($calc(%renkei.tech.damage * .15),0) | set %renkei.name Distortion | $set_chr_name($2) | set %renkei.description The techniques combine together to create a large amount of green energy that surrounds and then slams into %real.name $+ ! }
  if ((%renkei.tech.value >= 10) && (%renkei.tech.value < 15)) { set %attack.damage $round($calc(%renkei.tech.damage * .20),0) | set %renkei.name Fragmentation | $set_chr_name($2) | set %renkei.description The techniques combine together and cause large silver crystals to grow out of %real.name $+ 's body.  The crystals then explode, dealing damage. }
  if ((%renkei.tech.value >= 15) && (%renkei.tech.value <= 20)) { set %attack.damage $round($calc(%renkei.tech.damage * .25),0) | set %renkei.name Darkness | $set_chr_name($2) | set %renkei.description The techniques combine together and the sky grows dark. A huge orb of dark energy appears above %real.name $+ 's head.  The orb grows bigger and bigger before exploding violently ontop of %real.name dealing damage. }
  if (%renkei.tech.value > 20)  { set %attack.damage $round($calc(%renkei.tech.damage * .30),0) | set %renkei.name Light | $set_chr_name($2) | set %renkei.description The techniques combine together and the sky grows bright. A huge orb of pure light energy appears above %real.name $+ 's head.  The orb grows bigger and bigger before exploding violently ontop of %real.name dealing damage. }

  $deal_damage($1, $2, renkei)
  $display_damage($1,$2, renkei)
}

renkei.calculate {
  if ($readini(techniques.db, $3, magic) = yes) { return }
  var %renkei.tech.value $readini($char($2), renkei, TotalRenkeiValue)  
  var %renkei.tech.amount $readini(techniques.db, $3, Renkei)

  if ((%renkei.tech.amount = $null) || (%renkei.tech.amount = 0)) { return }

  if ($augment.check($1, RenkeiBonus) = true) { %renkei.tech.amount = $calc(%renkei.tech.amount * 2) }

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
