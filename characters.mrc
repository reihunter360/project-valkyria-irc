;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; CHARACTER COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Bot Owners have  the ability to zap/erase characters.
on 50:TEXT:!zap *:*: {  $set_chr_name($2) | $checkchar($2) | $zap_char($2) | query %battlechan $readini(translation.dat, system, zappedcomplete) | halt }

; Create a new character

on 1:TEXT:!new char*:*: {  $checkscript($2-)
  if ($isfile($char($nick)) = $true) { query $nick $readini(translation.dat, system, PlayerExists) | halt }
  if ($isfile($char($nick $+ _clone)) = $true) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($isfile($char(evil_ $+ $nick)) = $true)  { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($isfile($char($nick $+ _summon)) = $true) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($isfile($mon($nick)) = $true) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($isfile($boss($nick)) = $true) { query $nick $readini(translation.dat, system, NameReserved) | halt  }
  if ($isfile($npc($nick)) = $true) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($isfile($summon($nick)) = $true) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($nick = $nick $+ _clone) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($nick = evil_ $+ $nick) { query $nick $readini(translation.dat, system, NameReserved) | halt }
  if ($nick = monster_warmachine) { query $nick $readini(translation.dat, system, NameReserved) | halt }

  /.dns $nick
  $check_for_multiple_characters($nick)

  query %battlechan $readini(translation.dat, system, CharacterCreated)

  ; Calculate starting orb count..
  set %current.shoplevel 0
  set %totalplayers 0

  var %value 1
  while ($findfile( $char_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($char_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_chr) || (%name = $null)) { inc %value 1 } 
    if ($readini($char(%name), info, flag) = npc) { inc %value 1 }
    else { 
      var %temp.shoplevel $readini($char(%name), Stuff, ShopLevel)

      inc %current.shoplevel %temp.shoplevel
      inc %value 1 | inc %totalplayers 1
    }
  }

  if (%current.shoplevel > 0) {  %current.shoplevel = $round($calc(%current.shoplevel / %totalplayers),1) 
    if (%current.shoplevel > 1.0) {  inc %current.shoplevel 1 }
  }
  else { inc %current.shoplevel 1 }

  var %starting.orbs $readini(system.dat, system, startingorbs)
  if (%starting.orbs = $null) { starting.orbs = 1000 } 
  %starting.orbs = $round($calc(%starting.orbs * %current.shoplevel),0) 

  ; Create the new character now
  .copy $char(new_chr) $char($nick)
  writeini $char($nick) BaseStats Name $nick 
  writeini $char($nick) Info Created $fulldate

  ;  Add the starting orbs to the new character..
  writeini $char($nick) Stuff RedOrbs %starting.orbs

  ; Generate a password
  set %password battlearena $+ $rand(1,100) $+ $rand(a,z)

  writeini $char($nick) info password $encode(%password)

  query $nick $readini(translation.dat, system, StartingCharOrbs)
  query $nick $readini(translation.dat, system, StartingCharPassword)

  var %bot.owners $readini(system.dat, botinfo, bot.owner)
  if ($istok(%bot.owners,$nick,46) = $true) {  .auser 50 $nick }
  else { .auser 2 $nick }

  ; Give voice
  mode %battlechan +v $nick

  unset %current.shoplevel |  unset %totalplayers | unset %password | unset %ip.address. [ $+ [ $nick ] ] 
}

alias check_for_multiple_characters {
  var %value 1 | var %duplicate.ips 0
  while ($findfile( $char_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($char_path ,*.char,%value)) 
    set %name $remove(%file,.char)
    var %last.ip $readini($char(%name), info, lastIP) 

    if (%last.ip = %ip.address. [ $+ [ $1 ] ]) { inc %duplicate.ips 1 }
    inc %value 1
  }
  unset %name | unset %file | unset unset %ip.address. [ $+ [ $1 ] ] 

  var %max.chars $readini(system.dat, system, MaxCharacters) 
  if (%max.chars = $null) { var %max.chars 2 }
  if (%duplicate.ips >= %max.chars) { query %battlechan $readini(translation.dat, errors, Can'tHaveMoreThanTwoChars) | unset %ip.address. [ $+ [ $1 ] ] | halt }
  return
}

ON 2:TEXT:!newpass *:?:{ $checkscript($2-) | $password($nick) 
  if ($encode($2) = %password) {  writeini $char($nick) info password $encode($3) | .msg $nick $readini(translation.dat, system, newpassword) | unset %password | halt }
  if ($encode($2) != %password) { .msg $nick $readini(translation.dat, errors, wrongpassword) | unset %password | halt }
}

ON 1:TEXT:!id*:?:{ $idcheck($nick , $2) | mode %battlechan +v $nick | $set_chr_name($nick) | $set_chr_name($nick) | query %battlechan 10 $+ %real.name  $+  $readini($char($nick), Descriptions, Char) 
  /.dns $nick
  /close -m* 
}
ON 1:TEXT:!quick id*:?:{ $idcheck($nick , $3) | mode %battlechan +v $nick | $set_chr_name($nick) |  $id_login($nick) 
  /.dns $nick
  /close -m* 
}
ON 2:TEXT:!logout*:*:{
  .auser 1 $nick | mode %battlechan -v $newnick | .flush 1
}

alias idcheck { 
  if ($readini($char($1), info, flag) != $null) { .msg $nick $readini(translation.dat, errors, Can'tLogIntoThisChar) | halt }
  $passhurt($1) | $password($1)
  if (%password = $null) { unset %passhurt | unset %password | halt }
  if ($2 = $null) { halt }
  else { 
    if ($encode($2) == %password) {  $id_login($1) | unset %password | return | halt }
    if ($encode($2) != %password)  { 
      if ((%passhurt = $null) || (%passhurt < 3)) {  .msg $1 $readini(translation.dat, errors, WrongPassword2) | inc %passhurt 1 | writeini $char($1) info passhurt %passhurt | unset %password | unset %passhurt | halt }
      else { kick %battlechan $1 $readini(translation.dat, errors, TooManyWrongPass)  | unset %passhurt | unset %password | writeini $char($1) Info passhurt 0 | halt } 
    }
  }
}

alias id_login {
  var %bot.owners $readini(system.dat, botinfo, bot.owner)
  if ($istok(%bot.owners,$1, 46) = $true) {  .auser 50 $1 }
  else { .auser 2 $1 }
  writeini $char($1) Info LastSeen $fulldate
  return
}

on 2:TEXT:!weather*:*: {  query %battlechan $readini(translation.dat, battle, CurrentWeather) }

on 2:TEXT:!desc*:*: {  
  if ($2 != $null) { $checkchar($2) | $set_chr_name($2) | query %battlechan 3 $+ %real.name  $+ $readini($char($2), Descriptions, Char)   | unset %character.description | halt }
  else { $set_chr_name($nick) | query %battlechan 10 $+ %real.name  $+ $readini($char($nick), Descriptions, Char)  }
}
on 2:TEXT:!rdesc *:*:{ $checkchar($2) | $set_chr_name($2) | var %character.description $readini($char($2), Descriptions, Char) | query %battlechan 3 $+ %real.name $+ 's desc: %character.description | unset %character.description | halt }
on 2:TEXT:!cdesc *:*:{ $checkscript($2-)  | writeini $char($nick) Descriptions Char $2- | $okdesc($nick , Character) }
on 2:TEXT:!sdesc *:*:{ $checkscript($2-)  
  if ($readini($char($nick), skills, $2) != $null) { 
    writeini $char($nick) Descriptions $2 $3- | $okdesc($nick , Skill) 
  }
  if ($readini($char($nick), skills, $2) = $null) { .msg $nick $readini(translation.dat, errors, YouDoNotHaveSkill) | halt }
}
on 2:TEXT:!skill desc *:*:{ $checkscript($3-)  
  if ($readini($char($nick), skills, $3) != $null) { 
    writeini $char($nick) Descriptions $3 $4- | $okdesc($nick , Skill) 
  }
  if ($readini($char($nick), skills, $3) = $null) { .msg $nick $readini(translation.dat, errors, YouDoNotHaveSkill) | halt }
}

on 2:TEXT:!set desc *:*:{ $checkscript($2-)  | writeini $char($nick) Descriptions Char $3- | $okdesc($nick , Character) }
on 2:TEXT:!setgender*:*: { $checkscript($2-)
  if ($2 = neither) { writeini $char($nick) Info Gender its | writeini $char($nick) Info Gender2 its | .msg $nick $readini(translation.dat, system, SetGenderNeither) | unset %check | halt }
  if ($2 = none) { writeini $char($nick) Info Gender its | writeini $char($nick) Info Gender2 its | .msg $nick $readini(translation.dat, system, SetGenderNeither)  | unset %check | halt }
  if ($2 = male) { writeini $char($nick) Info Gender his | writeini $char($nick) Info Gender2 him | .msg $nick $readini(translation.dat, system, SetGenderMale)  | unset %check | halt }
  if ($2 = female) { writeini $char($nick) Info Gender her | writeini $char($nick) Info Gender2 her | .msg $nick $readini(translation.dat, system, SetGenderFemale) | unset %check | halt }
  else { .msg $nick $readini(translation.dat, errors, NeedValidGender) | unset %check | halt }
}
on 2:TEXT:!hp:*: { 
  $set_chr_name($nick) | $hp_status_hpcommand($nick) 
  query %battlechan $readini(translation.dat, system, ViewMyHP) | unset %real.name | unset %hstats 
}
on 2:TEXT:!battle hp:*: { 
  if (%battleis != on) { query %battlechan $readini(translation.dat, errors, NoBattleCurrently) }

  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line battle.txt
    if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }
    else { 
      $set_chr_name(%who.battle) | $hp_status_hpcommand(%who.battle) 
      var %hp.to.add  3 $+ $chr(91) $+  $+ %who.battle $+ :  %hstats $+ 3 $+ $chr(93) 
      %battle.hp.list = $addtok(%battle.hp.list,%hp.to.add,46) 
      inc %battletxt.current.line
    }
  }

  if ($chr(046) isin %battle.hp.list) { 
    %battle.hp.list = $replace(%battle.hp.list, $chr(046), $chr(032))
  }
  query %battlechan %battle.hp.list  | unset %real.name | unset %hstats | unset %battle.hp.list
}

on 2:TEXT:!tp:*:$set_chr_name($nick) | query %battlechan $readini(translation.dat, system, ViewMyTP) | unset %real.name
on 2:TEXT:!orbs*:*: { 
  if ($2 != $null) { var %orbs.spent $bytes($readini($char($2), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($2), stuff, BlackOrbsSpent),b) | $checkchar($2) | $set_chr_name($2) 

    var %showorbsinchannel $readini(system.dat, system,ShowOrbsCmdInChannel)
    if (%showorbsinchannel = $null) { var %showorbsinchannel true }
    if (%showorbsinchannel = true) { query %battlechan $readini(translation.dat, system, ViewOthersOrbs)  }
    else {  .msg $nick $readini(translation.dat, system, ViewOthersOrbs) }
  }
  else { var %orbs.spent $bytes($readini($char($nick), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($nick), stuff, BlackOrbsSpent),b) | $set_chr_name($nick) 

    var %showorbsinchannel $readini(system.dat, system,ShowOrbsCmdInChannel)
    if (%showorbsinchannel = $null) { var %showorbsinchannel true }
    if (%showorbsinchannel = true) { query %battlechan $readini(translation.dat, system, ViewMyOrbs)  }
    else {  .msg $nick $readini(translation.dat, system, ViewMyOrbs) }
  }
}
on 2:TEXT:!rorbs*:*: { var %orbs.spent $bytes($readini($char($2), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($2), stuff, BlackOrbsSpent),b) | $checkchar($2) | $set_chr_name($2) 
  var %showorbsinchannel $readini(system.dat, system,ShowOrbsCmdInChannel)
  if (%showorbsinchannel = $null) { var %showorbsinchannel true }
  if (%showorbsinchannel = true) { query %battlechan $readini(translation.dat, system, ViewOthersOrbs)  }
  else {  .msg $nick $readini(translation.dat, system, ViewOthersOrbs) }
}

on 2:TEXT:!stats*:*: { unset %all_status 
  if ($2 = $null) {
    $battle_stats($nick) | $player.status($nick) | $weapon_equipped($nick) | .msg $nick $readini(translation.dat, system, HereIsYourCurrentStats) 
    var %equipped.accessory $readini($char($nick), equipment, accessory) 
    if (%equipped.accessory = $null) { var %equipped.accessory none }
    /.timerDisplayStats1 $+ $nick 1 1  .msg $nick [4HP12 $readini($char($nick), Battle, HP) $+ 1/ $+ 12 $+ $readini($char($nick), BaseStats, HP) $+ 1] [4TP12 $readini($char($nick), Battle, TP) $+ 1/ $+ 12 $+ $readini($char($nick), BaseStats, TP) $+ 1] [4Status12 %all_status $+ 1] 
    /.timerDisplayStats2 $+ $nick 1 1  .msg $nick [4Strength12 %str $+ 1]  [4Defense12 %def $+ 1] [4Intelligence12 %int $+ 1] [4Speed12 %spd $+ 1]
    /.timerDisplayStats3 $+ $nick 1 1  .msg $nick [4 $+ $readini(translation.dat, system, CurrentWeaponEquipped) 12 $+ %weapon.equipped $+ 1]  [4 $+ $readini(translation.dat, system, CurrentAccessoryEquipped) 12 $+ %equipped.accessory $+ 1]
    unset %spd | unset %str | unset %def | unset %int | unset %status | unset %comma_replace | unset %comma_new | unset %all_status | unset %weapon.equipped
  }
  else { 
    $checkchar($2) 
    var %flag $readini($char($2), info, flag)
    if ((%flag = monster) || (%flag = npc)) { query %battlechan $readini(translation.dat, errors, SkillCommandOnlyOnPlayers) | halt }
    $battle_stats($2) | $player.status($2) | $weapon_equipped($2) | .msg $nick $readini(translation.dat, system, HereIsOtherCurrentStats) 
    var %equipped.accessory $readini($char($2), equipment, accessory) 
    if (%equipped.accessory = $null) { var %equipped.accessory none }
    /.timerDisplayStats1 $+ $nick 1 1  .msg $nick [4HP12 $readini($char($2), Battle, HP) $+ 1/ $+ 12 $+ $readini($char($2), BaseStats, HP) $+ 1] [4TP12 $readini($char($2), Battle, TP) $+ 1/ $+ 12 $+ $readini($char($2), BaseStats, TP) $+ 1] [4Status12 %all_status $+ 1] 
    /.timerDisplayStats2 $+ $nick 1 1  .msg $nick [4Strength12 %str $+ 1]  [4Defense12 %def $+ 1] [4Intelligence12 %int $+ 1] [4Speed12 %spd $+ 1]
    /.timerDisplayStats3 $+ $nick 1 1  .msg $nick [4 $+ $readini(translation.dat, system, CurrentWeaponEquipped) 12 $+ %weapon.equipped $+ 1]  [4 $+ $readini(translation.dat, system, CurrentAccessoryEquipped) 12 $+ %equipped.accessory $+ 1]
    unset %spd | unset %str | unset %def | unset %int | unset %status | unset %comma_replace | unset %comma_new | unset %all_status | unset %weapon.equipped
  }
}
on 2:TEXT:!weapons*:*: {  unset %*.wpn.list | unset %weapon.list
  if ($2 = $null) { $weapon.list($nick) | var %target $nick }
  else { $checkchar($2) | $weapon.list($2) | var %target $2 }
  /.timerDisplayWeaponList $+ $nick 1 3 /display_weapon_lists %target
}
on 2:TEXT:!rweapons*:*: { $checkchar($2) | $weapon.list($2)  | $set_chr_name($2) 
  /.timerDisplayWeaponList $+ $2 1 3 /display_weapon_lists $2
}
alias display_weapon_lists {  $set_chr_name($1) | query %battlechan $readini(translation.dat, system, ViewWeaponList) | unset %weapons | unset %weapon.list }

on 2:TEXT:!style*:*: {  unset %*.style.list | unset %style.list
  if ($2 = $null) { 
    ; Get and show the list
    $styles.list($nick)
    set %current.playerstyle $readini($char($nick), styles, equipped)
    set %current.playerstyle.xp $readini($char($nick), styles, %current.playerstyle $+ XP)
    set %current.playerstyle.level $readini($char($nick), styles, %current.playerstyle)
    var %current.playerstyle.xptolevel $calc(500 * %current.playerstyle.level)
    if (%current.playerstyle.level >= 10) {   $set_chr_name($nick) | query %battlechan $readini(translation.dat, system, ViewCurrentStyleMaxed) }
    if (%current.playerstyle.level < 10) {   $set_chr_name($nick) | query %battlechan $readini(translation.dat, system, ViewCurrentStyle) }
    query %battlechan $readini(translation.dat, system, ViewStyleList)
    unset %styles.list | unset %current.playerstyle.* | unset %styles | unset %style.name | unset %style_level | unset %current.playerstyle
  }
  if ($2 = change) { $style.change($nick, $2, $3) }
}

ON 50:TEXT:*style change to *:*:{ 
  if ($is_charmed($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  $style.change($1, $3, $5)
} 


alias style.change { 
  if ($2 = change) && ($3 = $null) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, SpecifyStyle) | halt }
  if ($2 = change) && ($3 != $null) {  
    var %valid.styles.list $readini(playerstyles.lst, styles, list)
    if ($istok(%valid.styles.list, $3, 46) = $false) { query %battlechan $readini(translation.dat, errors, InvalidStyle) | halt }
    var %current.playerstylelevel $readini($char($1), styles, $3)
    if ((%current.playerstylelevel = $null) || (%current.playerstylelevel = 0)) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotKnowThatStyle) | halt }

    $check_for_battle($1)

    ; finally, switch to it.
    $set_chr_name($1) | writeini $char($1) styles equipped $3 | query %battlechan $readini(translation.dat, system, SwitchStyles)
    unset %styles.list | unset %current.playerstyle.* | unset %styles | unset %style.name | unset %style_level | unset %current.playerstyle

    ; if the battle is on..
    if (%battleis = on) {  $check_for_double_turn($1)   }

  }
}

on 2:TEXT:!xp*:*: {  unset %*.style.list | unset %style.list
  if ($2 = $null) { 
    ; Get and show the list
    set %current.playerstyle $readini($char($nick), styles, equipped)
    set %current.playerstyle.xp $readini($char($nick), styles, %current.playerstyle $+ XP)
    set %current.playerstyle.level $readini($char($nick), styles, %current.playerstyle)
    var %current.playerstyle.xptolevel $calc(500 * %current.playerstyle.level)
    if (%current.playerstyle.level >= 10) {   $set_chr_name($nick) | query %battlechan $readini(translation.dat, system, ViewCurrentStyleMaxed) }
    if (%current.playerstyle.level < 10) {   $set_chr_name($nick) | query %battlechan $readini(translation.dat, system, ViewCurrentStyle) }
    unset %styles.list | unset %current.playerstyle.* | unset %styles | unset %style.name | unset %style_level | unset %current.playerstyle
  }
}

on 2:TEXT:!techs*:*: { 
  if ($2 = $null) { $weapon_equipped($nick) | $tech.list($nick, %weapon.equipped) | $set_chr_name($nick) 
    if (%techs.list != $null) { query %battlechan $readini(translation.dat, system, ViewMyTechs) }
    else { query %battlechan $readini(translation.dat, system, NoTechsForMe)  }
  }
  else { $checkchar($2) | $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) 

    if (%techs.list != $null) { query %battlechan $readini(translation.dat, system, ViewOthersTechs) }
    else { query %battlechan $readini(translation.dat, system, NoTechsForOthers) }
  }
}
on 2:TEXT:!readtechs*:*: { $checkchar($2)
  $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) |
  if (%techs.list != $null) { query %battlechan $readini(translation.dat, system, ViewOthersTechs) }
  else { query %battlechan $readini(translation.dat, system, NoTechsForOthers) }
}
on 2:TEXT:!rtechs*:*: { $checkchar($2)
  $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) |
  if (%techs.list != $null) { query %battlechan $readini(translation.dat, system, ViewOthersTechs) }
  else { query %battlechan $readini(translation.dat, system, NoTechsForOthers) }
}

on 2:TEXT:!skills*:*: { 
  if ($2 != $null) { $checkchar($2) | $skills.list($2) | $set_chr_name($2) 
    if (%passive.skills.list != $null) { query %battlechan $readini(translation.dat, system, ViewPassiveSkills)  }
    if (%passive.skills.list2 != $null) { query %battlechan $readini(translation.dat, system, ViewPassiveSkills2)  }
    if (%active.skills.list != $null) { query %battlechan $readini(translation.dat, system, ViewActiveSkills)  }
    if (%active.skills.list2 != $null) { query %battlechan $readini(translation.dat, system, ViewActiveSkills2)  }
    if (%resists.skills.list != $null) { query %battlechan $readini(translation.dat, system, ViewResistanceSkills)  }
    if (((%passive.skills.list = $null) && (%active.skills.list = $null) && (%resists.skills.list = $null))) { query %battlechan $readini(translation.dat, system, HasNoSkills) }
  }
  else { 
    $skills.list($nick) | $set_chr_name($nick) 
    if (%passive.skills.list != $null) { query %battlechan $readini(translation.dat, system, ViewPassiveSkills)  }
    if (%passive.skills.list2 != $null) { query %battlechan $readini(translation.dat, system, ViewPassiveSkills2)  }
    if (%active.skills.list != $null) { query %battlechan $readini(translation.dat, system, ViewActiveSkills)  }
    if (%active.skills.list2 != $null) { query %battlechan $readini(translation.dat, system, ViewActiveSkills2)  }
    if (%resists.skills.list != $null) { query %battlechan $readini(translation.dat, system, ViewResistanceSkills)  }
    if (((%passive.skills.list = $null) && (%active.skills.list = $null) && (%resists.skills.list = $null))) { query %battlechan $readini(translation.dat, system, HasNoSkills) }
  }
}
on 2:TEXT:!rskills*:*: { $readskills($2) }
on 2:TEXT:!readskills*:*: { $readskills($2) }

alias readskills {
  $checkchar($1) | $skills.list($1) | $set_chr_name($1) 
  if (%passive.skills.list != $null) { query %battlechan $readini(translation.dat, system, ViewPassiveSkills)  }
  if (%active.skills.list != $null) { query %battlechan $readini(translation.dat, system, ViewActiveSkills)  }
  if (%resists.skills.list != $null) { query %battlechan $readini(translation.dat, system, ViewResistanceSkills)  }
  if (((%passive.skills.list = $null) && (%active.skills.list = $null) && (%resists.skills.list = $null))) { query %battlechan $readini(translation.dat, system, HasNoSkills) }
}
on 2:TEXT:!keys*:*:{ 
  if ($2 != $null) { $checkchar($2)
    $keys.list($2) | $set_chr_name($2) 
    if (%keys.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewKeysItems) } 
    else { query %battlechan $readini(translation.dat, system, HasNoKeys) }    
  }
  else {
    $keys.list($nick) | $set_chr_name($nick) 
    if (%keys.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewKeysItems) } 
    else { query %battlechan $readini(translation.dat, system, HasNoKeys) }    
  }
}
on 2:TEXT:!items*:*:{ 
  if ($2 != $null) { $checkchar($2)
    $items.list($2) | $set_chr_name($2) 
    if (%items.list != $null) { query %battlechan $readini(translation.dat, system, ViewItems) }
    if (%summons.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewSummonItems) }
    if (%reset.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewShopResetItems) }
    if (%gems.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewGemItems) }
    if (%keys.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewKeysItems) } 
    if (%misc.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewMiscItems) } 
    if ((((((%summons.items.list = $null) && (%gems.items.list = $null) && (%keys.items = $null) && (%misc.items.list = $null) && (%reset.items.list = $null) && (%items.list = $null)))))) { query %battlechan $readini(translation.dat, system, HasNoItems) }    
    unset %items.list | unset %gems.items.list | unset %summons.items.list | unset %keys.items.list | unset %misc.items.list
  }
  else { 
    $items.list($nick) | $set_chr_name($nick) 
    if (%items.list != $null) { query %battlechan $readini(translation.dat, system, ViewItems) }
    if (%summons.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewSummonItems) }
    if (%reset.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewShopResetItems) }
    if (%gems.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewGemItems) }
    if (%keys.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewKeysItems) } 
    if (%misc.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewMiscItems) } 
    if ((((((%summons.items.list = $null) && (%gems.items.list = $null) && (%keys.items = $null) && (%misc.items.list = $null) && (%reset.items.list = $null) && (%items.list = $null)))))) { query %battlechan $readini(translation.dat, system, HasNoItems) }
    unset %items.list | unset %gems.items.list | unset %summons.items.list | unset %keys.items.list | unset %misc.items.list
  }
}
on 2:TEXT:!ritems *:*: { $checkchar($2)
  $items.list($2) | $set_chr_name($2) 
  if (%items.list != $null) { query %battlechan $readini(translation.dat, system, ViewItems) }
  if (%summons.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewSummonItems) }
  if (%reset.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewShopResetItems) }
  if (%gems.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewGemItems) }
  if (%keys.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewKeysItems) }
  if (%misc.items.list != $null) { query %battlechan $readini(translation.dat, system, ViewMiscItems) } 
  if ((((((%summons.items.list = $null) && (%gems.items.list = $null) && (%keys.items = $null) && (%misc.items.list = $null) && (%reset.items.list = $null) && (%items.list = $null)))))) { query %battlechan $readini(translation.dat, system, HasNoItems) }
  unset %items.list | unset %gems.items.list | unset %summons.items.list | unset %keys.items.list | unset %misc.items.list
}
on 2:TEXT:!accessories*:*:{ 
  if ($2 != $null) { $checkchar($2)
    $accessories.list($2) | $set_chr_name($2) 
    if (%accessories.list != $null) { query %battlechan $readini(translation.dat, system, ViewAccessories)
      var %equipped.accessory $readini($char($2), equipment, accessory)
      if ((%equipped.accessory = $null) || (%equipped.accessory = none)) { query %battlechan $readini(translation.dat, system, HasNoEquippedAccessory) }
      if ((%equipped.accessory != $null) && (%equipped.accessory != none)) { query %battlechan $readini(translation.dat, system, ViewEquippedAccessory) }
      unset %accessories.list 
    }
    else { query %battlechan $readini(translation.dat, system, HasNoAccessories) }
  }
  else { 
    $accessories.list($nick) | $set_chr_name($nick) 
    if (%accessories.list != $null) { query %battlechan $readini(translation.dat, system, ViewAccessories) 
      var %equipped.accessory $readini($char($nick), equipment, accessory)
      if ((%equipped.accessory = $null) || (%equipped.accessory = none)) { query %battlechan $readini(translation.dat, system, HasNoEquippedAccessory) }
      if ((%equipped.accessory != $null) && (%equipped.accessory != none)) { query %battlechan $readini(translation.dat, system, ViewEquippedAccessory) }
      unset %accessories.list 
    }
    else { query %battlechan $readini(translation.dat, system, HasNoAccessories) }
  }
}

ON 50:TEXT:*equips *:*:{ 
  if ($is_charmed($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  var %player.weapon.check $readini($char($1), weapons, $3)
  if (%player.weapon.check >= 1) {   writeini $char($1) weapons equipped $3 | $set_chr_name($1) | query %battlechan $readini(translation.dat, system, EquipWeaponGM)  }
  else { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveWeapon) | halt }
} 

on 2:TEXT:!equip *:*: { 
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($readini($char($nick), status, weapon.lock) != $null) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyWeaponLocked) | halt  }

  var %player.weapon.check $readini($char($nick), weapons, $2)
  if (%player.weapon.check >= 1) {   writeini $char($nick) weapons equipped $2 | $set_chr_name($nick) | query %battlechan $readini(translation.dat, system, EquipWeaponPlayer) }
  else { $set_chr_name($nick) | query %battlechan $readini(translation.dat, errors, DoNotHaveWeapon) | halt }
}

on 2:TEXT:!unequip *:*: { 
  if ($is_charmed($nick) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($readini($char($nick), status, weapon.lock) != $null) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyWeaponLocked) | halt  }

  $weapon_equipped($nick) 
  if ($2 != %weapon.equipped) { .msg $nick $readini(translation.dat, system, WrongEquippedWeapon) | halt }
  else {
    if ($2 = fists) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, errors, Can'tDetachHands) | halt }
    else { $set_chr_name($nick) | writeini $char($nick) weapons equipped Fists | query %battlechan $readini(translation.dat, system, UnequipWeapon) | halt }
  }
}

on 2:TEXT:!status:*: { $player.status($nick) | query %battlechan $readini(translation.dat, system, ViewStatus) | unset %all_status } 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TAUNT COMMAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!taunt *:*: { $set_chr_name($nick)
  if ($is_charmed($nick) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  $taunt($nick, $2) | halt 
}
ON 2:ACTION:taunt*:#:{ 
  if ($is_charmed($nick) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  $taunt($nick , $2) | halt 
} 
ON 50:TEXT:*taunts *:*:{ $set_chr_name($1)
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if $readini($char($1), Battle, HP) = $null) { halt }
  $set_chr_name($1) | $taunt($1, $3)
}

alias taunt {
  ; $1 = taunter
  ; $2 = target

  if (%battleis = off) { query %battlechan $readini(translation.dat, errors, NoCurrentBattle) | halt }
  $check_for_battle($1) 

  $person_in_battle($2) 

  var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($2), info, flag)
  if ($is_charmed($1) = true) { var %user.flag monster }
  if (%mode.pvp = on) { var %user.flag monster }

  if ((%user.flag != monster) && (%target.flag != monster)) { query %battlechan $readini(translation.dat, errors, OnlyTauntMonsters) | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, Can'tTauntWhiledead) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, Can'tTauntSomeoneWhoIsDead) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { query %battlechan $readini(translation.dat, errors, Can'tTauntSomeoneWhoFled) | unset %real.name | halt } 

  ; Add some style to the taunter.
  set %stylepoints.to.add $rand(60,80)
  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)

  if (%current.playerstyle = Trickster) { %stylepoints.to.add = $calc((10 * %current.playerstyle.level) + %stylepoints.to.add) }

  $add.stylepoints($1, $2, %stylepoints.to.add, taunt)  

  unset %current.playerstyle | unset %current.playerstyle.level

  ; Pick a random taunt and show it.
  $calculate.stylepoints($1)
  $set_chr_name($2) | set %enemy %real.name
  $set_chr_name($1) | query %battlechan 2 $+ %real.name looks at $set_chr_name($2) %real.name and says " $+ $read taunts.txt $+ "  %style.rating

  ; Now do a random effect to the monster.
  var %taunt.effect $rand(1,7)

  if (%taunt.effect = 1) { var %taunt.str $readini($char($2), battle, str) | inc %taunt.str $rand(1,2) | writeini $char($2) battle str %taunt.str | $set_chr_name($2) | query %battlechan $readini(translation.dat, battle, TauntRage) }
  if (%taunt.effect = 2) { var %taunt.def $readini($char($2), battle, def) | inc %taunt.def $rand(1,2) | writeini $char($2) battle def %taunt.def | $set_chr_name($2) | query %battlechan $readini(translation.dat, battle, TauntDefensive)  }
  if (%taunt.effect = 3) { var %taunt.int $readini($char($2), battle, int) | dec %taunt.int 1 | writeini $char($2) battle int %taunt.int | $set_chr_name($2) | query %battlechan $readini(translation.dat, battle, TauntClueless)  }
  if (%taunt.effect = 4) { var %taunt.str $readini($char($2), battle, str) | dec %taunt.str 1 | writeini $char($2) battle str %taunt.str | $set_chr_name($2) | query %battlechan $readini(translation.dat, battle, TauntTakenAback) }
  if (%taunt.effect = 5) { $set_chr_name($2) | query %battlechan $readini(translation.dat, battle, TauntBored) }
  if (%taunt.effect = 6) { set %taunt.hp $readini($char($2), battle, hp) | inc %taunt.hp $rand(1,5)  | set %taunt.maxhp $readini($char($2), battlestats, HP)
    if (%taunt.hp > %taunt.maxhp) { var %taunt.hp %taunt.maxhp }
    writeini $char($2) battle hp %taunt.hp | $set_chr_name($2) | query %battlechan $readini(translation.dat, battle, TauntLaugh) | unset %taunt.hp | unset %taunt.maxhp
  }
  if (%taunt.effect = 7) { var %taunt.tp $readini($char($2), battle, tp) | inc %taunt.tp 5 | var %taunt.maxtp $readini($char($2), battlestats, tp)
    if (%taunt.tp > %taunt.maxtp) { var %taunt.tp %taunt.maxtp }
    writeini $char($2) battle tp %taunt.tp | $set_chr_name($2) | query %battlechan $readini(translation.dat, battle, TauntSmile)
  }

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; GIVES COMMAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 2:ACTION:gives *:*:{  
  if ($2 !isnum) {  $gives.command($nick, $4, 1, $2)  }
  else { $gives.command($nick, $5, $2, $3) }
}
alias gives.command {
  ; $1 = person giving item
  ; $2 = person receiving item
  ; $3 = amount being given
  ; $4 = item being given

  $set_chr_name($1)

  if ($2 = $1) { query %battlechan $readini(translation.dat, errors, CannotGiveToYourself) | halt }

  var %flag $readini($char($2), Info, Flag)
  if (%flag != $null) { query %battlechan $readini(translation.dat, errors, Can'tGiveToNonChar) | halt }

  var %check.item.give $readini($char($1), Item_Amount, $4) 
  if ((%check.item.give <= 0) || (%check.item.give = $null)) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoesNotHaveThatItem) | halt }
  if (. isin $3) || ($3 <= 0) { query %battlechan $readini(translation.dat, errors, CannotGiveNegativeItem) | halt }
  if ($3 > %check.item) { query %battlechan $readini(translation.dat, errors, CannotGiveThatMuchofItem) | halt }

  var %equipped.accessory $readini($char($1), equipment, accessory)
  if (%equipped.accessory = $4) {
    if (%check.item = 1) { .msg $nick $readini(translation.dat, errors, StillWearingAccessory) | halt }
  }

  ; If so, decrease the amount
  dec %check.item.give $3
  writeini $char($1) item_amount $4 %check.item.give

  var %target.items $readini($char($2), item_amount, $4)
  inc %target.items $4 
  writeini $char($2) item_amount $4 %target.items

  query %battlechan $readini(translation.dat, system, GiveItemToTarget)

  var %number.of.items.given $readini($char($1), stuff, ItemsGiven)
  if (%number.of.items.given = $null) { var %number.of.items.given 0 }
  inc %number.of.items.given $3
  writeini $char($1) stuff ItemsGiven %number.of.items.given
  $achievement_check($1, Santa'sLittleHelper)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SCOREBOARD COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!scoreboard:*: {
  if (%battleis != on) { $generate.scoreboard }
  else { query %battlechan $readini(translation.dat, errors, ScoreBoardNotDuringBattle) | halt }
}

on 2:TEXT:!score*:*: {
  if ($2 = $null) { 
    var %score $get.score($nick)
    $set_chr_name($nick) | query %battlechan $readini(translation.dat, system, CurrentScore)
  }
  else {
    $checkchar($2) 
    var %flag $readini($char($2), info, flag)
    if ((%flag = monster) || (%flag = npc)) { query %battlechan $readini(translation.dat, errors, SkillCommandOnlyOnPlayers) | halt }
    var %score $get.score($2)
    $set_chr_name($2) | query %battlechan $readini(translation.dat, system, CurrentScore)
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; DIFFICULTY CMNDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!view difficulty*:*:{   $set_chr_name($nick) | $checkchar($nick) 
  var %saved.difficulty $readini($char($nick), info, difficulty)
  if (%saved.difficulty = $null) { var %saved.difficulty 0 }
  query %battlechan $readini(translation.dat, system, ViewDifficulty)
}

on 2:TEXT:!save difficulty*:*:{   $set_chr_name($nick) | $checkchar($nick) 
  if ($3 !isnum) { query %battlechan $readini(translation.dat, errors, DifficultyMustBeNumber) | halt }
  if (. isin $3) { query %battlechan $readini(translation.dat, errors, DifficultyMustBeNumber) | halt }
  if ($3 < 0) { query %battlechan $readini(translation.dat, errors, DifficultyCan'tBeNegative) | halt }

  writeini $char($nick) info difficulty $3
  query %battlechan $readini(translation.dat, system, SaveDifficulty)
}
