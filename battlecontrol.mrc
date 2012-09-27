;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; BATTLE CONTROL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

on 1:TEXT:!battle stats*:*: { 
  var %total.battles $bytes($readini(battlestats.dat, Battle, TotalBattles),b)
  var %total.wins $bytes($readini(battlestats.dat, Battle, TotalWins),b)
  var %total.losses $bytes($readini(battlestats.dat, Battle, TotalLoss),b)
  var %winning.record $bytes($readini(battlestats.dat, Battle, WinningStreakRecord),b)
  if (%winning.record = $null) { unset %winning.record) }
  if (%winning.record != $null) { var %winning.record (Highest record is: %winning.record $+ ) }

  query %battlechan $readini(translation.dat, system, BattleStatsData)
  if ($readini(battlestats.dat, Battle, WinningStreak) != 0) { query %battlechan $readini(translation.dat, system, BattleStatsWinningStreak) }
  if ($readini(battlestats.dat, Battle, LosingStreak) != 0) { query %battlechan $readini(translation.dat, system, BattleStatsLosingStreak) }
}

; Bot Owners can toggle the automated battle system to be on/off
on 50:TEXT:!toggle automated battle system*:*:{   
  if ($readini(system.dat, system, automatedbattlesystem) = off) { 
    writeini system.dat system automatedbattlesystem on
    query %battlechan $readini(translation.dat, system, AutomatedBattleOn)
    if (%battleis = off) { $clear_battle }
  }
  else {
    writeini system.dat system automatedbattlesystem off
    query %battlechan $readini(translation.dat, system, AutomatedBattleOff)
  }
}

; Bot owners can toggle the AI system on/off.

on 50:TEXT:!toggle ai system*:*:{   
  if ($readini(system.dat, system, aisystem) = off) { 
    writeini system.dat system aisystem on
    query %battlechan $readini(translation.dat, system, AiSystemOn)
  }
  else {
    writeini system.dat system aisystem off
    query %battlechan $readini(translation.dat, system, AiSystemOff)
  }
}

; Bot Owners can have some control over battles
on 50:TEXT:!startbat*:*:{   /.timerBattleStart off | $startnormal($2) }
on 50:TEXT:!start bat*:*:{   /.timerBattleStart off | $startnormal($3) } 
on 50:TEXT:!new bat*:*:{   /.timerBattleStart off | $startnormal($3) } 
on 50:TEXT:!end bat*:*:{   $endbattle($3) } 
on 50:TEXT:!endbat*:*:{   $endbattle($2) } 

; Bot owners can force the next turn
ON 50:TEXT:!next*:* { 
  if (%battleis = on)  { $check_for_double_turn($1) }
  else { query %battlechan $readini(translation.dat, Errors, NoCurrentBattle) | halt }
}

; Bot owners can reset the battle stats.
on 50:TEXT:!clear battle stats*:*:{ 
  writeini battlestats.dat Battle TotalBattles 0
  writeini battlestats.dat Battle TotalWins 0
  writeini battlestats.dat Battle TotalLoss 0 
  writeini battlestats.dat Battle LosingStreak 0
  writeini battlestats.dat Battle WinningStreak 0
  query %battlechan $readini(translation.dat, System, WipedBattleStats)
}

; Bot owners can change the time between battles.
on 50:TEXT:!time between battles *:*:{  
  writeini system.dat System TimeBetweenBattles $4
  query %battlechan $readini(translation.dat, System, ChangeTime)
}

; Bot owners can summon npcs/monsters/bosses to the battlefield during the "entering" phase.
on 50:TEXT:!summon*:*:{
  if ($2 = npc) {
    if ($isfile($npc($3)) = $true) {
      .copy -o $npc($3) $char($3)
      /enter $3
    }
    else { query %battlechan $readini(translation.dat, errors, NPCDoesNotExist) | halt }
  }
  if ($2 = monster) {
    var %number.of.monsters $readini(battle2.txt, BattleInfo, Monsters) 
    if (%number.of.monsters >= 10) { query %battlechan $readini(translation.dat, errors, MonsterLimit) | halt }
    if ($isfile($mon($3)) = $true) {
      .copy -o $mon($3) $char($3)
      /enter $3
      var %number.of.players $readini(battle2.txt, battleinfo, players)
      if (%number.of.players = $null) { var %number.of.players 1 }
      $boost_monster_stats($3)  
      $fulls($3) |  var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
    }
    else { query %battlechan $readini(translation.dat, errors, monsterdoesnotexist) | halt }
  }

  if ($2 = boss) {
    var %number.of.monsters $readini(battle2.txt, BattleInfo, Monsters) 
    if (%number.of.monsters >= 10) { query %battlechan $readini(translation.dat, errors, MonsterLimit)  | halt }
    if ($isfile($boss($3)) = $true) {
      .copy -o $boss($3) $char($3)
      /enter $3
      var %number.of.players $readini(battle2.txt, battleinfo, players)
      if (%number.of.players = $null) { var %number.of.players 1 }
      $boost_monster_stats($3)  
      $fulls($3) |  var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
    }
    else { query %battlechan $readini(translation.dat, errors, monsterdoesnotexist) | halt }
  }

}

; Use these commands to check to see who's in battle..
ON 2:TEXT:!batlist*:#:battlelist
ON 2:TEXT:!bat list*:#:battlelist


; ==========================
; This is the alias that clears battles
; ==========================
alias clear_battle { 
  ; Kill any related battle timers..
  /.timerBattleStart off
  /.timerBattleNext off
  /.timerBattleBegin off
  /.timerBattleRage off

  ; Kill the battle info
  set %battleis off | set %battleisopen off 
  .remove battle.txt | .remove battle2.txt 
  $clear_variables | writeini weather.lst weather current calm

  ; Erase any stray monsters/bosses..
  var %value 1
  while ($findfile( $char_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($char_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_chr) || (%name = $null)) { inc %value 1 } 
    else { 
      var %monster.flag $readini($char(%name), Info, Flag)
      if ((%monster.flag = monster) || (%monster.flag = npc)) { .remove $char(%name) }
      else { inc %value 1 }    
    }
  }

  ; Full everyone
  var %value 1
  while ($findfile( $char_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($char_path ,*.char,%value)) 
    set %name $remove(%file,.char)
    if ((%name = new_chr) || (%name = $null)) { inc %value 1 } 
    else { 
      $fulls(%name)
      inc %value 1
    }
  }

  unset %file |  unset %name 

  if ($readini(system.dat, system, automatedbattlesystem) != off) {

    var %time.between.battles $readini(system.dat, System, TimeBetweenBattles)
    if (%time.between.battles = $null) { var %time.between.battles 3 }

    set %timer.time $calc(%time.between.battles * 60)

    query %battlechan $readini(translation.dat, Battle, StartBattle)
    /.timerBattleStart 1 %timer.time /startnormal
    halt
  }
}

; ==========================
; This is the alias that opens battles
; ==========================
alias startnormal { 

  if (%battleis = on) { $clear_battle | halt }
  .remove battle.txt | .remove battle2.txt 
  query %battlechan $readini(translation.dat, Battle, BattleOpen)
  set %battleis on | set %battleisopen on

  unset %battle.type

  if ($1 = boss) { set %battle.type boss }
  if ($1 = monster) { set %battle.type monster }
  if ($1 = orbfountain) { set %battle.type orbfountain }
  if ($1 = orbbattle) { set %battle.type orbfountain }

  /.timerBattleBegin 1 120 /battlebegin
  ; /.timerBattleBegin 1 30 /battlebegin
}


; ==========================
; This is entering the battle
; ==========================
ON 2:TEXT:!enter*:#:/enter $nick
ON 50:TEXT:*enters the battle*:#:/enter $1


alias enter {
  $checkchar($1)
  if (%battleisopen != on) { $set_chr_name($1) | query %battlechan $readini(translation.dat, battle, BattleClosed)  | halt }

  set %curbat $readini(battle2.txt, Battle, List)
  if ($istok(%curbat,$1,46) = $true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, AlreadyInBattle) | halt }

  if ($readini(battle2.txt, BattleInfo, Players) >= 10) { query %battlechan $readini(translation.dat, errors, PlayerLimit) | halt }

  %curbat = $addtok(%curbat,$1,46)
  writeini battle2.txt Battle List %curbat

  if ($readini($char($1), info, flag) = $null) {
    var %battleplayers $readini(battle2.txt, BattleInfo, Players)
    inc %battleplayers 1 
    writeini battle2.txt BattleInfo Players %battleplayers

    var %current.shop.level $readini(battle2.txt, BattleInfo, ShopLevel)
    if (%current.shop.level = $null) { var %current.shop.level 0 }
    var %player.shop.level $readini($char($1), stuff, shoplevel)
    inc %current.shop.level %player.shop.level
    writeini battle2.txt BattleInfo ShopLevel %current.shop.level
  }

  $set_chr_name($1) | query %battlechan $readini(translation.dat, battle, EnteredTheBattle) | write battle.txt $1

  ; Full the person entering the battle.
  $fulls($1)
}

; ==========================
; Flee the battle!
; ==========================
ON 2:TEXT:!flee*:#:/flee $nick
ON 2:TEXT:!run away*:#:/flee $nick
ON 50:TEXT:*flees the battle*:#:/flee $1

alias flee {
  $check_for_battle($1)

  if ($is_charmed($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }

  writeini $char($1) battle status runaway
  $set_chr_name($1) | query %battlechan $readini(translation.dat, battle, FleeBattle)

  var %number.of.flees $readini($char($1), stuff, TimesFled)
  if (%number.of.flees = $null) { var %number.of.flees 0 }
  inc %number.of.items.sold 1
  writeini $char($1) stuff TimesFled %number.of.flees

  $achievement_check($1, ScardyCat)

  $next
}


; ==========================
; The battle begins
; ==========================

alias battlebegin {
  unset %monster.list
  set %battleisopen off

  ; First, see if there's any players in the battle..
  set %number.of.players $readini(battle2.txt, BattleInfo, Players)
  if ((%number.of.players = 0) || (%number.of.players = $null)) {  query %battlechan $readini(translation.dat, battle, NoPlayersOnField) | $clear_battle | halt }

  $random.weather.pick

  var %winning.streak $readini(battlestats.dat, battle, winningstreak)

  set %boss.battle.numbers 10.15.20.30.60.100.150.200
  if ($istok(%boss.battle.numbers,%winning.streak,46) = $true) { set %bosschance 1 }
  if ($istok(%boss.battle.numbers,%winning.streak,46) = $false) {   
    ; Now we determine what kind of battle it is
    var %bosschance $rand(1,100) 
  }

  unset %boss.battle.numbers

  if (%battle.type = $null) { 
    if (%bosschance <= 10) { set %battle.type boss }
    if ((%bosschance > 10) && (%bosschance < 95)) { set %battle.type monster }
    if (%bosschance >= 95) { set %battle.type orbfountain }
  }

  ; Okay, so now we need to determine how many monsters to pull.
  set %number.of.monsters.needed 1
  if (%battle.type = boss) { %number.of.monsters.needed = 1 } 
  if (%battle.type = orbfountain) { %number.of.monsters.needed = 1 }
  if ((%battle.type != boss) && (%battle.type != orbfountain)) { 
    %number.of.monsters.needed = $round($calc(%number.of.players / 2),0)
    if (%number.of.monsters.needed > 5) { %number.of.monsters.needed = 5 }
  }

  ; If the players have been winning a lot then we need to make things more interesting/difficult for them.
  if ((%winning.streak > 20) && (%winning.streak <= 50)) { inc %number.of.monsters.needed 1 }
  if (%winning.streak > 50) { inc %number.of.monsters.needed 2 }


  ; Let's see if there's any monsters already in battle (via !summon).  If so, we don't want more than 10..
  var %number.of.monsters $readini(battle2.txt, BattleInfo, Monsters) 
  if (%number.of.monsters = $null) { var %number.of.monsters 0 } 
  if (%number.of.monsters >= 10) { set %number.of.monsters.needed 0 }

  ; Generate the monsters..

  if (%battle.type = orbfountain) { 
    $generate_monster(orbfountain)
  }

  if (%battle.type = monster) {
    $generate_monster(monster)
  }

  if (%battle.type = boss) {
    $generate_monster(boss)

    if (%winning.streak >= 50) { 
      set %number.of.monsters.needed $round($calc(%number.of.players / 2),0)
      if (%number.of.monsters.needed = $null) { set %number.ofmonsters.needed 2 }
      if (%number.of.monsters.needed > 0) { $generate_monster(monster)   }
    }
  }

  ; Check for an NPC Ally to join the battle.
  $random.battlefield.ally

  ; Check for a random battle field curse.
  $random.battlefield.curse

  ; Turn on the rage timer.
  if ((%number.of.monsters.needed <= 3) && (%battle.type != boss)) {  /.timerBattleRage 1 900 /battle_rage }
  if (%battle.type = boss) {  /.timerBattleRage 1 1200 /battle_rage }
  else { /.timerBattleRage 1 1800 /battle_rage }

  $generate_battle_order
  set %who $read -l1 battle.txt | set %line 1
  $battlelist
  /.timerEnterPause 1 2 /query %battlechan $readini(translation.dat, battle, StepsUpFirst)
  ; To keep someone from sitting and doing nothing for hours at a time, there's a timer that will auto-force the next turn.
  /.timerBattleNext 1 180 /next

  unset %number.of.players

  $aicheck(%who)
}


alias generate_monster {
  if ($1 = orbfountain) {
    .copy -o $mon(orb_fountain) $char(orb_fountain)  | set %curbat $readini(battle2.txt, Battle, List) | %curbat = $addtok(%curbat,orb_fountain,46) | writeini battle2.txt Battle List %curbat | write battle.txt orb_fountain
    $boost_monster_stats(orb_fountain) | $fulls(orb_fountain)
    var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
    $set_chr_name(orb_fountain) 
    query %battlechan $readini(translation.dat, battle, EnteredTheBattle)
    query %battlechan 12 $+ %real.name  $+ $readini($char(orb_fountain), descriptions, char)
  }

  if ($1 = monster) {
    $get_mon_list
    var %monsters.total $numtok(%monster.list,46)
    if ((%monsters.total = 0) || (%monster.list = $null)) { query %battlechan $readini(translation.dat, Errors, NoMonsAvailable) | $clear_battle | halt }
    if (%monsters.total = 1) { 
      .copy -o $mon(%monster.list) $char(%monster.list) | set %curbat $readini(battle2.txt, Battle, List) |  %curbat = $addtok(%curbat,%monster.list,46) | writeini battle2.txt Battle List %curbat | write battle.txt %monster.list 
      $set_chr_name(%monster.list)
      query %battlechan $readini(translation.dat, battle, EnteredTheBattle)
      /.timerQueryPause 1 2 /query %battlechan 12 $+ %real.name  $+ $readini($char(%monster.list), descriptions, char)
      $boost_monster_stats(%monster.list)  
      $fulls(%monster.list)
      var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
    }
    else { 
      set %value 1
      while (%value <= %number.of.monsters.needed) {
        if (%monster.list = $null) { inc %value 1 } 
        set %monsters.total $numtok(%monster.list,46)
        set %random.monster $rand(1, %monsters.total) 
        set %monster.name $gettok(%monster.list,%random.monster,46)
        if (%monsters.total = 0) { inc %value 1 }
        if ($isfile($char(%monster.name)) = $false) { 
          .copy -o $mon(%monster.name) $char(%monster.name) | set %curbat $readini(battle2.txt, Battle, List) | %curbat = $addtok(%curbat,%monster.name,46) |  writeini battle2.txt Battle List %curbat 
          $set_chr_name(%monster.name) 
          query %battlechan $readini(translation.dat, battle, EnteredTheBattle)
          query %battlechan 12 $+ %real.name  $+ $readini($char(%monster.name), descriptions, char)
          set %monster.to.remove $findtok(%monster.list, %monster.name, 46)
          set %monster.list $deltok(%monster.list,%monster.to.remove,46)
          write battle.txt %monster.name
          $boost_monster_stats(%monster.name) 
          $fulls(%monster.name) |  var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
          if (%battlemonsters = 10) { set %number.of.monsters.needed 0 }
          inc %value 1
        }
        else {  %monster.list = $deltok(%monster.list,%monster.name,46) | dec %value 1 }
      }
    }
  }

  if ($1 = boss) {

    if ($readini(system.dat, system, EnableDoppelganger) = true) { var %doppelganger.chance $rand(1,100) }
    if ($readini(system.dat, system, EnableDoppelganger) != true) { var %doppelganger.chance $rand(100,100) }

    if (%doppelganger.chance > 7) { 
      if (%winning.streak < 50) { set %number.of.monsters.needed 1 }
      if ((%winning.streak >= 50) && (%winning.streak <= 70)) { set %number.of.monsters.needed $rand(1,2) }
      if (%winning.streak > 70) { set %number.of.monsters.needed $rand(2,3) }
      if (%number.of.monsters.needed > 3) { %number.of.monsters.needed = 3 }

      $get_boss_list
      var %monsters.total $numtok(%monster.list,46)
      if ((%monsters.total = 0) || (%monster.list = $null)) { query %battlechan 4Error: There are no bosses in the boss folder.. Have the bot admin check to make sure there are bosses for players to battle! | $clear_battle | halt }
      if (%monsters.total = 1) { 
        .copy -o $boss(%monster.list) $char(%monster.list) | set %curbat $readini(battle2.txt, Battle, List) |  %curbat = $addtok(%curbat,%monster.list,46) |  writeini battle2.txt Battle List %curbat | write battle.txt %monster.list
        $set_chr_name(%monster.list)
        query %battlechan $readini(translation.dat, battle, EnteredTheBattle)
        query %battlechan 12 $+ %real.name  $+ $readini($char(%monster.list), descriptions, char) 
        query %battlechan 2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.list), descriptions, BossQuote) $+ "
        var %boss.item $readini($char(%monster.list), stuff, drops)
        if (%boss.item != $null) { 
          var %boss.item $readini($char(%monster.list), stuff, drops)
          if (%boss.item != $null) { writeini battle2.txt battle bonusitem %boss.item | unset %boss.item }
        }
        $boost_monster_stats(%monster.list)
        $fulls(%monster.list) |  var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
      }
      else { 
        set %value 1
        while (%value <= %number.of.monsters.needed) {
          if (%monster.list = $null) { inc %value 1 } 
          set %monsters.total $numtok(%monster.list,46)
          set %random.monster $rand(1, %monsters.total) 
          set %monster.name $gettok(%monster.list,%random.monster,46)
          .copy -o $boss(%monster.name) $char(%monster.name) | set %curbat $readini(battle2.txt, Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini battle2.txt Battle List %curbat         $set_chr_name(%monster.name) 
          query %battlechan $readini(translation.dat, battle, EnteredTheBattle)
          query %battlechan 12 $+ %real.name  $+ $readini($char(%monster.name), descriptions, char)
          query %battlechan 2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.name), descriptions, BossQuote) $+ "
          var %boss.item $readini($char(%monster.name), stuff, drops)
          if (%boss.item != $null) { 
            var %temp.boss.list $readini(battle2.txt, battle, bonusitem)
            if (%temp.boss.list != $null) { writeini battle2.txt battle bonusitem %temp.boss.list $+ . $+ %boss.item }
            if (%temp.boss.list = $null) { writeini battle2.txt battle bonusitem %boss.item }
          }
          set %monster.to.remove $findtok(%monster.list, %monster.name, 46)
          set %monster.list $deltok(%monster.list,%monster.to.remove,46)
          write battle.txt %monster.name
          $boost_monster_stats(%monster.name) 
          $fulls(%monster.name) |   var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
          if (%battlemonsters = 10) { set %number.of.monsters.needed 0 }
          inc %value 1
        }
      }
    }
  }
  if (%doppelganger.chance <= 7) { 
    query %battlechan $readini(translation.dat, events, DoppelgangerFight)
    $generate_evil_clones
  }
}

; ==========================
; Battle Rage alias
; ==========================
alias battle_rage {
  ; When this alias is called all the monsters still alive in battle will become much harder to kill as all of their stats will be increased
  ; The idea is to make it so battles don't last forever (someone can't stall for 2 hours on one battle).  Players need to kill monsters fast.

  query %battlechan $readini(translation.dat, battle, DarknessCoversBattlefield)

  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line battle.txt
    var %flag $readini($char(%who.battle), info, flag)

    if (%flag = monster) { 
      var %current.status $readini($char(%who.battle), battle, status)
      if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }

      var %ignore.flag $readini($char(%who.battle), info, RageMode)
      if (%ignore.flag != ignore) {

        $boost_monster_stats(%who.battle, rage)
        writeini $char(%who.battle) Basestats HP $readini($char(%who.battle), Battle, HP)
        writeini $char(%who.battle) Battle Tp $readini($char(%who.battle), BaseStats, TP)
        writeini $char(%who.battle) Battle Str $readini($char(%who.battle), BaseStats, Str)
        writeini $char(%who.battle) Battle Def $readini($char(%who.battle), BaseStats, Def)
        writeini $char(%who.battle) Battle Int $readini($char(%who.battle), BaseStats, Int)
        writeini $char(%who.battle) Battle Spd $readini($char(%who.battle), BaseStats, Spd)

      }

      inc %battletxt.current.line 1
    }
    else { inc %battletxt.current.line 1 }
  }
}

; ==========================
; Generate the turn order
; ==========================
alias generate_battle_order {

  ; Are all the monsters defeated?  If so, we need to end the battle as a victory.
  if ($battle.monster.death.check = true) { /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle victory | halt }
  if ($battle.player.death.check = true) { /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle defeat | halt } 

  ; get rid of the Battle Table and the now un-needed file
  if ($isfile(BattleTable.file) = $true) { 
    hfree BattleTable
    .remove BattleTable.file
  }

  ; make the Battle List table
  hmake BattleTable

  ; load them from the file.   the initial list will be generated from the !enter commands.  
  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line battle.txt
    set %battle.speed $readini($char(%who.battle), battle, spd)
    if ($readini($char(%who.battle), status, slow) = yes) { %battle.speed = $calc(%battle.spd / 2) } 

    set %current.playerstyle $readini($char(%who.battle), styles, equipped)
    set %current.playerstyle.level $readini($char(%who.battle), styles, %current.playerstyle)

    if (%current.playerstyle = Trickster) {
      inc %battle.speed $calc(2 * %current.playerstyle.level)
    }

    if (%current.playerstyle = HitenMitsurugi-ryu) {
      inc %battle.speed $calc(3 * %current.playerstyle.level)
    }

    unset %current.playerstyle | unset %current.playerstyle.level

    if (%battle.speed <= 0) { set %battle.speed 1 }

    hadd BattleTable %who.battle %battle.speed
    inc %battletxt.current.line
  }

  ; save the BattleTable hashtable to a file
  hsave BattleTable BattleTable.file

  ; load the BattleTable hashtable (as a temporary table)
  hmake BattleTable_Temp
  hload BattleTable_Temp BattleTable.file

  ; sort the Battle Table
  hmake BattleTable_Sorted
  var %battletableitem, %battletabledata, %battletableindex, %battletablecount = $hget(BattleTable_Temp,0).item
  while (%battletablecount > 0) {
    ; step 1: get the lowest item
    %battletableitem = $hget(BattleTable_Temp,%battletablecount).item
    %battletabledata = $hget(BattleTable_Temp,%battletablecount).data
    %battletableindex = 1
    while (%battletableindex < %battletablecount) {
      if ($hget(BattleTable_Temp,%battletableindex).data < %battletabledata) {
        %battletableitem = $hget(BattleTable_Temp,%battletableindex).item
        %battletabledata = $hget(BattleTable_Temp,%battletableindex).data
      }
      inc %battletableindex
    }

    ; step 2: remove the item from the temp list
    hdel BattleTable_Temp %battletableitem

    ; step 3: add the item to the sorted list
    %battletableindex = sorted_ $+ $hget(BattleTable_Sorted,0).item
    hadd BattleTable_Sorted %battletableindex %battletableitem

    ; step 4: back to the beginning
    dec %battletablecount
  }

  ; get rid of the temp table
  hfree BattleTable_Temp

  ; Erase the old battle.txt and replace it with the new one.
  .remove battle.txt

  var %index = $hget(BattleTable_Sorted,0).item
  while (%index > 0) {
    dec %index
    var %tmp = $hget(BattleTable_Sorted,sorted_ $+ %index)
    write battle.txt %tmp
  }

  ; get rid of the sorted table
  hfree BattleTable_Sorted

  ; get rid of the Battle Table and the now un-needed file
  hfree BattleTable
  .remove BattleTable.file

  ; unset the battle.speed
  unset %battle.speed
}

; ==========================
; The battle ends
; ==========================
alias endbattle {
  ; $1 can be victory or defeat.
  ; If victory, add red orbs to everyone..  if boss, add a black orb to all survivors
  ; if defeat, add a small amount of red orbs to everyone..

  ; Let's increase the total number of battles that we've had so far.
  var %totalbattles $readini(battlestats.dat, Battle, TotalBattles) |  inc %totalbattles 1 | writeini battlestats.dat Battle TotalBattles %totalbattles

  if ($1 = defeat) {
    query %battlechan $readini(translation.dat, battle, BattleIsOver)
    query %battlechan $readini(translation.dat, battle, EvilHasWon)
    var %defeats $readini(battlestats.dat, battle, totalLoss) | inc %defeats 1 | writeini battlestats.dat battle totalLoss %defeats
    writeini battlestats.dat battle WinningStreak 0
    var %losing.streak $readini(battlestats.dat, battle, LosingStreak) | inc %losing.streak 1 | writeini battlestats.dat battle LosingStreak %losing.streak

    ; Add base orbs.
    if (%battle.type = monster) { set %base.redorbs $readini(system.dat, System, basexp) }
    if (%battle.type = boss) { set %base.redorbs $readini(system.dat, System, basebossxp) } 

    %base.redorbs = $round($calc(%base.redorbs * (.5 + %number.of.monsters.needed)), 0)
    set %bonus.orbs $round($readini(battle2.txt, BattleInfo, OrbBonus),0)

    inc %base.redorbs %bonus.orbs
    set %base.redorbs $round($calc(%base.redorbs / 2),0)
    inc %base.redorbs $rand(1,20)

    var %max.orb.reward $readini(system.dat, system, MaxOrbReward)
    if (%max.orb.reward = $null) { var %max.orb.reward 20000 }
    if (%base.redorbs > %max.orb.reward) { set %base.redorbs %max.orb.reward }

    $battle.reward.redorbs
    query %battlechan $readini(translation.dat, battle, RewardOrbsLoss)
  }

  if ($1 = victory) {
    query %battlechan $readini(translation.dat, battle, BattleIsOver)
    query %battlechan $readini(translation.dat, battle, GoodHasWon)
    var %wins $readini(battlestats.dat, battle, totalWins) | inc %wins 1 | writeini battlestats.dat battle totalWins %wins
    writeini battlestats.dat battle LosingStreak 0
    var %winning.streak $readini(battlestats.dat, battle, WinningStreak) | inc %winning.streak 1 | writeini battlestats.dat battle WinningStreak %winning.streak
    var %winning.streak.record $readini(battlestats.dat, battle, WinningStreakRecord)
    if (%winning.streak.record = $null) { var %winning.streak.record 0 }
    if (%winning.streak > %winning.streak.record) { writeini battlestats.dat battle WinningStreakRecord %winning.streak }

    ; Add base orbs.
    if (%battle.type = monster) { set %base.redorbs $readini(system.dat, System, basexp) }
    if (%battle.type = orbfountain) { set %base.redorbs $readini(system.dat, System, basexp) | inc %base.redorbs $rand(375,750) }
    if (%battle.type = boss) { set %base.redorbs $readini(system.dat, System, basebossxp) } 

    %base.redorbs = $round($calc(%base.redorbs * (1 + %number.of.monsters.needed)), 0)
    set %bonus.orbs $round($readini(battle2.txt, BattleInfo, OrbBonus),0)
    inc %base.redorbs %bonus.orbs

    var %max.orb.reward $readini(system.dat, system, MaxOrbReward)
    if (%max.orb.reward = $null) { var %max.orb.reward 20000 }
    if (%base.redorbs > %max.orb.reward) { set %base.redorbs %max.orb.reward }

    $battle.reward.redorbs
    $battle.reward.playerstylepoints
    $battle.reward.playerstylexp
    query %battlechan $readini(translation.dat, battle, RewardOrbsWin)

    ; If boss battle, do black orbs for select players.
    unset %black.orb.winners
    if (%battle.type = boss) { $generate_style_order | $battle.reward.blackorbs
      if (%black.orb.winners != $null) { query %battlechan $readini(translation.dat, battle, BlackOrbWin) }
      if ($readini(battle2.txt, battle, bonusitem) != $null) {
        set %item.winner $read -l $+ 1 battle.txt 
        var %winner.flag $readini($char(%item.winner), info, flag)
        if ((%winner.flag != monster) && (%winner.flag != npc)) {
          set %boss.item.list $readini(battle2.txt, battle, bonusitem)
          set %boss.item.total $numtok(%boss.item.list,46)
          set %random.boss.item $rand(1, %boss.item.total) 
          set %boss.item $gettok(%boss.item.list,%random.boss.item,46)

          unset %boss.item.total | unset %boss.item.list | unset %random.boss.item
          set %item.total $readini($char(%item.winner), item_amount, %boss.item)
          if (%item.total = $null) { writeini $char(%item.winner) item_amount %boss.item 1 }
          else { inc %item.total 1 | writeini $char(%item.winner) item_amount %boss.item %item.total }
          $set_chr_name(%item.winner) | query %battlechan $readini(translation.dat, battle, BonusItemWin) 
        }
        unset %boss.item | unset %item.winner
      }
    }
  }

  if (($1 = none) || ($1 = $null)) { query %battlechan $readini(translation.dat, battle, BattleIsOver) }

  ; then do a $clear_battle
  $clear_battle | halt
}

; ==========================
; The $next command.
; ==========================
alias next {
  ; Reset the Next timer.
  /.timerBattleNext 1 180 /next

  if (%battleis = off) { $clear_battle | halt }

  inc %line 1
  set %next.person $read -l $+ %line battle.txt
  if (%next.person = $null) { set %line 1 | $generate_battle_order  } 
  set %who $read -l $+ %line battle.txt 
  $turn(%who)
}

; ==========================
; Controls the turn
; ==========================
alias turn {
  unset %all_status | unset %status.message
  set %status $readini($char($1), Battle, Status)
  if ((%status = dead) || (%status = runaway)) { unset %status | $next | halt }
  if ($readini($char($1), info, ai_type) = defender) { $next | halt }
  if ($1 = orb_fountain) { $next | halt }

  else { 

    ; Are all the monsters defeated?  If so, we need to end the battle as a victory.
    if ($battle.monster.death.check = true) { /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle victory | halt }

    ; Are all the players defeated?  If so, we need to end the battle as a loss.
    if ($battle.player.death.check = true) { /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle defeat | halt } 

    $poison_check($1) | $zombie_check($1) | $zombieregenerating_check($1) | $regenerating_check($1) | $TPregenerating_check($1)
    $frozen_check($1) | $shock_check($1)  | $burning_check($1) | $tornado_check($1) | $drowning_check($1) | $earth-quake_check($1)
    $staggered_check($1) | $intimidated_check($1) | $blind_check($1) | $curse_check($1) | unset %hp.percent  | $stopped_check($1) | $charm_check($1) | $amnesia_check($1) | $paralysis_check($1)
    $drunk_check($1) | $slowed_check($1) | $asleep_check($1) | $stunned_check($1) | $boosted_check($1)

    if (%all_status = $null) { %all_status = none } 

    ; Are all the monsters defeated?  If so, we need to end the battle as a victory.
    if ($battle.monster.death.check = true) { /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle victory | halt }

    ; Are all the players defeated?  If so, we need to end the battle as a loss.
    if ($battle.player.death.check = true) { /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle defeat | halt } 

    $hp_status($1)
    set %status.message $readini(translation.dat, battle, TurnMessage)

    if ($readini($char($1), status, curse) != yes) {
      ; Add some TP to the player if it's not at max.
      set %tp.have $readini($char($1), battle, tp)
      set %tp.max $readini($char($1), basestats, tp)
      inc %tp.have 5

      if ($readini($char($1), skills, zen) > 0) { 
        var %zen.tp.gain $calc($readini($char($1), skills, Zen) * 5)
        inc %tp.have %zen.tp.gain
      }

      if (%tp.have >= %tp.max) { writeini $char($1) battle tp %tp.max }
      else { writeini $char($1) battle tp %tp.have }
      unset %tp.have | unset %tp.max
    }

    writeini $char($1) Status burning no | writeini $char($1) Status drowning no | writeini $char($1) Status earth-quake no | writeini $char($1) Status tornado no 
    writeini $char($1) Status freezing no | writeini $char($1) status frozen no | writeini $char($1) status shock no
    if (($readini($char($1), Status, Blind) = yes) || ($readini($char($1), Status, intimidate) = yes)) { 
      writeini $char($1) status intimidate no | writeini $char($1) Status blind no | writeini $char($1) status paralysis no | writeini $char($1) status stun no | writeini $char($1) status stop no |  /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 1 /next | halt
    }
    if ($readini($char($1), status, paralysis) = yes) { /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 1 /next  | halt }
    if ($readini($char($1), status, sleep) = yes) { /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 1 /next | halt  }
    if ($readini($char($1), status, stun) = yes) { writeini $char($1) status stun no | /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 1 /next | halt }
    if ($readini($char($1), status, stop) = yes) { writeini $char($1) status stop no | /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 1 /next | halt }

    .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 4 /query %battlechan %status.message

    ; Check for AI
    $aicheck($1) | halt
  }
}

; ==========================
; See if all the players are dead.
; ==========================
alias battle.player.death.check {
  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  var %death.count 0
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line battle.txt
    var %flag $readini($char(%who.battle), info, flag) 
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line }
    else { 
      var %current.status $readini($char(%who.battle), battle, status)
      if ((%current.status = dead) || (%current.status = runaway)) { inc %death.count 1 | inc %battletxt.current.line 1 }
      else { inc %battletxt.current.line 1 } 
    }
  }

  if (%death.count = $readini(battle2.txt, BattleInfo, Players)) { return true } 
  else { return false }
}

; ==========================
; See if all the monsters are dead
; ==========================
alias battle.monster.death.check {
  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  var %death.count 0
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line battle.txt
    if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
    else { 
      var %current.status $readini($char(%who.battle), battle, status)
      if ((%current.status = dead) || (%current.status = runaway)) { inc %death.count 1 | inc %battletxt.current.line 1 }
      else { inc %battletxt.current.line 1 } 
    }
  }

  if (%death.count = $readini(battle2.txt, BattleInfo, Monsters)) { return true } 
  else { return false }
}

; ==========================
; Get a list of people in battle
; ==========================
alias battlelist { 
  if (%battleis = off) { query %battlechan $readini(translation.dat, errors, NoBattleCurrently) | halt }
  unset %battle.list | set %lines $lines(battle.txt) | set %l 1
  while (%l <= %lines) { 
    set %who.battle $read -l [ $+ [ %l ] ] battle.txt | set %status.battle $readini($char(%who.battle), Battle, Status)
    if (%status.battle = $null) { inc %l 1 }
    else { 
      if (%status.battle = dead) { 
        var %token.to.add  $+ $colour(CTCP text) $+ %who.battle
        %battle.list = $addtok(%battle.list,%token.to.add,46) | inc %l 1 
      } 
      else { 
        var %token.to.add   $+ $colour(Part Text) $+ %who.battle
        %battle.list = $addtok(%battle.list,%token.to.add,46) | inc %l 1 
      }
    } 
  }
  unset %lines | unset %l 
  $battlelist.cleanlist
  if (%battle.list = $null) { query %battlechan $readini(translation.dat, battle, NoOneJoinedBattleYet) | unset %battle.list | unset %who.battle | halt }
  query %battlechan $readini(translation.dat, battle, BatListTitleMessage)  |  query %battlechan %battle.list | unset %battle.list | unset %who.battle
}

alias battlelist.cleanlist {
  ; CLEAN UP THE LIST
  if ($chr(046) isin %battle.list) { set %replacechar $chr(044) $chr(032)
    %battle.list = $replace(%battle.list, $chr(046), %replacechar)
  }
}

; ==========================
; REWARD ORBS 
; ===========================

alias battle.reward.redorbs {
  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line battle.txt
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 
      var %current.redorbs $readini($char(%who.battle), stuff, redorbs)
      inc %current.redorbs %base.redorbs
      var %total.redorbs.reward %base.redorbs

      ; Check for the orb hunter passive skill.
      if ($readini($char(%who.battle), skills, OrbHunter) != $null) {
        var %orbhunter.inc.amount $readini(skills.db, orbhunter, amount)
        if (%orbhunter.inc.amount = $null) { var %orbhunter.inc.amount 15 }
        inc %current.redorbs $round($calc(%orbhunter.inc.amount * $readini($char(%who.battle), skills, OrbHunter)),0) 
        inc %total.redorbs.reward $round($calc(%orbhunter.inc.amount * $readini($char(%who.battle), skills, OrbHunter)),0) 
      }

      ;  Check for the an accessory that increases red orbs
      set %current.accessory $readini($char(%who.battle), equipment, accessory) 
      if ($readini(items.db, %current.accessory, accessorytype) = IncreaseRedOrbs) {
        set %accessory.amount $readini(items.db, %current.accessory, amount)
        var %increase.orbs.amount $round($calc(%base.redorbs * %accessory.amount),0)
        inc %current.redorbs %increase.orbs.amount
        inc %total.redorbs.reward %increase.orbs.amount
        unset %accessory.amount
      }
      unset %current.accessory

      writeini $char(%who.battle) stuff redorbs %current.redorbs

      %red.orb.winners = $addtok(%red.orb.winners, $+ %who.battle $+  $+ $chr(91) $+ $chr(43) $+ %total.redorbs.reward $+ $chr(93),46)

      inc %battletxt.current.line 1 
    }
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %red.orb.winners) { set %replacechar $chr(044) $chr(032)
    %red.orb.winners = $replace(%red.orb.winners, $chr(046), %replacechar)
  }
}

alias battle.reward.blackorbs { 
  unset %black.orb.winners
  set %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line battle.txt
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 
      set %current.status $readini($char(%who.battle), battle, status)
      if (%current.status = dead) { inc %battletxt.current.line 1 }
      else { 
        ; Increase black orbs
        var %current.blackorbs $readini($char(%who.battle), stuff, blackorbs)
        inc %current.blackorbs 1
        writeini $char(%who.battle) stuff blackorbs %current.blackorbs
        %black.orb.winners = $addtok(%black.orb.winners,%who.battle,46)
        inc %battletxt.current.line 1 
      } 
    }
  }
  ; CLEAN UP THE LIST
  if ($chr(046) isin %black.orb.winners) { set %replacechar $chr(044) $chr(032)
    %black.orb.winners = $replace(%black.orb.winners, $chr(046), %replacechar)
  }
  unset %current.status
}

; ==========================
; REWARD PLAYER STYLE XP
; ===========================

alias battle.reward.playerstylexp {
  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 | set %playerstyle.xp.reward $rand(1,3)
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line battle.txt
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 
      var %vogue.check $readini($char(%who.battle), skills, Vogue) 
      if (%vogue.check > 0) { 
        var %vogue.value $readini($char(%who.battle), skills, Vogue) * 1
        inc %playerstyle.xp.reward %vogue.value
      }
      $add.playerstyle.xp(%who.battle, %playerstyle.xp.reward)
      inc %battletxt.current.line 1 
    }
  }
  unset %playerstyle.xp
}

; ============================
; STATUS EFFECTS aliases
;=============================

alias poison_check { 
  ;  Check for the an accessory that poisons the user
  set %current.accessory $readini($char($1), equipment, accessory) 
  if ($readini(items.db, %current.accessory, accessorytype) = IncreaseMeleeAddPoison) {
    writeini $char($1) status poison yes
    writeini $char($1) status poison.timer 0
  }
  unset %current.accessory

  if (($readini($char($1), status, poison) = yes) || ($readini($char($1), status, poison-heavy) = yes)) {
    set %poison.timer $readini($char($1), status, poison.timer)  
    if (%poison.timer > 3) {  
      writeini $char($1) status poison no
      writeini $char($1) status poison-heavy no 
      writeini $char($1) status poison.timer 1
      $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, PoisonWornOff) | unset %curse.timer | return 
    }
    else { 
      %poison.timer = $calc(%poison.timer + 1) | writeini $char($1) status poison.timer %poison.timer 
      if ($readini($char($1), Status, poison-heavy) = yes) { $heavy-poison($1) | return }
      $status_message_check(poisoned) 
      var %max.hp $readini($char($1), battlestats, hp)
      var %poison $round($calc(%max.hp * .10),0)
      set %hp $readini($char($1), Battle, HP) | $set_chr_name($1)
      if (%poison >= %hp) { query %battlechan %status.message | query %battlechan $readini(translation.dat, status, PoisonKills) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | next | halt }
      if (%poison < %hp) { /.timer $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 /query %battlechan $readini(translation.dat, status, PoisonMessage) | dec %hp %poison | writeini $char($1) Battle HP %hp | return }
    }
  }
  else { return }
}


alias heavy-poison { $status_message_check(poisoned heavily)
  var %max.hp $readini($char($1), battlestats, hp)
  var %poison $round($calc(%max.hp * .20),0)
  set %hp $readini($char($1), Battle, HP) | $set_chr_name($1)
  if (%poison >= %hp) { query %battlechan %status.message | query %battlechan $readini(translation.dat, status, PoisonKills) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | next | halt }
  if (%poison < %hp) { query %battlechan $readini(translation.dat, status, PoisonMessage) | dec %hp %poison | writeini $char($1) Battle HP %hp | return }
}

alias curse_check {

  if ($readini($char($1), equipment, accessory) = Aztec-Gold) {
    writeini $char($1) status curse yes
    writeini $char($1) status curse.timer 0
    writeini $char($1) battle tp 0
  }

  if ($readini($char($1), status, curse) = yes) { 
    set %curse.timer $readini($char($1), status, curse.timer)  
    if (%curse.timer <= 3) { %curse.timer = $calc(%curse.timer + 1) | writeini $char($1) status curse.timer %curse.timer | $status_message_check(cursed)
      $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, CurrentlyCursed) | unset %curse.timer | return 
    }
    else {
      writeini $char($1) status curse no | writeini $char($1) status curse.timer 1 
      $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, CurseWornOff) | unset %curse.timer | return 
    }
  }
  else { return } 
}

alias regenerating_check { 
  if (($readini($char($1), Status, zombieregenerating) = yes) || ($readini($char($1), Status, ZombieRegenerating) = on)) { return }
  if (($readini($char($1), Status, regenerating) = yes) || ($readini($char($1), Status, Regenerating) = on)) { 
    $status_message_check(regenerating HP) | var %howmuch $skill.regen.calculate($1) | $set_chr_name($1)
    var %current.hp $readini($char($1), battle, HP) | inc %current.hp %howmuch | writeini $char($1) Battle HP %current.hp 
    $regen_done_check($1, %howmuch, HP)
  }
  else { return }
}

alias regen_done_check { 
  var %current $readini($char($1), Battle, $3) | var %max $readini($char($1), BaseStats, $3)

  if (($3 = hp) || ($3 = mp)) {
    if (%current >= %max) { 
      $set_chr_name($1) | /.timerRegenMessage 1 3 /query %battlechan $readini(translation.db, skill, FinishedRegen)
      if ($3 = TP) { writeini $char($1) Status TPRegenerating no }
      if ($3 = HP) { writeini $char($1) Status Regenerating no }
      var %max $readini($char($1), BaseStats, $3) |  writeini $char($1) Battle $3 %max | return 
    }
    else { .timerRegen $+ $rand(a,z) 1 2 /query %battlechan $readini(translation.dat, skill, RegenerationMessage)  | return } 
  }

  else { .timerRegen $+ $rand(1,1000) 1 2 /query %battlechan $readini(translation.dat, skill, RegenerationMessage) | return } 
}

alias zombieregenerating_check { 
  if (($readini($char($1), Status, zombieregenerating) = yes) || ($readini($char($1), Status, ZombieRegenerating) = on)) { 
    $status_message_check(regenerating HP) | var %howmuch $skill.zombieregen.calculate($1) | $set_chr_name($1)
    var %current.hp $readini($char($1), battle, HP) | inc %current.hp %howmuch | writeini $char($1) Battle HP %current.hp 

    var %current $readini($char($1), Battle, hp) | var %max $readini($char($1), BaseStats, hp)
    if (%current >= %max) {  writeini $char($1) Battle hp %max }

    .timerRegen $+ $rand(a,z) 1 3 /query %battlechan $readini(translation.dat, skill, ZombieRegeneration)  | return
  }
  else { return }
}

alias staggered_check { 
  if ($readini($char($1), Status, staggered) = yes) { $status_message_check(staggered)
    $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, TooStaggeredToFight)
    writeini $char($1) status staggered no | writeini $char($1) info CanStagger no | $next
  }
  else { return } 
}

alias blind_check { 
  if ($readini($char($1), Status, blind) = yes) { $status_message_check(blind)
    $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, TooBlindToFight)
  }
  else { return } 
}

alias TPregenerating_check { 
  if (($readini($char($1), Status, TPregenerating) = yes) || ($readini($char($1), Status, TPRegenerating) = on)) { 
    $status_message_check(regenerating TP) | var %howmuch $skill.regen.calculate($1) | $set_chr_name($1)
    var %current.tp $readini($char($1), battle, TP) | inc %current.tp %howmuch | writeini $char($1) Battle TP %current.tp 
    $regen_done_check($1, %howmuch, TP)
  }
  else { return }
}

alias intimidated_check { 
  if ($readini($char($1), Status, intimidate) = yes) { $status_message_check(intimidated)
    $set_chr_name($1) | .timerThrottle $+ $nick $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, TooIntimidatedToFight)
  }
  else { return } 
}

alias frozen_check { 
  if ($readini($char($1), Status, frozen) = yes) { $status_message_check(freezing) 
    set %freezing $rand(1,10) | set %hp $readini($char($1), Battle, HP) | $set_chr_name($1)
    if (%freezing >= %hp) { .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, FrozenDeath) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | next | halt }
    if (%freezing < %hp) { .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, FrozenMessage) | dec %hp %freezing |  writeini $char($1) Battle HP %hp | return }
  }
  else { return }
}

alias asleep_check {
  if ($readini($char($1), Status, Sleep) = yes) { $status_message_check(asleep)
    $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, CurrentlyAsleep)
  }
  else { return } 
}

alias stunned_check {
  if ($readini($char($1), Status, Stun) = yes) { $status_message_check(stunned)
  $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, CurrentlyStunned)  }
  else { return } 
}

alias stopped_check {
  if ($readini($char($1), Status, Stop) = yes) { $status_message_check(frozen in time)
  $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, CurrentlyStopped)  }
  else { return } 
}

alias shock_check { 
  if ($readini($char($1), Status, shock) = yes) { $status_message_check(shocked) 
    set %shock $rand(1,10) | set %hp $readini($char($1), Battle, HP) | $set_chr_name($1)
    if (%shock >= %hp) { .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, ShockDeath)  | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | next | halt }
    if (%shock < %hp) { .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, ShockMessage)  | dec %hp %shock |  writeini $char($1) Battle HP %hp | return }
  }
  else { return }
}

alias burning_check { 
  if ($readini($char($1), Status, burning) = yes) { $status_message_check(burning) 
    set %burning $rand(1,10) | set %hp $readini($char($1), Battle, HP) | $set_chr_name($1)
    if (%burning >= %hp) { .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, BurningDeath) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | next | halt }
    if (%burning < %hp) { .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, BurningMessage) | dec %hp %burning | writeini $char($1) Battle HP %hp | return }
  }
  else { return }
}

alias tornado_check { 
  if ($readini($char($1), Status, tornado) = yes) { $status_message_check(caught in a tornado) 
    set %tornado $rand(1,10) | set %hp $readini($char($1), Battle, HP) | $set_chr_name($1)
    if (%tornado >= %hp) { .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, TornadoDeath) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | next | halt }
    if (%tornado < %hp) { .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, TornadoMessage) | dec %hp %tornado | writeini $char($1) Battle HP %hp | return }
  }
  else { return }
}

alias drowning_check { 
  if ($readini($char($1), Status, drowning) = yes) { $status_message_check(drowning) 
    set %drowning $rand(1,10) | set %hp $readini($char($1), Battle, HP) | $set_chr_name($1)
    if (%drowning >= %hp) { .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, DrowningDeath)  | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | next | halt }
    if (%drowning < %hp) { .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, DrowningMessage) | writeini $char($1) Battle Status normal | dec %hp %drowning | writeini $char($1) Battle HP %hp | return }
  }
  else { return }
}

alias earth-quake_check { 
  if ($readini($char($1), Status, earth-quake) = yes) { $status_message_check(shaking) 
    set %shaken $rand(1,10) | set %hp $readini($char($1), Battle, HP) | $set_chr_name($1)
    if (%shaken >= %hp) { .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, EarthquakeDeath) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | next | halt }
    if (%shaken < %hp) { .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, EarthquakeMessage)   | writeini $char($1) Battle Status normal | dec %hp %shaken | writeini $char($1) Battle HP %hp | return }
  }
  else { return }
}

alias weight_check { 
  if ($readini($char($1), Status, weight) = yes) { $status_message_check(weighed down)
  $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 2 query %battlechan $readini(translation.dat, status, CurrentlyWeighed) | return }
  else { return } 
}

alias drunk_check {
  if ($readini($char($1), Status, drunk) = yes) { 
    set %drunk.timer $readini($char($1), status, drunk.timer)  
    if (%drunk.timer <= 3) { %drunk.timer = $calc(%drunk.timer + 1) | writeini $char($1) status drunk.timer %drunk.timer | $status_message_check(drunk)
      $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, CurrentlyDrunk) | unset %drunk.timer | return 
    }
    else {
      writeini $char($1) status drunk no | writeini $char($1) status drunk.timer 1 
      $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, DrunkWornOff) | unset %virus.timer | return 
    }
  }
  else { return } 
}

alias zombie_check { 
  if ($readini($char($1), monster, type) = zombie) { 
    writeini $char($1) status zombieregenerating on
    $status_message_check(zombie) | return 
  }
  var %zombie.timer $readini($char($1), status, zombie.timer)  
  if (%zombie.timer <= 3) { 
    if ($readini($char($1), Status, zombie) = yes) { $status_message_check(zombie) |  %zombie.timer = $calc(%zombie.timer + 1) | writeini $char($1) status zombie.timer %zombie.timer |  writeini $char($1) status zombieregenerating on
    $set_chr_name($1) | return }
  }
  else { 
    if ($readini($char($1), Status, zombie) = yes) {   writeini $char($1) status zombie no | writeini $char($1) status zombie.timer 1 | $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, ZombieWornOff) |  writeini $char($1) status zombieregenerating off | unset %zombie.timer | return  }
  }
  return
}

alias slowed_check { 
  var %slow.timer $readini($char($1), status, slow.timer)  
  if (%slow.timer <= 3) { 
    if ($readini($char($1), Status, slow) = yes) { $status_message_check(slowed) |  %slow.timer = $calc(%slow.timer + 1) | writeini $char($1) status slow.timer %slow.timer
    $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, currentlyslowed) | return }
  }
  else { 
    if ($readini($char($1), Status, slow) = yes) {   writeini $char($1) status slow no | writeini $char($1) status slow.timer 1 | $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, SlowWornOff)  | unset %slow.timer | return  }
  }
  return
}

alias amnesia_check {
  if ($readini($char($1), status, amnesia) = yes) { 
    set %amnesia.timer $readini($char($1), status, amnesia.timer)  
    if (%amnesia.timer <= 3) { %amnesia.timer = $calc(%amnesia.timer + 1) | writeini $char($1) status amnesia.timer %amnesia.timer | $status_message_check(under amnesia)
      $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, CurrentlyHasAmensia) | unset %amnesia.timer | return 
    }
    else {
      writeini $char($1) status amnesia no | writeini $char($1) status amnesia.timer 1 
      $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, AmnesiaWornOff) | unset %amnesia.timer | return 
    }
  }
  else { return } 
}

alias charm_check {
  if ($readini($char($1), status, charmed) = yes) { 
    set %charm.timer $readini($char($1), status, charm.timer) | set %charmer $readini($char($1), status, charmer)
    if ($readini($char(%charmer), battle, status) = dead) {  writeini $char($1) status charm.timer 1 | writeini $char($1) status charmed no | $set_chr_name(%charmer) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, CharmerDeathWornOff) | unset %charm.timer | unset %charmer | return  }

    if (%charm.timer > 1) { %charm.timer = $calc(%charm.timer - 1) | writeini $char($1) status charm.timer %charm.timer | $status_message_check(charmed)
      $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, CurrentlyCharmedMessage) | unset %charm.timer | unset %charmer | return 
    }
    else {
      writeini $char($1) status charmed no | writeini $char($1) status charm.timer 1 | writeini $char($1) status charmer nooneIknowlol
      $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, CharmWornOff) | unset %charm.timer | unset %charmer | return 
    }
  }
  else { return } 
}

alias paralysis_check {
  if ($readini($char($1), status, paralysis) = yes) { 
    set %paralysis.timer $readini($char($1), status, paralysis.timer)  
    if (%paralysis.timer <= 2) { %paralysis.timer = $calc(%paralysis.timer + 1) | writeini $char($1) status paralysis.timer %paralysis.timer | $status_message_check(paralysis)
      $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, CurrentlyParalyzed) | unset %paralysis.timer | return 
    }
    else {
      writeini $char($1) status paralysis no | writeini $char($1) status paralysis.timer 1 
      $set_chr_name($1) | .timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 3 query %battlechan $readini(translation.dat, status, ParalysisWornOff) | unset %paralysis.timer | return 
    }
  }
  else { return } 
}

alias boosted_check { 
  if ($readini($char($1), Status, boosted) = yes) { $status_message_check(power boosted) }
}
