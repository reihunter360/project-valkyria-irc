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

  if (%totalplayers <= 2) { query %battlechan $readini(translation.dat, errors, ScoreBoardNotEnoughPlayers)   | unset %totalplayers | halt }
  unset %totalplayers

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

  ; Get the top 3 and display it.
  unset %score.list | set %current.line 1
  while (%current.line <= 3) { 
    set %who.score $read -l [ $+ [ %current.line ] ] scoreboard.txt | var %score $bytes($readini($char(%who.score), scoreboard, score),b)
    %score.list = %score.list $chr(91) $+  $+ $chr(35) $+ %current.line $+  %who.score $chr(40) $+ %score $+ $chr(41) $+ $chr(93) $chr(32)
    inc %current.line 1 
  }
  unset %lines | unset %current.line

  query %battlechan $readini(translation.dat, system, ScoreBoardTitle)
  query %battlechan $chr(3) $+ 2 $+ %score.list

  unset %score.list | unset %who.score |   .remove ScoreBoard.txt | unset %ScoreBoard.score
}

get.score {
  var %score 0
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
  dec %score $readini($char($1), stuff, TotalDeaths)
  inc %score $readini($char($1), stuff, MonsterKills)
  dec %score $readini($char($1), stuff, TimesFled)
  inc %score $readini($char($1), stuff, ChestsOpened)
  dec %score $readini($char($1), stuff, DiscountsUsed)
  inc %score $readini($char($1), stuff, NumberOfResets)
  inc %score $readini($char($1), Styles, Trickster)
  inc %score $readini($char($1), Styles, Guardian)
  inc %score $readini($char($1), Styles, WeaponMaster)
  writeini $char($1) scoreboard score %score
  return %score
}  
