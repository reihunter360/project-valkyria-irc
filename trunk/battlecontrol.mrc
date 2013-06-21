;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; BATTLE CONTROL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

on 1:TEXT:!battle stats*:*: { $battle.stats }
on 1:TEXT:!battlestats*:*: { $battle.stats }

on 1:TEXT:!conquest*:*: { $conquest.display($1, $2) }

alias battle.stats {
  var %total.battles $bytes($readini(battlestats.dat, Battle, TotalBattles),b)
  var %total.wins $bytes($readini(battlestats.dat, Battle, TotalWins),b)
  var %total.losses $bytes($readini(battlestats.dat, Battle, TotalLoss),b)
  var %total.draws $bytes($readini(battlestats.dat, battle, TotalDraws),b)
  if (%total.draws = $null) { var %total.draws 0 } 
  var %winning.record $bytes($readini(battlestats.dat, Battle, WinningStreakRecord),b)
  var %total.gauntlet.wins $bytes($readini(battlestats.dat, Battle, GauntletRecord),b)

  if (%winning.record = $null) { unset %winning.record) }
  if (%winning.record != $null) { var %winning.record (Highest record is: %winning.record $+ ) }

  $display.system.message($readini(translation.dat, system, BattleStatsData), private)

  if ($readini(battlestats.dat, Battle, WinningStreak) != 0) { $display.system.message($readini(translation.dat, system, BattleStatsWinningStreak), private) }
  if ($readini(battlestats.dat, Battle, LosingStreak) != 0) { $display.system.message($readini(translation.dat, system, BattleStatsLosingStreak), private) }
  if (%total.gauntlet.wins > 0) { $display.system.message($readini(translation.dat, system, BattleStatsGauntletRecord), private) } 
}

; Bot Admins can toggle the bonus event flag.  Bonus Events = double the currency at the end of battle.
on 50:TEXT:!toggle bonus event*:*:{   
  if ($readini(system.dat, system, BonusEvent) = false) { 
    writeini system.dat system BonusEvent true
    $display.system.message($readini(translation.dat, system, BonusEventOn), global)
  }
  else {
    writeini system.dat system BonusEvent false
    $display.system.message($readini(translation.dat, system, BonusEventOff), global)
  }
}

; Bot Admins can toggle if damage is capped or not.
on 50:TEXT:!toggle damage cap*:*:{   
  if ($readini(system.dat, system, IgnoreDmgCap) = false) { 
    writeini system.dat system IgnoreDmgCap true
    $display.system.message($readini(translation.dat, system, DamageNotCapped), global)
  }
  else {
    writeini system.dat system IgnoreDmgCap false
    $display.system.message($readini(translation.dat, system, DamageNowCapped), global)
  }
}

; Bot Admins can toggle the automated battle system to be on/off
on 50:TEXT:!toggle automated battle system*:*:{   
  if ($readini(system.dat, system, automatedbattlesystem) = off) { 
    writeini system.dat system automatedbattlesystem on
    $display.system.message($readini(translation.dat, system, AutomatedBattleOn), global)
    if (%battleis = off) { $clear_battle }
  }
  else {
    writeini system.dat system automatedbattlesystem off
    $display.system.message($readini(translation.dat, system, AutomatedBattleOff), global)
  }
}

; Bot Admins can toggle which battle formulas are used.
on 50:TEXT:!toggle battle formula*:*:{   
  if ($readini(system.dat, system, BattleDamageFormula) = 1) { 
    writeini system.dat system BattleDamageFormula 2
    $display.system.message($readini(translation.dat, system, NewDmgFormulaIsOn), global)
  }
  else { 
    writeini system.dat system BattleDamageFormula 1
    $display.system.message($readini(translation.dat, system, NewDmgFormulaIsOff), global)
  }
}

; Bot admins can manually set the winning streak.
on 50:TEXT:!set streak*:*:{   
  if ($3 = $null) { .msg $nick 4!set streak number | halt }
  if ($3 <= 0) { .msg $nick the streak cannot be negative or 0. | halt }
  if (. isin $3) { .msg $nick the streak must be a whole number. | halt }
  writeini battlestats.dat battle LosingStreak 0
  writeini battlestats.dat battle winningstreak $3
  $display.system.message(3The winning streak has been set to: $3, global)
}

; Bot admins can toggle the AI system on/off.

on 50:TEXT:!toggle ai system*:*:{   
  if ($readini(system.dat, system, aisystem) = off) { 
    writeini system.dat system aisystem on
    $display.system.message($readini(translation.dat, system, AiSystemOn), global)
  }
  else {
    writeini system.dat system aisystem off
    $display.system.message($readini(translation.dat, system, AiSystemOff), global)
  }
}

; Bot admins can toggle the battlefield events
on 50:TEXT:!toggle battlefield events*:*:{   
  if ($readini(system.dat, system, EnableBattlefieldEvents) != true) { 
    writeini system.dat system EnableBattlefieldEvents true
    $display.system.message($readini(translation.dat, system, EnableBattlefieldEventsOn), global)
  }
  else {
    writeini system.dat system EnableBattlefieldEvents false
    $display.system.message($readini(translation.dat, system, EnableBattlefieldEventsOff), global)
  }
}

; Bot admins can adjust the "level adjust"
on 50:TEXT:!leveladjust*:*:{  
  if ($2 = $null) { $view.leveladjust }
  if ($2 != $null) {  

    if ($2 !isnum) {   $display.system.message($readini(translation.dat, errors, DifficultyMustBeNumber), private) | halt }
    if (. isin $2) {   $display.system.message($readini(translation.dat, errors, DifficultyMustBeNumber), private) | halt }
    if ($2 < 0) {   $display.system.message($readini(translation.dat, errors, DifficultyCan'tBeNegative), private) | halt }

    writeini battlestats.dat battle leveladjust $2
    $display.system.message($readini(translation.dat, system, SaveLevelAdjust), global)
  }
}

on 3:TEXT:!leveladjust:*:{ 
  if ($1 = !level) { halt }
  $view.leveladjust 
}

alias view.leveladjust {
  var %leveladjust $readini(battlestats.dat, battle, LevelAdjust)
  if (%leveladjust = $null) { var %leveladjust 0 }
  $display.system.message($readini(translation.dat, system, ViewLevelAdjust), private)
}

; Everyone can save and view a battle streak to their files.  Think of it like a quick save.

on 3:TEXT:!view battle save*:*:{   $set_chr_name($nick) | $checkchar($nick) 
  var %saved.streak $readini($char($nick), info, savedstreak)
  if (%saved.streak = $null) { var %saved.streak 0 }
  $display.system.message($readini(translation.dat, system, ViewBattleStreak), global)
}
on 3:TEXT:!save battle streak*:*:{   $set_chr_name($nick) | $checkchar($nick) 
  if (%battleis = on) {   $display.system.message($readini(translation.dat, errors, Can'tDoThisInBattle), private) | halt }
  var %current.streak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.streak <= 0) {   $display.system.message($readini(translation.dat, errors, Can'tSaveALosingStreak), private) | halt }

  else { 
    var %last.saved $readini($char($nick), info, savedstreak.time)
    var %current.time $ctime
    var %time.difference $calc(%current.time - %last.saved)

    if ((%time.difference = $null) || (%time.difference > 3600)) {
      var %saved.streak $readini($char($nick), info, savedstreak)
      if (%saved.streak = $null) { var %saved.streak 0 }
      if (%current.streak < %saved.streak) {   $display.system.message($readini(translation.dat, errors, Can'tSaveALowerStreak), private) | halt }
      writeini $char($nick) Info SavedStreak %current.streak
      writeini $char($nick) Info SavedStreak.time $ctime
      $display.system.message($readini(translation.dat, system, SaveBattleStreak), global)
    }
    else {   $display.system.message($readini(translation.dat, errors, NotEnoughTimeToSave), private) | halt }
  }
}

on 3:TEXT:!reload battle streak*:*:{   $set_chr_name($nick) | $checkchar($nick)
  if (%battleis = on) {   $display.system.message($readini(translation.dat, errors, Can'tDoThisInBattle), private) | halt }
  var %current.streak $readini(battlestats.dat, Battle, WinningStreak)
  if (%current.streak > 10) {   $display.system.message($readini(translation.dat, errors, Can'tReloadOnAWinningStreak), private) | halt }
  else { 
    var %saved.streak $readini($char($nick), info, savedstreak)
    if (%saved.streak = $null) {   $display.system.message($readini(translation.dat, errors, NoWinningStreakSaved), private) | halt }
    if (%saved.streak = 0) {   $display.system.message($readini(translation.dat, errors, NoWinningStreakSaved), private) | halt }
    writeini battlestats.dat Battle WinningStreak %saved.streak
    writeini battlestats.dat Battle LosingStreak 0
    $display.system.message($readini(translation.dat, system, ReloadBattleStreak), global)
    writeini $char($nick) info savedstreak 0
  }
}

; Bot Owners can have some control over battles
on 50:TEXT:!startbat*:*:{  
  if (%battleis = on) { $display.system.message($readini(translation.dat, errors, BattleAlreadyStarted), private) | halt }
  /.timerBattleStart off | $startnormal($2) 
}
on 50:TEXT:!start bat*:*:{   
  if (%battleis = on) { $display.system.message($readini(translation.dat, errors, BattleAlreadyStarted), private) | halt }
  /.timerBattleStart off | $startnormal($3) 
}
on 50:TEXT:!new bat*:*:{   
  if (%battleis = on) { $display.system.message($readini(translation.dat, errors, BattleAlreadyStarted), private) | halt }
  /.timerBattleStart off | $startnormal($3) 
}
on 50:TEXT:!end bat*:*:{ $endbattle($3) } 
on 50:TEXT:!endbat*:*:{  $endbattle($2) } 

; Bot owners can force the next turn
ON 50:TEXT:!next*:* { 
  if (%battleis = on)  { $check_for_double_turn(%who) }
  else { $display.system.message($readini(translation.dat, Errors, NoCurrentBattle), private) | halt }
}

; Bot owners can reset the battle stats.
on 50:TEXT:!clear battle stats*:*:{ 
  writeini battlestats.dat Battle TotalBattles 0
  writeini battlestats.dat Battle TotalWins 0
  writeini battlestats.dat Battle TotalLoss 0 
  writeini battlestats.dat Battle TotalDraws 0
  writeini battlestats.dat Battle LosingStreak 0
  writeini battlestats.dat Battle WinningStreak 0
  writeini battlestats.dat Battle GauntletRecord 0
  writeini battlestats.dat Battle WinningStreakRecord 0
  $display.system.message($readini(translation.dat, System, WipedBattleStats), global)
}

; Bot owners can change the time between battles.
on 50:TEXT:!time between battles *:*:{  
  writeini system.dat System TimeBetweenBattles $4
  $display.system.message($readini(translation.dat, System, ChangeTime), global)
}

; Bot owners can summon npcs/monsters/bosses to the battlefield during the "entering" phase.
on 50:TEXT:!summon*:*:{
  if ($readini(system.dat, system, botType) = IRC) {
    if ($2 = npc) {
      if ($isfile($npc($3)) = $true) {
        .copy -o $npc($3) $char($3)
        $boost_monster_stats($3)  
        $enter($3)
      }
      else { $display.system.message($readini(translation.dat, errors, NPCDoesNotExist), private) | halt }
    }
    if ($2 = monster) {
      var %number.of.monsters $readini(battle2.txt, BattleInfo, Monsters) 
      if (%number.of.monsters >= 10) { $display.system.message($readini(translation.dat, errors, MonsterLimit), private) | halt }
      if ($isfile($mon($3)) = $true) {
        .copy -o $mon($3) $char($3)
        $enter($3)
        var %number.of.players $readini(battle2.txt, battleinfo, players)
        if (%number.of.players = $null) { var %number.of.players 1 }
        $boost_monster_stats($3)  
        $fulls($3) |  var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
      }
      else { $display.system.message($readini(translation.dat, errors, monsterdoesnotexist), private) | halt }
    }

    if ($2 = boss) {
      var %number.of.monsters $readini(battle2.txt, BattleInfo, Monsters) 
      if (%number.of.monsters >= 10) { $display.system.message($readini(translation.dat, errors, MonsterLimit), private) | halt }
      if ($isfile($boss($3)) = $true) {
        .copy -o $boss($3) $char($3)
        $enter($3)
        var %number.of.players $readini(battle2.txt, battleinfo, players)
        if (%number.of.players = $null) { var %number.of.players 1 }
        $boost_monster_stats($3)  
        $fulls($3) |  var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
      }
      else { $display.system.message($readini(translation.dat, errors, monsterdoesnotexist), private) | halt }
    }
  }
}

; Use these commands to check to see who's in battle..
on 3:TEXT:!batlist*:#:battlelist
on 3:TEXT:!bat list*:#:battlelist
on 3:TEXT:!bat info*:#:battlelist

on 50:TEXT:!clear battle:*:{   
  $clear_battle
}

; ==========================
; This is the alias that clears battles
; ==========================
alias clear_battle { 

  ; Kill any related battle timers..
  $clear_timers

  set %chest.time $readini(system.dat, system, ChestTime)
  if ((%chest.time = $null) || (%chest.time < 2)) { set %chest.time 45 }
  /.timerChestDestroy 1 %chest.time /destroy_treasurechest

  ; Kill the battle info
  set %battleis off | set %battleisopen off 
  if ($lines(temp_status.txt) != $null) { .remove temp_status.txt }
  writeini battlefields.db weather current calm

  unset %clear.flag | unset %chest.time

  ; Search through the characters folder and find stray monsters/npcs.  Also full players.
  .echo -q $findfile( $char_path , *.char, 0, 0, clear_files $1-) 

  ; Clear battle variables
  $clear_variables

  ; Remove the battle text files
  .remove battle.txt | .remove battle2.txt | .remove MonsterTable.file

  ; Announce the next battle, if the automated battle system is on
  if ($readini(system.dat, system, automatedbattlesystem) != off) {
    var %time.between.battles $readini(system.dat, System, TimeBetweenBattles)
    if (%time.between.battles = $null) { var %time.between.battles 3 }
    set %timer.time $calc(%time.between.battles * 60)
    /.timerBattleStart 1 %timer.time /startnormal
    $display.system.message($readini(translation.dat, Battle, StartBattle), global)
  }

  ; Check for the conquest tally
  $conquest.tally

  halt
}

alias clear_timers {
  /.timerBattleStart off
  /.timerBattleNext off
  /.timerBattleBegin off
  /.timerBattleRage off
  /.timerHolyAura off
  /.timerOrbTimer off
}

alias clear_files {
  set %name $remove($1-,.char)
  set %name $nopath(%name)

  if ($lines(status $+ %name $+ .txt) != $null) {   .remove status $+ %name $+ .txt }
  if ((%name = new_chr) || (%name = $null)) { return } 
  else { 
    var %clear.flag $readini($char(%name), Info, Flag)

    if ((%clear.flag = $null) && ($readini($char(%name), basestats, hp) = $null)) { .remove $char(%name) }
    if ((%clear.flag = monster) || (%clear.flag = npc)) { .remove $char(%name) }
    if ($file($char(%name)).size = 0) { $zap_char(%name) }

    ; If the person is a player, let's refill their hp/mp/stats to max.
    if ((%clear.flag = $null) && ($readini($char(%name), basestats, hp) != $null)) { writeini $char(%name) DCCchat Room Lobby |  $fulls(%name)  }
  }
}

; ==========================
; This is the alias that opens battles
; ==========================
alias startnormal { 

  if (%battleis = on) { $clear_battle | halt }
  .remove battle.txt | .remove battle2.txt 

  var %time.to.enter $readini(system.dat, system, TimeToEnter)
  if (%time.to.enter = $null) { var %time.to.enter 120 }
  var %time.to.enter.minutes $round($calc(%time.to.enter / 60),1)

  $display.system.message($readini(translation.dat, Battle, BattleOpen), global)

  set %battleis on | set %battleisopen on

  unset %battle.type

  if ($1 = boss) { set %battle.type boss }
  if ($1 = monster) { set %battle.type monster }
  if ($1 = orbfountain) { set %battle.type orbfountain }
  if ($1 = orbbattle) { set %battle.type orbfountain }
  if ($1 = pvp) { set %mode.pvp on }
  if ($1 = gauntlet) { set %mode.gauntlet on | set %mode.gauntlet.wave 1 }
  if ($1 = manual) { set %battle.type manual }

  /.timerBattleBegin 1 %time.to.enter /battlebegin
}


; ==========================
; This is entering the battle
; ==========================
on 3:TEXT:!enter*:#:/enter $nick
ON 50:TEXT:*enters the battle*:#:/enter $1

alias enter {
  $checkchar($1)
  if (%battleisopen != on) { $set_chr_name($1)
    $display.system.message($readini(translation.dat, battle, BattleClosed), global)  | halt 
  }

  set %curbat $readini(battle2.txt, Battle, List)
  if ($istok(%curbat,$1,46) = $true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, AlreadyInBattle), private) | halt  }

  ; There's a player limit in IRC mode due to the potential for flooding..  There is no limit for DCCchat mode.
  if ($readini(system.dat, system, botType) = IRC) {
    if ($readini(battle2.txt, BattleInfo, Players) >= 8) { query %battlechan $readini(translation.dat, errors, PlayerLimit) | halt }
  }

  ; For DCCchat mode we need to move the player into the battle room.
  writeini $char($1) DCCchat Room BattleRoom

  ; Add the person into the battle.
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

    var %current.player.levels $readini(battle2.txt, BattleInfo, PlayerLevels)
    if (%current.player.levels = $null) { var %current.player.levels 0 }
    var %player.level $get.level($1)
    inc %current.player.levels %player.level
    writeini battle2.txt BattleInfo PlayerLevels %current.player.levels

    var %current.difficulty $readini(battle2.txt, BattleInfo, Difficulty)
    if (%current.difficulty = $null) { var %current.difficulty 0 }
    var %player.difficulty $readini($char($1), info, difficulty)
    if (%player.difficulty = $null) { var %player.difficulty 0 }
    inc %current.difficulty %player.difficulty
    writeini battle2.txt BattleInfo Difficulty %current.difficulty
  }

  $set_chr_name($1) 
  $display.system.message($readini(translation.dat, battle, EnteredTheBattle), global)

  write battle.txt $1

  ; Full the person entering the battle.
  $fulls($1)

  ; Check for the Warbound achievement
  var %total.battles $readini($char($1), stuff, TotalBattles)
  if (%total.battles = $null) { var %total.battles 0 }
  inc %total.battles 1
  writeini $char($1) stuff TotalBattles %total.battles
  $achievement_check($1, Warbound)
}

; ==========================
; Flee the battle!
; ==========================
on 3:TEXT:!flee*:#:/flee $nick
on 3:TEXT:!run away*:#:/flee $nick
ON 50:TEXT:*flees the battle*:#:/flee $1

alias flee {
  $check_for_battle($1)

  if ($is_charmed($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused), private) | halt }

  writeini $char($1) battle status runaway
  $set_chr_name($1) | $display.system.message($readini(translation.dat, battle, FleeBattle), battle)

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

  if ((%number.of.players = 0) || (%number.of.players = $null)) {  
    $display.system.message($readini(translation.dat, battle, NoPlayersOnField), global) 
    ; Increase the empty rounds counter and check to see if the empty rounds is > the max allowed before resetting the streak.
    var %max.emptyrounds $readini(system.dat, system, EmptyRoundsBeforeStreakReset)
    var %current.emptyrounds $readini(battlestats.dat, battle, emptyRounds) 
    inc %current.emptyrounds 1
    writeini battlestats.dat battle emptyRounds %current.emptyrounds
    if (%current.emptyrounds >= %max.emptyrounds) { 
      if ($readini(battlestats.dat, battle, winningStreak) > 0) { $display.system.message($readini(translation.dat, system, StreakResetTo0),global) }
      writeini battlestats.dat battle emptyRounds 0
      writeini battlestats.dat battle winningStreak 0
      writeini battlestats.dat battle losingStreak 0
    }

    $clear_battle 
    halt 

  }

  if (%mode.pvp = on) { 
    set %number.of.players $readini(battle2.txt, BattleInfo, Players)
    if ((%number.of.players < 2) || (%number.of.players = $null)) {
      $display.system.message($readini(translation.dat, battle, NotEnoughPlayersOnField), global)
      $clear_battle | halt 
    }
  }

  ; Get a random battlefield
  $random.battlefield.pick

  ; Get a random weather from the battlefield
  $random.weather.pick

  ; Generate the monsters
  $battle.getmonsters

  ; Check for an NPC Ally to join the battle.
  $random.battlefield.ally

  ; Check for a random back attack.
  $random.surpriseattack

  ; Check for a random battle field curse.
  $random.battlefield.curse

  ; Check to see if there's any battlefield limitations
  $battlefield.limitations

  ; Check to see if players go first
  $random.playersgofirst

  ; Reset the empty rounds counter.
  writeini battlestats.dat battle emptyRounds 0

  ; Turn on the rage timer.
  if ((%number.of.monsters.needed <= 3) && (%battle.type != boss)) {  /.timerBattleRage 1 900 /battle_rage_warning }
  if (%battle.type = boss) {  /.timerBattleRage 1 1200 /battle_rage_warning }
  else { /.timerBattleRage 1 1800 /battle_rage_warning }

  if (%mode.gauntlet = on) { /.timerBattleRage off }

  unset %winning.streak

  ; Generate the battle turn order and display who's going first.
  $generate_battle_order
  set %who $read -l1 battle.txt | set %line 1
  set %current.turn 1
  $battlelist(public)

  $display.system.message($readini(translation.dat, battle, StepsUpFirst), battle)

  ; To keep someone from sitting and doing nothing for hours at a time, there's a timer that will auto-force the next turn.
  var %nextTimer $readini(system.dat, system, TimeForIdle)
  if (%nextTimer = $null) { var %nextTimer 180 }
  /.timerBattleNext 1 %nextTimer /next

  unset %number.of.players

  if (%demonwall.fight = on) { /.timerBattleRage 1 1 /battle_rage_warning } 

  if ($readini(battlestats.dat, dragonballs, ShenronWish) = on) { $display.system.message($readini(translation.dat, Dragonball, ShenronWishActive), battle) }

  $aicheck(%who)
}

alias battle.getmonsters {
  if (%mode.pvp != on) {
    set %winning.streak $readini(battlestats.dat, battle, winningstreak)

    set %boss.battle.numbers $readini(system.dat, system, GuaranteedBossBattles)
    if (%boss.battle.numbers = $null) { set %boss.battle.numbers 10.15.20.30.60.100.150.180.220.280.320.350.401.440.460.501.560.601.670.705.780.810.890.920.999.1100.1199.1260. 1305.1464.1500.1650.1720.1880.1999.2050.2250.9999  }
    if ($istok(%boss.battle.numbers,%winning.streak,46) = $true) { set %bosschance 1 }
    if ($istok(%boss.battle.numbers,%winning.streak,46) = $false) {   
      ; Now we determine what kind of battle it is

      if (%winning.streak < 10) { var %bosschance $rand(11,100) }
      if (%winning.streak >= 10) { var %bosschance $rand(1,100) }
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
    if (%battle.type = orbfountain) { 
      %number.of.monsters.needed = 1 
      /.timerOrbTimer 1 3600 /endbattle draw
    }
    if ((%battle.type != boss) && (%battle.type != orbfountain)) { 
      %number.of.monsters.needed = $round($calc(%number.of.players / 2),0)
      if (%number.of.monsters.needed > 4) { %number.of.monsters.needed = 4 }
    }

    $winningstreak.addmonster.amount

    ; Let's see if there's any monsters already in battle (via !summon).  If so, we don't want more than 10..
    var %number.of.monsters $readini(battle2.txt, BattleInfo, Monsters) 
    if (%number.of.monsters = $null) { var %number.of.monsters 0 } 

    ; Check to see if we're over the max number of monsters allowed.
    var %max.number.of.mons $readini(system.dat, system, MaxNumberOfMonsInBattle)
    if (%number.of.monsters >= %max.number.of.mons) { set %number.of.monsters.needed 0 }

    ; Generate the monsters..

    if (%battle.type = orbfountain) { 
      $generate_monster(orbfountain)
    }

    if (%battle.type = monster) {
      $generate_monster(monster)
    }

    if (%battle.type = boss) {
      $generate_monster(boss)
      var %difficulty $readini(battle2.txt, BattleInfo, Difficulty)
      if (%difficulty > 0) { inc %winning.streak %difficulty }

      if (%battle.type != manual) { 
        if (%winning.streak >= 101) { 

          if (%demonwall.fight != on) {
            set %number.of.monsters.needed $round($calc(%number.of.players / 2),0)
            if (%number.of.monsters.needed = $null) { set %number.ofmonsters.needed 2 }
            if (%number.of.monsters.needed > 0) { $generate_monster(monster)   }
          }
        }

      }
    }

    return

  }
}

alias generate_monster {
  if ($1 = orbfountain) {
    .copy -o $mon(orb_fountain) $char(orb_fountain)  | set %curbat $readini(battle2.txt, Battle, List) | %curbat = $addtok(%curbat,orb_fountain,46) | writeini battle2.txt Battle List %curbat | write battle.txt orb_fountain
    $boost_monster_stats(orb_fountain) | $fulls(orb_fountain)
    var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters
    $set_chr_name(orb_fountain) 
    $display.system.message($readini(translation.dat, battle, EnteredTheBattle), battle)
    $display.system.message(12 $+ %real.name  $+ $readini($char(orb_fountain), descriptions, char), battle)
  }

  if ($1 = monster) {
    $get_mon_list
    var %monsters.total $numtok(%monster.list,46)

    if ((%monsters.total = 0) || (%monster.list = $null)) { $display.system.message($readini(translation.dat, Errors, NoMonsAvailable), global) | $endbattle(none) | halt }

    if (%mode.gauntlet != $null) { set %number.of.monsters.needed 2  }

    if (%monster.total = 1) { set %number.of.monsters.needed 1 }

    set %value 1
    while (%value <= %number.of.monsters.needed) {
      if (%monster.list = $null) { inc %value 1 } 

      set %monsters.total $numtok(%monster.list,46)
      set %random.monster $rand(1, %monsters.total) 
      set %monster.name $gettok(%monster.list,%random.monster,46)
      if (%monsters.total = 0) { inc %value 1 }

      .copy -o $mon(%monster.name) $char(%monster.name) | set %curbat $readini(battle2.txt, Battle, List) | %curbat = $addtok(%curbat,%monster.name,46) |  writeini battle2.txt Battle List %curbat 
      $set_chr_name(%monster.name) 
      $display.system.message($readini(translation.dat, battle, EnteredTheBattle), battle)
      $display.system.message(12 $+ %real.name  $+ $readini($char(%monster.name), descriptions, char), battle)

      var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) 
      inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters 

      var %boss.item $readini($char(%monster.name), stuff, drops)
      if (%boss.item != $null) { 
        var %temp.drops.list $readini(battle2.txt, battle, bonusitem)
        var %number.of.items $numtok(%temp.drops.list, 46)
        if (%number.of.items <= 20) { 
          if (%temp.drops.list != $null) { writeini battle2.txt battle bonusitem %temp.drops.list $+ . $+ %boss.item }
          if (%temp.drops.list = $null) { writeini battle2.txt battle bonusitem %boss.item }
        }
      }

      set %monster.to.remove $findtok(%monster.list, %monster.name, 46)
      set %monster.list $deltok(%monster.list,%monster.to.remove,46)
      write battle.txt %monster.name
      $boost_monster_stats(%monster.name) 
      $fulls(%monster.name) 
      if (%battlemonsters = 10) { set %number.of.monsters.needed 0 }
      inc %value 1
      else {  %monster.list = $deltok(%monster.list,%monster.name,46) | dec %value 1 }
    }
  }

  if ($1 = boss) {
    $get_boss_type

    if (%boss.type = normal) {

      $get_boss_list
      var %monsters.total $numtok(%monster.list,46)

      if ((%monsters.total = 0) || (%monster.list = $null)) { $display.system.message(4Error: There are no bosses in the boss folder.. Have the bot admin check to make sure there are bosses for players to battle!, global) | $endbattle(none) | halt }
      if (%mode.gauntlet != $null) { set %number.of.monsters.needed 2  }

      if (%monster.total = 1) { set %number.of.monsters.needed 1 }

      set %value 1
      while (%value <= %number.of.monsters.needed) {
        if (%monster.list = $null) { inc %value 1 } 
        set %monsters.total $numtok(%monster.list,46)
        set %random.monster $rand(1, %monsters.total) 
        set %monster.name $gettok(%monster.list,%random.monster,46)

        var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) 
        if ($readini($char(%monster.name), battle, hp) = $null) { inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters }

        .copy -o $boss(%monster.name) $char(%monster.name) | set %curbat $readini(battle2.txt, Battle, List) |  %curbat = $addtok(%curbat,%monster.name,46) |  writeini battle2.txt Battle List %curbat  |   $set_chr_name(%monster.name) 
        $display.system.message($readini(translation.dat, battle, EnteredTheBattle), battle)
        $display.system.message(12 $+ %real.name  $+ $readini($char(%monster.name), descriptions, char), battle)
        $display.system.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.name), descriptions, BossQuote) $+ ", battle)
        var %boss.item $readini($char(%monster.name), stuff, drops)
        if (%boss.item != $null) { 
          var %temp.boss.list $readini(battle2.txt, battle, bonusitem)

          var %number.of.items $numtok(%temp.boss.list, 46)
          if (%number.of.items <= 20) { 
            if (%temp.boss.list != $null) { writeini battle2.txt battle bonusitem %temp.boss.list $+ . $+ %boss.item }
            if (%temp.boss.list = $null) { writeini battle2.txt battle bonusitem %boss.item }
          }
        }
        set %monster.to.remove $findtok(%monster.list, %monster.name, 46)
        set %monster.list $deltok(%monster.list,%monster.to.remove,46)
        write battle.txt %monster.name
        $boost_monster_stats(%monster.name) 
        $fulls(%monster.name)
        if (%battlemonsters = 10) { set %number.of.monsters.needed 0 }
        inc %value 1
      }
    }


    if (%boss.type = doppelganger) { 
      $display.system.message($readini(translation.dat, events, DoppelgangerFight), battle)
      $generate_evil_clones
    }

    if (%boss.type = warmachine) {
      $display.system.message($readini(translation.dat, events, WarmachineFight), battle)
      $generate_monster_warmachine
    }

    if (%boss.type = elderdragon) {
      $generate_elderdragon
    }

    if (%boss.type = demonwall) {
      $display.system.message($readini(translation.dat, events, DemonWallFight), battle)
      $generate_demonwall
    }
    unset %boss.type
  }
}

; ==========================
; Battle Rage alias
; ==========================
alias battle_rage_warning {
  ; This alias is just used to display a 5 minute warning before the darkness overcomes the battlefield.
  if (%demonwall.fight != on) {  $display.system.message($readini(translation.dat, battle, DarknessWarning), battle) }
  if (%demonwall.fight = on) { $display.system.message($readini(translation.dat, events, DemonWallFightWarning), battle) } 
  set %darkness.fivemin.warn true
  /.timerBattleRage 1 300 /battle_rage
}

alias battle_rage {
  ; When this alias is called all the monsters still alive in battle will become much harder to kill as all of their stats will be increased
  ; The idea is to make it so battles don't last forever (someone can't stall for 2 hours on one battle).  Players need to kill monsters fast.

  if (%demonwall.fight = on) { $display.system.message($readini(translation.dat, events, DemonWallFightOver), battle) | unset %demonwall.fight |  /endbattle defeat | halt }

  set %battle.rage.darkness on

  $display.system.message($readini(translation.dat, battle, DarknessCoversBattlefield), battle)

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

  ; Is the battle over? Let's find out.
  $battle.check.for.end

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

    if (%surpriseattack = on) {
      var %ai.type $readini($char(%who.battle), info, ai_type)
      if (%ai.type != defender) { 
        if ($readini($char(%who.battle), info, flag) = monster) { inc %battle.speed 9999999999 }
      }
    }

    if (%playersgofirst = on) {
      if ($readini($char(%who.battle), info, flag) = $null) { inc %battle.speed 9999999999 }
    }

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

  ; increase the current turn.
  inc %current.turn 1

  ; Count the total number of monsters in battle
  $count.monsters

  unset %surpriseattack | unset %playersgofirst
  if (%first.round.protection.turn != $null) { 
    if (%current.turn > %first.round.protection.turn) { unset %first.round.protection | unset %first.round.protection.turn }
  }

  if (%current.turn > 1) { $battlefield.event }
}

; ==========================
; The battle ends
; ==========================
alias endbattle {
  ; $1 can be victory, defeat or draw.
  ; If victory, add red orbs to everyone..  if boss, add a black orb to all survivors
  ; if defeat, add a small amount of red orbs to everyone..
  ; if draw, add a small amont of red orbs to everyone

  var %thisbattle.winning.streak $readini(battlestats.dat, battle, WinningStreak)

  $clear_timers

  if (%battleis = off) { halt }

  ; Let's increase the total number of battles that we've had so far.
  if ((%mode.pvp != on) && (%mode.gauntlet != on)) { var %totalbattles $readini(battlestats.dat, Battle, TotalBattles) |  inc %totalbattles 1 | writeini battlestats.dat Battle TotalBattles %totalbattles }

  if ($1 = defeat) {
    $display.system.message($readini(translation.dat, battle, BattleIsOver), global)
    if (%mode.pvp != on)  {

      if (%portal.bonus != true) {

        $display.system.message($readini(translation.dat, battle, EvilHasWon), global)

        if (%mode.gauntlet = $null) {

          ; Decrease the conquest points
          var %streak.on $readini(battlestats.dat, Battle,  WinningStreak)
          var %conquestpoints.to.remove 0
          var %player.levels $readini(battle2.txt, BattleInfo, PlayerLevels)
          if (%current.turn > 1) {
            if (%player.levels >= %streak.on) { var %conquestpoints.to.remove $round($calc(%streak.on / 1.5),0) }
            if (%player.levels < %streak.on) { var %conquestpoints.to.remove $round($calc(%streak.on / 3),0) } 
          }
          if (%current.turn <= 1) { 
            if (%player.levels >= %streak.on) { var %conquestpoints.to.remove $round($calc(%streak.on / 15),0) }
            if (%player.levels < %streak.on) { var %conquestpoints.to.remove $round($calc(%streak.on / 30),0) } 
          }

          $conquest.points(subtract, %conquestpoints.to.remove)

          var %defeats $readini(battlestats.dat, battle, totalLoss) | inc %defeats 1 | writeini battlestats.dat battle totalLoss %defeats
          writeini battlestats.dat battle WinningStreak 0
          var %losing.streak $readini(battlestats.dat, battle, LosingStreak) | inc %losing.streak 1 | writeini battlestats.dat battle LosingStreak %losing.streak
        }
      }

      if (%portal.bonus = true) { $display.system.message($readini(translation.dat, battle, EvilHasWonPortal), battle) }

      $battle.calculate.redorbs($1, %thisbattle.winning.streak)
      $battle.reward.redorbs
      $display.system.message($readini(translation.dat, battle, RewardOrbsLoss), battle)
    }
  }

  if ($1 = draw) {
    $display.system.message($readini(translation.dat, battle, BattleIsOver), global)
    if (%mode.pvp != on)  {

      if (%portal.bonus != true) { $display.system.message($readini(translation.dat, battle, BattleIsDraw), global) }

      if (%mode.gauntlet = $null) {
        var %totaldraws $readini(battlestats.dat, Battle, TotalDraws) 
        if (%totaldraws = $null) { var %totaldraws 0 } 
        inc %totaldraws 1 | writeini battlestats.dat Battle TotalDraws %totaldraws
      }

      if (%portal.bonus = true) { $display.system.message($readini(translation.dat, battle, DrawPortal), global) }

      $battle.calculate.redorbs($1, %thisbattle.winning.streak)
      $battle.reward.redorbs
      $display.system.message($readini(translation.dat, battle, RewardOrbsDraw), battle)
    }
  }

  if ($1 = victory) {
    $display.system.message($readini(translation.dat, battle, BattleIsOver), global)

    if (%mode.pvp != on) {

      if (%portal.bonus != true) {
        var %winning.streak $readini(battlestats.dat, battle, WinningStreak) | inc %winning.streak 1 | writeini battlestats.dat battle WinningStreak %winning.streak

        var %winning.streak.record $readini(battlestats.dat, battle, WinningStreakRecord)
        if (%winning.streak.record = $null) { var %winning.streak.record 0 }
        if (%winning.streak > %winning.streak.record) { writeini battlestats.dat battle WinningStreakRecord %winning.streak }

        var %wins $readini(battlestats.dat, battle, totalWins) | inc %wins 1 | writeini battlestats.dat battle totalWins %wins
        writeini battlestats.dat battle LosingStreak 0

        $display.system.message($readini(translation.dat, battle, GoodHasWon), global)
      }

      if (%portal.bonus = true) { $display.system.message($readini(translation.dat, battle, GoodHasWonPortal), battle) }

      $battle.calculate.redorbs($1, %thisbattle.winning.streak)
      $battle.reward.redorbs(victory)
      $battle.reward.playerstylepoints
      $battle.reward.playerstylexp
      $battle.reward.ignitionGauge.all

      ; Calculate the amount of conquest points to add.

      var %conquestpoints.to.add  %winning.streak
      var %conquest.rate 0
      var %conquest.rate .030

      if (%battle.type = boss) { 
        if (%winning.streak < 500) { inc %conquest.rate .03 }
        if (%winning.streak >= 500) { inc %conquest.rate .01 }
        var %conquestpoints.to.add $round($calc(%conquestpoints.to.add * %conquest.rate),0) 
      }
      if (%battle.type != boss) { var %conquestpoints.to.add $round($calc(%conquestpoints.to.add * %conquest.rate),0) }

      if (%conquestpoints.to.add <= 0) { var %conquestpoints.to.add 1 }
      $conquest.points(add, %conquestpoints.to.add)

      $generate_style_order
      $display.system.message($readini(translation.dat, battle, RewardOrbsWin), battle)

      if (%portal.bonus = true) { $display.system.message($readini(translation.dat, battle, AlliedNotesGain), battle)  }

      ; If boss battle, do black orbs for select players.
      unset %black.orb.winners
      if (%battle.type = boss) { $battle.reward.blackorbs
        if (%black.orb.winners != $null) { $display.system.message($readini(translation.dat, battle, BlackOrbWin), battle) }
        $give_random_reward
        $db.dragonball.find
      }

      if (%battle.type != orbfountain) { 
        $give_random_reward

        ; If the reward streak is > 15 then we can check for keys and if it's +25 then we can check for creating a chest
        if ($readini(system.dat, system, EnableChests) = true) {
          if (%portal.bonus = true) { $give_random_key_reward | $create_treasurechest  }
          else {

            if (%winning.streak >= 15) {  $give_random_key_reward }
            if (%winning.streak >= 25) { 
              var %chest.chance $rand(1,100)
              if (%chest.chance >= 60) {  $create_treasurechest }
            }
          }
        }

      }

    }
  }
  if (($1 = none) || ($1 = $null)) { $display.system.message($readini(translation.dat, battle, BattleIsOver), global) }

  ; Check to see if Shenron's Wish is active and if we need to turn it off..
  $db.shenronwish.turncheck

  ; then do a $clear_battle
  set %battleis off | $clear_battle | halt
}

; ==========================
; The $next command.
; ==========================
alias next {
  set %debug.location alias next
  unset %skip.ai | unset %file.to.read.lines 
  ; Reset the Next timer.
  var %nextTimer $readini(system.dat, system, TimeForIdle)
  if (%nextTimer = $null) { var %nextTimer 180 }
  /.timerBattleNext 1 %nextTimer /next

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
  set %debug.location alias turn
  unset %all_status | unset %status.message
  set %status $readini($char($1), Battle, Status)
  if ((%status = dead) || (%status = runaway)) { unset %status | $next | halt }
  if ($readini($char($1), info, ai_type) = defender) { $next | halt }
  if ($1 = orb_fountain) { $next | halt }
  if ($1 = lost_soul) { $next | halt }

  else { 
    ; Is the battle over? Let's find out.
    $battle.check.for.end

    set %wait.your.turn on

    $turn.statuscheck($1)

    set %debug.location alias turn

    $hp_status($1)
    set %status.message $readini(translation.dat, battle, TurnMessage)
    $display.system.message(%status.message, battle)


    if (($lines(temp_status.txt) != $null) && ($lines(temp_status.txt) > 0)) { 
      /.timerThrottle $+ $rand(a,z) $+ $rand(1,1000) $+ $rand(a,z) 1 1 /display.statusmessages $1 
    } 

    if ($readini($char($1), status, curse) != yes) {
      ; Add some TP to the player if it's not at max.
      set %tp.have $readini($char($1), battle, tp)
      set %tp.max $readini($char($1), basestats, tp)
      inc %tp.have 5

      set %debug.location alias turn (zencheck)
      if ($readini($char($1), skills, zen) > 0) { 
        var %zen.tp.gain $calc($readini($char($1), skills, Zen) * 5)
        if ($augment.check($1, EnhanceZen) = true) {  inc %zen.tp.gain $calc(%augment.strength * 10),0) }
        inc %tp.have %zen.tp.gain
      }

      if (%tp.have >= %tp.max) { writeini $char($1) battle tp %tp.max }
      else { writeini $char($1) battle tp %tp.have }
      unset %tp.have | unset %tp.max
    }

    if ($lines(temp_status.txt) != $null) { 
      set %file.to.read.lines $lines(temp_status.txt)
      inc %file.to.read.lines 2
    }


    writeini $char($1) Status burning no | writeini $char($1) Status drowning no | writeini $char($1) Status earth-quake no | writeini $char($1) Status tornado no 
    writeini $char($1) Status freezing no | writeini $char($1) status frozen no | writeini $char($1) status shock no

    if ($readini($char($1), status, staggered) = yes) { set %skip.ai on | writeini $char($1) status staggered no  | /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next | halt }
    if (((($readini($char($1), Status, Blind) = yes) || ($readini($char($1), Status, Petrified) = yes) ||  ($readini($char($1), status, bored) = yes) || ($readini($char($1), Status, intimidate) = yes)))) { 
      writeini $char($1) status petrified no | writeini $char($1) status intimidate no | writeini $char($1) Status blind no | writeini $char($1) status paralysis no | writeini $char($1) status paralysis.timer 1 | writeini $char($1) status stun no | writeini $char($1) status stop no |  set %skip.ai on | /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next | halt
    }
    if ($readini($char($1), Status, cocoon) = yes) { set %skip.ai on |  /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next  | halt }
    if ($readini($char($1), status, paralysis) = yes) { set %skip.ai on | /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next  | halt }
    if ($readini($char($1), status, sleep) = yes) { set %skip.ai on | /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next | halt  }
    if ($readini($char($1), status, stun) = yes) { set %skip.ai on | writeini $char($1) status stun no | /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next | halt }
    if ($readini($char($1), status, stop) = yes) { set %skip.ai on | writeini $char($1) status stop no | /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next | halt }
  }

  if (%skip.ai != on) {
    ; Check for AI
    if (%file.to.read.lines > 0) { 
      /.timerSlowYouDown $+ $rand(a,z) $+ $rand(1,100) 1 %file.to.read.lines /set %wait.your.turn off 
      /.timerSlowYouDown2 $+ $rand(a,z) $+ $rand(1,100) 1 %file.to.read.lines /aicheck $1 | halt
    }
    else { set %wait.your.turn off | $aicheck($1) | halt }
  }
}

; ==========================
; See if all the players are dead.
; ==========================
alias battle.player.death.check {
  set %debug.location battle.player.death.check
  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  var %death.count 0
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line battle.txt
    var %flag $readini($char(%who.battle), info, flag)  | var %summon.flag $readini($char(%who.battle), info, summon)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line }
    else if (%summon.flag = yes) { inc %battletxt.current.line }
    else { 
      var %current.status $readini($char(%who.battle), battle, status)
      if ((%current.status = dead) || (%current.status = runaway)) { inc %death.count 1 | inc %battletxt.current.line 1 }
      else { inc %battletxt.current.line 1 } 
    }
  }

  if (%mode.pvp != on) {
    if (%death.count = $readini(battle2.txt, BattleInfo, Players)) { return true } 
    else { return false }
  }
  if (%mode.pvp = on) {
    if (%death.count = $calc($readini(battle2.txt, BattleInfo, Players) - 1)) { return true }
    else { return false }
  }
}

; ==========================
; See if all the monsters are dead
; ==========================
alias battle.monster.death.check {
  set %debug.location battle.monster.death.check
  if (%mode.pvp = on) { return }

  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  var %death.count 0
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line battle.txt
    var %summon.flag $readini($char(%who.battle), info, summon)
    if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
    else if (%summon.flag = yes) { inc %battletxt.current.line }
    else { 
      var %current.status $readini($char(%who.battle), battle, status)
      if ((%current.status = dead) || (%current.status = runaway)) { inc %death.count 1 | inc %battletxt.current.line 1 }
      else { inc %battletxt.current.line 1 } 
    }
  }

  if (%death.count >= $readini(battle2.txt, BattleInfo, Monsters)) { 
    if (%battle.player.death = false) { $multiple_wave_check }
    if (%multiple.wave = $null) { return true }
    if (%multiple.wave = yes) { unset %multiple.wave | return false }
  } 
  else { return false }
}

; ==========================
; Checks to see if anyone won yet
; ==========================
alias battle.check.for.end {
  set %debug.location battle.check.for.end

  ; Count the total number of monsters in battle
  $count.monsters

  set %battle.player.death $battle.player.death.check
  set %battle.monster.death $battle.monster.death.check

  if ((%battle.monster.death = true) && (%battle.player.death = true)) {  /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle draw | halt } 
  if ((%battle.monster.death = true) && (%battle.player.death = false)) { /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle victory | halt } 
  if ((%battle.monster.death = false) && (%battle.player.death = true)) { /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle defeat | halt } 
  if ((%battle.monster.death = $null) && (%battle.player.death = true)) {  /.timerEndBattle $+ $rand(a,z) 1 4 /endbattle victory | halt } 

  unset %battle.player.death | unset %battle.monster.death
}

; ==========================
; Get a list of people in battle
; ==========================
alias battlelist { 
  if (%battleis = off) { $display.system.message($readini(translation.dat, errors, NoBattleCurrently), private) | halt }
  unset %battle.list | set %lines $lines(battle.txt) | set %l 1
  while (%l <= %lines) { 
    set %who.battle $read -l [ $+ [ %l ] ] battle.txt | set %status.battle $readini($char(%who.battle), Battle, Status)
    if (%status.battle = $null) { inc %l 1 }
    else { 
      if (%status.battle = dead) { 
        var %token.to.add 4 $+ %who.battle
        %battle.list = $addtok(%battle.list,%token.to.add,46) | inc %l 1 
      } 
      else { 
        if ($readini($char(%who.battle), info, flag) = monster) { var %token.to.add 5 $+ %who.battle }
        if ($readini($char(%who.battle), info, flag) = npc) { var %token.to.add 12 $+ %who.battle }
        if ($readini($char(%who.battle), info, flag) = $null) { var %token.to.add 3 $+ %who.battle }

        %battle.list = $addtok(%battle.list,%token.to.add,46) | inc %l 1 
      }
    } 
  }

  unset %lines | unset %l 
  $battlelist.cleanlist

  if (%current.turn = $null) { var %current.turn 0 }

  if ($1 = $null) {
    if (%battle.list = $null) { $display.system.message($readini(translation.dat, battle, NoOneJoinedBattleYet), private) | unset %battle.list | unset %who.battle | $endbattle(none) | halt }
    $display.system.message($readini(translation.dat, battle, BatListTitleMessage), private)
    $display.system.message(4[Turn #:12 %current.turn $+ 4][Weather:12 $readini(battlefields.db, weather, current) $+ 4] [Battlefield:12 %current.battlefield $+ 4], private)
    $display.system.message(4[Battle Order: %battle.list $+ 4], private) | unset %battle.list | unset %who.battle
  }
  if ($1 = public) { 
    if (%battle.list = $null) { $display.system.message($readini(translation.dat, battle, NoOneJoinedBattleYet), battle) | unset %battle.list | unset %who.battle | $endbattle(none) | halt }
    $display.system.message($readini(translation.dat, battle, BatListTitleMessage), battle)
    $display.system.message(4[Turn #:12 %current.turn $+ 4][Weather:12 $readini(battlefields.db, weather, current) $+ 4] [Battlefield:12 %current.battlefield $+ 4], battle)
    $display.system.message(4[Battle Order: %battle.list $+ 4], battle) | unset %battle.list | unset %who.battle
  }
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

alias battle.calculate.redorbs {
  set %debug.location battle.calculate.redorbs
  ; $1 = victory, draw, defeat
  ; $2 = winning streak
  unset %base.redorbs

  ; Get base red orbs based on battle type
  if (%battle.type = monster) { set %base.redorbs $readini(system.dat, System, basexp) }
  if (%battle.type = manual) { set %base.redorbs $readini(system.dat, System, basexp) }
  if (%battle.type = orbfountain) { set %base.redorbs $readini(system.dat, System, basexp) | inc %base.redorbs $rand(400,500) }
  if (%battle.type = boss) { set %base.redorbs $readini(system.dat, System, basebossxp) } 

  %base.redorbs = $round($calc(%base.redorbs * (1 + %number.of.monsters.needed)), 0)

  ; Get a multiplier based on win/draw/loss
  var %base.orb.multiplier 0
  if ($1 = victory) { inc %base.orb.multiplier 1.2 }
  if ($1 = defeat) { inc %base.orb.multiplier .30 }
  if ($1 = draw) { inc %base.orb.multiplier .75 }

  ; If the winning streak is above 0, let's add some of it into the orb bonus.

  if ($1 = victory) { inc %base.redorbs $round($calc($2 / 1.1),0) }
  if (($1 = defeat) || ($1 = draw)) { inc %base.redorbs $round($calc($2 / 1.8),0) }

  ; Get the orb bonus that players earned by defeating monsters
  set %bonus.orbs $round($readini(battle2.txt, BattleInfo, OrbBonus),0)
  if ((%bonus.orbs = $null) || (%bonus.orbs < 0)) { set %bonus.orbs 0 }

  inc %base.redorbs %bonus.orbs

  ; Set the max reward and make sure the orb amount isn't above that.
  if (%mode.gauntlet = on) { var %max.orb.reward $readini(system.dat, system, MaxGauntletOrbReward) }
  if (%mode.gauntlet != on) {  var %max.orb.reward $readini(system.dat, system, MaxOrbReward) }
  if (%max.orb.reward = $null) { var %max.orb.reward 20000 }

  if ($readini(battlestats.dat, dragonballs, ShenronWish) = on) { %max.orb.reward = $round($calc(%max.orb.reward * 1.2),0) }

  ; If we had a gauntlet battle or a multiple wave battle, let's increase the amount by this.
  if (%multiple.wave.bonus = yes) { 
    var %winning.streak $2
    if (%mode.gauntlet.wave != $null) { inc %winning.streak %mode.gauntlet.wave }      

    if (%winning.streak <= 100) { %max.orb.reward = $round($calc(%max.orb.reward * 2.1),0)  }
    if ((%winning.streak > 100) && (%winning.streak <= 200)) { %max.orb.reward = $round($calc(%max.orb.reward * 2.8),0)  }
    if ((%winning.streak > 200) && (%winning.streak <= 400)) { %max.orb.reward = $round($calc(%max.orb.reward * 3),0)  }
    if (%winning.streak > 400) { %max.orb.reward = $round($calc(%max.orb.reward * 3.5),0) }
  }

  if ($1 = defeat) { %max.orb.reward = $round($calc(%max.orb.reward * .4),0) }

  ; Find out how many red orbs we actually won
  %base.redorbs = $round($calc(%base.redorbs * %base.orb.multiplier),0) 

  ; If we went above the max, set the amount to max
  if (%base.redorbs > %max.orb.reward) { set %base.redorbs %max.orb.reward }

  ; Nerf or boost the orbs based on the winning streak
  $orb.adjust

  ; Add some orbs for difficulty
  if (%difficulty != 0) {
    if ($1 = defeat) { inc %base.redorbs $round($calc(%difficulty * .2),0) }
    if ($1 != defeat) {  inc %base.redorbs $round($calc(%difficulty * 3.0),0) }
  }

  ; If a demon portal had appeared in battle, increase the bonus.
  var %bonus.orbs $readini(battle2.txt, battleinfo, portalbonus)
  if (%bonus.orbs = $null) { var %bonus.orbs 0 }

  var %conquest.orbbonus $readini(battlestats.dat, conquest, ConquestBonus)
  if (%conquest.orbbonus > 1000) { var %conquest.orbbonus 1000 }
  if (%conquest.orbbonus <= 0) { var %conquest.orbbonus 0 }

  if ($1 = victory) {  inc %base.redorbs $calc(450 * %bonus.orbs) | inc %base.redorbs %conquest.orbbonus }
  if (($1 = draw) || ($1 = defeat)) {  inc %base.redorbs $calc(100 * %bonus.orbs) | inc %base.redorbs $round($calc(%conquest.orbbonus * .10),0) }

  ; Finally, if the orb amount  is less than 200, let's add 200 to it.
  if (%base.redorbs <= 200) { inc %base.redorbs 200 }
  if (%base.redorbs <= 0) { set %base.redorbs 200 }

  ; If it's a bonus event, let's double the amount.
  if ($readini(system.dat, system, BonusEvent) = true) { %base.redorbs = $round($calc(%base.redorbs * 2),0) }

  return
}

alias battle.reward.redorbs {
  set %debug.location battle.reward.redorbs
  unset %red.orb.winners

  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line battle.txt
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 
      var %current.redorbs $readini($char(%who.battle), stuff, redorbs)
      inc %current.redorbs %base.redorbs
      var %total.redorbs.reward %base.redorbs

      if ($readini($char(%who.battle), battle, status) != runaway) {

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

        ; Check for the orb bonus status.
        if ($readini($char(%who.battle), status, OrbBonus) = yes) {
          var %orb.bonus $round($calc(%base.redorbs / 100),0)
          if (%orb.bonus <= 100) { var %orb.bonus 100 }
          inc %current.redorbs %orb.bonus
          inc %total.redorbs.reward %orb.bonus
          writeini $char(%who.battle) status OrbBonus no
        }
      }

      writeini $char(%who.battle) stuff redorbs %current.redorbs
      writeini $char(%who.battle) status orbbonus no

      %red.orb.winners = $addtok(%red.orb.winners, $+ %who.battle $+  $+ $chr(91) $+ $chr(43) $+ $bytes(%total.redorbs.reward,b) $+ $chr(93),46)

      if ((%portal.bonus = true) && ($1 = victory)) {
        var %total.portalbattles.won $readini($char(%who.battle), stuff, PortalBattlesWon) 
        if (%total.portalbattles.won = $null) { var %total.portalbattles.won 0 }
        inc %total.portalbattles.won 1 

        writeini $char(%who.battle) stuff PortalBattlesWon %total.portalbattles.won
        $give_alliednotes(%who.battle) 

        $achievement_check(%who.battle, AlliedScrub)
        $achievement_check(%who.battle, AlliedSoldier)
      }

      if (($1 = victory) && ($readini($char(%who.battle), skills, aggressor.on) = on)) {
        var %total.aggression.won $readini($char(%who.battle), stuff, BattlesWonWithAggressor) 
        if (%total.aggression.won = $null) { var %total.aggression.won 0 }
        inc %total.aggression.won 1
        writeini $char(%who.battle) stuff BattlesWonWithAggressor %total.aggression.won
        $achievement_check(%who.battle, GlassCannon)
      }

      if (($1 = victory) && ($readini($char(%who.battle), skills, defender.on) = on)) {
        var %total.defender.won $readini($char(%who.battle), stuff, BattlesWonWithDefender) 
        if (%total.defender.won = $null) { var %total.defender.won 0 }
        inc %total.defender.won 1
        writeini $char(%who.battle) stuff BattlesWonWithDefender %total.defender.won
        $achievement_check(%who.battle, StoneWall)
      }


      inc %battletxt.current.line 1 
    }
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %red.orb.winners) { set %replacechar $chr(044) $chr(032)
    %red.orb.winners = $replace(%red.orb.winners, $chr(046), %replacechar)
  }
}

alias battle.reward.blackorbs { 
  set %debug.location battle.reward.blackorbs
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

; ===========================
; REWARD PLAYER STYLE XP
; ===========================

alias battle.reward.playerstylexp {
  set %debug.location battle.reward.playerstyleexp
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


;==========================
; REWARD IGNITION GAUGE
;==========================
alias battle.reward.ignitionGauge.all {
  set %debug.location battle.reward.ignition.all
  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 | set %player.ig.reward 1
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line battle.txt
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { inc %battletxt.current.line 1 }
    else { 
      $restore_ig(%who.battle, %player.ig.reward)
      inc %battletxt.current.line 1 
    }
  }
  unset %player.ig.current | unset %player.ig.max | unset %player.ig.reward
}

alias battle.reward.ignitionGauge.single {
  if ($readini($char($1), info, flag) = monster) { return }
  $restore_ig($1, 1)
}

;==========================
; Check the various status effects
;==========================
alias turn.statuscheck {
  set %debug.location turn.statuscheck
  unset %all_skills | unset %all_status

  if ($lines(temp_status.txt) != $null) {   /.remove temp_status.txt }

  $poison_check($1) | $zombie_check($1) | $zombieregenerating_check($1) | $virus_check($1) 
  $frozen_check($1) | $shock_check($1)  | $burning_check($1) | $tornado_check($1) | $drowning_check($1) | $earth-quake_check($1)
  $staggered_check($1) | $intimidated_check($1) | $blind_check($1) | $curse_check($1) | unset %hp.percent  | $stopped_check($1) | $charm_check($1) | $confuse_check($1) | $amnesia_check($1) | $paralysis_check($1)
  $drunk_check($1) | $slowed_check($1) | $asleep_check($1) | $stunned_check($1) | $defensedown_check($1) | $strengthdown_check($1) | $intdown_check($1) | $ethereal_check($1) 
  $cocoon_check($1) | $weapon_locked($1) | $petrified_check($1)  | $bored_check($1) | $reflect.check($1)

  $regenerating_check($1) | $TPregenerating_check($1) | $boosted_check($1)  | $ignition_check($1) | $revive_check($1)
  $protect_check($1) | $shell_check($1) | $bar_check($1)


  set %debug.location turn.statuscheck

  ; Check for certain skills
  $player.skills.list($1)

  if (%all_status = $null) { %all_status = none } 
  if (%all_skills = $null) { %all_skills = none } 

  return
}

alias display.statusmessages {
  set %debug.location display.statusmessages
  if (($lines(temp_status.txt) != $null) && ($lines(temp_status.txt) > 0)) { 
    var %file.to.read temp_status.txt

    if ($readini(system.dat, system, botType) = IRC) {  /.play %battlechan %file.to.read }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.status.messages(%file.to.read) }

    /.remove temp_status.txt
    /.timerReturnFromStatus $+ $rand(a,z) 1 2 /return 
  }
}

; ============================
; STATUS EFFECTS aliases
;=============================

alias poison_check { 
  set %debug.location poison_check
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
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, PoisonWornOff) 
      return 
    }
    if (%poison.timer <= 3) {
      %poison.timer = $calc(%poison.timer + 1) | writeini $char($1) status poison.timer %poison.timer 
      if ($readini($char($1), Status, poison-heavy) = yes) { $heavy-poison($1) | return }
      $status_message_check(poisoned) 
      set %max.hp $readini($char($1), basestats, hp)
      set %poison $round($calc(%max.hp * .10),0)
      set %hp $readini($char($1), Battle, HP)  |   unset %max.hp
      if (%poison >= %hp) { $display.system.message(%status.message, battle) | $set_chr_name($1) | $display.system.message($readini(translation.dat, status, PoisonKills), battle) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead |  $increase.death.tally($1)  | $add.style.effectdeath 
      $goldorb_check($1) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
      if (%poison < %hp) {
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, PoisonMessage) | dec %hp %poison | writeini $char($1) Battle HP %hp |  unset %hp | unset %poison |  return  }
    }
  }
  else { return }
}

alias heavy-poison { 
  set %debug.location heavy-poison
  $status_message_check(poisoned heavily)
  set %max.hp $readini($char($1), basestats, hp)
  set %poison $round($calc(%max.hp * .20),0)
  set %hp $readini($char($1), Battle, HP) | $set_chr_name($1)
  unset %max.hp
  if (%poison >= %hp) { $display.system.message(%status.message, battle) | $display.system.message($readini(translation.dat, status, PoisonKills), battle) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | $increase.death.tally($1) | $add.style.effectdeath
  $goldorb_check($1) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
  if (%poison < %hp) { $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, PoisonMessage) | dec %hp %poison | writeini $char($1) Battle HP %hp | unset %hp | unset %poison |  return  }
}

alias curse_check {
  set %debug.location curse_check
  set %current.accessory $readini($char($1), equipment, accessory) 
  set %current.accessory.type $readini(items.db, %current.accessory, accessorytype)

  if (%current.accessory.type = CurseAddDrain) {
    writeini $char($1) status curse yes
    writeini $char($1) status curse.timer 0
    writeini $char($1) battle tp 0
  }

  unset %current.accessory | unset %current.accessory.type

  if ($readini($char($1), status, curse) = yes) { 
    set %curse.timer $readini($char($1), status, curse.timer)  
    if (%curse.timer <= 3) { %curse.timer = $calc(%curse.timer + 1) | writeini $char($1) status curse.timer %curse.timer | $status_message_check(cursed)
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurrentlyCursed) | unset %curse.timer | return 
    }
    else {
      writeini $char($1) status curse no | writeini $char($1) status curse.timer 1 
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurseWornOff) | unset %curse.timer | return 
    }
  }
  else { return } 
}

alias regenerating_check { 
  set %debug.location regenerating_check
  if (($readini($char($1), Status, zombieregenerating) = yes) || ($readini($char($1), Status, ZombieRegenerating) = on)) { return }
  if (($readini($char($1), Status, regenerating) = yes) || ($readini($char($1), Status, Regenerating) = on)) { 
    $status_message_check(regenerating HP) | var %howmuch $skill.regen.calculate($1) | $set_chr_name($1)
    var %current.hp $readini($char($1), battle, HP) | inc %current.hp %howmuch | writeini $char($1) Battle HP %current.hp 
    $regen_done_check($1, %howmuch, HP)
  }
  else { return }
}

alias TPregenerating_check {
  set %debug.location TPregenerating_check
  if (($readini($char($1), Status, TPRegenerating) = yes) || ($readini($char($1), Status, TPRegenerating) = on)) { 
    $status_message_check(regenerating TP) | var %howmuch $skill.TPregen.calculate($1) | $set_chr_name($1)
    var %current.tp $readini($char($1), battle, TP) | inc %current.tp %howmuch | writeini $char($1) Battle TP %current.tp 
    $regen_done_check($1, %howmuch, TP)
  }
  else { return }
}

alias regen_done_check { 
  set %debug.location regen_done_check
  var %current $readini($char($1), Battle, $3) | var %max $readini($char($1), BaseStats, $3)

  if (($3 = hp) || ($3 = tp)) {
    if (%current >= %max) { 
      $set_chr_name($1) | $set_chr_name($1) | write temp_status.txt $readini(translation.dat, skill, FinishedRegen)
      if ($3 = TP) { writeini $char($1) Status TPRegenerating no }
      if ($3 = HP) { writeini $char($1) Status Regenerating no }
      var %max $readini($char($1), BaseStats, $3) |  writeini $char($1) Battle $3 %max | return 
    }
    else { $set_chr_name($1) | write temp_status.txt $readini(translation.dat, skill, RegenerationMessage)  | return } 
  }

  else { $set_chr_name($1) | write temp_status.txt $readini(translation.dat, skill, RegenerationMessage) | return } 
}

alias zombieregenerating_check { 
  set %debug.location zombieregenerating_check
  if (($readini($char($1), Status, zombieregenerating) = yes) || ($readini($char($1), Status, ZombieRegenerating) = on)) { 
    $status_message_check(regenerating HP) | var %howmuch $skill.zombieregen.calculate($1) | $set_chr_name($1)
    var %current.hp $readini($char($1), battle, HP) | inc %current.hp %howmuch | writeini $char($1) Battle HP %current.hp 

    var %current $readini($char($1), Battle, hp) | var %max $readini($char($1), BaseStats, hp)
    if (%current >= %max) {  writeini $char($1) Battle hp %max }

    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, skill, ZombieRegeneration)  | return
  }
  else { return }
}

alias staggered_check { 
  if ($readini($char($1), Status, staggered) = yes) { $status_message_check(staggered)
    $set_chr_name($1) | $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, TooStaggeredToFight)
    writeini $char($1) info CanStagger no
  }
  else { return } 
}

alias blind_check { 
  if ($readini($char($1), Status, blind) = yes) { $status_message_check(blind)
    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, TooBlindToFight)
  }
  else { return } 
}

alias petrified_check { 
  if ($readini($char($1), Status, petrified) = yes) { $status_message_check(petrified)
    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, TooPetrifiedToFight)
  }
  else { return } 
}

alias cocoon_check { 
  var %cocoon.timer $readini($char($1), status, cocoon.timer)  
  if (%cocoon.timer < 3) { 
    if ($readini($char($1), Status, cocoon) = yes) {
      $status_message_check(evolving) |  %cocoon.timer = $calc(%cocoon.timer + 1) | writeini $char($1) status cocoon.timer %cocoon.timer
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurrentlyCocoonEvolve) | return 
    }
  }
  else { 
    if ($readini($char($1), Status, cocoon) = yes) {   

      if ($readini($char($1), descriptions, EvolveEnd) = $null) { set %skill.description $readini(translation.dat, status, CocoonWornOff) }
      else { set %skill.description $readini($char($1), descriptions, EvolveEnd) }
      $set_chr_name($1) | write temp_status.txt 12 $+ %real.name  $+ %skill.description
      writeini $char($1) status cocoon no | writeini $char($1) status cocoon.timer 1 
      unset %cocoon.timer | unset %skill.description $boost_monster_stats($1, evolve) | $fulls($1) | return
    }
  }
  return
}

alias intimidated_check { 
  if ($readini($char($1), Status, intimidate) = yes) { $status_message_check(intimidated)
    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, TooIntimidatedToFight)
  }
  else { return } 
}

alias frozen_check { 
  if ($readini($char($1), Status, frozen) = yes) { $status_message_check(freezing) 
    set %hp $readini($char($1), Battle, HP) | $set_chr_name($1)
    set %max.hp $readini($char($1), basestats, hp)
    set %freezing $round($calc(%max.hp * .05),0)
    unset %max.hp | set %hp $readini($char($1), battle, hp)
    if (%freezing >= %hp) { $display.system.message($readini(translation.dat, status, FrozenDeath), battle) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | $increase.death.tally($1)  | $add.style.effectdeath 
    $goldorb_check($1) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
    if (%freezing < %hp) { $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, FrozenMessage) | dec %hp %freezing |  writeini $char($1) Battle HP %hp | return }
  }
  else { return }
}

alias asleep_check {
  if ($readini($char($1), Status, Sleep) = yes) { $status_message_check(asleep)
    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurrentlyAsleep)
  }
  else { return } 
}

alias stunned_check {
  if ($readini($char($1), Status, Stun) = yes) { $status_message_check(stunned)
  $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurrentlyStunned)  }
  else { return } 
}

alias stopped_check {
  if ($readini($char($1), Status, Stop) = yes) { $status_message_check(frozen in time)
  $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurrentlyStopped)  }
  else { return } 
}

alias shock_check { 
  if ($readini($char($1), Status, shock) = yes) { $status_message_check(shocked) 
    set %max.hp $readini($char($1), basestats, hp)
    set %shock $round($calc(%max.hp * .05),0)
    unset %max.hp | set %hp $readini($char($1), battle, hp)
    $set_chr_name($1)
    if (%shock >= %hp) { $display.system.message($readini(translation.dat, status, ShockDeath), battle)  | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | $increase.death.tally($1) | $add.style.effectdeath 
    $goldorb_check($1) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, ShockMessage)  | dec %hp %shock |  writeini $char($1) Battle HP %hp | return 
  }
  else { return }
}

alias burning_check { 
  if ($readini($char($1), Status, burning) = yes) { $status_message_check(burning) 
    set %max.hp $readini($char($1), basestats, hp)
    set %burning $round($calc(%max.hp * .05),0)
    unset %max.hp | set %hp $readini($char($1), battle, hp)
    $set_chr_name($1)
    if (%burning >= %hp) { $display.system.message($readini(translation.dat, status, BurningDeath), battle) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | $increase.death.tally($1)  | $add.style.effectdeath 
    $goldorb_check($1) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, BurningMessage) | dec %hp %burning | writeini $char($1) Battle HP %hp | return 
  }
  else { return }
}

alias tornado_check { 
  if ($readini($char($1), Status, tornado) = yes) { $status_message_check(caught in a tornado) 
    set %max.hp $readini($char($1), basestats, hp)
    set %tornado $round($calc(%max.hp * .05),0)
    unset %max.hp | set %hp $readini($char($1), battle, hp)
    $set_chr_name($1)
    if (%tornado >= %hp) { $display.system.message($readini(translation.dat, status, TornadoDeath), battle) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | $increase.death.tally($1)  | $add.style.effectdeath
    $goldorb_check($1) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, TornadoMessage) | dec %hp %tornado | writeini $char($1) Battle HP %hp | return 
  }
  else { return }
}

alias drowning_check { 
  if ($readini($char($1), Status, drowning) = yes) { $status_message_check(drowning) 
    set %max.hp $readini($char($1), basestats, hp)
    set %drowning $round($calc(%max.hp * .05),0)
    unset %max.hp | set %hp $readini($char($1), battle, hp)
    $set_chr_name($1)
    if (%drowning >= %hp) { $display.system.message($readini(translation.dat, status, DrowningDeath), battle)  | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | $increase.death.tally($1)  |  $add.style.effectdeath 
    $goldorb_check($1) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, DrowningMessage) | writeini $char($1) Battle Status normal | dec %hp %drowning | writeini $char($1) Battle HP %hp | return 
  }
  else { return }
}

alias earth-quake_check { 
  if ($readini($char($1), Status, earth-quake) = yes) { $status_message_check(shaking) 
    set %max.hp $readini($char($1), basestats, hp)
    set %shaken $round($calc(%max.hp * .05),0)
    unset %max.hp | set %hp $readini($char($1), battle, hp)
    $set_chr_name($1)
    if (%shaken >= %hp) { $display.system.message($readini(translation.dat, status, EarthquakeDeath),battle) | writeini $char($1) Battle HP 0 | writeini $char($1) Battle Status Dead | $increase.death.tally($1) | $add.style.effectdeath
    $goldorb_check($1) | $spawn_after_death($1) | remini $char($1) Renkei | next | halt }
    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, EarthquakeMessage)   | writeini $char($1) Battle Status normal | dec %hp %shaken | writeini $char($1) Battle HP %hp | return 
  }
  else { return }
}

alias weight_check { 
  if ($readini($char($1), Status, weight) = yes) { $status_message_check(weighed down)
  $set_chr_name($1) | write temp_status.txt query %battlechan $readini(translation.dat, status, CurrentlyWeighed) | return }
  else { return } 
}

alias weapon_locked {
  if ($readini($char($1), Status, weapon.locked) != $null) { 
    set %weaponlock.timer $readini($char($1), status, weaponlock.timer)  
    if (%weaponlock.timer < 4) { %weaponlock.timer = $calc(%weaponlock.timer + 1) | writeini $char($1) status weaponlock.timer %weaponlock.timer | $status_message_check(Weapon Locked)
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurrentlyWeaponLocked) | unset %weaponlock.timer | return 
    }
    else {
      remini $char($1) status weapon.locked | writeini $char($1) status weaponlock.timer 1 
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, WeaponLockWornOff) | unset %weaponlock.timer | return 
    }
  }
  else { return } 
}

alias drunk_check {
  if ($readini($char($1), Status, drunk) = yes) { 
    set %drunk.timer $readini($char($1), status, drunk.timer)  
    if (%drunk.timer < 3) { %drunk.timer = $calc(%drunk.timer + 1) | writeini $char($1) status drunk.timer %drunk.timer | $status_message_check(drunk)
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurrentlyDrunk) | unset %drunk.timer | return 
    }
    else {
      writeini $char($1) status drunk no | writeini $char($1) status drunk.timer 1 
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, DrunkWornOff) | unset %drunk.timer | return 
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
  if (%zombie.timer < 3) { 
    if ($readini($char($1), Status, zombie) = yes) { $status_message_check(zombie) |  %zombie.timer = $calc(%zombie.timer + 1) | writeini $char($1) status zombie.timer %zombie.timer |  writeini $char($1) status zombieregenerating on
    $set_chr_name($1) | return }
  }
  else { 
    if ($readini($char($1), Status, zombie) = yes) {   writeini $char($1) status zombie no | writeini $char($1) status zombie.timer 1 | $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, ZombieWornOff) |  writeini $char($1) status zombieregenerating off | unset %zombie.timer | return  }
  }
  return
}

alias virus_check { 
  var %virus.timer $readini($char($1), status, virus.timer)  
  if (%virus.timer < 3) { 
    if ($readini($char($1), Status, virus) = yes) { $status_message_check(virus) |  %virus.timer = $calc(%virus.timer + 1) | writeini $char($1) status virus.timer %virus.timer
    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurrentlyHasVirus) | return }
  }
  else { 
    if ($readini($char($1), Status, virus) = yes) {   writeini $char($1) status virus no | writeini $char($1) status virus.timer 1 | $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, virusWornOff) |  writeini $char($1) status virusregenerating off | unset %virus.timer | return  }
  }
  return
}

alias slowed_check { 
  var %slow.timer $readini($char($1), status, slow.timer)  
  if (%slow.timer < 3) { 
    if ($readini($char($1), Status, slow) = yes) { $status_message_check(slowed) |  %slow.timer = $calc(%slow.timer + 1) | writeini $char($1) status slow.timer %slow.timer
    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, currentlyslowed) | return }
  }
  else { 
    if ($readini($char($1), Status, slow) = yes) {   writeini $char($1) status slow no | writeini $char($1) status slow.timer 1 | $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, SlowWornOff)  | unset %slow.timer | return  }
  }
  return
}

alias defensedown_check { 
  var %defensedown.timer $readini($char($1), status, defensedown.timer)  
  if (%defensedown.timer = $null) { var %defensedown.timer 0 }
  if (%defensedown.timer < 3) { 
    if ($readini($char($1), Status, DefenseDown) = yes) { $status_message_check(Defense Down) |  %defensedown.timer = $calc(%defensedown.timer + 1) | writeini $char($1) status defensedown.timer %defensedown.timer
    $set_chr_name($1)  | write temp_status.txt $readini(translation.dat, status, currentlydefensedown) | unset %defensedown.timer | return }
  }
  else { 
    if ($readini($char($1), Status, DefenseDown) = yes) {   writeini $char($1) status DefenseDown no | writeini $char($1) status defensedown.timer 1 | $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, DefenseDownWornOff)  | unset %defensedown.timer | return  }
  }
  return
}

alias strengthdown_check { 
  var %strengthdown.timer $readini($char($1), status, strengthdown.timer)  
  if (%strengthdown.timer = $null) { var %strengthdown.timer 0 }
  if (%strengthdown.timer < 3) { 
    if ($readini($char($1), Status, strengthDown) = yes) { $status_message_check(Strength Down) |  %strengthdown.timer = $calc(%strengthdown.timer + 1) | writeini $char($1) status strengthdown.timer %strengthdown.timer
    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, currentlystrengthdown) | unset %strengthdown.timer | return }
  }
  else { 
    if ($readini($char($1), Status, strengthDown) = yes) {   writeini $char($1) status strengthDown no | writeini $char($1) status strengthdown.timer 1 | $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, StrengthDownWornOff)  | unset %strengthdown.timer | return  }
  }
  return
}

alias intdown_check { 
  var %intdown.timer $readini($char($1), status, intdown.timer)  
  if (%intdown.timer = $null) { var %intdown.timer 0 }
  if (%intdown.timer < 3) { 
    if ($readini($char($1), Status, intDown) = yes) { $status_message_check(Int Down) |  %intdown.timer = $calc(%intdown.timer + 1) | writeini $char($1) status intdown.timer %intdown.timer
    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, currentlyintdown) | unset %intdown.timer | return }
  }
  else { 
    if ($readini($char($1), Status, intDown) = yes) {   writeini $char($1) status intDown no | writeini $char($1) status intdown.timer 1 | $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, intDownWornOff)  | unset %intdown.timer | return  }
  }
  return
}

alias shell_check {
  var %shell.timer $readini($char($1), status, shell.timer)  
  if (%shell.timer = $null) { var %shell.timer 0 }
  if (%shell.timer < 5) { 
    if ($readini($char($1), Status, shell) = yes) { $status_message_check(shell) |  %shell.timer = $calc(%shell.timer + 1) | writeini $char($1) status shell.timer %shell.timer | unset %shell.timer | return }
  }
  else { 
    if ($readini($char($1), Status, shell) = yes) {   writeini $char($1) status shell no | writeini $char($1) status shell.timer 0 | $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, shellWornOff)  | unset %shell.timer | return  }
  }
  return
}

alias protect_check {
  var %protect.timer $readini($char($1), status, protect.timer)  
  if (%protect.timer = $null) { var %protect.timer 0 }
  if (%protect.timer < 5) { 
    if ($readini($char($1), Status, Protect) = yes) { $status_message_check(protect) |  %protect.timer = $calc(%protect.timer + 1) | writeini $char($1) status protect.timer %protect.timer | unset %protect.timer | return }
  }
  else { 
    if ($readini($char($1), Status, Protect) = yes) {   writeini $char($1) status protect no | writeini $char($1) status protect.timer 0 | $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, ProtectWornOff)  | unset %protect.timer | return  }
  }
  return
}

alias bar_check {
  if ($readini($char($1), status, resist-fire) = yes) { $status_message_check(resist-fire) }
  if ($readini($char($1), status, resist-earth) = yes) { $status_message_check(resist-earth) }
  if ($readini($char($1), status, resist-wind) = yes) { $status_message_check(resist-wind) }
  if ($readini($char($1), status, resist-ice) = yes) { $status_message_check(resist-ice) }
  if ($readini($char($1), status, resist-water) = yes) { $status_message_check(resist-water) }
  if ($readini($char($1), status, resist-lightning) = yes) { $status_message_check(resist-lightning) }
  if ($readini($char($1), status, resist-light) = yes) { $status_message_check(resist-light) }
  if ($readini($char($1), status, resist-dark) = yes) { $status_message_check(resist-dark) }
}

alias weaponlock_check { 
  var %weaponlock.timer $readini($char($1), status, weaponlock.timer)  
  if (%weaponlock.timer = $null) { var %weaponlock.timer 0 }
  if (%weaponlock.timer <= 5) { 
    if ($readini($char($1), Status, weapon.lock) != $null) { $status_message_check(Weapon Locked) |  %weaponlock.timer = $calc(%weaponlock.timer + 1) | writeini $char($1) status weaponlock.timer %weaponlock.timer
    $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, currentlyweaponlocked) | unset %weaponlock.timer | return }
  }
  else { 
    if ($readini($char($1), Status, strengthDown) = yes) {  remini $char($1) status weapon.lock  | writeini $char($1) status strengthdown.timer 1 | $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, WeaponLockWornOff)  | unset %weaponlock.timer | return  }
  }
  return
}

alias ethereal_check {
  var %ethereal.timer $readini($char($1), status, ethereal.timer)  
  if (%ethereal.timer = $null) { var %ethereal.timer 0 }

  if (%ethereal.timer <= 3) { 
    if ($readini($char($1), Status, Ethereal) = yes) { $status_message_check(Ethereal) |  %ethereal.timer = $calc(%ethereal.timer + 1) | writeini $char($1) status ethereal.timer %ethereal.timer
    $set_chr_name($1) | $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, currentlyethereal) | unset %ethereal.timer | return }
  }
  else { 
    if ($readini($char($1), Status, Ethereal) = yes) {   writeini $char($1) status Ethereal no | writeini $char($1) status ethereal.timer 1 | $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, EtherealWornOff)  | unset %ethereal.timer | return  }
  }
  return
}

alias amnesia_check {
  if ($readini($char($1), status, amnesia) = yes) { 
    set %amnesia.timer $readini($char($1), status, amnesia.timer)  
    if (%amnesia.timer <= 3) { %amnesia.timer = $calc(%amnesia.timer + 1) | writeini $char($1) status amnesia.timer %amnesia.timer | $status_message_check(under amnesia)
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurrentlyHasAmensia) | unset %amnesia.timer | return 
    }
    else {
      writeini $char($1) status amnesia no | writeini $char($1) status amnesia.timer 1 
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, AmnesiaWornOff) | unset %amnesia.timer | return 
    }
  }
  else { return } 
}

alias charm_check {
  if ($readini($char($1), status, charmed) = yes) { 
    set %charm.timer $readini($char($1), status, charm.timer) | set %charmer $readini($char($1), status, charmer)
    if ($readini($char(%charmer), battle, status) = dead) {  writeini $char($1) status charm.timer 1 | writeini $char($1) status charmed no | $set_chr_name(%charmer) | write temp_status.txt $readini(translation.dat, status, CharmerDeathWornOff) | unset %charm.timer | unset %charmer | return  }

    if (%charm.timer <= 3) { %charm.timer = $calc(%charm.timer + 1) | writeini $char($1) status charm.timer %charm.timer | $status_message_check(charmed)
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurrentlyCharmedMessage) | unset %charm.timer | unset %charmer | return 
    }
    else {
      writeini $char($1) status charmed no | writeini $char($1) status charm.timer 1 | writeini $char($1) status charmer nooneIknowlol
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CharmWornOff) | unset %charm.timer | unset %charmer | return 
    }
  }
  else { return } 
}

alias confuse_check {
  if ($readini($char($1), status, confuse) = yes) { 
    set %confuse.timer $readini($char($1), status, confuse.timer) 
    if ((%confuse.timer = $null) || (%confuse.timer <= 3)) {
      inc %confuse.timer 1 | writeini $char($1) status confuse.timer %confuse.timer | $status_message_check(confused)
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurrentlyConfusedMessage) | unset %confuse.timer | return 
    }
    else {
      writeini $char($1) status confuse no | writeini $char($1) status confuse.timer 1
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, ConfuseWornOff) | unset %confuse.timer | return 
    }
  }
  else { return } 
}

alias paralysis_check {
  if ($readini($char($1), status, paralysis) = yes) { 
    set %paralysis.timer $readini($char($1), status, paralysis.timer)  
    if (%paralysis.timer = $null) { set %paralysis.timer 1 }
    if (%paralysis.timer < 3) { %paralysis.timer = $calc(%paralysis.timer + 1) | writeini $char($1) status paralysis.timer %paralysis.timer | $status_message_check(paralyzed)
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurrentlyParalyzed) | unset %paralysis.timer | return 
    }
    else {
      writeini $char($1) status paralysis no | writeini $char($1) status paralysis.timer 1 
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, ParalysisWornOff) | unset %paralysis.timer | return 
    }
  }
  else { return } 
}

alias bored_check {
  if ($readini($char($1), status, bored) = yes) { 
    set %bored.timer $readini($char($1), status, bored.timer)  
    if (%bored.timer = $null) { set %bored.timer 0 }
    if (%bored.timer < 3) { %bored.timer = $calc(%bored.timer + 1) | writeini $char($1) status bored.timer %bored.timer | $status_message_check(bored)
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurrentlyBored) | unset %bored.timer | return 
    }
    else {
      writeini $char($1) status bored no | writeini $char($1) status bored.timer 0 
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, BoredWornOff) | unset %bored.timer | return 
    }
  }
  else { return } 
}

alias reflect.check {
  if ($readini($char($1), status, reflect) = yes) { 
    set %reflect.timer $readini($char($1), status, reflect.timer)  
    if (%reflect.timer = $null) { set %reflect.timer 0 }
    if (%reflect.timer < 2) { %reflect.timer = $calc(%reflect.timer + 1) | writeini $char($1) status reflect.timer %reflect.timer | $status_message_check(has a reflective barrier)
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, CurrentlyReflected) | unset %reflect.timer | return 
    }
    else {
      writeini $char($1) status reflect no | writeini $char($1) status reflect.timer 0 
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, status, reflectWornOff) | unset %reflect.timer | return 
    }
  }
  else { return } 
}

alias boosted_check { 
  if ($readini($char($1), Status, boosted) = yes) { $status_message_check(power boosted) }
}

alias revive_check { 
  if ($readini($char($1), Status, revive) = yes) { $status_message_check(will auto revive) }
}

alias conserveTP_check {
  if ($readini($char($1), status, conservetp) = yes) { $status_message_check(conserving TP) }
}

alias ignition_check {
  if ($readini($char($1), Status, ignition.on) = on) { 
    set %ignition.name $readini($char($1), status, ignition.name)
    set %ignition.cost $readini(ignitions.db, %ignition.name, IgnitionConsume)
    set %player.current.ig $readini($char($1), battle, ignitionGauge)

    if (%player.current.ig < %ignition.cost) { 
      $set_chr_name($1) | write temp_status.txt $readini(translation.dat, system, IgnitionReverted) 
      writeini $char($1) status ignition.on off
      remini $char($1) status ignition.name | remini $char($1) status ignition.augment 
      $revert($1, %ignition.name)
      unset %ignition.name | unset %ignition.cost | unset %player.current.ig
      return
    }

    dec %player.current.ig %ignition.cost
    writeini $char($1) battle IgnitionGauge %player.current.ig
    $status_message_check(ignition boosted)
    unset %ignition.name | unset %ignition.cost | unset %player.current.ig
  }
}
