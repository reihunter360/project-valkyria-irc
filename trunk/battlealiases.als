check_for_battle { 
  if ((%battleis = on) && (%who = $1)) { return }
  if ((%battleis = on) && (%who != $1)) { query %battlechan $readini(translation.dat, errors, WaitYourTurn) | halt }
  else { return  }
}

boost_summon_stats {
  var %hp $readini($char($1 $+ _summon), BaseStats, HP)
  var %tp $readini($char($1 $+ _summon), BaseStats, TP)
  var %str $readini($char($1 $+ _summon), BaseStats, Str)
  var %def $readini($char($1 $+ _ summon), BaseStats, Def)
  var %int $readini($char($1 $+ _summon), BaseStats, Int)
  var %spd $readini($char($1 $+ _summon), BaseStats, Spd)

  set %increase.amount $calc(.25 * $2) 
  inc %increase.amount $calc($rand(1,5) / 100)

  %hp = $round($calc(%hp * %increase.amount),0) 
  %tp = $round($calc(%tp * %increase.amount),0) 
  %str = $round($calc(%str * %increase.amount),0) 
  %def = $round($calc(%def * %increase.amount),0) 
  %int = $round($calc(%int * %increase.amount),0) 
  %spd = $round($calc(%spd * %increase.amount),0) 

  writeini $char($1 $+ _summon) BaseStats HP %hp
  writeini $char($1 $+ _summon) BaseStats TP %tp
  writeini $char($1 $+ _summon) BaseStats Str %str
  writeini $char($1 $+ _summon) BaseStats Def %def
  writeini $char($1 $+ _summon) BaseStats Int %int
  writeini $char($1 $+ _summon) BaseStats Spd %spd
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

  if (%number.of.players = 1) {  %shop.level = $round($calc(%shop.level / (%number.of.players.in.battle + 2)),0) }
  if (%number.of.players >= 2) { 
    %shop.level = $round($calc(%shop.level / (%number.of.players.in.battle + 3)),0)
  }

  if (%winning.streak <= 0) { var %winning.streak $calc($readini(battlestats.dat, battle, losingstreak) * -1) }

  var %monster.level 0
  inc %monster.level %winning.streak
  inc %monster.level %level.boost
  inc %monster.level %shop.level

  if (%winning.streak > 20) {
    if ($isfile($boss($1)) = $true) { inc %monster.level $rand(1,2) | inc %hp $rand(100,200)  }
    if ($isfile($boss($1)) = $false) { inc %hp $rand(10,25) }
  }

  if ($2 = rage) { set %increase.amount 100 }
  if ($2 = doppelganger) {  set %increase.amount $calc(%monster.level * .02575)  }
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

  inc %increase.amount 1

  if (%increase.amount <= 0) { set %increase.amount .01 }

  if ($readini($char($1), info, BattleStats) = hp) { %hp = $round($calc(%hp * %increase.amount),0) | writeini $char($1) BaseStats HP %hp  | return }

  if ($readini($char($1), info, BattleStats) != ignorehp) { %hp = $round($calc(%hp * %increase.amount),0) }

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
  writeini $char($1) BaseStats Spd %spd

  unset %increase.amount
}

old_boost_monster_stats {
  if ($readini($char($1), info, BattleStats) = ignore) { return }

  var %hp $readini($char($1), BaseStats, HP)
  var %tp $readini($char($1), BaseStats, TP)
  var %str $readini($char($1), BaseStats, Str)
  var %def $readini($char($1), BaseStats, Def)
  var %int $readini($char($1), BaseStats, Int)
  var %spd $readini($char($1), BaseStats, Spd)

  if ($2 = 1) { set %increase.amount .25 }
  if (($2 > 1) && ($2 < 4)) { set %increase.amount $calc(.5 + $round($calc($2 / 2),0)) }
  else { set %increase.amount $calc(.95 + $2) }

  if ($isfile($boss($1)) = $true) { inc %increase.amount $rand(.5,.7) }

  var %shop.level $readini(battle2.txt, BattleInfo, ShopLevel)
  if ($readini(battle2.txt, battleinfo, players) = 1)  { inc %increase.amount $calc(%shop.level / 32)  }
  if ($readini(battle2.txt, battleinfo, players) = 2)  {  inc %increase.amount $calc(%shop.level / 28)  }
  if ($readini(battle2.txt, battleinfo, players) >= 3)  {  inc %increase.amount $calc(%shop.level / 25)   }

  %hp = $round($calc(%hp * %increase.amount),0) 
  if ($isfile($boss($1)) = $true) { inc %hp $rand(10,50) }
  if ($isfile($boss($1)) = $false) { inc %hp $rand(5,15) }

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
  writeini $char($1) BaseStats Spd %spd

  unset %increase.amount
  return
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

old_wins_boost  {
  if ($readini($char($1), info, BattleStats) = ignore) { return }
  ; The players have won battles, so we need to increase the strength of the monsters.  The more times the players win, the stronger monsters become
  var %str $readini($char($1), BaseStats, Str)
  var %def $readini($char($1), BaseStats, Def)
  var %int $readini($char($1), BaseStats, Int)
  var %spd $readini($char($1), BaseStats, Spd)
  var %hp $readini($char($1), BaseStats, HP)

  var %winning.streak $readini(battlestats.dat, battle, winningstreak)
  var %level.boost $readini(battlestats.dat, battle, LevelAdjust)

  if (%level.boost = $null) { var %level.boost 0 }
  inc %winning.streak %level.boost

  if ((%winning.streak > 0) && (%winning.streak <= 20)) { var %boost.amount .105 
    var %hp.boost.amount 1.1 
    var %shop.level $readini(battle2.txt, BattleInfo, ShopLevel)

    if ($readini(battle2.txt, battleinfo, players) = 1)  { var %shop.level $calc(%shop.level / 14)  }
    if ($readini(battle2.txt, battleinfo, players) = 2)  { var %shop.level $calc(%shop.level / 12)  }
    if ($readini(battle2.txt, battleinfo, players) >= 3)  { var %shop.level $calc(%shop.level / 30)  }
    inc %hp.boost.amount %shop.level

    if ($1 = Final_Guard) { var %hp.boost.amount 1 } 
    if ($2 = npc) { var %hp.boost.amount 1 }
  }
  if ((%winning.streak > 20) && (%winning.streak <= 50)) { var %boost.amount .110 }
  if ((%winning.streak > 50) && (%winning.streak <= 100)) { var %boost.amount .135 }
  if ((%winning.streak > 100) && (%winning.streak <= 200)) { var %boost.amount .160 }
  if ((%winning.streak > 200) && (%winning.streak <= 300)) { var %boost.amount .190 }
  if (%winning.streak > 300)  { var %boost.amount .210 }

  var %increase.amount $calc(%boost.amount * %winning.streak)
  inc %increase.amount 1

  if ($2 = boss) { %increase.amount = $calc(%increase.amount / 3) }
  if ($2 = npc) { %increase.amount = $calc(%increase.amount / 4) }

  if (%hp.boost.amount = $null) { var %hp.boost.amount %increase.amount }
  if ($isfile($boss($1)) = $true) { inc %hp.boost.amount $rand(1,1.2) }

  %hp = $round($calc(%hp * %hp.boost.amount),0)   
  %str = $round($calc(%str * %increase.amount),0) 
  %def = $round($calc(%def * %increase.amount),0) 
  %int = $round($calc(%int * %increase.amount),0) 
  %spd = $round($calc(%spd * %increase.amount),0) 

  writeini $char($1) BaseStats Str %str
  writeini $char($1) BaseStats Def %def
  writeini $char($1) BaseStats Int %int
  writeini $char($1) BaseStats Spd %spd
  writeini $char($1) BaseStats HP %hp
}

person_in_battle {
  if (($1 !isin $readini(battle2.txt, Battle, List)) && (%battleis = on)) { query %battlechan $set_chr_name($1) $readini(translation.dat, errors, NotInbattle) | unset %real.name | halt }
  if (($1 !isin $readini(rbattle.txt, Battle, List)) && (%rt = on)) { query %battlechan $set_chr_name($1) $readini(translation.dat, errors, NotInbattle) | unset %real.name | halt }
  else { return }
}

check_for_double_turn {  $set_chr_name($1)
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

  var %cover.status $readini($char($1), battle, status)
  if ((%cover.status = dead) || (%cover.status = runaway)) { writeini $char($1) skills CoverTarget none | set %attack.target $1 | return } 

  set %attack.target %cover.target
  writeini $char($1) skills CoverTarget none
  query %battlechan $readini(translation.dat, battle, TargetCovered)
}

deal_damage {
  ; $1 = person dealing damage
  ; $2 = target
  ; $3 = action that was done (tech name, item, etc)
  ; $4 = absorb or none

  var %life.target $readini($char($2), Battle, HP)
  dec %life.target %attack.damage
  writeini $char($2) battle hp %life.target

  ; Add some style points to the user
  $add.stylepoints($1, $2, %attack.damage, $3)

  ; If it's an Absorb HP type, we need to add the hp to the person.
  if ($4 = absorb) { 
    var %absorb.amount $round($calc(%attack.damage / 2.3),0)
    if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.5),0) }
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
    if ($readini($char($1 $+ _summon), battle, status) != dead) { writeini $char($1 $+ _summon) battle status dead | writeini $char($1 $+ _summon) battle hp 0 | $set_chr_name($1 $+ _clone) | /.timerSummonDeath $+ $1 1 1 /query %battlechan 4 $+ %real.name fades away. }
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
  }

  if ($3 = item) {
    query %battlechan 3 $+ %user $+  $readini(items.db, $4, desc)
  }

  if ($3 = fullbring) {
    query %battlechan 3 $+ %user $+  $readini(items.db, $4, fullbringdesc)
  } 

  ; Show the damage
  if ($3 != item) { $calculate.stylepoints($1) }

  if ((((%double.attack = $null) && (%triple.attack = $null) && (%fourhit.attack = $null) && (%fivehit.attack = $null)))) { 

    if (%guard.message = $null) { query %battlechan The attack did4 $bytes(%attack.damage,b) damage %style.rating }
    if (%guard.message != $null) { query %battlechan %guard.message | unset %guard.message }
    if (%element.desc != $null) {  query %battlechan %element.desc | unset %element.desc }
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
    if (%attack.damage > $readini($char($2), basestats, hp)) { set %overkill 7<<OVERKILL>> }
    query %battlechan 4 $+ %enemy has been defeated by %user $+ !  %overkill
    $goldorb_check($2) 
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
  $set_chr_name($2) | query %battlechan 3 $+ %real.name has been healed for %attack.damage health! 

  ; Did the person die?  If so, show the death message.
  if ($readini($char($2), battle, HP) <= 0) { 
    $set_chr_name($2) | query %battlechan 4 $+ %enemy has been defeated by %user $+ !  
  }

  return 
}

random.weather.pick {
  var %weather.list $readini(weather.lst, weather, list)
  set %random $rand(1, $numtok(%weather.list,46))
  if (%random = $null) { var %random 1 }
  set %new.weather $gettok(%weather.list,%random,46)
  writeini weather.lst weather current %new.weather
  query %battlechan 10The weather changes.  It is now %new.weather
  unset %number.of.weather | unset %new.weather | unset %random
}

random.battlefield.curse {
  var %curse.chance $rand(1,100)
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
  if (%curse.chance >= 95) {  /.timerCurseMessage 1 1 /query %battlechan $readini(translation.dat, Events, BloodMoon) | set %bloodmoon on  }
  return
}

random.battlefield.ally {

  var %npc.chance $rand(1,100) 
  var %losing.streak $readini(battlestats.dat, battle, LosingStreak)
  var %winning.streak $readini(battlestats.dat, battle, WinningStreak)

  if (%losing.streak >= 3) { var %npc.chance 1 }
  if ((%winning.streak >= 11) && (%number.of.players = 1)) { var %npc.chance $rand(1,20) }

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
      writeini $char(evil_ $+ %who.battle) Basestats name Evil Doppelganger of %who.battle
      $boost_monster_stats(evil_ $+ %who.battle, doppelganger)
      $fulls(evil_ $+ %who.battle) 
      writeini $char(evil_ $+ %who.battle) info OrbBonus yes
      set %curbat $readini(battle2.txt, Battle, List) |  %curbat = $addtok(%curbat,evil_ $+ %who.battle,46) |  writeini battle2.txt Battle List %curbat | write battle.txt evil_ $+ %who.battle
      $set_chr_name(evil_ $+ %who.battle) | query %battlechan $readini(translation.dat, battle, EnteredTheBattle)
      var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
      inc %battletxt.current.line 1 
    }
  }
}

inflict_status {
  ; $1 = user
  ; $2 = target
  ; $3 = status type

  if ($3 = random) { 
    var %random.status.type $rand(1,11)
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
    if (%random.status.type = 11) { set %tech.status.type intimidate | var %tech.status.grammar intimidated }
  }

  if ($3 = stop) { var %tech.status.grammar frozen in time }
  if ($3 = poison) { var %tech.status.grammar poisoned }
  if ($3 = silence) { var %tech.status.grammar silenced }
  if ($3 = blind) { var %tech.status.grammar blind }
  if ($3 = virus) { var %tech.status.grammar inflicted with a virus }
  if ($3 = amnesia) { var %tech.status.grammar inflicted with amnesia }
  if ($3 = paralysis) { var %tech.status.grammar paralyzed }
  if ($3 = zombie) { var %tech.status.grammar a zombie }
  if ($3 = slow) { var %tech.status.grammar slowed }
  if ($3 = stun) { var %tech.status.grammar stunned }
  if ($3 = curse) { var %tech.status.grammar cursed }
  if ($3 = charm) { var %tech.status.grammar charmed }
  if ($3 = intimidate) { var %tech.status.grammar intimidated }

  var %chance $rand(1,140) | $set_chr_name($1) 
  if ($readini($char($2), skills, utsusemi.on) = on) { set %chance 0 } 

  ; Check for resistance to that status type.
  set %resist.have resist- $+ $3
  set %resist.skill $readini($char($2), skills, %resist.have)

  $ribbon.accessory.check($2)

  if ($3 = charm) {
    if ($readini($char($2), status, zombie) != no) { set %resist.skill 100 }
    if ($readini($char($2), monster, type) = undead) { set %resist.skill 100 }
  }

  if ((%resist.skill <= 100) || (%resist.skill = $null)) {
    if ((%resist.skill != $null) && (%resist.skill > 0)) { dec %chance %resist.skill }
  }

  if (%resist.skill >= 100) { $set_chr_name($2) | set %statusmessage.display 4 $+ %real.name is immune to the $3 status! }
  if ((%resist.skill < 100) || (%resist.skill = $null)) {

    if (%chance <= 0) { $set_chr_name($2) | set %statusmessage.display 4 $+ %real.name has resisted $set_chr_name($1) %real.name $+ 's $lower($3) status effect! }
    if ((%chance > 0) && (%chance <= 45)) { $set_chr_name($1) | set %statusmessage.display 4 $+ %real.name $+ 's $lower($3) status effect has failed against $set_chr_name($2) %real.name $+ ! }
    if (%chance > 45) {
      $set_chr_name($2) | set %statusmessage.display 4 $+ %real.name is now %tech.status.grammar $+ ! 
      if ($3 = poison) && ($readini($char($2), status, poison) = yes) { writeini $char($2) status poison no | writeini $char($2) status poison-heavy yes }
      if ($3 = poison) && ($readini($char($2), status, poison-heavy) != yes) { writeini $char($2) status poison yes }
      if ($3 = charm) { writeini $char($2) status charmed yes | writeini $char($2) status charmer $1 | writeini $char($2) status charm.timer $rand(2,3) }
      if ($3 = curse) { writeini $char($2) Status $3 yes | writeini $char($2) battle tp 0 }
      else { writeini $char($2) Status $3 yes  }
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
