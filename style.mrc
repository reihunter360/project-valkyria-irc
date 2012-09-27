;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; STYLE CONTROL 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias calculate.stylepoints {
  unset %style.rating
  if ($readini($char($1), info, flag) = monster) { return }
  var %style.points $readini(battle2.txt, style, $1)
  if (%style.points = $null) { set %style.points 0 }

  if (%style.points <= 30) { set %style.rating $readini(translation.dat, styles, FlatOutBoring) }
  if ((%style.points > 30) && (%style.points <=  80)) { set %style.rating $readini(translation.dat, styles, Dope) }
  if ((%style.points > 80) && (%style.points <=  100)) { set %style.rating $readini(translation.dat, styles, Cool) }
  if ((%style.points > 100) && (%style.points <=  120)) { set %style.rating $readini(translation.dat, styles, Blast) }
  if ((%style.points > 120) && (%style.points <=  140)) { set %style.rating $readini(translation.dat, styles, Alright) }
  if ((%style.points > 140) && (%style.points <=  180)) { set %style.rating $readini(translation.dat, styles, Atomic) }
  if ((%style.points > 180) && (%style.points <=  250)) { set %style.rating $readini(translation.dat, styles, Sweet) }
  if ((%style.points > 250) && (%style.points <=  450)) { set %style.rating $readini(translation.dat, styles, SShowtime) }
  if ((%style.points > 450) && (%style.points <= 750)) { set %style.rating $readini(translation.dat, styles, SSStylish) }
  if ((%style.points > 750) && (%style.points <= 2500)) { set %style.rating $readini(translation.dat, styles, SSSSmokingHotStyle) }
  if ((%style.points > 2500) && (%style.points < 5000)) { set %style.rating $readini(translation.dat, styles, Jackpot) }
  if (%style.points >= 5000) { set %style.rating $readini(translation.dat, styles, MaximumStyle) }
}

alias add.stylepoints {
  ; $1 = person who earns style points
  ; $2 = person who loses style points
  ; $3 = attack damage
  ; $4 = last action taken

  $decrease.stylepoints($2, $3)
  if ($readini($char($1), info, flag) = monster) { return }

  unset %style.multiplier
  var %lastaction $readini(battle2.txt, style, $1 $+ .lastaction) 
  if (%lastaction = $4) { set %style.multiplier .15 }  
  else { set %style.multiplier 1.1 | writeini battle2.txt style $1 $+ .lastaction $4 }
  set %stylepoints.current $readini(battle2.txt, style, $1)  

  if (($3 != mon_death) && ($3 != boss_death)) { set %stylepoints.toadd $round($calc($3 * %style.multiplier),0)) }
  if ($3 = mon_death) {  set %stylepoints.toadd $readini(system.dat, style, MonDeath) | $add.playerstyle.xp($1, $rand(1,2)) }
  if ($3 = boss_death) {  set %stylepoints.toadd $readini(system.dat, style, BossDeath) | $add.playerstyle.xp($1, $rand(3,4)) }

  if (%stylepoints.current = $null) { set %stylepoints.current 0 }
  if (%stylepoints.current >= 5000) { set %stylepoints.to.add 0 }
  inc %stylepoints.current %stylepoints.toadd
  writeini battle2.txt style $1 %stylepoints.current
  unset %stylepoints.toadd | unset %stylepoints.current
}

alias decrease.stylepoints {
  set %stylepoints.current $readini(battle2.txt, style, $1)  
  if ($3 <= 1) { set %stylepoints.toremove 2 } 
  if ($3 = 1) { set %stylepoints.toremove $rand(1,5) }
  else { set %stylepoints.toremove $round($calc(%stylepoints.current / 2),0)) }

  if (%stylepoints.current = $null) { return }
  dec %stylepoints.current %stylepoints.toremove
  if (%stylepoints.current < 0) { set %stylepoints.current 0 }
  writeini battle2.txt style $1 %stylepoints.current

  unset %stylepoints.toremove | unset %stylepoints.current
}

alias add.style.orbbonus {
  set %style.points $readini(battle2.txt, style, $1)
  if (%style.points = $null) { %style.points = 1 }

  set %multiplier 0
  if ($2 = monster) { %multiplier = 1.2 }
  if ($2 = boss) { %multiplier = 1.7 }

  var %orb.bonus.flag $readini($char($3), info, OrbBonus)
  if (%orb.bonus.flag = yes) { inc %multiplier $rand(4,6) }

  set %current.orb.bonus $readini(battle2.txt, BattleInfo, OrbBonus)
  if (%current.orb.bonus = $null) { set %current.orb.bonus 0 }

  %style.points = $round($calc(%style.points / 1.7),0)
  set %total.orbs.to.add $calc(%style.points * %multiplier)
  if (%total.orbs.to.add <= 0) { set %total.orbs.to.add 1 } 

  inc %current.orb.bonus %total.orbs.to.add

  writeini battle2.txt BattleInfo OrbBonus %current.orb.bonus
  unset %style.points | unset %current.orb.bonus | unset %total.orbs.to.add
}

alias add.playerstyle.xp {
  ; $1 = person adding xp
  ; $2 = # of xp you get

  if ($readini($char($1), info, flag) != $null) { return }

  set %current.playerstyle $readini($char($1), styles, equipped)
  if (%current.playerstyle = $null) { return } 

  set %current.playerstyle.xp $readini($char($1), styles, %current.playerstyle $+ XP)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
  set %current.playerstyle.xptolevel $calc(500 * %current.playerstyle.level)

  if ($2 = $null) { var %style.xp.to.add 1 } 
  if ($2 != $null) { var %style.xp.to.add $2 }

  inc %current.playerstyle.xp %style.xp.to.add
  writeini $char($1) styles %current.playerstyle $+ XP %current.playerstyle.xp

  if (%current.playerstyle.xp >= %current.playerstyle.xptolevel) {
    inc %current.playerstyle.level 1 | writeini $char($1) styles %current.playerstyle %current.playerstyle.level
    writeini $char($1) styles %current.playerstyle $+ XP 0
  }
  unset %current.playerstyle |  unset %current.playerstyle.*
  return
}


alias generate_style_order {

  ; make the Battle List table
  hmake BattleTable

  ; load them from the file.   the initial list will be generated from the !enter commands.  
  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line battle.txt
    set %battle.style $readini(battle2.txt, style, %who.battle)
    var %flag $readini($char(%who.battle), info, flag)
    if ((%flag = monster) || (%flag = npc)) { set %battle.style 0 }
    if ((%battle.style = $null) || (%battle.style = 0)) { set %battle.style 1 }
    hadd BattleTable %who.battle %battle.style
    inc %battletxt.current.line
  }

  ; save the BattleTable hashtable to a file
  hsave BattleTable BattleTable.file

  ; load the BattleTable hashtable (as a temporary table)
  hmake BattleTable_Temp
  hload BattleTable_Temp BattleTable.file

  ; sort the Battle Table
  hmake BattleTable_Sorted
  var %item, %data, %index, %count = $hget(BattleTable_Temp,0).item
  while (%count > 0) {
    ; step 1: get the lowest item
    %item = $hget(BattleTable_Temp,%count).item
    %data = $hget(BattleTable_Temp,%count).data
    %index = 1
    while (%index < %count) {
      if ($hget(BattleTable_Temp,%index).data < %data) {
        %item = $hget(BattleTable_Temp,%index).item
        %data = $hget(BattleTable_Temp,%index).data
      }
      inc %index
    }

    ; step 2: remove the item from the temp list
    hdel BattleTable_Temp %item

    ; step 3: add the item to the sorted list
    %index = sorted_ $+ $hget(BattleTable_Sorted,0).item
    hadd BattleTable_Sorted %index %item

    ; step 4: back to the beginning
    dec %count
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

  ; unset the style rating
  unset %battle.style
}
