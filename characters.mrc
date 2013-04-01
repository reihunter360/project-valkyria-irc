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
  if ($nick = demon_wall) { query $nick $readini(translation.dat, system, NameReserved) | halt }

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

  ; Give voice
  mode %battlechan +v $nick

  if ($readini(system.dat, system, botType) = DCCchat) {  .auser 2 $nick | dcc chat $nick }
  if ($readini(system.dat, system, botType) = IRC) { .auser 3 $nick }

  var %bot.owners $readini(system.dat, botinfo, bot.owner)
  if ($istok(%bot.owners,$nick,46) = $true) {  .auser 50 $nick }

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

ON 1:TEXT:!id*:?:{ 
  $idcheck($nick , $2) | mode %battlechan +v $nick |  /.dns $nick |  /close -m* 
  if ($readini(system.dat, system, botType) = IRC) { $set_chr_name($nick) | query %battlechan 10 $+ %real.name  $+  $readini($char($nick), Descriptions, Char) }
}
ON 1:TEXT:!quick id*:?:{ $idcheck($nick , $3, quickid) | mode %battlechan +v $nick |   /.dns $nick
  if ($readini(system.dat, system, botType) = IRC) { $set_chr_name($nick) }
  /close -m* 
}
on 3:TEXT:!logout*:*:{ .auser 1 $nick | mode %battlechan -v $nick | .flush 1 }
on 3:TEXT:!log out*:*:{ .auser 1 $nick | mode %battlechan -v $nick | .flush 1 }

alias idcheck { 
  if ($readini($char($1), info, flag) != $null) { .msg $nick $readini(translation.dat, errors, Can'tLogIntoThisChar) | halt }
  if ($readini($char($1), info, banned) = yes) { .msg $nick 4This character has been banned and cannot be used to log in. | halt }
  $passhurt($1) | $password($1)
  if (%password = $null) { unset %passhurt | unset %password | halt }
  if ($2 = $null) { halt }
  else { 
    if ($encode($2) == %password) { $id_login($1) | unset %password | return }
    if ($encode($2) != %password)  { 
      if ((%passhurt = $null) || (%passhurt < 3)) {  .msg $1 $readini(translation.dat, errors, WrongPassword2) | inc %passhurt 1 | writeini $char($1) info passhurt %passhurt | unset %password | unset %passhurt | halt }
      else { kick %battlechan $1 $readini(translation.dat, errors, TooManyWrongPass)  | unset %passhurt | unset %password | writeini $char($1) Info passhurt 0 | halt } 
    }
  }
}

alias id_login {
  var %bot.owners $readini(system.dat, botinfo, bot.owner)
  if ($istok(%bot.owners,$1, 46) = $true) {  .auser 50 $1
    if ($readini(system.dat, system, botType) = DCCchat) { 
      unset %dcc.alreadyloggedin
      $dcc.check.for.double.login($1)
      if (%dcc.alreadyloggedin != true) { dcc chat $nick }
      unset %dcc.alreadyloggedin
    }
  }
  else { 
    if ($readini(system.dat, system, botType) = IRC) { .auser 3 $1 }
    if ($readini(system.dat, system, botType) = DCCchat) { .auser 2 $1 
      unset %dcc.alreadyloggedin
      $dcc.check.for.double.login($1)
      if (%dcc.alreadyloggedin != true) { dcc chat $nick }
      unset %dcc.alreadyloggedin
    }
  }
  writeini $char($1) Info LastSeen $fulldate
  return
}

on 3:TEXT:!weather*:#: {  query %battlechan $readini(translation.dat, battle, CurrentWeather) }
on 3:TEXT:!weather*:?: {  .msg $nick $readini(translation.dat, battle, CurrentWeather) }

on 3:TEXT:!desc*:#: {  
  if ($2 != $null) { $checkchar($2) | $set_chr_name($2) | query %battlechan 3 $+ %real.name  $+ $readini($char($2), Descriptions, Char)   | unset %character.description | halt }
  else { $set_chr_name($nick) | query %battlechan 10 $+ %real.name  $+ $readini($char($nick), Descriptions, Char)  }
}
on 3:TEXT:!desc*:?: {  
  if ($2 != $null) { $checkchar($2) | $set_chr_name($2) | .msg $nick 3 $+ %real.name  $+ $readini($char($2), n, Descriptions, Char)   | unset %character.description | halt }
  else { $set_chr_name($nick) | .msg $nick 10 $+ %real.name  $+ $readini($char($nick), Descriptions, Char)  }
}
on 3:TEXT:!rdesc *:*:{ $checkchar($2) | $set_chr_name($2) | var %character.description $readini($char($2), Descriptions, Char) | query %battlechan 3 $+ %real.name $+ 's desc: %character.description | unset %character.description | halt }
on 3:TEXT:!cdesc *:*:{ $checkscript($2-)  | writeini $char($nick) Descriptions Char $2- | $okdesc($nick , Character) }
on 3:TEXT:!sdesc *:*:{ $checkscript($2-)  
  if ($readini($char($nick), skills, $2) != $null) { 
    writeini $char($nick) Descriptions $2 $3- | $okdesc($nick , Skill) 
  }
  if ($readini($char($nick), skills, $2) = $null) { .msg $nick $readini(translation.dat, errors, YouDoNotHaveSkill) | halt }
}
on 3:TEXT:!skill desc *:*:{ $checkscript($3-)  | $set_chr_name($nick) 
  if ($readini($char($nick), skills, $3) != $null) { 
    writeini $char($nick) Descriptions $3 $4- | $okdesc($nick , Skill) 
  }
  if ($readini($char($nick), skills, $3) = $null) { .msg $nick $readini(translation.dat, errors, YouDoNotHaveSkill) | halt }
}

on 3:TEXT:!ignition desc *:*:{ $checkscript($3-)  | $set_chr_name($nick) 
  if ($readini($char($nick), ignitions, $3) != $null) { 
    writeini $char($nick) Descriptions $3 $4- | $okdesc($nick , Ignition) 
  }
  if ($readini($char($nick), ignitions, $3) = $null) { .msg $nick $readini(translation.dat, errors, DoNotKnowThatIgnition) | halt }
}

on 3:TEXT:!clear desc *:*:{ $checkscript($3-)  | $set_chr_name($nick) 
  if (($3 = character) || ($3 = char)) { var %description.to.clear char | writeini $char($nick) descriptions char needs to set a character description! | .msg $nick $readini(translation.dat, system, ClearDesc) }
  else { remini $char($nick) descriptions $3 | .msg $nick $readini(translation.dat, system, ClearDesc) }
}

on 3:TEXT:!set desc *:*:{ $checkscript($2-)  | writeini $char($nick) Descriptions Char $3- | $okdesc($nick , Character) }
on 3:TEXT:!setgender*:*: { $checkscript($2-)
  if ($2 = neither) { writeini $char($nick) Info Gender its | writeini $char($nick) Info Gender2 its | .msg $nick $readini(translation.dat, system, SetGenderNeither) | unset %check | halt }
  if ($2 = none) { writeini $char($nick) Info Gender its | writeini $char($nick) Info Gender2 its | .msg $nick $readini(translation.dat, system, SetGenderNeither)  | unset %check | halt }
  if ($2 = male) { writeini $char($nick) Info Gender his | writeini $char($nick) Info Gender2 him | .msg $nick $readini(translation.dat, system, SetGenderMale)  | unset %check | halt }
  if ($2 = female) { writeini $char($nick) Info Gender her | writeini $char($nick) Info Gender2 her | .msg $nick $readini(translation.dat, system, SetGenderFemale) | unset %check | halt }
  else { .msg $nick $readini(translation.dat, errors, NeedValidGender) | unset %check | halt }
}

on 3:TEXT:!level*:#: { 
  if ($1 = !leveladjust) { halt }
  if ($2 = $null) { $set_chr_name($nick) | var %player.level $bytes($round($get.level($nick),0),b) | query %battlechan $readini(translation.dat, system, ViewLevel) | unset %real.name }
  if ($2 != $null) { $checkscript($2-) | $checkchar($2) | $set_chr_name($2) | var %player.level $bytes($round($get.level($2),0),b) | query %battlechan $readini(translation.dat, system, ViewLevel) | unset %real.name }
}
on 3:TEXT:!level*:?: { 
  if ($1 = !leveladjust) { halt }
  if ($2 = $null) { $set_chr_name($nick) | var %player.level $bytes($round($get.level($nick),0),b) | .msg $nick $readini(translation.dat, system, ViewLevel) | unset %real.name }
  if ($2 != $null) { $checkscript($2-) | $checkchar($2) | $set_chr_name($2) | var %player.level $bytes($round($get.level($2),0),b) | .msg $nick $readini(translation.dat, system, ViewLevel) | unset %real.name }
}

on 3:TEXT:!hp:#: { 
  $set_chr_name($nick) | $hp_status_hpcommand($nick) 
  query %battlechan $readini(translation.dat, system, ViewMyHP) | unset %real.name | unset %hstats 
}
on 3:TEXT:!hp:?: { 
  $set_chr_name($nick) | $hp_status_hpcommand($nick) 
  .msg $nick $readini(translation.dat, system, ViewMyHP) | unset %real.name | unset %hstats 
}
on 3:TEXT:!battle hp:#: { 
  if (%battleis != on) { query %battlechan $readini(translation.dat, errors, NoBattleCurrently) }
  $build_battlehp_list
  query %battlechan %battle.hp.list  | unset %real.name | unset %hstats | unset %battle.hp.list
}
on 3:TEXT:!battle hp:?: { 
  if (%battleis != on) { query %battlechan $readini(translation.dat, errors, NoBattleCurrently) }
  $build_battlehp_list
  .msg $nick %battle.hp.list  | unset %real.name | unset %hstats | unset %battle.hp.list
}

on 3:TEXT:!tp:#:$set_chr_name($nick) | query %battlechan $readini(translation.dat, system, ViewMyTP) | unset %real.name
on 3:TEXT:!tp:?:$set_chr_name($nick) | .msg $nick $readini(translation.dat, system, ViewMyTP) | unset %real.name
on 3:TEXT:!ig:#:$set_chr_name($nick) | query %battlechan $readini(translation.dat, system, ViewMyIG) | unset %real.name
on 3:TEXT:!ignition gauge:#:$set_chr_name($nick) | query %battlechan $readini(translation.dat, system, ViewMyIG) | unset %real.name
on 3:TEXT:!ig:?:$set_chr_name($nick) | .msg $nick $readini(translation.dat, system, ViewMyIG) | unset %real.name
on 3:TEXT:!ignition gauge:?:$set_chr_name($nick) | .msg $nick $readini(translation.dat, system, ViewMyIG) | unset %real.name
on 3:TEXT:!orbs*:#: { 
  if ($2 != $null) { $checkchar($2) | var %orbs.spent $bytes($readini($char($2), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($2), stuff, BlackOrbsSpent),b) | $set_chr_name($2) 

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
on 3:TEXT:!orbs*:?: { 
  if ($2 != $null) { $checkchar($2) | var %orbs.spent $bytes($readini($char($2), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($2), stuff, BlackOrbsSpent),b) | $set_chr_name($2) 
    .msg $nick $readini(translation.dat, system, ViewOthersOrbs) 
  }
  else { var %orbs.spent $bytes($readini($char($nick), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($nick), stuff, BlackOrbsSpent),b) | $set_chr_name($nick) 
    .msg $nick $readini(translation.dat, system, ViewMyOrbs)
  }
}

on 3:TEXT:!rorbs*:#: { var %orbs.spent $bytes($readini($char($2), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($2), stuff, BlackOrbsSpent),b) | $checkchar($2) | $set_chr_name($2) 
  var %showorbsinchannel $readini(system.dat, system,ShowOrbsCmdInChannel)
  if (%showorbsinchannel = $null) { var %showorbsinchannel true }
  if (%showorbsinchannel = true) { query %battlechan $readini(translation.dat, system, ViewOthersOrbs)  }
  else {  .msg $nick $readini(translation.dat, system, ViewOthersOrbs) }
}
on 3:TEXT:!rorbs*:?: { var %orbs.spent $bytes($readini($char($2), stuff, RedOrbsSpent),b) | var %blackorbs.spent $bytes($readini($char($2), stuff, BlackOrbsSpent),b) | $checkchar($2) | $set_chr_name($2) 
  .msg $nick $readini(translation.dat, system, ViewOthersOrbs)
}

on 3:TEXT:!alliednotes*:#: {  
  if ($2 = $null) { $check.allied.notes($nick, channel) }
  if ($2 != $null) { $checkchar($2) | $check.allied.notes($2, channel) }
}
on 3:TEXT:!allied notes*:#: {  
  if ($3 = $null) { $check.allied.notes($nick, channel) }
  if ($3 != $null) { $checkchar($3) | $check.allied.notes($3, channel) }
}
on 3:TEXT:!notes*:#: {  
  if ($2 = $null) { $check.allied.notes($nick, channel) }
  if ($2 != $null) { $checkchar($2) | $check.allied.notes($2, channel) }
}
on 3:TEXT:!alliednotes*:?: {  
  if ($2 = $null) { $check.allied.notes($nick, private) }
  if ($2 != $null) { $checkchar($2) | $check.allied.notes($2, private) }
}
on 3:TEXT:!allied notes*:?: {  
  if ($3 = $null) { $check.allied.notes($nick, private) }
  if ($3 != $null) { $checkchar($2) | $check.allied.notes($2, private) }
}
on 3:TEXT:!notes*:?: {  
  if ($2 = $null) { $check.allied.notes($nick, private) }
  if ($2 != $null) { $checkchar($2) | $check.allied.notes($2, private) }
}

on 3:TEXT:!stats*:*: { unset %all_status 
  if ($2 = $null) { 
    $battle_stats($nick) | $player.status($nick) | $weapon_equipped($nick) | .msg $nick $readini(translation.dat, system, HereIsYourCurrentStats) 
    var %equipped.accessory $readini($char($nick), equipment, accessory) 
    if (%equipped.accessory = $null) { var %equipped.accessory nothing }
    var %equipped.armor.head $readini($char($nick), equipment, head) 
    if (%equipped.armor.head = $null) { var %equipped.armor.head nothing }
    var %equipped.armor.body $readini($char($nick), equipment, body) 
    if (%equipped.armor.body = $null) { var %equipped.armor.body nothing }
    var %equipped.armor.legs $readini($char($nick), equipment, legs) 
    if (%equipped.armor.legs = $null) { var %equipped.armor.legs nothing }
    var %equipped.armor.feet $readini($char($nick), equipment, feet) 
    if (%equipped.armor.feet = $null) { var %equipped.armor.feet nothing }
    var %equipped.armor.hands $readini($char($nick), equipment, hands) 
    if (%equipped.armor.hands = $null) { var %equipped.armor.hands nothing }

    var %blocked.meter $readini($char($nick), skills, royalguard.dmgblocked)
    if (%blocked.meter = $null) { var %blocked.meter 0 }

    /.timerDisplayStats1 $+ $nick 1 1  .msg $nick [4HP12 $readini($char($nick), Battle, HP) $+ 1/ $+ 12 $+ $readini($char($nick), BaseStats, HP) $+ 1] [4TP12 $readini($char($nick), Battle, TP) $+ 1/ $+ 12 $+ $readini($char($nick), BaseStats, TP) $+ 1] [4Ignition Gauge12 $readini($char($nick), Battle, IgnitionGauge) $+ 1/ $+ 12 $+ $readini($char($nick), BaseStats, IgnitionGauge) $+ 1] [4Status12 %all_status $+ 1] [4Royal Guard Meter12 %blocked.meter $+ 1] 
    /.timerDisplayStats2 $+ $nick 1 1  .msg $nick [4Strength12 %str $+ 1]  [4Defense12 %def $+ 1] [4Intelligence12 %int $+ 1] [4Speed12 %spd $+ 1]
    /.timerDisplayStats3 $+ $nick 1 1  .msg $nick [4 $+ $readini(translation.dat, system, CurrentWeaponEquipped) 12 $+ %weapon.equipped $+ 1]  [4 $+ $readini(translation.dat, system, CurrentAccessoryEquipped) 12 $+ %equipped.accessory $+ 1]  [4 $+ $readini(translation.dat, system, CurrentArmorHeadEquipped) 12 $+ %equipped.armor.head $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorBodyEquipped) 12 $+ %equipped.armor.body $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorLegsEquipped) 12 $+ %equipped.armor.legs $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorFeetEquipped) 12 $+ %equipped.armor.feet $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorHandsEquipped) 12 $+ %equipped.armor.hands $+ 1]
    unset %spd | unset %str | unset %def | unset %int | unset %status | unset %comma_replace | unset %comma_new | unset %all_status | unset %weapon.equipped
  }
  else { 
    $checkchar($2) 
    var %flag $readini($char($2), info, flag)
    if ((%flag = monster) || (%flag = npc)) { query %battlechan $readini(translation.dat, errors, SkillCommandOnlyOnPlayers) | halt }
    $battle_stats($2) | $player.status($2) | $weapon_equipped($2) | .msg $nick $readini(translation.dat, system, HereIsOtherCurrentStats) 
    var %equipped.accessory $readini($char($2), equipment, accessory) 
    if (%equipped.accessory = $null) { var %equipped.accessory nothing }
    var %equipped.armor.head $readini($char($2), equipment, head) 
    if (%equipped.armor.head = $null) { var %equipped.armor.head nothing }
    var %equipped.armor.body $readini($char($2), equipment, body) 
    if (%equipped.armor.body = $null) { var %equipped.armor.body nothing }
    var %equipped.armor.legs $readini($char($2), equipment, legs) 
    if (%equipped.armor.legs = $null) { var %equipped.armor.legs nothing }
    var %equipped.armor.feet $readini($char($2), equipment, feet) 
    if (%equipped.armor.feet = $null) { var %equipped.armor.feet nothing }
    var %equipped.armor.hands $readini($char($2), equipment, hands) 
    if (%equipped.armor.hands = $null) { var %equipped.armor.hands nothing }

    var %blocked.meter $readini($char($2), skills, royalguard.dmgblocked)
    if (%blocked.meter = $null) { var %blocked.meter 0 }

    /.timerDisplayStats1 $+ $nick 1 1  .msg $nick [4HP12 $readini($char($2), Battle, HP) $+ 1/ $+ 12 $+ $readini($char($2), BaseStats, HP) $+ 1] [4TP12 $readini($char($2), Battle, TP) $+ 1/ $+ 12 $+ $readini($char($2), BaseStats, TP) $+ 1] [4Ignition Gauge12 $readini($char($2), Battle, IgnitionGauge) $+ 1/ $+ 12 $+ $readini($char($2), BaseStats, IgnitionGauge) $+ 1] [4Status12 %all_status $+ 1] [4Royal Guard Meter12 %blocked.meter $+ 1] 
    /.timerDisplayStats2 $+ $nick 1 1  .msg $nick [4Strength12 %str $+ 1]  [4Defense12 %def $+ 1] [4Intelligence12 %int $+ 1] [4Speed12 %spd $+ 1]
    /.timerDisplayStats3 $+ $nick 1 1  .msg $nick [4 $+ $readini(translation.dat, system, CurrentWeaponEquipped) 12 $+ %weapon.equipped $+ 1]  [4 $+ $readini(translation.dat, system, CurrentAccessoryEquipped) 12 $+ %equipped.accessory $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorHeadEquipped) 12 $+ %equipped.armor.head $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorBodyEquipped) 12 $+ %equipped.armor.body $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorLegsEquipped) 12 $+ %equipped.armor.legs $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorFeetEquipped) 12 $+ %equipped.armor.feet $+ 1] [4 $+ $readini(translation.dat, system, CurrentArmorHandsEquipped) 12 $+ %equipped.armor.hands $+ 1]
    unset %spd | unset %str | unset %def | unset %int | unset %status | unset %comma_replace | unset %comma_new | unset %all_status | unset %weapon.equipped
  }
}

on 3:TEXT:!look*:#: { unset %all_status 
  if ($2 = $null) { $lookat($nick, channel) }
  if ($2 != $null) { $checkchar($2) | $lookat($2, channel) }
}
on 3:TEXT:!look*:?: { unset %all_status 
  if ($2 = $null) { $lookat($nick, private) }
  if ($2 != $null) { $checkchar($2) | $lookat($2, private) }
}

on 3:TEXT:!weapons*:#: {  unset %*.wpn.list | unset %weapon.list
  if ($2 = $null) { $weapon.list($nick) | set %wpn.lst.target $nick }
  else { $checkchar($2) | $weapon.list($2) | set %wpn.lst.target $2 }
  /.timerDisplayWeaponList $+ $nick 1 3 /display_weapon_lists %wpn.lst.target channel
}
on 3:TEXT:!rweapons*:#: { $checkchar($2) | $weapon.list($2)  | $set_chr_name($2) 
  /.timerDisplayWeaponList $+ $2 1 3 /display_weapon_lists $2 channel
}
on 3:TEXT:!weapons*:?: {  unset %*.wpn.list | unset %weapon.list
  if ($2 = $null) { $weapon.list($nick) | set %wpn.lst.target $nick }
  else { $checkchar($2) | $weapon.list($2) | set %wpn.lst.target $2 }
  /.timerDisplayWeaponList $+ $nick 1 3 /display_weapon_lists %wpn.lst.target private $nick
}
on 3:TEXT:!rweapons*:?: { $checkchar($2) | $weapon.list($2)  | $set_chr_name($2) 
  /.timerDisplayWeaponList $+ $nick 1 3 /display_weapon_lists $2 private $nick
}
alias display_weapon_lists {  $set_chr_name($1) 
  if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewWeaponList) }
  if ($2 = private) { .msg $3 $readini(translation.dat, system, ViewWeaponList) }
  if ($2 = dcc) { $dcc.private.message($3, $readini(translation.dat, system, ViewWeaponList)) }
  unset %wpn.lst.target | unset %base.weapon.list | unset %weapons | unset %weapon.list 
}

on 3:TEXT:!style*:*: {  unset %*.style.list | unset %style.list
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
  if ($is_confused($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  $style.change($1, $3, $5)
} 
alias style.change { 
  if ($2 = change) && ($3 = $null) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, SpecifyStyle) | halt }
  if ($2 = change) && ($3 != $null) {  
    var %valid.styles.list $readini(playerstyles.lst, styles, list)
    if ($istok(%valid.styles.list, $3, 46) = $false) { query %battlechan $readini(translation.dat, errors, InvalidStyle) | halt }
    var %current.playerstylelevel $readini($char($1), styles, $3)
    if ((%current.playerstylelevel = $null) || (%current.playerstylelevel = 0)) { $set_chr_name($1) 
      if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, errors, DoNotKnowThatStyle) }
      if ($readini(system.dat, system, botType) = DCCchat) {  $dcc.private.message($nick, $readini(translation.dat, errors, DoNotKnowThatStyle)) }
      halt
    }

    $check_for_battle($1)

    ; finally, switch to it.
    $set_chr_name($1) | writeini $char($1) styles equipped $3 
    if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, system, SwitchStyles) }
    if ($readini(system.dat, system, botType) = DCCchat) {  
      if (%battleis = off) { $dcc.private.message($nick, $readini(translation.dat, system, SwitchStyles)) }
      if (%battleis = on) { $dcc.battle.message($readini(translation.dat, system, SwitchStyles)) }
    }

    unset %styles.list | unset %current.playerstyle.* | unset %styles | unset %style.name | unset %style_level | unset %current.playerstyle

    ; if the battle is on..
    if (%battleis = on) {  $check_for_double_turn($1)   }
  }
}
on 3:TEXT:!xp*:#: {  unset %*.style.list | unset %style.list
  if ($2 != $null) { $checkchar($2) | $show.stylexp($2, channel) }
  if ($2 = $null) { $show.stylexp($nick, channel) }
}
on 3:TEXT:!xp*:?: {  unset %*.style.list | unset %style.list
  if ($2 != $null) { $checkchar($2) | $show.stylexp($2, private) }
  if ($2 = $null) { $show.stylexp($nick, private) }
}

alias show.stylexp {
  ; Get and show the list
  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.xp $readini($char($1), styles, %current.playerstyle $+ XP)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
  var %current.playerstyle.xptolevel $calc(500 * %current.playerstyle.level)
  $set_chr_name($1) 
  if (%current.playerstyle.level >= 10) {   
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewCurrentStyleMaxed) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewCurrentStyleMaxed) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewCurrentStyleMaxed)) }
  }
  if (%current.playerstyle.level < 10) {   
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewCurrentStyle) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewCurrentStyle) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewCurrentStyle)) }
  }
  unset %styles.list | unset %current.playerstyle.* | unset %styles | unset %style.name | unset %style_level | unset %current.playerstyle
}

on 3:TEXT:!techs*:#: { 
  if ($2 = $null) { $weapon_equipped($nick) | $tech.list($nick, %weapon.equipped) | $set_chr_name($nick) 
    if (%techs.list != $null) { query %battlechan $readini(translation.dat, system, ViewMyTechs) }
    else { query %battlechan $readini(translation.dat, system, NoTechsForMe)  }
  }
  else { $checkchar($2) | $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) 
    if (%techs.list != $null) { query %battlechan $readini(translation.dat, system, ViewOthersTechs) }
    else { query %battlechan $readini(translation.dat, system, NoTechsForOthers) }
  }
}
on 3:TEXT:!techs*:?: { 
  if ($2 = $null) { $weapon_equipped($nick) | $tech.list($nick, %weapon.equipped) | $set_chr_name($nick) 
    if (%techs.list != $null) { .msg $nick $readini(translation.dat, system, ViewMyTechs) }
    else { .msg $nick $readini(translation.dat, system, NoTechsForMe)  }
  }
  else { $checkchar($2) | $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) 
    if (%techs.list != $null) { .msg $nick $readini(translation.dat, system, ViewOthersTechs) }
    else { .msg $nick $readini(translation.dat, system, NoTechsForOthers) }
  }
}

on 3:TEXT:!readtechs*:#: { $checkchar($2)
  $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) |
  if (%techs.list != $null) { query %battlechan $readini(translation.dat, system, ViewOthersTechs) }
  else { query %battlechan $readini(translation.dat, system, NoTechsForOthers) }
}
on 3:TEXT:!rtechs*:#: { $checkchar($2)
  $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) |
  if (%techs.list != $null) { query %battlechan $readini(translation.dat, system, ViewOthersTechs) }
  else { query %battlechan $readini(translation.dat, system, NoTechsForOthers) }
}
on 3:TEXT:!readtechs*:?: { $checkchar($2)
  $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) |
  if (%techs.list != $null) { .msg $nick $readini(translation.dat, system, ViewOthersTechs) }
  else { .msg $nick $readini(translation.dat, system, NoTechsForOthers) }
}
on 3:TEXT:!rtechs*:?: { $checkchar($2)
  $weapon_equipped($2) | $tech.list($2, %weapon.equipped)  | $set_chr_name($2) |
  if (%techs.list != $null) { .msg $nick $readini(translation.dat, system, ViewOthersTechs) }
  else { .msg $nick $readini(translation.dat, system, NoTechsForOthers) }
}

on 3:TEXT:!ignitions*:#:{ 
  if ($2 = $null) { $ignition.list($nick) | $set_chr_name($nick) 
    if (%ignitions.list != $null) { query %battlechan $readini(translation.dat, system, ViewIgnitions) | unset %ignitions.list }
    else { query %battlechan $readini(translation.dat, system, NoIgnitions)  }
  }
  else { $checkchar($2) | $ignition.list($2)  | $set_chr_name($2) 
    if (%ignitions.list != $null) { query %battlechan $readini(translation.dat, system, ViewIgnitions) | unset %ignitions.list }
    else { query %battlechan $readini(translation.dat, system, NoIgnitions)  }
  }
}
on 3:TEXT:!readignitions*:#: {
  $checkchar($2) | $ignition.list($2)  | $set_chr_name($2) 
  if (%ignitions.list != $null) { query %battlechan $readini(translation.dat, system, ViewIgnitions) }
  else { query %battlechan $readini(translation.dat, system, NoIgnitions)  }
}
on 3:TEXT:!ignitions*:?:{ 
  if ($2 = $null) { $ignition.list($nick) | $set_chr_name($nick) 
    if (%ignitions.list != $null) { .msg $nick $readini(translation.dat, system, ViewIgnitions) | unset %ignitions.list }
    else { .msg $nick $readini(translation.dat, system, NoIgnitions)  }
  }
  else { $checkchar($2) | $ignition.list($2)  | $set_chr_name($2) 
    if (%ignitions.list != $null) { .msg $nick $readini(translation.dat, system, ViewIgnitions) | unset %ignitions.list }
    else { .msg $nick $readini(translation.dat, system, NoIgnitions)  }
  }
}
on 3:TEXT:!readignitions*:?: {
  $checkchar($2) | $ignition.list($2)  | $set_chr_name($2) 
  if (%ignitions.list != $null) { .msg $nick $readini(translation.dat, system, ViewIgnitions) }
  else { .msg $nick $readini(translation.dat, system, NoIgnitions)  }
}

on 3:TEXT:!skills*:#: { 
  if ($2 != $null) { $checkchar($2) | $skills.list($2) | $set_chr_name($2) | $readskills($2, channel)  }
  else { $skills.list($nick) | $set_chr_name($nick) | $readskills($nick, channel) }
}
on 3:TEXT:!skills*:?: { 
  if ($2 != $null) { $checkchar($2) | $skills.list($2) | $set_chr_name($2) | $readskills($2, private)  }
  else { $skills.list($nick) | $set_chr_name($nick) | $readskills($nick, private) }
}
on 3:TEXT:!rskills*:#: { $readskills($2, channel) }
on 3:TEXT:!readskills*:#: { $readskills($2,private) }
on 3:TEXT:!rskills*:?: { $readskills($2, channel) }
on 3:TEXT:!readskills*:?: { $readskills($2,private) }

alias readskills {
  $checkchar($1) | $skills.list($1) | $set_chr_name($1) 
  if (%passive.skills.list != $null) { 
    if ($2 = channel) { 
      query %battlechan $readini(translation.dat, system, ViewPassiveSkills) 
      if (%passive.skills.list2 != $null) { query %battlechan 3 $+ %passive.skills.list2 }
    }
    if ($2 = private) {
      .msg $nick $readini(translation.dat, system, ViewPassiveSkills) 
      if (%passive.skills.list2 != $null) { .msg $nick 3 $+ %passive.skills.list2 }
    }
    if ($2 = dcc) {
      $dcc.private.message($nick, $readini(translation.dat, system, ViewPassiveSkills))
      if (%passive.skills.list2 != $null) { $dcc.private.message($nick, 3 $+ %passive.skills.list2) }
    }

  }
  if (%active.skills.list != $null) { 
    if ($2 = channel) { 
      query %battlechan $readini(translation.dat, system, ViewActiveSkills) 
      if (%active.skills.list2 != $null) { query %battlechan 3 $+ %active.skills.list2 }
    }
    if ($2 = private) {
      .msg $nick $readini(translation.dat, system, ViewActiveSkills)
      if (%active.skills.list2 != $null) { .msg $nick 3 $+ %active.skills.list2 }
    }
    if ($2 = dcc) {
      $dcc.private.message($nick, $readini(translation.dat, system, ViewActiveSkills))
      if (%active.skills.list2 != $null) { $dcc.private.message($nick, 3 $+ %active.skills.list2) }

    }
    if (%resists.skills.list != $null) { 
      if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewResistanceSkills)  }
      if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewResistanceSkills)  }
      if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewResistanceSkills))  }
    }
    if (((%passive.skills.list = $null) && (%active.skills.list = $null) && (%resists.skills.list = $null))) { 
      if ($2 = channel) { query %battlechan $readini(translation.dat, system, HasNoSkills)   }
      if ($2 = private) { .msg $nick $readini(translation.dat, system, HasNoSkills)   }
      if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoSkills)) }
    }
  }
  unset %passive.skills.list | unset %active.skills.list | unset %active.skills.list2 | unset %resists.skills.list
}
on 3:TEXT:!keys*:#:{ 
  if ($2 != $null) { $checkchar($2) | $keys.list($2) | $set_chr_name($2) | $readkeys($2, channel) }
  else {  $keys.list($nick) | $set_chr_name($nick) | $readkeys($nick, channel) }
}
on 3:TEXT:!keys*:?:{ 
  if ($2 != $null) { $checkchar($2) | $keys.list($2) | $set_chr_name($2) | $readkeys($2, private) }
  else {  $keys.list($nick) | $set_chr_name($nick) | $readkeys($nick, private) }
}

alias readkeys {
  if (%keys.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewKeysItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewKeysItems) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewKeysItems)) }
  } 
  else { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, HasNoKeys) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, HasNoKeys) }
    if ($2 = dcc) {  $dcc.private.message($nick, $readini(translation.dat, system, HasNoKeys)) }
  }    
}
on 3:TEXT:!items*:#:{ 
  if ($2 != $null) { $checkchar($2) | $items.list($2) | $set_chr_name($2) | $readitems($2, channel) }
  else {  $items.list($nick) | $set_chr_name($nick) | $readitems($nick, channel) }
}
on 3:TEXT:!ritems*:#:{ $checkchar($2) | $items.list($2) | $set_chr_name($2) | $readitems($2, channel) }
on 3:TEXT:!items*:?:{ 
  if ($2 != $null) { $checkchar($2) | $items.list($2) | $set_chr_name($2) | $readitems($2, private) }
  else {  $items.list($nick) | $set_chr_name($nick) | $readitems($nick, private) }
}
on 3:TEXT:!ritems*:?:{ $checkchar($2) | $items.list($2) | $set_chr_name($2) | $readitems($2, private) }

alias readitems {
  if (%items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewItems) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewItems)) }
  }
  if (%statplus.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewStatPlusItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewStatPlusItems) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewStatPlusItems)) }
  }
  if (%summons.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewSummonItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewSummonItems) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewSummonItems)) }
  }
  if (%reset.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewShopResetItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewShopResetItems) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewShopResetItems)) }
  }
  if (%gems.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewGemItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewGemItems) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewGemItems)) }
  }
  if (%portals.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewPortalItems) } 
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewPortalItems) } 
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewPortalItems)) }
  }
  if (%misc.items.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewMiscItems) } 
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewMiscItems) } 
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewMiscItems)) }
  }

  if (((((((%items.list = $null) && (%statplus.items.list = $null) && (%summons.items.list = $null) && (%reset.items.list = $null) && (%gems.items.list = $null) && (%portals.items.list = $null) && (%misc.items.list = $null))))))) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, HasNoItems) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, HasNoItems) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoItems)) }
  }    
  unset %items.list | unset %gems.items.list | unset %summons.items.list | unset %keys.items.list | unset %misc.items.list | unset %statplus.items.list | unset %portals.items.list
}

on 3:TEXT:!accessories*:#:{ 
  if ($2 != $null) { $checkchar($2) | $accessories.list($2) | $set_chr_name($2) | $readaccessories($2, channel) }
  else { $accessories.list($nick) | $set_chr_name($nick) | $readaccessories($nick, channel) }
}
on 3:TEXT:!accessories*:?:{ 
  if ($2 != $null) { $checkchar($2) | $accessories.list($2) | $set_chr_name($2) | $readaccessories($2, private) }
  else { $accessories.list($nick) | $set_chr_name($nick) | $readaccessories($nick, private) }
}

alias readaccessories {
  if (%accessories.list != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewAccessories) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewAccessories) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewAccessories)) }

    var %equipped.accessory $readini($char($1), equipment, accessory)
    if ((%equipped.accessory = $null) || (%equipped.accessory = none)) { 
      if ($2 = channel) { query %battlechan $readini(translation.dat, system, HasNoEquippedAccessory) }
      if ($2 = private) { .msg $nick $readini(translation.dat, system, HasNoEquippedAccessory) }
      if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoEquippedAccessory)) }
    }
    if ((%equipped.accessory != $null) && (%equipped.accessory != none)) {
      if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewEquippedAccessory) }
      if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewEquippedAccessory) }
      if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewEquippedAccessory)) }
    }
    unset %accessories.list 
  }
  else { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, HasNoAccessories) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, HasNoAccessories) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoAccessories)) } 
  }
}

on 3:TEXT:!armor*:#:{ 
  if ($2 != $null) { $checkchar($2) | $armor.list($2) | $set_chr_name($2) | $readarmor($2, channel) }
  else {  $armor.list($nick) | $set_chr_name($nick) | $set_chr_name($nick) | $readarmor($nick, channel) } 
}
on 3:TEXT:!armor*:?:{ 
  if ($2 != $null) { $checkchar($2) | $armor.list($2) | $set_chr_name($2) | $readarmor($2, private) }
  else {  $armor.list($nick) | $set_chr_name($nick) | $set_chr_name($nick) | $readarmor($nick, private) } 
}

alias readarmor {
  if (%armor.head != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewArmorHead) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewArmorHead) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorHead)) }
  }
  if (%armor.body != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewArmorBody) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewArmorBody) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorBody)) }
  }
  if (%armor.legs != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewArmorLegs) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewArmorLegs) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorLegs)) }
  }
  if (%armor.feet != $null) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewArmorFeet) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewArmorFeet) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorFeet)) }
  }
  if (%armor.hands != $null) {
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, ViewArmorHands) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, ViewArmorHands) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, ViewArmorHands)) }
  }

  if (((((%armor.head = $null) && (%armor.body = $null) && (%armor.legs = $null) && (%armor.feet = $null) && (%armor.hands = $null))))) { 
    if ($2 = channel) { query %battlechan $readini(translation.dat, system, HasNoArmor) }
    if ($2 = private) { .msg $nick $readini(translation.dat, system, HasNoArmor) }
    if ($2 = dcc) { $dcc.private.message($nick, $readini(translation.dat, system, HasNoArmor)) }
  }    

  unset %armor.head | unset %armor.body | unset %armor.legs | unset %armor.feet | unset %armor.hands
}

ON 50:TEXT:*equips *:*:{ 
  if ($is_charmed($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  var %player.weapon.check $readini($char($1), weapons, $3)
  if (%player.weapon.check >= 1) {   writeini $char($1) weapons equipped $3 | $set_chr_name($1) | query %battlechan $readini(translation.dat, system, EquipWeaponGM)  }
  else { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveWeapon) | halt }
} 

on 3:TEXT:!equip *:*: { 
  if ($2 = accessory) { $wear.accessory($nick, $3) | halt }
  if ($2 = armor) { $wear.armor($nick, $3) | halt }

  if ($is_charmed($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  if ($readini($char($nick), status, weapon.lock) != $null) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyWeaponLocked) | halt  }

  var %player.weapon.check $readini($char($nick), weapons, $2)
  if (%player.weapon.check >= 1) {   writeini $char($nick) weapons equipped $2 | $set_chr_name($nick) | query %battlechan $readini(translation.dat, system, EquipWeaponPlayer) }
  else { $set_chr_name($nick) | query %battlechan $readini(translation.dat, errors, DoNotHaveWeapon) | halt }
}

on 3:TEXT:!unequip *:*: { 
  if ($2 = accessory) { $remove.accessory($nick, $3) }
  if ($2 = armor) { $remove.armor($nick, $3) }

  if ($is_charmed($nick) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  if ($readini($char($nick), status, weapon.lock) != $null) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyWeaponLocked) | halt  }

  $weapon_equipped($nick) 
  if ($2 != %weapon.equipped) { .msg $nick $readini(translation.dat, system, WrongEquippedWeapon) | halt }
  else {
    if ($2 = fists) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, errors, Can'tDetachHands) | halt }
    else { $set_chr_name($nick) | writeini $char($nick) weapons equipped Fists | query %battlechan $readini(translation.dat, system, UnequipWeapon) | halt }
  }
}

on 3:TEXT:!status:#: { $player.status($nick) | query %battlechan $readini(translation.dat, system, ViewStatus) | unset %all_status } 
on 3:TEXT:!status:?: { $player.status($nick) | .msg $nick $readini(translation.dat, system, ViewStatus) | unset %all_status }

on 3:TEXT:!total deaths *:#: { 
  if ($3 = $null) { .msg $nick 4!total deaths target | halt }
  if ($isfile($boss($3)) = $true) { set %total.deaths $readini(monsterdeaths.lst, boss, $3) | set %real.name $readini($boss($3), basestats, name) }
  else  if ($isfile($mon($3)) = $true) { set  %total.deaths $readini(monsterdeaths.lst, monster, $3) |  set %real.name $readini($mon($3), basestats, name) }
  else {
    if ($3 = demon_portal) { set %total.deaths $readini(monsterdeaths.lst, monster, demon_portal) | set %real.name Demon Portal }
    else {   $checkchar($3) |  set %total.deaths $readini($char($3), stuff, totaldeaths) | $set_chr_name($3) }
  }
  if ((%total.deaths = $null) || (%total.deaths = 0)) { query %battlechan $readini(translation.dat, system, TotalDeathNone) }
  if (%total.deaths > 0) { query %battlechan $readini(translation.dat, system, TotalDeathTotal)  }
  unset %total.deaths
}
on 3:TEXT:!total deaths *:?: { 
  if ($3 = $null) { .msg $nick 4!total deaths target | halt }
  if ($isfile($boss($3)) = $true) { set %total.deaths $readini(monsterdeaths.lst, boss, $3) | set %real.name $readini($boss($3), basestats, name) }
  else  if ($isfile($mon($3)) = $true) { set  %total.deaths $readini(monsterdeaths.lst, monster, $3) |  set %real.name $readini($mon($3), basestats, name) }
  else {
    if ($3 = demon_portal) { set %total.deaths $readini(monsterdeaths.lst, monster, demon_portal) | set %real.name Demon Portal }
    else {   $checkchar($3) |  set %total.deaths $readini($char($3), stuff, totaldeaths) | $set_chr_name($3) }
  }
  if ((%total.deaths = $null) || (%total.deaths = 0)) { .msg $nick $readini(translation.dat, system, TotalDeathNone) }
  if (%total.deaths > 0) { .msg $nick $readini(translation.dat, system, TotalDeathTotal)  }
  unset %total.deaths
}

on 3:TEXT:!achievements*:#: { 
  if ($2 != $null) { $checkchar($2) | $achievement.list($2) 
    if (%achievement.list != $null) { $set_chr_name($2) | query %battlechan $readini(translation.dat, system, AchievementList) 
      if (%achievement.list.2 != $null) { query %battlechan 3 $+ %achievement.list.2 }
      if (%achievement.list.3 != $null) { query %battlechan 3 $+ %achievement.list.3 }
    }
    if (%achievement.list = $null) { $set_chr_name($2) | query %battlechan $readini(translation.dat, system, NoAchievements) }
    unset %achievement.list | unset %achievement.list.2 | unset %achievement.list.3
  }
  if ($2 = $null) {
    $achievement.list($nick) 
    if (%achievement.list != $null) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, system, AchievementList) 
      if (%achievement.list.2 != $null) { query %battlechan 3 $+ %achievement.list.2 }
      if (%achievement.list.3 != $null) { query %battlechan 3 $+ %achievement.list.3 }
    }
    if (%achievement.list = $null) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, system, NoAchievements) }
    unset %achievement.list | unset %achievement.list.2 | unset %achievement.list.3
  }
}
on 3:TEXT:!achievements*:?: { 
  if ($2 != $null) { $checkchar($2) | $achievement.list($2) 
    if (%achievement.list != $null) { $set_chr_name($2) | .msg $nick $readini(translation.dat, system, AchievementList) 
      if (%achievement.list.2 != $null) { .msg $nick 3 $+ %achievement.list.2 }
      if (%achievement.list.3 != $null) { .msg $nick 3 $+ %achievement.list.3 }
    }
    if (%achievement.list = $null) { $set_chr_name($2) | .msg $nick $readini(translation.dat, system, NoAchievements) }
    unset %achievement.list | unset %achievement.list.2 | unset %achievement.list.3
  }
  if ($2 = $null) {
    $achievement.list($nick) 
    if (%achievement.list != $null) { $set_chr_name($nick) | .msg $nick $readini(translation.dat, system, AchievementList) 
      if (%achievement.list.2 != $null) { .msg $nick 3 $+ %achievement.list.2 }
      if (%achievement.list.3 != $null) { .msg $nick 3 $+ %achievement.list.3 }
    }
    if (%achievement.list = $null) { $set_chr_name($nick) | .msg $nick $readini(translation.dat, system, NoAchievements) }
    unset %achievement.list | unset %achievement.list.2 | unset %achievement.list.3
  }
}

; Bot admins can manually give an item and orbs to a player..
on 50:TEXT:!add*:*:{
  $checkchar($2)
  if ($4 = $null) { .msg $nick 4!add <person> <item name/redorbs/blackorbs> <amount> | halt }
  if ($4 <= 0) { .msg $nick 4cannot add negative amount | halt }

  if (($3 != redorbs) && ($3 != blackorbs)) {
    var %item.type $readini(items.db, $3, type)
    if (%item.type = $null) { .msg $nick 4invalid item | halt }
    var %player.amount $readini($char($2), item_amount, $3) 
    if (%player.amount = $null) { var %player.amount 0 }
    inc %player.amount $4 | writeini $char($2) item_amount $3 %player.amount
    $set_chr_name($2) | query %battlechan 4 $+ %real.name has gained $4 $3 $+ (s)
    halt
  }

  if ($3 = redorbs) { 
    var %player.amount $readini($char($2), stuff, RedOrbs) 
    if (%player.amount = $null) { var %player.amount 0 }
    inc %player.amount $4 | writeini $char($2) stuff  RedOrbs %player.amount
    $set_chr_name($2) | query %battlechan 4 $+ %real.name has gained $4 $readini(system.dat, system, currency) 
    halt
  }

  if ($3 = blackorbs) {
    var %player.amount $readini($char($2), stuff, blackorbs) 
    if (%player.amount = $null) { var %player.amount 0 }
    inc %player.amount $4 | writeini $char($2) stuff  BlackOrbs %player.amount
    $set_chr_name($2) | query %battlechan 4 $+ %real.name has gained $4 Black Orbs
    halt
  }
}

; Bot admins can remove stuff from players..
on 50:TEXT:!take *:*:{
  $checkchar($2)
  if ($4 = $null) { .msg $nick 4!take <person> <item name/redorbs/blackorbs> <amount> | halt }
  if ($4 <= 0) { .msg $nick 4cannot remove negative amount | halt }

  if (($3 != redorbs) && ($3 != blackorbs)) {
    var %item.type $readini(items.db, $3, type)
    if (%item.type = $null) { .msg $nick 4invalid item | halt }
    var %player.amount $readini($char($2), item_amount, $3) 
    if (%player.amount = $null) { var %player.amount 0 | .msg $nick 4 $+ $2 doesn't have any of this item to remove! | halt }
    dec %player.amount $4 
    if (%player.amount < 0) { var %player.amount 0 }
    writeini $char($2) item_amount $3 %player.amount
    $set_chr_name($2) | query %battlechan 4 $+ %real.name has lost $4 $3 $+ (s)
    halt
  }

  if ($3 = redorbs) { 
    var %player.amount $readini($char($2), stuff, RedOrbs) 
    if (%player.amount = $null) { var %player.amount 0 | .msg $nick 4 $+ $2 doesn't have any red orbs to remove! | halt }
    dec %player.amount $4 
    if (%player.amount < 0) { var %player.amount 0 }
    writeini $char($2) stuff  RedOrbs %player.amount
    $set_chr_name($2) | query %battlechan 4 $+ %real.name has lost $4 $readini(system.dat, system, currency) 
    halt
  }

  if ($3 = blackorbs) {
    var %player.amount $readini($char($2), stuff, BlackOrbs) 
    if (%player.amount = $null) { var %player.amount 0 | .msg $nick 4 $+ $2 doesn't have any black orbs to remove! | halt }
    dec %player.amount $4 
    if (%player.amount < 0) { var %player.amount 0 }
    writeini $char($2) stuff  BlackOrbs %player.amount
    $set_chr_name($2) | query %battlechan 4 $+ %real.name has lost $4 Black Orbs 
    halt
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TAUNT COMMAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 3:TEXT:!taunt *:*: { $set_chr_name($nick)
  if ($is_charmed($nick) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  $taunt($nick, $2) | halt 
}
ON 2:ACTION:taunt*:#:{ 
  if ($is_charmed($nick) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  $taunt($nick , $2) | halt 
} 
ON 50:TEXT:*taunts *:*:{ $set_chr_name($1)
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  if $readini($char($1), Battle, HP) = $null) { halt }
  $set_chr_name($1) | $taunt($1, $3)
}

alias taunt {
  ; $1 = taunter
  ; $2 = target

  if (%battleis = off) { $display.system.message($readini(translation.dat, errors, NoCurrentBattle), private) | halt  }
  $check_for_battle($1) 
  $person_in_battle($2) 

  var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($2), info, flag)
  if ($is_charmed($1) = true) { var %user.flag monster }
  if ($is_confused($1) = true) { var %user.flag monster }
  if (%mode.pvp = on) { var %user.flag monster }

  if ((%user.flag != monster) && (%target.flag != monster)) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, OnlyTauntMonsters), private) | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, Can'tTauntWhiledead), private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, Can'tTauntSomeoneWhoIsDead), private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { $display.system.message($readini(translation.dat, errors, Can'tTauntSomeoneWhoFled), private) | unset %real.name | halt } 

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
  $set_chr_name($1) 

  $display.system.message(2 $+ %real.name looks at $set_chr_name($2) %real.name and says " $+ $read taunts.txt $+ "  %style.rating, battle) 

  ; Now do a random effect to the monster.
  var %taunt.effect $rand(1,7)

  if (%taunt.effect = 1) { var %taunt.str $readini($char($2), battle, str) | inc %taunt.str $rand(1,2) | writeini $char($2) battle str %taunt.str | $set_chr_name($2) | $display.system.message($readini(translation.dat, battle, TauntRage), battle) }
  if (%taunt.effect = 2) { var %taunt.def $readini($char($2), battle, def) | inc %taunt.def $rand(1,2) | writeini $char($2) battle def %taunt.def | $set_chr_name($2) | $display.system.message($readini(translation.dat, battle, TauntDefensive), battle) }
  if (%taunt.effect = 3) { var %taunt.int $readini($char($2), battle, int) | dec %taunt.int 1 | writeini $char($2) battle int %taunt.int | $set_chr_name($2) | $display.system.message($readini(translation.dat, battle, TauntClueless), battle) }
  if (%taunt.effect = 4) { var %taunt.str $readini($char($2), battle, str) | dec %taunt.str 1 | writeini $char($2) battle str %taunt.str | $set_chr_name($2) | $display.system.message($readini(translation.dat, battle, TauntTakenAback), battle) }
  if (%taunt.effect = 5) { $set_chr_name($2) | $display.system.message($readini(translation.dat, battle, TauntBored), battle) }
  if (%taunt.effect = 6) { $restore_hp($2, $rand(1,10)) | $set_chr_name($2) |  $display.system.message($readini(translation.dat, battle, TauntLaugh), battle) | unset %taunt.hp }
  if (%taunt.effect = 7) { $restore_tp($2, 5) | $set_chr_name($2) | $display.system.message($readini(translation.dat, battle, TauntSmile), battle) }

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

  $checkchar($2)

  if ($2 = $1) { $display.system.message($readini(translation.dat, errors, CannotGiveToYourself), private) | halt }

  var %flag $readini($char($2), Info, Flag)
  if (%flag != $null) { $display.system.message($readini(translation.dat, errors, Can'tGiveToNonChar), private) | halt }

  var %check.item.give $readini($char($1), Item_Amount, $4) 

  if ((%check.item.give <= 0) || (%check.item.give = $null)) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoesNotHaveThatItem), private) | halt }
  if ((. isin $3) || ($3 <= 0)) { $display.system.message($readini(translation.dat, errors, Can'tGiveNegativeItem), private) | halt }
  if ($3 > %check.item.give) { $display.system.message($readini(translation.dat, errors, CannotGiveThatMuchofItem), private) | halt }

  var %equipped.accessory $readini($char($1), equipment, accessory)
  if (%equipped.accessory = $4) {
    if (%check.item = 1) { $display.system.message($readini(translation.dat, errors, StillWearingAccessory), private) | halt }
  }

  ; If so, decrease the amount
  dec %check.item.give $3
  writeini $char($1) item_amount $4 %check.item.give

  var %target.items $readini($char($2), item_amount, $4)
  inc %target.items $3 
  writeini $char($2) item_amount $4 %target.items

  $display.system.message($readini(translation.dat, system, GiveItemToTarget), global)

  var %number.of.items.given $readini($char($1), stuff, ItemsGiven)
  if (%number.of.items.given = $null) { var %number.of.items.given 0 }
  inc %number.of.items.given $3
  writeini $char($1) stuff ItemsGiven %number.of.items.given
  $achievement_check($1, Santa'sLittleHelper)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SCOREBOARD COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 3:TEXT:!scoreboard:*: {
  if (%battleis != on) { $generate.scoreboard }
  else { $display.system.message($readini(translation.dat, errors, ScoreBoardNotDuringBattle), private) | halt }
}

on 3:TEXT:!score*:*: {
  if ($2 = $null) { 
    var %score $get.score($nick)
    $set_chr_name($nick) | $display.system.message($readini(translation.dat, system, CurrentScore), private)
  }
  else {
    $checkchar($2) 
    var %flag $readini($char($2), info, flag)
    if ((%flag = monster) || (%flag = npc)) { display.system.message($readini(translation.dat, errors, SkillCommandOnlyOnPlayers), private) | halt }
    var %score $get.score($2)
    $set_chr_name($2) | $display.system.message($readini(translation.dat, system, CurrentScore), private)
  }
}

on 3:TEXT:!deathboard*:*: {
  if (%battleis != on) { 
    if ((($2 = monster) || ($2 = mon) || ($2 = monsters))) { $generate.monsterdeathboard }
    if (($2 = boss) || ($2 = bosses)) { $generate.bossdeathboard } 
    if ($2 = $null) { $display.system.message(4!deathboard <monster/boss>, private) | halt }
  }
  else { $display.system.message($readini(translation.dat, errors, DeathBoardNotDuringBattle), private) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; DIFFICULTY CMNDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 3:TEXT:!view difficulty*:*:{   $set_chr_name($nick) | $checkchar($nick) 
  var %saved.difficulty $readini($char($nick), info, difficulty)
  if (%saved.difficulty = $null) { var %saved.difficulty 0 }
  $display.system.message($readini(translation.dat, system, ViewDifficulty), private)
}

on 3:TEXT:!save difficulty*:*:{   $set_chr_name($nick) | $checkchar($nick) 
  if ($3 !isnum) { $display.system.message($readini(translation.dat, errors, DifficultyMustBeNumber),private) | halt }
  if (. isin $3) { $display.system.message($readini(translation.dat, errors, DifficultyMustBeNumber),private) | halt }
  if ($3 < 0) { $display.system.message($readini(translation.dat, errors, DifficultyCan'tBeNegative),private) | halt }
  if ($3 > 200) { $display.system.message($readini(translation.dat, errors, DifficultyCan'tBeOver200),private) | halt }

  writeini $char($nick) info difficulty $3
  $display.system.message($readini(translation.dat, system, SaveDifficulty), global)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; AUGMENT CMNDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

on 3:TEXT:!runes*:#:{ 
  if ($2 != $null) { $checkchar($2)
    $runes.list($2) | $set_chr_name($2) 
    if (%runes.list != $null) { $display.system.message($readini(translation.dat, system, ViewRunes), private) |  unset %runes.list }
    else { $display.system.message($readini(translation.dat, system, HasNoRunes), private) }
  }
  else { 
    $runes.list($nick) | $set_chr_name($nick) 
    if (%runes.list != $null) { $display.system.message($readini(translation.dat, system, ViewRunes), private) | unset %runes.list }
    else { $display.system.message($readini(translation.dat, system, HasNoRunes), private) }
  }
}
on 3:TEXT:!runes*:?:{ 
  if ($2 != $null) { $checkchar($2)
    $runes.list($2) | $set_chr_name($2) 
    if (%runes.list != $null) { .msg $nick $readini(translation.dat, system, ViewRunes) |  unset %runes.list }
    else { .msg $nick $readini(translation.dat, system, HasNoRunes) }
  }
  else { 
    $runes.list($nick) | $set_chr_name($nick) 
    if (%runes.list != $null) { .msg $nick $readini(translation.dat, system, ViewRunes) | unset %runes.list }
    else { .msg $nick $readini(translation.dat, system, HasNoRunes) }
  }
}
on 3:TEXT:!augment*:*:{ 
  if ($2 = $null) { $augments.list($nick) }

  if ($2 = list) { 
    if ($3 = $null) { $augments.list($nick) }
    if ($3 != $null) { $checkchar($3) | $augments.list($3) }
  }

  if ($2 = strength) { 
    if ($3 = $null) { $augments.strength($nick) }
    if ($3 != $null) { $checkchar($3) |  $augments.strength($3) }
  }

  if ($2 = add) { 
    if ($3 = $null) { $display.system.message($readini(translation.dat, errors, AugmentAddCmd), private) | halt }
    if ($4 = $null) {  $display.system.message($readini(translation.dat, errors, AugmentAddCmd), private) | halt }

    ; does the player own that weapon?
    var %player.weapon.check $readini($char($nick), weapons, $3)

    if ((%player.weapon.check < 1) || (%player.weapon.check = $null)) {  $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, DoNotHaveWeapon), private) | halt }

    ; Check to see if weapon is already augmented.  
    var %current.augment $readini($char($nick), augments, $3)

    if (%current.augment != $null) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, AugmentWpnAlreadyAugmented), private) | halt }

    ; Check to see if person has rune
    var %rune.amount $readini($char($nick), item_amount, $4) 

    if ((%rune.amount < 1) || (%rune.amount = $null)) { $set_chr_name($nick) |  $display.system.message($readini(translation.dat, errors, DoNotHaveRune), private) | halt }

    ; Augment the weapon
    set %augment.name $readini(items.db, $4, augment)
    writeini $char($nick) augments $3 %augment.name
    dec %rune.amount 1 | writeini $char($nick) item_amount $4 %rune.amount

    $set_chr_name($nick) | $display.system.message($readini(translation.dat, system, WeaponAugmented), global)

    var %number.of.augments $readini($char($nick), stuff, WeaponsAugmented)
    if (%number.of.augments = $null) { var %number.of.augments 0 }
    inc %number.of.augments 1
    writeini $char($nick) stuff WeaponsAugmented %number.of.augments
    $achievement_check($nick, NowYou'rePlayingWithPower)

    unset %augment.name
  }

  if ($2 = remove) { 
    if ($3 = $null) { $display.system.message($readini(translation.dat, errors, AugmentRemoveCmd), private) | halt }

    var %player.weapon.check $readini($char($nick), weapons, $3)
    if ((%player.weapon.check < 1) || (%player.weapon.check = $null)) {  $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, DoNotHaveWeapon), private) | halt }

    ; Check to see if weapon is augmented or not.  
    var %current.augment $readini($char($nick), augments, $3)
    if (%current.augment = $null) {  $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, AugmentWpnNotAugmented), private) | halt }

    ; Remove augment.
    remini $char($nick) augments $3 
    $set_chr_name($nick) | $display.system.message($readini(translation.dat, system, WeaponDeAugmented), global)
  }
}

alias augments.list {
  ; Check for augments
  $weapons.get.list($1)
  unset %weapon.list | var %number.of.weapons $numtok(%base.weapon.list, 46)

  var %value 1
  while (%value <= %number.of.weapons) {
    set %weapon.name $gettok(%base.weapon.list, %value, 46)
    set %weapon_augment $readini($char($1), augments, %weapon.name)

    if (%weapon_augment != $null) { 
      var %weapon_to_add  $+ %weapon.name $+ $chr(040) $+ %weapon_augment $+ $chr(041) $+ 
      %weapon.list = $addtok(%weapon.list,%weapon_to_add,46)
    }
    inc %value 1 
  }
  unset %value | unset %weapon.name | unset %weapon_level | unset %number.of.weapons

  if (%weapon.list = $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, NoAugments), private) | halt }

  if ($chr(046) isin %weapon.list) { set %replacechar $chr(044) $chr(032)
    %weapon.list = $replace(%weapon.list, $chr(046), %replacechar)
  }
  $set_chr_name($1) | $display.system.message($readini(translation.dat, system, ListOfAugments), private)
}

alias augments.strength {
  ; CHECKING AUGMENTS
  unset %augment.list | unset %augment.list.2 | unset %augment.list.3

  var %value 1 | var %augments.lines $lines(augments.lst)
  if ((%augments.lines = $null) || (%augments.lines = 0)) { return }

  while (%value <= %augments.lines) {

    var %augment.name $read -l $+ %value augments.lst

    if ($augment.check($1, %augment.name) = true) {

      if ($numtok(%augment.list,46) <= 11) { %augment.list = $addtok(%augment.list, %augment.name $+ [ $+ %augment.strength $+ ], 46) }
      else { 
        if ($numtok(%augment.list.2,46) >= 11) { %augment.list.3 = $addtok(%augment.list.3, %augment.name $+ [ $+ %augment.strength $+ ], 46) }
        else { %augment.list.2 = $addtok(%augment.list.2, %augment.name $+ [ $+ %augment.strength $+ ], 46) }
      }
    }
    unset %augment.strength
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %augment.list ) { set %replacechar $chr(044) $chr(032)
    %augment.list = $replace(%augment.list, $chr(046), %replacechar)
  }

  if ($chr(046) isin %augment.list.2 ) { set %replacechar $chr(044) $chr(032)
    %augment.list.2 = $replace(%augment.list.2, $chr(046), %replacechar)
  }

  if ($chr(046) isin %augment.list.3 ) { set %replacechar $chr(044) $chr(032)
    %augment.list.3 = $replace(%augment.list.3, $chr(046), %replacechar)
  }

  if (%augment.list != $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, system, augmentList), private)
    if (%augment.list.2 != $null) { $display.system.message(3 $+ %augment.list.2, private) }
    if (%augment.list.3 != $null) { $display.system.message(3 $+ %augment.list.3, private) }
  }
  if (%augment.list = $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, system, Noaugments), private) }
  unset %augment.list | unset %augment.list.2 | unset %augment.list.3
}
