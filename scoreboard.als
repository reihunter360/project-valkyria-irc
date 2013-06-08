generate.scoreboard {

  set %totalplayers 0

  var %value 1
  while ($findfile( $char_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($char_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_chr) || (%name = $null)) { inc %value 1 } 
    var %flag $readini($char(%name), info, flag)
    if (((%flag = $null) && (%name != new_chr) && (%name != $null))) {
      var %score $get.score(%name)


      write scoreboard.txt %name
      inc %value 1 | inc %totalplayers 1
    }
  }

  if (%totalplayers <= 2) { $display.system.message($readini(translation.dat, errors, ScoreBoardNotEnoughPlayers), private)  | unset %totalplayers | halt }


  ; Generate the scoreboard.

  ; get rid of the Scoreboard Table and the now un-needed file
  if ($isfile(ScoreboardTable.file) = $true) { 
    hfree ScoreboardTable
    .remove ScoreboardTable.file
  }

  ; make the Scoreboard List table
  hmake ScoreBoardTable

  ; load them from the file.   the initial list will be generated from the !enter commands.  
  var %ScoreBoardtxt.lines $lines(ScoreBoard.txt) | var %ScoreBoardtxt.current.line 1 
  while (%ScoreBoardtxt.current.line <= %ScoreBoardtxt.lines) { 
    var %who.ScoreBoard $read -l $+ %ScoreBoardtxt.current.line ScoreBoard.txt
    set %ScoreBoard.score $readini($char(%who.ScoreBoard), ScoreBoard, score)

    if (%ScoreBoard.score <= 0) { set %ScoreBoard.score 0 }

    hadd ScoreBoardTable %who.ScoreBoard %ScoreBoard.score
    inc %ScoreBoardtxt.current.line
  }

  ; save the ScoreBoardTable hashtable to a file
  hsave ScoreBoardTable ScoreBoardTable.file

  ; load the ScoreBoardTable hashtable (as a temporary table)
  hmake ScoreBoardTable_Temp
  hload ScoreBoardTable_Temp ScoreBoardTable.file

  ; sort the ScoreBoard Table
  hmake ScoreBoardTable_Sorted
  var %ScoreBoardtableitem, %ScoreBoardtabledata, %ScoreBoardtableindex, %ScoreBoardtablecount = $hget(ScoreBoardTable_Temp,0).item
  while (%ScoreBoardtablecount > 0) {
    ; step 1: get the lowest item
    %ScoreBoardtableitem = $hget(ScoreBoardTable_Temp,%ScoreBoardtablecount).item
    %ScoreBoardtabledata = $hget(ScoreBoardTable_Temp,%ScoreBoardtablecount).data
    %ScoreBoardtableindex = 1
    while (%ScoreBoardtableindex < %ScoreBoardtablecount) {
      if ($hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).data < %ScoreBoardtabledata) {
        %ScoreBoardtableitem = $hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).item
        %ScoreBoardtabledata = $hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).data
      }
      inc %ScoreBoardtableindex
    }

    ; step 2: remove the item from the temp list
    hdel ScoreBoardTable_Temp %ScoreBoardtableitem

    ; step 3: add the item to the sorted list
    %ScoreBoardtableindex = sorted_ $+ $hget(ScoreBoardTable_Sorted,0).item
    hadd ScoreBoardTable_Sorted %ScoreBoardtableindex %ScoreBoardtableitem

    ; step 4: back to the beginning
    dec %ScoreBoardtablecount
  }

  ; get rid of the temp table
  hfree ScoreBoardTable_Temp

  ; Erase the old ScoreBoard.txt and replace it with the new one.
  .remove ScoreBoard.txt

  var %index = $hget(ScoreBoardTable_Sorted,0).item
  while (%index > 0) {
    dec %index
    var %tmp = $hget(ScoreBoardTable_Sorted,sorted_ $+ %index)
    write ScoreBoard.txt %tmp
  }

  ; get rid of the sorted table
  hfree ScoreBoardTable_Sorted

  ; get rid of the ScoreBoard Table and the now un-needed file
  hfree ScoreBoardTable
  .remove ScoreBoardTable.file

  ; unset the ScoreBoard.speed
  unset %ScoreBoard.speed


  if (%totalplayers < 5) { 

    ; Get the top 3 and display it.
    unset %score.list | set %current.line 1
    while (%current.line <= 3) { 
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), scoreboard, score),b)
      %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }

  if ((%totalplayers >= 5) && (%totalplayers < 10)) { 
    unset %score.list | set %current.line 1
    while (%current.line <= 5) { 
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), scoreboard, score),b)
      %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }


  if (%totalplayers >= 10) { 
    unset %score.list | unset %score.list.2 | set %current.line 1
    while (%current.line <= 10) { 
      set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), scoreboard, score),b)
      if (%current.line <= 5) {  %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)  }
      if ((%current.line > 5) && (%current.line <= 10)) {  %score.list.2 = %score.list.2 $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32) }
      inc %current.line 1 
    }
    unset %lines | unset %current.line
  }

  $display.system.message($readini(translation.dat, system, ScoreBoardTitle), private)
  $display.system.message($chr(3) $+ 2 $+ %score.list, private)
  if (%score.list.2 != $null) { $display.system.message($chr(3) $+ 2 $+ %score.list.2, private)  }
  unset %totalplayers | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score
}

get.score {
  var %score 0
  var %scoreboard.type $readini(system.dat, system, ScoreBoardType)
  if (%scoreboard.type = $null) { var %scoreboard.type 2 }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL SCORE.
  ;;; TYPE 1
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if (%scoreboard.type = 1) { 
    inc %score $readini($char($1), basestats, hp)
    inc %score $readini($char($1), basestats, tp)
    inc %score $readini($char($1), basestats, str)
    inc %score $readini($char($1), basestats, def)
    inc %score $readini($char($1), basestats, int)
    inc %score $readini($char($1), basestats, spd)
    inc %score $readini($char($1), basestats, str)
    inc %score $readini($char($1), stuff, RedOrbs)
    inc %score $readini($char($1), stuff, BlackOrbs)
    inc %score $readini($char($1), stuff, RedOrbsSpent)
    inc %score $readini($char($1), stuff, BlackOrbsSpent)
    inc %score $readini($char($1), stuff, MonsterKills)
    inc %score $readini($char($1), stuff, ChestsOpened)
    inc %score $readini($char($1), stuff, NumberOfResets)
    inc %score $readini($char($1), stuff, WeaponsAugmented)
    inc %score $readini($char($1), stuff, MonstersToGems)
    inc %score $readini($char($1), stuff, LightSpellsCasted)
    inc %score $readini($char($1), stuff, DarkSpellsCasted)
    inc %score $readini($char($1), stuff, EarthSpellsCasted)
    inc %score $readini($char($1), stuff, FireSpellsCasted)
    inc %score $readini($char($1), stuff, WindSpellsCasted)
    inc %score $readini($char($1), stuff, WaterSpellsCasted)
    inc %score $readini($char($1), stuff, IceSpellsCasted)
    inc %score $readini($char($1), stuff, LightningSpellsCasted)
    inc %score $readini($char($1), stuff, PortalBattlesWon)
    inc %score $readini($char($1), stuff, TimesHitByBattlefieldEvent)
    inc %score $readini($char($1), stuff, IgnitionsUsed)
    inc %score $readini($char($1), stuff, TimesDodged)
    inc %score $readini($char($1), stuff, TimesCountered)
    inc %score $readini($char($1), stuff, TimesParried)
    inc %score $readini($char($1), stuff, ItemsSold)
    inc %score $readini($char($1), stuff, LostSoulsKilled)

    inc %score $readini($char($1), Styles, Trickster)
    inc %score $readini($char($1), Styles, Guardian)
    inc %score $readini($char($1), Styles, WeaponMaster)
    if ($readini($char($1), styles, Spellmaster) != $null) { inc %score $readini($char($1), Styles, Spellmaster) }
    if ($readini($char($1), styles, QuickSilver) != $null) { inc %score $readini($char($1), Styles, QuickSilver) }
    if ($readini($char($1), styles, CounterStance) != $null) { inc %score $readini($char($1), Styles, CounterStance) }
    if ($readini($char($1), styles, Doppelganger) != $null) { inc %score $readini($char($1), Styles, Doppelganger) }
    if ($readini($char($1), styles, HitenMitsurugi-ryu) != $null) { inc %score $readini($char($1), Styles, HitenMitsurugi-ryu) }

    dec %score $readini($char($1), stuff, TotalDeaths)
    dec %score $readini($char($1), stuff, TimesFled)
    dec %score $readini($char($1), stuff, DiscountsUsed)
  }


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL SCORE.
  ;;; TYPE 2
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if (%scoreboard.type = 2) { 

    inc %score $calc($readini($char($1), basestats, hp) / 1000)
    inc %score $calc($readini($char($1), basestats, tp) / 100)
    inc %score $get.level($1)
    inc %score $calc($readini($char($1), stuff, BlackOrbsSpent) / 10)
    inc %score $calc($readini($char($1), stuff, RedOrbsSpent) / 50000)
    inc %score $readini($char($1), stuff, MonsterKills)
    inc %score $readini($char($1), stuff, ChestsOpened)
    inc %score $readini($char($1), stuff, NumberOfResets)
    inc %score $readini($char($1), stuff, WeaponsAugmented)
    inc %score $readini($char($1), stuff, MonstersToGems)
    inc %score $readini($char($1), stuff, LightSpellsCasted)
    inc %score $readini($char($1), stuff, DarkSpellsCasted)
    inc %score $readini($char($1), stuff, EarthSpellsCasted)
    inc %score $readini($char($1), stuff, FireSpellsCasted)
    inc %score $readini($char($1), stuff, WindSpellsCasted)
    inc %score $readini($char($1), stuff, WaterSpellsCasted)
    inc %score $readini($char($1), stuff, IceSpellsCasted)
    inc %score $readini($char($1), stuff, LightningSpellsCasted)
    inc %score $readini($char($1), stuff, PortalBattlesWon)
    inc %score $readini($char($1), stuff, TimesHitByBattlefieldEvent)
    inc %score $readini($char($1), stuff, IgnitionsUsed)
    inc %score $readini($char($1), stuff, TimesDodged)
    inc %score $readini($char($1), stuff, TimesCountered)
    inc %score $readini($char($1), stuff, TimesParried)
    inc %score $readini($char($1), stuff, ItemsSold)

    inc %score $readini($char($1), Styles, Trickster)
    inc %score $readini($char($1), Styles, Guardian)
    inc %score $readini($char($1), Styles, WeaponMaster)
    if ($readini($char($1), styles, Spellmaster) != $null) { inc %score $readini($char($1), Styles, Spellmaster) }
    if ($readini($char($1), styles, QuickSilver) != $null) { inc %score $readini($char($1), Styles, QuickSilver) }
    if ($readini($char($1), styles, CounterStance) != $null) { inc %score $readini($char($1), Styles, CounterStance) }
    if ($readini($char($1), styles, Doppelganger) != $null) { inc %score $readini($char($1), Styles, Doppelganger) }
    if ($readini($char($1), styles, HitenMitsurugi-ryu) != $null) { inc %score $readini($char($1), Styles, HitenMitsurugi-ryu) }

    dec %score $readini($char($1), stuff, TotalDeaths)
    dec %score $readini($char($1), stuff, RevivedTimes)
    dec %score $calc($readini($char($1), stuff, TimesFled) * 5)
    dec %score $round($readini($char($1), stuff, DiscountsUsed) * 5,0)

    if (%score <= 0) { var %score 1 }

  }




  writeini $char($1) scoreboard score %score
  return %score
}  


generate.monsterdeathboard {

  set %totalmonsters 0 | set %total.deaths 0

  var %value 1
  while ($findfile( $mon_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($mon_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_mon) || (%name = $null)) { inc %value 1 } 
    set %score $readini(monsterdeaths.lst, monster, %name)
    if (%score != $null) {  inc %total.deaths %score }

    if (%score != $null) {   write scoreboard.txt %name | inc %totalmonsters 1 }
    inc %value 1
  }

  if ($readini(monsterdeaths.lst, monster, demon_portal) != $null) { write scoreboard.txt demon_portal | inc %totalmonsters 1 }

  if ((%totalmonsters <= 2) || (%totalmonsters = $null)) { $display.system.message($readini(translation.dat, errors, DeathBoardNotEnoughMonsters), private) |  unset %totalmonsters | halt }

  ; Generate the scoreboard.

  ; get rid of the Scoreboard Table and the now un-needed file
  if ($isfile(ScoreboardTable.file) = $true) { 
    hfree ScoreboardTable
    .remove ScoreboardTable.file
  }

  ; make the Scoreboard List table
  hmake ScoreBoardTable

  ; load them from the file.   the initial list will be generated from the !enter commands.  
  var %ScoreBoardtxt.lines $lines(ScoreBoard.txt) | var %ScoreBoardtxt.current.line 1 
  while (%ScoreBoardtxt.current.line <= %ScoreBoardtxt.lines) { 
    var %who.ScoreBoard $read -l $+ %ScoreBoardtxt.current.line ScoreBoard.txt
    set %ScoreBoard.score $readini(monsterdeaths.lst, monster,%who.scoreboard)

    if (%ScoreBoard.score <= 0) { set %ScoreBoard.score 0 }
    hadd ScoreBoardTable %who.ScoreBoard %ScoreBoard.score
    inc %ScoreBoardtxt.current.line
  }

  ; save the ScoreBoardTable hashtable to a file
  hsave ScoreBoardTable ScoreBoardTable.file

  ; load the ScoreBoardTable hashtable (as a temporary table)
  hmake ScoreBoardTable_Temp
  hload ScoreBoardTable_Temp ScoreBoardTable.file

  ; sort the ScoreBoard Table
  hmake ScoreBoardTable_Sorted
  var %ScoreBoardtableitem, %ScoreBoardtabledata, %ScoreBoardtableindex, %ScoreBoardtablecount = $hget(ScoreBoardTable_Temp,0).item
  while (%ScoreBoardtablecount > 0) {
    ; step 1: get the lowest item
    %ScoreBoardtableitem = $hget(ScoreBoardTable_Temp,%ScoreBoardtablecount).item
    %ScoreBoardtabledata = $hget(ScoreBoardTable_Temp,%ScoreBoardtablecount).data
    %ScoreBoardtableindex = 1
    while (%ScoreBoardtableindex < %ScoreBoardtablecount) {
      if ($hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).data < %ScoreBoardtabledata) {
        %ScoreBoardtableitem = $hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).item
        %ScoreBoardtabledata = $hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).data
      }
      inc %ScoreBoardtableindex
    }

    ; step 2: remove the item from the temp list
    hdel ScoreBoardTable_Temp %ScoreBoardtableitem

    ; step 3: add the item to the sorted list
    %ScoreBoardtableindex = sorted_ $+ $hget(ScoreBoardTable_Sorted,0).item
    hadd ScoreBoardTable_Sorted %ScoreBoardtableindex %ScoreBoardtableitem

    ; step 4: back to the beginning
    dec %ScoreBoardtablecount
  }

  ; get rid of the temp table
  hfree ScoreBoardTable_Temp

  ; Erase the old ScoreBoard.txt and replace it with the new one.
  .remove ScoreBoard.txt

  var %index = $hget(ScoreBoardTable_Sorted,0).item
  while (%index > 0) {
    dec %index
    var %tmp = $hget(ScoreBoardTable_Sorted,sorted_ $+ %index)
    write ScoreBoard.txt %tmp
  }

  ; get rid of the sorted table
  hfree ScoreBoardTable_Sorted

  ; get rid of the ScoreBoard Table and the now un-needed file
  hfree ScoreBoardTable
  .remove ScoreBoardTable.file

  ; unset the ScoreBoard.speed
  unset %ScoreBoard.speed


  if ($1 = total) {  $display.system.message($readini(translation.dat, system, DeathBoardTotalMon), private) }

  if ($1 = $null) { 
    if (%totalmonsters < 5) { 

      ; Get the top 3 and display it.
      unset %score.list | set %current.line 1

      while (%current.line <= 3) { 
        set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | set %score $bytes( $readini(monsterdeaths.lst, monster, %who.score),b)
        %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
        inc %current.line 1 
      }
      unset %lines | unset %current.line
    }

    if ((%totalmonsters >= 5) && (%totalmonsters < 10)) { 
      unset %score.list | set %current.line 1

      while (%current.line <= 5) { 
        set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | set %score $bytes($readini(monsterdeaths.lst, monster, %who.score),b)
        %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
        inc %current.line 1 
      }
      unset %lines | unset %current.line
    }


    if (%totalmonsters >= 10) { 
      unset %score.list | unset %score.list.2 | set %current.line 1
      while (%current.line <= 10) { 
        set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | set %score $bytes($readini(monsterdeaths.lst, monster, %who.score),b)
        if (%current.line <= 5) {  %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)  }
        if ((%current.line > 5) && (%current.line <= 10)) {  %score.list.2 = %score.list.2 $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32) }
        inc %current.line 1 
      }
      unset %lines | unset %current.line
    }

    $display.system.message($readini(translation.dat, system, DeathBoardTitleMon), private)
    $display.system.message($chr(3) $+ 2 $+ %score.list, private)
    if (%score.list.2 != $null) { $display.system.message($chr(3) $+ 2 $+ %score.list.2, private) }

  }

  unset %totalmonsters | unset %score | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score
  unset %total.deaths
}


generate.bossdeathboard {

  set %totalbosss 0 | set %total.deaths 0

  var %value 1
  while ($findfile( $boss_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($boss_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_boss) || (%name = $null)) { inc %value 1 } 
    set %score $readini(monsterdeaths.lst, boss, %name)
    if (%score != $null) {  inc %total.deaths %score }

    if (%score != $null) { write scoreboard.txt %name | inc %totalboss 1 }
    inc %value 1
  }

  if ((%totalboss <= 2) || (%totalboss = $null)) { $display.system.message($readini(translation.dat, errors, DeathBoardNotEnoughmonsters), private) | unset %totalboss | halt }

  ; Generate the scoreboard.

  ; get rid of the Scoreboard Table and the now un-needed file
  if ($isfile(ScoreboardTable.file) = $true) { 
    hfree ScoreboardTable
    .remove ScoreboardTable.file
  }

  ; make the Scoreboard List table
  hmake ScoreBoardTable

  ; load them from the file.   the initial list will be generated from the !enter commands.  
  var %ScoreBoardtxt.lines $lines(ScoreBoard.txt) | var %ScoreBoardtxt.current.line 1 
  while (%ScoreBoardtxt.current.line <= %ScoreBoardtxt.lines) { 
    var %who.ScoreBoard $read -l $+ %ScoreBoardtxt.current.line ScoreBoard.txt
    set %ScoreBoard.score $readini(monsterdeaths.lst, boss,%who.scoreboard)

    if (%ScoreBoard.score <= 0) { set %ScoreBoard.score 0 }
    hadd ScoreBoardTable %who.ScoreBoard %ScoreBoard.score
    inc %ScoreBoardtxt.current.line
  }

  ; save the ScoreBoardTable hashtable to a file
  hsave ScoreBoardTable ScoreBoardTable.file

  ; load the ScoreBoardTable hashtable (as a temporary table)
  hmake ScoreBoardTable_Temp
  hload ScoreBoardTable_Temp ScoreBoardTable.file

  ; sort the ScoreBoard Table
  hmake ScoreBoardTable_Sorted
  var %ScoreBoardtableitem, %ScoreBoardtabledata, %ScoreBoardtableindex, %ScoreBoardtablecount = $hget(ScoreBoardTable_Temp,0).item
  while (%ScoreBoardtablecount > 0) {
    ; step 1: get the lowest item
    %ScoreBoardtableitem = $hget(ScoreBoardTable_Temp,%ScoreBoardtablecount).item
    %ScoreBoardtabledata = $hget(ScoreBoardTable_Temp,%ScoreBoardtablecount).data
    %ScoreBoardtableindex = 1
    while (%ScoreBoardtableindex < %ScoreBoardtablecount) {
      if ($hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).data < %ScoreBoardtabledata) {
        %ScoreBoardtableitem = $hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).item
        %ScoreBoardtabledata = $hget(ScoreBoardTable_Temp,%ScoreBoardtableindex).data
      }
      inc %ScoreBoardtableindex
    }

    ; step 2: remove the item from the temp list
    hdel ScoreBoardTable_Temp %ScoreBoardtableitem

    ; step 3: add the item to the sorted list
    %ScoreBoardtableindex = sorted_ $+ $hget(ScoreBoardTable_Sorted,0).item
    hadd ScoreBoardTable_Sorted %ScoreBoardtableindex %ScoreBoardtableitem

    ; step 4: back to the beginning
    dec %ScoreBoardtablecount
  }

  ; get rid of the temp table
  hfree ScoreBoardTable_Temp

  ; Erase the old ScoreBoard.txt and replace it with the new one.
  .remove ScoreBoard.txt

  var %index = $hget(ScoreBoardTable_Sorted,0).item
  while (%index > 0) {
    dec %index
    var %tmp = $hget(ScoreBoardTable_Sorted,sorted_ $+ %index)
    write ScoreBoard.txt %tmp
  }

  ; get rid of the sorted table
  hfree ScoreBoardTable_Sorted

  ; get rid of the ScoreBoard Table and the now un-needed file
  hfree ScoreBoardTable
  .remove ScoreBoardTable.file

  ; unset the ScoreBoard.speed
  unset %ScoreBoard.speed


  if ($1 = total) {  $display.system.message($readini(translation.dat, system, DeathBoardTotalBoss), private) }
  if ($1 = $null) {

    if (%totalboss < 5) { 

      ; Get the top 3 and display it.
      unset %score.list | set %current.line 1

      while (%current.line <= 3) { 
        set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | set %score $bytes( $readini(monsterdeaths.lst, boss, %who.score),b)
        %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
        inc %current.line 1 
      }
      unset %lines | unset %current.line
    }

    if ((%totalboss >= 5) && (%totalboss < 10)) { 
      unset %score.list | set %current.line 1

      while (%current.line <= 5) { 
        set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | set %score $bytes($readini(monsterdeaths.lst, boss, %who.score),b)
        %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
        inc %current.line 1 
      }
      unset %lines | unset %current.line
    }


    if (%totalboss >= 10) { 
      unset %score.list | unset %score.list.2 | set %current.line 1
      while (%current.line <= 10) { 
        set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | set %score $bytes($readini(monsterdeaths.lst, boss, %who.score),b)
        if (%current.line <= 5) {  %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)  }
        if ((%current.line > 5) && (%current.line <= 10)) {  %score.list.2 = %score.list.2 $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32) }
        inc %current.line 1 
      }
      unset %lines | unset %current.line
    }

    $display.system.message($readini(translation.dat, system, DeathBoardTitleBosses), private)
    $display.system.message($chr(3) $+ 2 $+ %score.list, private)
    if (%score.list.2 != $null) { $display.system.message($chr(3) $+ 2 $+ %score.list.2, private) }
  }

  unset %totalboss | unset %score | unset %score.list | unset %score.list.2 | unset %who.score |  .remove ScoreBoard.txt | unset %ScoreBoard.score | unset %total.deaths
}
