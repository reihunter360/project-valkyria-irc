battle.version { return 2.0beta_040113 } 
quitmsg { return Battle Arena version $battle.version written by James  "Iyouboushi" }
checkscript {
  var %command $1-
  %command = $remove(%command,$set_chr_name)
  %command = $remove(%command,$chr(36) $+ 1, $chr(36) $+ 2, $chr(36) $+ 3, $chr(36) $+ 4, $chr(36) $+ 5)
  %command = $remove(%command,$chr(36) $+ set_chr_name())
  %command = $remove(%command,$chr(36) $+ $chr(43))
  %command = $replacex(%command,$chr(36) $+ gender(),OK))
  %command = $replacex(%command,$chr(36) $+ gender2(),OK))
  %command = $replacex(%command,$chr(36) $+ gender3(),OK))
  if ($chr(47) $+ set isin %command) { .msg $nick $readini(translation.dat, errors, NoScriptsWithCommands) | halt }
  if (| isin %command) { .msg $nick $readini(translation.dat, errors, NoScriptsWithCommands) | halt }
  if (($chr(36) $+ readini isin %command) || ($chr(36) $+ decode isin $1-)) { .msg $nick $readini(translation.dat, errors, NoScriptsWithCommands) | halt }
  if (writeini isin %command) {  .msg $nick $readini(translation.dat, errors, NoScriptsWithCommands) | halt }
  if (encode isin %command) {  .msg $nick $readini(translation.dat, errors, NoScriptsWithCommands) | halt }
  if (decode isin %command) {  .msg $nick $readini(translation.dat, errors, NoScriptsWithCommands) | halt }
  if ($chr(36) isin %command) {  .msg $nick $readini(translation.dat, errors, NoScriptsWithCommands) | halt }
  return
}
checkchar {
  var %check $readini($char($1), Stuff, ShopLevel)
  if (%check = $null) { $display.system.message($readini(translation.dat, errors, NotInDataBank), private) | halt }
  else { return }
}
check.allied.notes {
  var %allied.notes $readini($char($1), stuff, alliednotes) 
  if (%allied.notes = $null) { var %allied.notes no }
  $set_chr_name($1) 
  if ($readini(system.dat, system, botType) = IRC) {
    if ($2 = channel) {  query %battlechan $readini(translation.dat, system, ViewAlliedNotes) } 
    else { .msg $nick $readini(translation.dat, system, ViewAlliedNotes) }
  }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($nick, $readini(translation.dat, system, ViewAlliedNotes)) }

  unset %real.name | unset %hstats 
}
lookat {
  $weapon_equipped($1) | $set_chr_name($1)
  var %equipped.accessory $readini($char($1), equipment, accessory) 
  if (%equipped.accessory = $null) { var %equipped.accessory nothing }
  var %equipped.armor.head $readini($char($1), equipment, head) 
  if (%equipped.armor.head = $null) { var %equipped.armor.head nothing }
  var %equipped.armor.body $readini($char($1), equipment, body) 
  if (%equipped.armor.body = $null) { var %equipped.armor.body nothing }
  var %equipped.armor.legs $readini($char($1), equipment, legs) 
  if (%equipped.armor.legs = $null) { var %equipped.armor.legs nothing }
  var %equipped.armor.feet $readini($char($1), equipment, feet) 
  if (%equipped.armor.feet = $null) { var %equipped.armor.feet nothing }
  var %equipped.armor.hands $readini($char($1), equipment, hands) 
  if (%equipped.armor.hands = $null) { var %equipped.armor.hands nothing }
  if ($readini(system.dat, system, botType) = IRC) { 
    if ($2 = channel) {  /.timerDisplayLook $+ $nick 1 1 query %battlechan 3 $+ %real.name is wearing %equipped.armor.head on $gender($1) head, %equipped.armor.body on $gender($1) body, %equipped.armor.legs on $gender($1) legs, %equipped.armor.feet on $gender($1) feet, %equipped.armor.hands on $gender($1) hands. %real.name also has %equipped.accessory equipped as an accessory and is currently using the %weapon.equipped weapon. }
    if ($2 != channel) {  /.timerDisplayLook $+ $nick 1 1 .msg $nick 3 $+ %real.name is wearing %equipped.armor.head on $gender($1) head, %equipped.armor.body on $gender($1) body, %equipped.armor.legs on $gender($1) legs, %equipped.armor.feet on $gender($1) feet, %equipped.armor.hands on $gender($1) hands. %real.name also has %equipped.accessory equipped as an accessory and is currently using the %weapon.equipped weapon. }
  }
  if ($readini(system.dat, system, botType) = DCCchat) {
    var %look.message 3 $+ %real.name is wearing %equipped.armor.head on $gender($1) head, %equipped.armor.body on $gender($1) body, %equipped.armor.legs on $gender($1) legs, %equipped.armor.feet on $gender($1) feet, %equipped.armor.hands on $gender($1) hands. %real.name also has %equipped.accessory equipped as an accessory and is currently using the %weapon.equipped weapon.
  $dcc.private.message($nick, %look.message) }
}
char { return $mircdir $+ %player_folder $+ $1 $+ .char }
boss { return $mircdir $+ %boss_folder $+ $1 $+ .char } 
mon { return $mircdir $+ %monster_folder $+ $1 $+ .char }
npc { return $mircdir $+ %npc_folder $+ $1 $+ .char }
summon { return $mircdir $+ %summon_folder $+ $1 $+ .char } 
zapped { return $mircdir $+ %player_folder $+ zapped $+ \ $+ $1 $+ .char }
char_path { return $mircdir $+ %player_folder }
mon_path { return $mircdir $+ %monster_folder }
boss_path { return $mircdir $+ %boss_folder }
npc_path { return $mircdir $+ %npc_folder }
password { set %password $readini($char($1), n, Info, Password) }
passhurt { set %passhurt $readini($char($1), Info, Passhurt) | return }
userlevel { set %userlevel $readini($char($1), Info, user) | return }
clr_passhurt { writeini $char($1) Info Passhurt 0 | unset %passhurt | return }
gender { return $readini($char($1), Info, Gender) }
gender2 {
  if ($gender($1) = her) { return her }
  if ($gender($1) = its) { return it }
  else { return him }
}
gender3 {
  if ($gender($1) = her) { return she }
  if ($gender($1) = its) { return it }
  else { return he }
}
get.level {
  var %str $readini($char($1),battle, str)
  var %def $readini($char($1), battle, def)
  var %int $readini($char($1), battle, int)
  var %spd $readini($char($1), battle, spd)

  var %level %str
  inc %level %def
  inc %level %int
  inc %level %spd

  var %level $round($calc(%level / 20), 1)

  return %level
}

display.system.message {
  ; $1 = the message
  ; $2 = is a flag for the DCCchat option to determine where it sends the message
  if ($readini(system.dat, system, botType) = IRC) { 
    query %battlechan $1
  }
  if ($readini(system.dat, system, botType) = DCCchat) { 
    if ($2 = private) { $dcc.private.message($nick, $1) }
    if ($2 = battle) { $dcc.battle.message($1) }
    if ($2 = $null) { $dcc.global.message($1) }
    if ($2 = global) { $dcc.global.message($1) }
  }
}
display.private.message {
  if ($readini(system.dat, system, botType) = IRC) {
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) 1 1 /.msg $nick $1 
  }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($nick, $1) }
}

get.unspentpoints {
  ; $1 = monster
  ; $2 = level it should be
  ; $3 = type of battle

  var %str $readini($char($1), basestats, str)
  var %def $readini($char($1), basestats, def)
  var %int $readini($char($1), basestats, int)
  var %spd $readini($char($1), basestats, spd)

  var %total.points.spent %str
  inc %total.points.spent %def
  inc %total.points.spent %int
  inc %total.points.spent %spd

  if ($isfile($boss($1)) = $true) {  var %points.per.level $rand(19,22) | var %points.should.have.spent $round($calc(%points.per.level * $2),0) }
  if ($isfile($mon($1)) = $true) {   
    if ($2 < 10) { var %points.should.have.spent $round($calc(10 * $2),0) } 
    if ($2 >= 10) { var %points.should.have.spent $round($calc(20 * $2),0) }
  }
  if ($isfile($npc($1)) = $true) {   var %points.should.have.spent $round($calc(17 * $2),0) }
  if ($isfile($summon($4)) = $true) {   var %points.should.have.spent $round($calc(19 * $2),0) }

  if ($3 = doppelganger) { var %points.should.have.spent $round($calc(20 * $2),0) }
  if ($3 = demonwall) { var %points.should.have.spent $round($calc(20 * $2),0) }
  if ($3 = warmachine) { var %points.should.have.spent $round($calc(20 * $2),0) }
  if ($3 = rage) { var %points.should.have.spent $round($calc(1000 * $2),0) }

  var %unspent.points $calc(%points.should.have.spent - %total.points.spent)

  return %unspent.points
}

player.status { unset %all_status | unset %all_skills | $set_chr_name($1) 
  if ($readini($char($1), Battle, Status) = dead) { set %all_status dead | return } 
  else { 
    if ($readini($char($1), Battle, Status) = rage) { $status_message_check(rage) } 
    if ($readini($char($1), Status, poison) = yes) {  $status_message_check(poisoned) }
    if ($readini($char($1), Status, HeavyPoison) = yes) { $status_message_check(poisoned heavily) }
    if ($readini($char($1), Status, Poison-heavy) = yes) { $status_message_check(poisoned heavily) }
    if ($readini($char($1), Status, Blind) = yes) { $status_message_check(blind) } 
    if ($readini($char($1), Status, Regenerating) = yes) { $status_message_check(regenerating) }
    if ($readini($char($1), Status, TPRegenerating) = yes) { $status_message_check(regenerating TP) }
    if ($readini($char($1), Status, Frozen) = yes) { $status_message_check(frozen) } 
    if ($readini($char($1), Status, shock) = yes) { $status_message_check(shocked) } 
    if ($readini($char($1), Status, burning) = yes) { $status_message_check(burning) } 
    if ($readini($char($1), Status, drowning) = yes) { $status_message_check(drowning) } 
    if ($readini($char($1), Status, earth-quake) = yes) { $status_message_check(shaking violently) } 
    if ($readini($char($1), Status, silence) = yes) { $status_message_check(silenced) } 
    if ($readini($char($1), Status, intimidated) = yes) { $status_message_check(intimidated) }
    if ($readini($char($1), Status, weight) = yes) { $status_message_check(weighed down) } 
    if ($readini($char($1), Status, charmed) = yes) { $status_message_check(charmed by $readini($char($1), Status, Charmer)) }
    if ($readini($char($1), Status, amnesia) = yes) { $status_message_check(under amnesia) }
    if ($readini($char($1), status, paralysis) = yes) { $status_message_check(paralyzed) }
    if ($readini($char($1), Status, drunk) = yes) { $status_message_check(drunk) } 
    if ($readini($char($1), status, tornado) = yes) { $status_message_check(caught in a tornado) }
    if ($readini($char($1), status, zombie) = yes) { $status_message_check(a zombie) }
    if ($readini($char($1), status, slow) = yes) { $status_message_check(slowed) }
    if ($readini($char($1), status, sleep) = yes) { $status_message_check(asleep) }
    if ($readini($char($1), status, stun) = yes) { $status_message_check(stunned) }
    if ($readini($char($1), status, stop) = yes) { $status_message_check(frozen in time) }
    if ($readini($char($1), status, virus) = yes) { $status_message_check(inflicted with a virus) }
    if ($readini($char($1), status, curse) = yes) { $status_message_check(cursed) }
    if ($readini($char($1), status, revive) = yes) { $status_message_check(will auto revive) }
    if ($readini($char($1), status, petrified) = yes) { $status_message_check(petrified) }
    if ($readini($char($1), status, bored) = yes) { $status_message_check(bored) }
    if ($readini($char($1), status, confuse) = yes) { $status_message_check(confused) }
    if ($readini($char($1), status, reflect) = yes) { $status_message_check(has a reflective barrier) }
    if ($readini($char($1), skills, drainsamba.on) = on) { $status_message_check(using Drain Samba) }
    if ($readini($char($1), status, defensedown) = on) { $status_message_check(defense down) }
    if ($readini($char($1), status, strengthdown) = on) { $status_message_check(strength down) }
    if ($readini($char($1), status, intdown) = on) { $status_message_check(int down) }
    if ($readini($char($1), status, ethereal) = yes) { $status_message_check(ethereal) }
    if ($readini($char($1), status, ignition.on) = on) { $status_message_check(ignition boosted) }
    if ($readini($char($1), status, shell) = yes) { $status_message_check(shell) }
    if ($readini($char($1), status, protect) = yes) { $status_message_check(protect) }
    if ($readini($char($1), status, resist-fire) = yes) { $status_message_check(resist-fire) }
    if ($readini($char($1), status, resist-earth) = yes) { $status_message_check(resist-earth) }
    if ($readini($char($1), status, resist-wind) = yes) { $status_message_check(resist-wind) }
    if ($readini($char($1), status, resist-ice) = yes) { $status_message_check(resist-ice) }
    if ($readini($char($1), status, resist-water) = yes) { $status_message_check(resist-water) }
    if ($readini($char($1), status, resist-lightning) = yes) { $status_message_check(resist-lightning) }
    if ($readini($char($1), status, resist-light) = yes) { $status_message_check(resist-light) }
    if ($readini($char($1), status, resist-dark) = yes) { $status_message_check(resist-dark) }

    $player.skills.list($1)

    if (%all_status = $null) { %all_status = 3Normal }
    if (%all_skills = $null) { %all_skills = 3None }
    return
  }
  unset %real.name | unset %status 
}

player.skills.list {
  unset %all_skills
  if ($readini($char($1), status, conservetp.on) = on) { $skills_message_check(2conserving TP) }
  if ($readini($char($1), skills, utsusemi.on) = on) { $skills_message_check(2Utsusemi[ $+ $readini($char($1), skills, utsusemi.shadows) $+ ]) }
  if ($readini($char($1), skills, royalguard.on) = on) { $skills_message_check(2Royal Guard) }
  if ($readini($char($1), skills, manawall.on) = on) { $skills_message_check(2Mana Wall) }
  if ($readini($char($1), skills, mightystrike.on) = on) { $skills_message_check(2Mighty Strike) }
  if ($readini($char($1), skills, elementalseal.on) = on) { $skills_message_check(2Elemental Seal) }
  if ($readini($char($1), skills, thirdeye.on) = on) { $skills_message_check(2Third Eye) }
  if ($readini($char($1), skills, konzen-ittai.on) = on) { $skills_message_check(2Konzen-Ittai) }
  if ($readini($char($1), skills, defender.on) = on) { $skills_message_check(2Defender) }
  if ($readini($char($1), skills, aggressor.on) = on) { $skills_message_check(2Aggressor) }

  set %cover.target $readini($char($1), skills, CoverTarget)
  if ((%cover.target != $null) && (%cover.target != none)) { $skills_message_check(2Covered by %cover.target) }

  unset %cover.target
}

status_message_check { 
  if (%all_status = $null) { %all_status = 4 $+ $1- | return }
  else { %all_status = 4 $+ %all_status $+ $chr(0160) $+ 3 $+ $chr(124) $+ 4 $+ $chr(0160) $+ $1- | return }
}
skills_message_check { 
  if (%all_skills = $null) { %all_skills = 4 $+ $1- | return }
  else { %all_skills = 4 $+ %all_skills $+ $chr(0160) $+ 3 $+ $chr(124) $+ 4 $+ $chr(0160) $+ $1- | return }
}

is_charmed {
  if ($readini($char($1), status, charmed) = yes) { return true }
  else { return false }
}

is_confused {
  if ($readini($char($1), status, confuse) = yes) { return true }
  else { return false }
}

amnesia.check {
  var %amnesia.check $readini($char($1), status, amnesia)
  if (%amnesia.check = no) { return }
  else { 
    $set_chr_name($1) 
    if ($readini(system.dat, system, botType) = IRC) {  query %battlechan $readini(translation.dat, status, CurrentlyAmnesia) }
    if ($readini(system.dat, system, botType) = DCCchat { $dcc.battle.message($readini(translation.dat, status, CurrentlyAmnesia) }
    halt 
  }
}

id_login { set %idwho $1 | unset %newbie | unset %password | unset %userlevel | unset %character.description | .dns %idwho | $clr_passhurt($1) | writeini $char($1) Info LastSeen $fulldate | .close -m* |  unset %guess  | unset %gender | halt }
okdesc { 
  if ($readini(system.dat, system, botType) = IRC) { .msg $1 $readini(translation.dat, system,OKDesc) }
  if ($readini(system.dat, system, botType) = DCCchat { $dcc.private.message($1, $readini(translation.dat, system,OKDesc))  }
  return 
}
set_chr_name {
  set %real.name $readini($char($1), BaseStats, Name)
  if (%real.name = $null) { set %real.name $1 | return }
  else { return }
}

battle_stats { set %str $readini($char($1), Battle, Str) | set %def $readini($char($1), Battle, Def) | set %int $readini($char($1), Battle, int) | set %spd $readini($char($1), Battle, spd) | return }  
build_battlehp_list {
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
}
weapon_equipped { set %weapon.equipped $readini($char($1), Weapons, Equipped) | return }
weapon.list { 
  $weapons.get.list($1)

  ; CLEAN UP THE LIST
  if ($chr(046) isin %weapon.list) { set %replacechar $chr(044) $chr(032)
    %weapon.list = $replace(%weapon.list, $chr(046), %replacechar)
  }

  return
}
weapons.get.list { 
  unset %weapon.list | unset %weapons | unset %number.of.weapons | unset %base.weapon.list
  set %weapons $readini(weapons.db, Weapons, HandToHand)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Swords)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Whips)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Guns)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Wands)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Katanas)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Spears)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Scythes)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, GreatSwords)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Axes)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Daggers)

  if ($readini($char($1), info, flag) = $null) {  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Glyphs) }
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Rifles)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Bows)
  set %weapons2 $readini(weapons.db, Weapons, MonsterWpns)
  set %weapons3 $readini(weapons.db, Weapons, MonsterWpns2)
  set %weapons4 $readini(weapons.db, Weapons, MonsterWpns3)
  set %weapons5 $readini(weapons.db, Weapons, MonsterWpns4)
  var %number.of.weapons $numtok(%weapons, 46)

  var %value 1
  while (%value <= %number.of.weapons) {
    set %weapon.name $gettok(%weapons, %value, 46)
    set %weapon_level $readini($char($1), weapons, %weapon.name)

    if ((%weapon_level != $null) && (%weapon_level >= 1)) { 
      ; add the weapon level to the weapon list
      var %weapon_to_add  $+ %weapon.name $+ $chr(040) $+ %weapon_level $+ $chr(041) $+ 
      %weapon.list = $addtok(%weapon.list,%weapon_to_add,46)
      %base.weapon.list = $addtok(%base.weapon.list, %weapon.name, 46)
    }
    inc %value 1 
  }
  unset %value | unset %weapon.name | unset %weapon_level | unset %number.of.weapons

  var %number.of.weapons $numtok(%weapons2, 46)
  var %value 1
  while (%value <= %number.of.weapons) {
    set %weapon.name $gettok(%weapons2, %value, 46)
    set %weapon_level $readini($char($1), weapons, %weapon.name)

    if ((%weapon_level != $null) && (%weapon_level >= 1)) { 
      ; add the weapon level to the weapon list
      var %weapon_to_add  $+ %weapon.name $+ $chr(040) $+ %weapon_level $+ $chr(041) $+ 
      %weapon.list = $addtok(%weapon.list,%weapon_to_add,46)
      %base.weapon.list = $addtok(%base.weapon.list, %weapon.name, 46)
    }
    inc %value 1 
  }
  unset %value | unset %weapon.name | unset %weapon_level | unset %weapons2

  var %number.of.weapons $numtok(%weapons3, 46)
  var %value 1
  while (%value <= %number.of.weapons) {
    set %weapon.name $gettok(%weapons3, %value, 46)
    set %weapon_level $readini($char($1), weapons, %weapon.name)

    if ((%weapon_level != $null) && (%weapon_level >= 1)) { 
      ; add the weapon level to the weapon list
      var %weapon_to_add  $+ %weapon.name $+ $chr(040) $+ %weapon_level $+ $chr(041) $+ 
      %weapon.list = $addtok(%weapon.list,%weapon_to_add,46)
      %base.weapon.list = $addtok(%base.weapon.list, %weapon.name, 46)
    }
    inc %value 1 
  }
  unset %value | unset %weapon.name | unset %weapon_level | unset %weapons3

  var %number.of.weapons $numtok(%weapons4, 46)
  var %value 1
  while (%value <= %number.of.weapons) {
    set %weapon.name $gettok(%weapons4, %value, 46)
    set %weapon_level $readini($char($1), weapons, %weapon.name)

    if ((%weapon_level != $null) && (%weapon_level >= 1)) { 
      ; add the weapon level to the weapon list
      var %weapon_to_add  $+ %weapon.name $+ $chr(040) $+ %weapon_level $+ $chr(041) $+ 
      %weapon.list = $addtok(%weapon.list,%weapon_to_add,46)
      %base.weapon.list = $addtok(%base.weapon.list, %weapon.name, 46)
    }
    inc %value 1 
  }
  unset %value | unset %weapon.name | unset %weapon_level | unset %weapons4

  var %number.of.weapons $numtok(%weapons5, 46)
  var %value 1
  while (%value <= %number.of.weapons) {
    set %weapon.name $gettok(%weapons5, %value, 46)
    set %weapon_level $readini($char($1), weapons, %weapon.name)

    if ((%weapon_level != $null) && (%weapon_level >= 1)) { 
      ; add the weapon level to the weapon list
      var %weapon_to_add  $+ %weapon.name $+ $chr(040) $+ %weapon_level $+ $chr(041) $+ 
      %weapon.list = $addtok(%weapon.list,%weapon_to_add,46)
      %base.weapon.list = $addtok(%base.weapon.list, %weapon.name, 46)
    }
    inc %value 1 
  }
  unset %value | unset %weapon.name | unset %weapon_level | unset %weapons5

  return
}

styles.list { 
  set %styles.list $styles.get.list($1)

  ; CLEAN UP THE LIST
  if ($chr(046) isin %styles.list) { set %replacechar $chr(044) $chr(032)
    %styles.list = $replace(%styles.list, $chr(046), %replacechar)
  }
  return
}
styles.get.list { 
  unset %styles.list | unset %styles | unset %number.of.styles
  set %styles $readini(playerstyles.lst, styles, list)
  var %number.of.styles $numtok(%styles, 46)

  var %value 1
  while (%value <= %number.of.styles) {
    set %style.name $gettok(%styles, %value, 46)
    set %style_level $readini($char($1), styles, %style.name)

    if (%style_level = $null) {
      if (%style.name = Trickster) { writeini $char($1) styles Trickster 1 | writeini $char($1) styles TricksterXP 0 }
      if (%style.name = WeaponMaster) { writeini $char($1) styles WeaponMaster 1 | writeini $char($1) styles WeaponMasterXP 0 }
      if (%style.name = Guardian) { writeini $char($1) styles Guardian 1 | writeini $char($1) styles GuardianXP 0 }
    }

    if ((%style_level != $null) && (%style_level >= 1)) { 
      ; add the style level to the weapon list
      var %style_to_add  $+ %style.name $+ $chr(040) $+ %style_level $+ $chr(041) $+ 
      %styles.list = $addtok(%styles.list,%style_to_add,46)
    }

    inc %value 1 
  }

  if ($readini($char($1), styles, equipped) = $null) { writeini $char($1) styles equipped Trickster }
  unset %value | unset %weapon.name | unset %weapon_level
  return %styles.list
}

ignition.list {
  unset %ignitionss.list
  set %ignitions.list $ignitions.get.list($1)
  return
}
ignitions.get.list { 
  unset %ignitions.list | unset %ignitions | unset %number.of.ignitions
  var %ignitions $readini(ignitions.db, ignitions, list)
  var %number.of.ignitions $numtok(%ignitions, 46)
  var %value 1
  while (%value <= %number.of.ignitions) {
    set %ignition.name $gettok(%ignitions, %value, 46)
    set %ignition_level $readini($char($1), ignitions, %ignition.name)
    if ((%ignition_level != $null) && (%ignition_level >= 1)) { 
      ; add the ignition to the list
      var %ignition_to_add %ignition.name
      %ignitions.list = $addtok(%ignitions.list,%ignition_to_add,46)
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %ignitions.list) { set %replacechar $chr(044) $chr(032)
    %ignitions.list = $replace(%ignitions.list, $chr(046), %replacechar)
  }

  unset %value | unset %ignition.name | unset %ignition_level
  return %ignitions.list
}

tech.list {
  unset %techs.list
  set %techs.list $techs.get.list($1, $2)
  return
}
techs.get.list { 
  unset %tech.list | unset %techs | unset %number.of.techs
  var %techs $readini(techniques.db, techs, $2)
  var %number.of.techs $numtok(%techs, 46)
  var %value 1
  while (%value <= %number.of.techs) {
    set %tech.name $gettok(%techs, %value, 46)
    set %tech_level $readini($char($1), techniques, %tech.name)
    if ((%tech_level != $null) && (%tech_level >= 1)) { 
      ; add the tech level to the tech list
      var %tech_to_add %tech.name $+ $chr(040) $+ %tech_level $+ $chr(041)
      %tech.list = $addtok(%tech.list,%tech_to_add,46)
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %tech.list) { set %replacechar $chr(044) $chr(032)
    %tech.list = $replace(%tech.list, $chr(046), %replacechar)
  }

  unset %value | unset %tech.name | unset %tech_level
  return %tech.list
}

skills.list {
  $passive.skills.list($1)
  $active.skills.list($1)
  set %resists.skills.list $resists.skills.list($1)
  unset %total.skills | unset %skill.name | unset %skill_level | unset %replacechar
  return
}

passive.skills.list { 
  ; CHECKING PASSIVE SKILLS
  unset %passive.skills.list | unset %passive.skills.list2 | unset %total.skills
  var %passive.skills $readini(skills.db, Skills, PassiveSkills)
  var %number.of.skills $numtok(%passive.skills, 46)

  var %value 1
  while (%value <= %number.of.skills) {
    set %skill.name $gettok(%passive.skills, %value, 46)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      inc %total.skills 1
      if (%total.skills > 13) {  %passive.skills.list2 = $addtok(%passive.skills.list2,%skill_to_add,46) }
      else {  %passive.skills.list = $addtok(%passive.skills.list,%skill_to_add,46) }
    }
    inc %value 1
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %passive.skills.list) { set %replacechar $chr(044) $chr(032)
    %passive.skills.list = $replace(%passive.skills.list, $chr(046), %replacechar)
  }
  if ($chr(046) isin %passive.skills.list2) { set %replacechar $chr(044) $chr(032)
    %passive.skills.list2 = $replace(%passive.skills.list2, $chr(046), %replacechar)
  }

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value 
}

active.skills.list {
  ; CHECKING ACTIVE SKILLS
  unset %active.skills.list | unset %active.skills.list2 | unset %total.skills
  var %active.skills $readini(skills.db, Skills, activeSkills)
  var %number.of.skills $numtok(%active.skills, 46)

  var %value 1
  while (%value <= %number.of.skills) {
    set %skill.name $gettok(%active.skills, %value, 46)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      inc %total.skills 1
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      if (%total.skills > 13) { %active.skills.list2 = $addtok(%active.skills.list2,%skill_to_add,46) }
      else { %active.skills.list = $addtok(%active.skills.list,%skill_to_add,46) }
    }
    inc %value 1 
  }

  var %active.skills $readini(skills.db, Skills, activeSkills2)
  var %number.of.skills $numtok(%active.skills, 46)
  var %value 1
  while (%value <= %number.of.skills) {
    set %skill.name $gettok(%active.skills, %value, 46)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      inc %total.skills 1
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      if (%total.skills > 13) { %active.skills.list2 = $addtok(%active.skills.list2,%skill_to_add,46) }
      else { %active.skills.list = $addtok(%active.skills.list,%skill_to_add,46) }
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %active.skills.list) { set %replacechar $chr(044) $chr(032)
    %active.skills.list = $replace(%active.skills.list, $chr(046), %replacechar)
  }
  if ($chr(046) isin %active.skills.list2) { set %replacechar $chr(044) $chr(032)
    %active.skills.list2 = $replace(%active.skills.list2, $chr(046), %replacechar)
  }

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
}

resists.skills.list { 
  ; CHECKING RESISTANCE SKILLS
  unset %resists.skills.list
  var %resists.skills $readini(skills.db, Skills, Resists)
  var %number.of.skills $numtok(%resists.skills, 46)

  var %value 1
  while (%value <= %number.of.skills) {
    set %skill.name $gettok(%resists.skills, %value, 46)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      %resists.skills.list = $addtok(%resists.skills.list,%skill_to_add,46)
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %resists.skills.list) { set %replacechar $chr(044) $chr(032)
    %resists.skills.list = $replace(%resists.skills.list, $chr(046), %replacechar)
  }

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  return %resists.skills.list
}

keys.list {
  unset %items.list | unset %gems.items.list | unset %summons.items.list | unset %keys.items.list | unset %misc.items.list | unset %reset.items.list 

  ; CHECKING KEYS 
  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  var %keys.items $readini(items.db, items, Keys)
  var %number.of.items $numtok(%keys.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%keys.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 14 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %keys.items.list = $addtok(%keys.items.list,%item_to_add,46)
    }
    inc %value 1 
  }

  if ($chr(046) isin %keys.items.list) { set %replacechar $chr(044) $chr(032)
    %keys.items.list = $replace(%keys.items.list, $chr(046), %replacechar)
  }

}
items.list {
  ; CHECKING HEALING ITEMS
  unset %items.list | unset %gems.items.list | unset %summons.items.list | unset %keys.items.list | unset %misc.items.list | unset %reset.items.list | unset %statplus.items.list
  unset %portals.items.list
  var %healing.items $readini(items.db, items, HealingItems)
  var %number.of.items $numtok(%healing.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%healing.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 3 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %items.list = $addtok(%items.list,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CHECKING CRAFTED ITEMS
  var %crafted.items $readini(items.db, items, CraftedItems)
  var %number.of.items $numtok(%crafted.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%crafted.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      set %item.type $readini(items.db, %item.name, type)
      if (%item.type = damage) {  var %item_to_add 4 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041)  }
      if (%item.type = status) {  var %item_to_add 4 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041)  }
      if ((%item.type = heal) || (%item.type = tp)) {  var %item_to_add 3 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) }
      if ((((%item.type != accessory) && (%item.type != consume) && (%item.type != misc) && (%item.type != summon)))) {  %items.list = $addtok(%items.list,%item_to_add,46) }
    }
    unset %item.type
    inc %value 1 
  }

  ; CHECKING BATTLE & RANDOM ITEMS
  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  var %battle.items $readini(items.db, items, BattleItems) $+ . $+ $readini(items.db, items, Random)
  var %number.of.items $numtok(%battle.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%battle.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 4 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %items.list = $addtok(%items.list,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CHECKING CONSUMABLE ITEMS
  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  var %consume.items $readini(items.db, items, ConsumeItems)
  var %number.of.items $numtok(%consume.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%consume.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 15 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %items.list = $addtok(%items.list,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CHECKING SHOP RESET ITEMS
  unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %reset.items.list
  var %reset.items $readini(items.db, items, ShopReset)
  var %number.of.items $numtok(%reset.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%reset.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 2  $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %reset.items.list = $addtok(%reset.items.list,%item_to_add,46)
    }
    inc %value 1 
  }


  ; CHECKING MISC ITEMS
  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  var %misc.items $readini(items.db, items, Misc)
  var %number.of.items $numtok(%misc.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%misc.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 1 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %misc.items.list = $addtok(%misc.items.list,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CHECKING +STAT ITEMS
  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  var %food.items $readini(items.db, items, FoodItems) 
  var %number.of.items $numtok(%food.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%food.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 12 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %statplus.items.list = $addtok(%statplus.items.list,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CHECKING SUMMON ITEMS
  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  var %summon.items $readini(items.db, items, SummonItems)
  var %number.of.items $numtok(%summon.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%summon.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 10 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %summons.items.list = $addtok(%summons.items.list,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CHECKING GEMS ITEMS
  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  var %gems.items $readini(items.db, items, Gems)
  var %number.of.items $numtok(%summon.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%gems.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 7 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %gems.items.list = $addtok(%gems.items.list,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CHECKING PORTAL ITEMS
  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  var %portal.items $readini(items.db, items, PortalItems)
  var %number.of.items $numtok(%portal.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%portal.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if (%item_amount = 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 14 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %portals.items.list = $addtok(%portals.items.list,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CLEAN UP THE LISTS
  if ($chr(046) isin %items.list) { set %replacechar $chr(044) $chr(032)
    %items.list = $replace(%items.list, $chr(046), %replacechar)
  }

  if ($chr(046) isin %summons.items.list) { set %replacechar $chr(044) $chr(032)
    %summons.items.list = $replace(%summons.items.list, $chr(046), %replacechar)
  }

  if ($chr(046) isin %gems.items.list) { set %replacechar $chr(044) $chr(032)
    %gems.items.list = $replace(%gems.items.list, $chr(046), %replacechar)
  }

  if ($chr(046) isin %keys.items.list) { set %replacechar $chr(044) $chr(032)
    %keys.items.list = $replace(%keys.items.list, $chr(046), %replacechar)
  }

  if ($chr(046) isin %misc.items.list) { set %replacechar $chr(044) $chr(032)
    %misc.items.list = $replace(%misc.items.list, $chr(046), %replacechar)
  }

  if ($chr(046) isin %reset.items.list) { set %replacechar $chr(044) $chr(032)
    %reset.items.list = $replace(%reset.items.list, $chr(046), %replacechar)
  }

  if ($chr(046) isin %statplus.items.list) { set %replacechar $chr(044) $chr(032)
    %statplus.items.list = $replace(%statplus.items.list, $chr(046), %replacechar)
  }

  if ($chr(046) isin %portals.items.list) { set %replacechar $chr(044) $chr(032)
    %portals.items.list = $replace(%portals.items.list, $chr(046), %replacechar)
  }

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %food.items | unset %consume.items
  return
}

armor.list {
  unset %armor.head | unset %armor.body | unset %armor.legs | unset %armor.feet | unset %armor.hands

  ; CHECKING HEAD ARMOR
  var %equipment $readini(items.db, items, HeadEquipment)
  var %number.of.items $numtok(%equipment, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%equipment, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 3 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %armor.head = $addtok(%armor.head,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CHECKING BODY ARMOR
  var %equipment $readini(items.db, items, BodyEquipment)
  var %number.of.items $numtok(%equipment, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%equipment, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 3 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %armor.body = $addtok(%armor.body,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CHECKING LEG ARMOR
  var %equipment $readini(items.db, items, LegsEquipment)
  var %number.of.items $numtok(%equipment, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%equipment, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 3 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %armor.legs = $addtok(%armor.legs,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CHECKING FEET ARMOR
  var %equipment $readini(items.db, items, FeetEquipment)
  var %number.of.items $numtok(%equipment, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%equipment, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 3 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %armor.feet = $addtok(%armor.feet,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CHECKING HAND ARMOR
  var %equipment $readini(items.db, items, HandsEquipment)
  var %number.of.items $numtok(%equipment, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%equipment, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add 3 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %armor.hands = $addtok(%armor.hands,%item_to_add,46)
    }
    inc %value 1 
  }


  ; CLEAN UP THE LISTS
  if ($chr(046) isin %armor.head) { set %replacechar $chr(044) $chr(032)
    %armor.head = $replace(%armor.head, $chr(046), %replacechar)
  }

  if ($chr(046) isin %armor.body) { set %replacechar $chr(044) $chr(032)
    %armor.body = $replace(%armor.body, $chr(046), %replacechar)
  }

  if ($chr(046) isin %armor.legs) { set %replacechar $chr(044) $chr(032)
    %armor.legs = $replace(%armor.legs, $chr(046), %replacechar)
  }

  if ($chr(046) isin %armor.feet) { set %replacechar $chr(044) $chr(032)
    %armor.feet = $replace(%armor.feet, $chr(046), %replacechar)
  }

  if ($chr(046) isin %armor.hands) { set %replacechar $chr(044) $chr(032)
    %armor.hands = $replace(%armor.hands, $chr(046), %replacechar)
  }

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %food.items | unset %consume.items
  return
}

accessories.list {
  ; CHECKING ACCESSORIE
  unset %accessories.list
  var %accessory.items $readini(items.db, items, Accessories)
  var %number.of.items $numtok(%accessory.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%accessory.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %accessories.list = $addtok(%accessories.list,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %accessories.list) { set %replacechar $chr(044) $chr(032)
    %accessories.list = $replace(%accessories.list, $chr(046), %replacechar)
  }

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  return
}

runes.list {
  ; CHECKING RUNES
  unset %runes.list
  var %runes.items $readini(items.db, items, Runes)
  var %number.of.items $numtok(%runes.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%runes.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %runes.list = $addtok(%runes.list,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %runes.list) { set %replacechar $chr(044) $chr(032)
    %runes.list = $replace(%runes.list, $chr(046), %replacechar)
  }

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The fulls command brings
; everyone back to max hp
; and regular stats.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fulls {  
  writeini $char($1) Battle Hp $readini($char($1), BaseStats, HP)
  writeini $char($1) Battle Tp $readini($char($1), BaseStats, TP)
  writeini $char($1) Battle Str $readini($char($1), BaseStats, Str)
  writeini $char($1) Battle Def $readini($char($1), BaseStats, Def)
  writeini $char($1) Battle Int $readini($char($1), BaseStats, Int)
  writeini $char($1) Battle Spd $readini($char($1), BaseStats, Spd)
  writeini $char($1) Battle Status alive 

  if ($readini($char($1), BaseStats, IgnitionGauge) = $null) { writeini $char($1) BaseStats IgnitionGauge 0 | writeini $char($1) Battle IgnitionGauge 0 }
  if ($readini($char($1), Battle, IgnitionGauge) = $null) { writeini $char($1) Battle IgnitionGauge 0 }

  $clear_status($1)

  ; If it's not a monster or NPC, we need to clear some more stuff..
  if ($readini($char($1), info, flag) = $null) { 
    $clear_skills($1) | var %stylelist $styles.get.list($1) 
    .remini $char($1) modifiers
  }

  remini $char($1) Renkei

  ; THIS IS A FIX FOR A TYPO 
  var %wizardry $readini($char($1), skills, wizardy)
  if (%wizardry != $null) { writeini $char($1) skills wizardry %wizardry | remini $char($1) skills wizardy }

  $fullNaturalArmor($1)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Refills a char's natural armor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fullNaturalArmor {
  if ($readini($char($1), info, flag) = $null) { return }
  var %naturalArmorMax $readini($char($1), NaturalArmor, Max)
  if (%naturalArmorMax != $null) { writeini $char($1) NaturalArmor Current %naturalArmorMax }
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Turns skills off on chars.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_skills {
  writeini $char($1) skills speed.on no | writeini $char($1) skills doubleturn.on off | writeini $char($1) status charmed no | writeini $char($1) status charmer noonethatIknowlol | writeini $char($1) status charm.timer 0 
  writeini $char($1) skills soulvoice.on off | writeini $char($1) skills manawall.on off | writeini $char($1) skills elementalseal.on off
  writeini $char($1) skills mightystrike.on off | writeini $char($1) skills royalguard.on off |  writeini $char($1) skills drainsamba.turn 0 
  writeini $char($1) skills drainsamba.on off | writeini $char($1) skills utsusemi.on off |  writeini $char($1) skills utsusemi.shadows 0 
  writeini $char($1) skills Quicksilver.turn -1 | writeini $char($1) skills Quicksilver.used 0 | writeini $char($1) skills CoverTarget none
  remini $char($1) skills PerfectCounter.on | writeini $char($1) skills aggressor.on off | writeini $char($1) skills defender.on off
  writeini $char($1) skills konzen-ittai.on off |  writeini $char($1) skills thirdeye.on off | writeini $char($1) status thirdeye.turn 0 
  writeini $char($1) skills scavenge.on off
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clears most statuses on
; chars. This is for the 
; clearstatus type items.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_most_status {
  writeini $char($1) Status poison no | writeini $char($1) Status HeavyPoison no | writeini $char($1) Status blind no
  writeini $char($1) Status Heavy-Poison no | writeini $char($1) status poison-heavy no | writeini $char($1) Status curse no 
  writeini $char($1) Status weight no | writeini $char($1) status virus no | writeini $char($1) status poison.timer 0
  writeini $char($1) Status drunk no | writeini $char($1) Status amnesia no | writeini $char($1) status paralysis no | writeini $char($1) status amnesia.timer 1 | writeini $char($1) status paralysis.timer 1 | writeini $char($1) status drunk.timer 1
  writeini $char($1) status zombie no | writeini $char($1) Status slow no | writeini $char($1) Status sleep no | writeini $char($1) Status stun no
  writeini $char($1) status boosted no  | writeini $char($1) status curse.timer 1 | writeini $char($1) status slow.timer 1 | writeini $char($1) status zombie.timer 1
  writeini $char($1) status zombieregenerating no | writeini $char($1) status silence no | writeini $char($1) status petrified no | writeini $char($1) status bored no 
  writeini $char($1) status confuse.timer 1 | writeini $char($1) status defensedown no | writeini $char($1) status defensedown.timer 0 | writeini $char($1) status strengthdown no 
  writeini $char($1) status strengthdown.timer 0 | writeini $char($1) status intdown no | writeini $char($1) status intdown.timer 1
  writeini $char($1) status protect no | writeini $char($1) status shell no | writeini $char($1) status protect.timer 0 | writeini $char($1) status shell.timer 0
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clears statuses on chars
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_status {
  if ($readini($char($1), status, finalgetsuga) = yes) {
    $reset_char($1) | $set_chr_name($1)

    if ($readini(system.dat, system, botType) = IRC) { query %battlechan 4 $+ %real.name feels all of $gender($1) power leaving $gender($1) body, resetting $gender2($1) back to level 1. }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.global.message(4 $+ %real.name feels all of $gender($1) power leaving $gender($1) body, resetting $gender2($1) back to level 1.) }
    unset %real.name
  }

  ; Negative status effects
  writeini $char($1) Status poison no | writeini $char($1) Status HeavyPoison no | writeini $char($1) Status blind no
  writeini $char($1) Status Heavy-Poison no | writeini $char($1) status poison-heavy no | writeini $char($1) Status curse no | writeini $char($1) Status intimidated no
  writeini $char($1) Status weight no | writeini $char($1) status virus no | writeini $char($1) status poison.timer 1 | writeini $char($1) status charmer noOneThatIKnow | writeini $char($1) status charm.timer 0 | writeini $char($1) status charmed no 
  writeini $char($1) Status drunk no | writeini $char($1) Status amnesia no | writeini $char($1) status paralysis no | writeini $char($1) status amnesia.timer 1 | writeini $char($1) status paralysis.timer 1 | writeini $char($1) status drunk.timer 1
  writeini $char($1) status zombie no | writeini $char($1) Status slow no | writeini $char($1) Status sleep no | writeini $char($1) Status stun no | writeini $char($1) status curse.timer 1 | writeini $char($1) status slow.timer 1 | writeini $char($1) status zombie.timer 1
  writeini $char($1) status zombieregenerating no | writeini $char($1) status intimidate no |  writeini $char($1) status defensedown no | writeini $char($1) status strengthdown no
  writeini $char($1) status strengthdown.timer 0 | writeini $char($1) status intdown.timer 0 | writeini $char($1) status defensedown.timer 0 |  writeini $char($1) status stop no | writeini $char($1) status petrified no 
  writeini $char($1) status bored no | writeini $char($1) status bored.timer 0 | remini $char($1) status weapon.locked | writeini $char($1) status confuse no | writeini $char($1) status confuse.timer 1

  ; Positive status effects
  writeini $char($1) Status Regenerating no | writeini $char($1) Status MPRegenerating no | writeini $char($1) Status KiRegenerating no
  writeini $char($1) status boosted no | writeini $char($1) status FinalGetsuga no | writeini $char($1) status revive no  
  writeini $char($1) status TPRegenerating no | writeini $char($1) status conservetp no |   writeini $char($1) status ignition.on off | remini $char($1) status ignition.name | remini $char($1) status ignition.augment
  writeini $char($1) status orbbonus no | writeini $char($1) status protect no | writeini $char($1) status shell no | writeini $char($1) status protect.timer 0 | writeini $char($1) status shell.timer 0

  ; Magic effects  
  writeini $char($1) Status frozen no | writeini $char($1) status freezing no | writeini $char($1) Status shock no | writeini $char($1) Status burning no 
  writeini $char($1) Status drowning no | writeini $char($1) Status tornado no |  writeini $char($1) Status earth-quake no 

  ; The resists are used to resist the magic effect stuff (Freezing, Burning, etc).  Only players need this removed each time.
  if ($readini($char($1), info, flag) = $null) { 
    writeini $char($1) status resist-fire no | writeini $char($1) status resist-lightning no | writeini $char($1) status resist-ice no
    writeini $char($1) status resist-earth no | writeini $char($1) status resist-wind no | writeini $char($1) status resist-water no
    writeini $char($1) status resist-light no | writeini $char($1) status resist-dark no
  }

  ; Monsters that are zombies need to be reset as zombies.
  if ($readini($char($1), monster, type) = zombie) {  writeini $char($1) status zombie yes | writeini $char($1) status zombieregenerating yes } 

  if ($readini($char($1), equipment, accessory) = Fool's-Tablet) {
    writeini $char($1) status poison yes
    writeini $char($1) status poison.timer 0
  }
  if ($readini($char($1), info, flag) = $null) {  writeini $char($1) status ethereal no | writeini $char($1) status reflect no | writeini $char($1) status reflect.timer 1 }
  if ($augment.check($1, AutoReraise) = true) { 
    if (%augment.strength >= 5) { writeini $char($1) status revive yes }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the min streak for
; mons/bosses to show up
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_minimum_streak {
  if ($1 = mon) {
    set %monster.info.streak $readini($mon($2), info, Streak)
  }

  if ($1 = boss) {
    set %monster.info.streak $readini($boss($2), info, Streak)
  }
  if (%monster.info.streak = $null) { set %monster.info.streak 0 }
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the max streak
; for mons/bosses to show
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_maximum_streak {
  if ($1 = mon) {
    set %monster.info.streak.max $readini($mon($2), info, StreakMax)
  }

  if ($1 = boss) {
    set %monster.info.streak.max $readini($boss($2), info, StreakMax)
  }
  if (%monster.info.streak.max = $null) { set %monster.info.streak.max none }
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get a list of monsters
; eligable for the battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_mon_list {
  unset %monster.list
  var %value 1 | var %current.winning.streak.value $readini(battlestats.dat, battle, WinningStreak) 
  var %difficulty $readini(battle2.txt, BattleInfo, Difficulty) | inc %current.winning.streak.value %difficulty
  var %current.month $left($adate, 2)

  if (%mode.gauntlet.wave != $null) { inc %current.winning.streak.value %mode.gauntlet.wave }

  if (%portal.bonus = true) { var %current.winning.streak 100 }

  while ($findfile( $mon_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($mon_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if (((%name = new_mon) || (%name = $null) || (%name = orb_fountain))) { inc %value 1 } 
    else { 

      if ((%mode.gauntlet != $null) && ($readini($mon(%name), info, streak) > -500)) { write temporary_mlist.txt %name | inc %value 1 }
      else {

        ; Check the winning streak #..  some monsters won't show up until a certain streak or higher.
        $get_minimum_streak(mon, %name)
        $get_maximum_streak(mon, %name)

        if ($readini($mon(%name), info, month) = %current.month) { write temporary_mlist.txt %name  | inc %value 1 }
        if ($readini($mon(%name), info, month) != %current.month) { 
          if (%monster.info.streak <= -500) { inc %value 1 }
          if ((%monster.info.streak > -500) || (%monster.info.streak = $null)) {


            var %biome $readini($mon(%name), info, biome)

            if (%biome = $null) {
              if (%current.winning.streak.value >= %monster.info.streak) {  
                if ((%current.winning.streak.value <= %monster.info.streak.max) || (%monster.info.streak.max = none)) {   write temporary_mlist.txt %name       }
              }
            }
            if ((%biome != $null) && ($istok(%biome,%current.battlefield,46) = $true)) { 
              if (%current.winning.streak.value >= %monster.info.streak) {  
                if ((%current.winning.streak.value <= %monster.info.streak.max) || (%monster.info.streak.max = none)) {   write temporary_mlist.txt %name       }
              }
            }

          }
          inc %value 1
        }
      }
    }
  }

  unset %monster.info.streak | unset %monster.info.streak.max
  $sort_mlist

  set %token.value 1
  while (%token.value <= 15) {
    var %monster.name $read -l $+ %token.value temporary_mlist.txt
    if (%monster.name != $null) { %monster.list = $addtok(%monster.list,%monster.name,46) | inc %token.value 1 }
    else { inc %token.value 15 }
  }
  .remove temporary_mlist.txt   
  unset %token.value
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get a list of bosses eligable
; for the battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_boss_list {

  set %current.battlefield ocean

  unset %monster.list
  var %value 1 | var %current.winning.streak.value $readini(battlestats.dat, battle, WinningStreak) 
  var %difficulty $readini(battle2.txt, BattleInfo, Difficulty) | inc %current.winning.streak.value %difficulty
  var %current.month $left($adate, 2)
  if (%mode.gauntlet.wave != $null) { inc %current.winning.streak.value %mode.gauntlet.wave }

  while ($findfile( $boss_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($boss_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if (((%name = new_mon) || (%name = new_boss) || (%name = $null))) { inc %value 1 } 
    else { 

      if ((%mode.gauntlet != $null) && ($readini($boss(%name), info, streak) > -500)) { write temporary_mlist.txt %name | inc %value 1 }
      else {

        ; Check the winning streak #..  some bosses won't show up until a certain streak or higher.
        $get_minimum_streak(boss, %name)
        $get_maximum_streak(boss, %name)

        if ($readini($boss(%name), info, month) = %current.month) { write temporary_mlist.txt %name  | inc %value 1 }
        if ($readini($boss(%name), info, month) != %current.month) { 
          if (%monster.info.streak <= -500) { inc %value 1 }
          if ((%monster.info.streak > -500) || (%monster.info.streak = $null)) {

            var %biome $readini($boss(%name), info, biome)

            if (%biome = $null) {
              if (%current.winning.streak.value >= %monster.info.streak) {  
                if ((%current.winning.streak.value <= %monster.info.streak.max) || (%monster.info.streak.max = none)) {  write temporary_mlist.txt %name     }
              }
            }
            if ((%biome != $null) && ($istok(%biome,%current.battlefield,46) = $true)) { 
              if (%current.winning.streak.value >= %monster.info.streak) {  
                if ((%current.winning.streak.value <= %monster.info.streak.max) || (%monster.info.streak.max = none)) {   write temporary_mlist.txt %name       }
              }
            }

            inc %value 1
          }
        }
      }
    }
  }
  unset %monster.info.streak | unset %monster.info.streak.max
  $sort_mlist

  set %token.value 1
  while (%token.value <= 15) {
    var %monster.name $read -l $+ %token.value temporary_mlist.txt
    if (%monster.name != $null) { %monster.list = $addtok(%monster.list,%monster.name,46) | inc %token.value 1 }
    else { inc %token.value 15 }
  }
  .remove temporary_mlist.txt   
  unset %token.value
  return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get a list of NPCs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_npc_list {
  unset %npc.list
  var %value 1
  while ($findfile( $npc_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($npc_path ,*.char,%value)) 
    set %name $remove(%file,.char)
    if ((%name = new_npc) || (%name = $null)) { inc %value 1 } 
    else { 
      inc %value 1
      write temporary_mlist.txt %name
    }
  }
  $sort_mlist

  set %token.value 1
  while (%token.value <= 15) {
    var %monster.name $read -l $+ %token.value temporary_mlist.txt
    if (%monster.name != $null) { %npc.list = $addtok(%npc.list,%monster.name,46) | inc %token.value 1 }
    else { inc %token.value 15 }
  }
  .remove temporary_mlist.txt   
  unset %token.value
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function sorts the
; monster list.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sort_mlist {
  ; get rid of the Monster Table and the now un-needed file
  if ($isfile(MonsterTable.file) = $true) { 
    .hfree MonsterTable
    .remove MonsterTable.file
  }

  ; make the monster List table
  hmake MonsterTable

  ; load them from the file.   the initial list will be generated from the !enter commands.  
  var %monstertxt.lines $lines(temporary_mlist.txt) | var %monstertxt.current.line 1 
  while (%monstertxt.current.line <= %monstertxt.lines) { 
    var %who.monster $read -l $+ %monstertxt.current.line temporary_mlist.txt
    set %monster.index.num $rand(1,10000)
    hadd MonsterTable %who.monster %monster.index.num
    inc %monstertxt.current.line
  }

  ; save the MonsterTable hashtable to a file
  hsave MonsterTable MonsterTable.file

  ; load the MonsterTable hashtable (as a temporary table)
  hmake MonsterTable_Temp
  hload MonsterTable_Temp MonsterTable.file

  ; sort the Monster Table
  hmake MonsterTable_Sorted
  var %MonsterTableitem, %MonsterTabledata, %MonsterTableindex, %MonsterTablecount = $hget(MonsterTable_Temp,0).item
  while (%MonsterTablecount > 0) {
    ; step 1: get the lowest item
    %MonsterTableitem = $hget(MonsterTable_Temp,%MonsterTablecount).item
    %MonsterTabledata = $hget(MonsterTable_Temp,%MonsterTablecount).data
    %MonsterTableindex = 1
    while (%MonsterTableindex < %MonsterTablecount) {
      if ($hget(MonsterTable_Temp,%MonsterTableindex).data < %MonsterTabledata) {
        %MonsterTableitem = $hget(MonsterTable_Temp,%MonsterTableindex).item
        %MonsterTabledata = $hget(MonsterTable_Temp,%MonsterTableindex).data
      }
      inc %MonsterTableindex
    }

    ; step 2: remove the item from the temp list
    hdel MonsterTable_Temp %MonsterTableitem

    ; step 3: add the item to the sorted list
    %MonsterTableindex = sorted_ $+ $hget(MonsterTable_Sorted,0).item
    hadd MonsterTable_Sorted %MonsterTableindex %MonsterTableitem

    ; step 4: back to the beginning
    dec %MonsterTablecount
  }

  ; get rid of the temp table
  hfree MonsterTable_Temp

  ; Erase the old monster.txt and replace it with the new one.
  .remove temporary_mlist.txt

  var %index = $hget(MonsterTable_Sorted,0).item
  while (%index > 0) {
    dec %index
    var %tmp = $hget(MonsterTable_Sorted,sorted_ $+ %index)
    if (%tmp != $null) { write temporary_mlist.txt %tmp }
  }

  ; get rid of the sorted table
  hfree MonsterTable_Sorted

  ; get rid of the Monster Table and the now un-needed file
  hfree MonsterTable
  .remove MonsterTable.file

  ; unset the monster.index
  unset %monster.index.num
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; These two statuses return
; the HP status (perfect,
; injured, good, etc)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hp_status { 
  set %current.hp $readini($char($1), Battle, HP) | set %max.hp $readini($char($1), BaseStats, HP) | set %hp.percent $calc((%current.hp / %max.hp)*100) |  unset %current.hp | unset %max.hp 
  if (%hp.percent >= 100) { set %hstats $readini(translation.dat, health, perfect)  | return }
  if ((%hp.percent < 100) && (%hp.percent >= 90)) { set %hstats $readini(translation.dat, health, great) | return }
  if ((%hp.percent < 90) && (%hp.percent >= 80)) { set %hstats $readini(translation.dat, health, good) | return }
  if ((%hp.percent < 80) && (%hp.percent >= 70)) { set %hstats $readini(translation.dat, health, decent) | return }
  if ((%hp.percent < 70) && (%hp.percent >= 60)) { set %hstats $readini(translation.dat, health, scratched)  | return }
  if ((%hp.percent < 60) && (%hp.percent >= 50)) { set %hstats $readini(translation.dat, health, bruised) | return }
  if ((%hp.percent < 50) && (%hp.percent >= 40)) { set %hstats $readini(translation.dat, health, hurt) | return }
  if ((%hp.percent < 40) && (%hp.percent >= 30)) { set %hstats $readini(translation.dat, health, injured) | return }
  if ((%hp.percent < 30) && (%hp.percent >= 15)) { set %hstats $readini(translation.dat, health, injuredbadly) | return } 
  if ((%hp.percent < 15) && (%hp.percent > 2)) { set %hstats $readini(translation.dat, health, critical) | return }
  if ((%hp.percent <= 2) && (%hp.percent > 0)) { set %hstats $readini(translation.dat, health, AliveHairBredth) | return }
  if (%hp.percent <= 0) { set %whoturn $1 |  next | halt }
}
hp_status_hpcommand { 
  set %current.hp $readini($char($1), Battle, HP) | set %max.hp $readini($char($1), BaseStats, HP) | set %hp.percent $calc((%current.hp / %max.hp)*100) |  unset %current.hp | unset %max.hp 
  if (%hp.percent >= 100) { set %hstats $readini(translation.dat, health, perfect)  | return }
  if ((%hp.percent < 100) && (%hp.percent >= 90)) { set %hstats $readini(translation.dat, health, great) | return }
  if ((%hp.percent < 90) && (%hp.percent >= 80)) { set %hstats $readini(translation.dat, health, good) | return }
  if ((%hp.percent < 80) && (%hp.percent >= 70)) { set %hstats $readini(translation.dat, health, decent) | return }
  if ((%hp.percent < 70) && (%hp.percent >= 60)) { set %hstats $readini(translation.dat, health, scratched)  | return }
  if ((%hp.percent < 60) && (%hp.percent >= 50)) { set %hstats $readini(translation.dat, health, bruised) | return }
  if ((%hp.percent < 50) && (%hp.percent >= 40)) { set %hstats $readini(translation.dat, health, hurt) | return }
  if ((%hp.percent < 40) && (%hp.percent >= 30)) { set %hstats $readini(translation.dat, health, injured) | return }
  if ((%hp.percent < 30) && (%hp.percent >= 15)) { set %hstats $readini(translation.dat, health, injuredbadly) | return } 
  if ((%hp.percent < 15) && (%hp.percent > 2)) { set %hstats $readini(translation.dat, health, critical) | return }
  if ((%hp.percent <= 2) && (%hp.percent > 0)) { set %hstats $readini(translation.dat, health, AliveHairBredth) | return }
  if (%hp.percent <= 0) { set %hstats $readini(translation.dat, health, Dead)  | return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions to restore HP
; TP and IG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $1 = person being restored
; $2 = amount
restore_hp {
  var %max.hp $readini($char($1), basestats, hp)
  var %current.hp $readini($char($1), battle, hp)
  inc %current.hp $2
  if ($readini($char($1), status, ignition.on) = off) {
    if (%current.hp >= %max.hp) { writeini $char($1) battle hp %max.hp }
    else {  writeini $char($1) battle hp %current.hp }
  } 
  else {  writeini $char($1) battle hp %current.hp }
}

restore_tp {
  var %max.tp $readini($char($1), basestats, tp)
  var %current.tp $readini($char($1), battle, tp)
  inc %current.tp $2
  if ($readini($char($1), status, ignition.on) = off) {
    if (%current.tp >= %max.tp) { writeini $char($1) battle tp %max.tp }
    else {  writeini $char($1) battle tp %current.tp }
  } 
  else { writeini $char($1) battle tp %current.tp }
}

restore_ig {
  var %max.ig $readini($char($1), basestats, IgnitionGauge)
  var %current.ig $readini($char($1), battle, IgnitionGauge)

  if (%max.ig > 0) { 
    inc %current.ig $2
    if (%current.ig >= %max.ig) { writeini $char($1) battle IgnitionGauge %max.ig }
    else {  writeini $char($1) battle IgnitionGauge %current.ig }
  }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; These two functions clear
; variables.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_variables { 
  $clear_variables2
  unset %boss.type | unset %portal.bonus | unset %holy.aura | unset %darkness.fivemin.warn  | unset %battle.rage.darkness |  unset %battleconditions |  unset %red.orb.winners |  unset %bloodmoon 
  unset %line | unset %file | unset %name | unset %curbat | unset %real.name | unset %attack.target
  unset %battle.type | unset %number.of.monsters.needed | unset %who |  unset %next.person | unset %status | unset %hstats | unset %baseredorbs | unset %hp.percent
  unset %monster.list | unset %monsters.total | unset %random.monster | unset %monster.name |  unset %ai.target | unset %resist.skill | unset %value | unset %mastery.bonus
  unset %user | unset %enemy | unset %handtohand.wpn.list | unset %sword.wpn.list | unset %monster.wpn.list | unset %base.redorbs | unset %tech.type | unset %whoturn | unset %replacechar | unset %status.battle 
  unset %number.of.hits | unset %timer.time | unset %help.topics3 | unset %skill.name |  unset %skill_level | unset %action | unset %idwho | unset %currentshoplevel | unset %totalplayers
  unset %life.max | unset %passive.skills.list | unset %active.skills.list | unset %reists.skills.list |  unset %items.list | unset %techs.list | unset %tech.name | unset %tech_level | unset %multiplier
  unset %number.of.techs | unset %tech.list | unset %ai.tech | unset %who.battle | unset %weapon.equipped |  unset %ai.targetlist | unset %all_skills | unset %all_status | unset %status.message | unset %stylepoints.toremove
  unset %resist.have | unset %bonus.orbs | unset %attack.damage | unset %style.multiplier |  unset %style.rating | unset %file | unset %name | unset %weapon.howmany.hits | unset %element.desc
  unset %monster.to.remove | unset %burning | unset %hp | unset %drowning | unset %weapon.price |  unset %tornado | unset %tech.to.remove | unset %upgrade.list | unset %tech.price | unset %total.price
  unset %skill.price | unset %shop.list.passiveskills | unset %shop.list.activeskills |  unset %skill.list | unset %shop.list.resistanceskills | unset %resists.skills.list | unset %shop.statbonus
  unset %password | unset %passhurt | unset %userlevel | unset %comma_replace | unset %comma_new |  unset %freezing | unset %file | unset %name | unset %inc.shoplevel
  unset %poison.timer | unset %skill.description | unset %item.total | unset %black.orb.winners |  unset %file | unset %name | unset %bosschance | unset %fullbring.check | unset %check.item
  unset %fourhit.attack | unset %weapon.name | unset %shock | unset %skill.max | unset %skill.have |  unset %weapon.list | unset %tp.current | unset %drainsamba.turn | unset %absorb | unset %drainsamba.turns
  unset %drainsamba.turn.max | unset %life.target | unset %drainsamba.on | unset %weapons | unset %techs | unset %number.of.players | unset %keys.items.list
  unset %amount | unset %current.shoplevel | unset %shop.list | unset %battletxt.lines | unset %battletxt.current.lint
  unset %opponent.flag | unset %spell.element | unset %timer.time |   unset %battletxt.currentline | unset %first.round.protection | unset %first.round.protection.turn
  unset %npc.list | unset %random.npc | unset %npc.to.remove | unset %npc.name | unset %current.battlefield | unset %double.attack
  unset %shaken | unset %info.fullbringmsg | unset %basepower | unset %fullbring.needed | unset %poison
  unset %fullbring.type | unset %fullbring.target | unset %fullbring.status | unset %item.base | unset %timer.time
  unset %real.name | unset %weapon.name | unset %weapon.price | unset %steal.item | unset %skip.ai | unset %file.to.read.lines 
  unset %attacker.spd | unset %playerstyle.* | unset %stylepoints.to.add | unset %current.playerstyle.* | unset %styles | unset %wait.your.turn
}
clear_variables2 {
  unset %styles.list | unset %style.name | unset %style.level | unset %player.style.level | unset %style.price | unset %styles
  unset %ai.skill | unset %weapon.name.used | unset %weapon.used.type | unset %quicksilver.used | unset %upgrade.list2
  unset %upgrade.list3 | unset %ai.skilllist | unset %ai.type | unset %statusmessage.display | unset %current.turn | unset %surpriseattack
  unset %mode.pvp | unset %summons.items.list | unset %style_level | unset %attack.damage4 | unset %renkei.name | unset %renkei.description
  unset %status.type | unset %number.of.items.sold | unset %who.battle.flag | unset %shop.level | unset %overkill
  unset %style.name | unset %style_level | unset %styles | unset %trickster.dodged | unset %ip.address.* | unset %multiple.wave.bonus
  unset %monster.to.spawn | unset %mode.gauntlet | unset %mode.gauntlet.wave | unset %changeweapon.chance | unset %active.skills.list2 | unset %total.skills
  unset %who.battle.ai | unset %demonwall.fight | unset %weapon.base | unset %target.hp | unset %ignition.description | unset %temp.battle.list
  unset %style.name | unset %style_level | unset %quicksilver.used | unset %quicksilver.turn | unset %playersgofirst
  unset %battlefield.event.number | unset %number.of.events | unset %augment.strength | unset %augment.found | unset %curse.night | unset %random.item
  unset %absorb.message |   unset %battle.player.death | unset %battle.monster.death | unset %ignition.list | unset %renkei.tech.percent | unset %current.item.total
  unset %portals.bstmen | unset %allied.notes | unset %portals.kindred | unset %item.name | unset %item_amount | unset %treasure.hunter.percent
  unset %player.ig.current | unset player.ig.max | unset %player.ig.reward | unset %battletxt.current.line | %multiple.wave.noaction | unset %covering.someone
  unset %previous.tp | unset %multiple.wave | unset %portal.multiple.wave | unset %augment.strength | unset %current.monster.level.temp
  unset %current.monster.weapon.level.temp | unset %weapon.type | unset %original.attackdmg | unset %target | unset %monster.level 
  unset %target.tech.null | unset %naturalArmorName | unset %target.stat | unset %base.stat | unset %shop.level | unset %total.price
  unset %random.tech | unset %multiple.wave.noactio | unset %debug.location | unset %multiple.wave.noaction
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; See if the user $1 has
; the skill $2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
skillhave.check {
  if ($readini($char($1), skills, $2) > 0) { return true }
  else { return false }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Zap (erase) a character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zap_char {
  .copy $char($1) $zapped($1)
  .rename $zapped($1) $mircdir $+ %player_folder $+ %zapped_folder $+ $1 $+ _ $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,100) $+ .char
  .remove $char($1) 
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Resets a char to base
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reset_char {
  ; Reset all stats to base
  writeini $char($1) basestats hp 100 |  writeini $char($1) battle hp 100
  writeini $char($1) basestats tp 20 |  writeini $char($1) battle tp 20
  writeini $char($1) basestats str 5 |  writeini $char($1) battle str 5
  writeini $char($1) basestats def 5 |  writeini $char($1) battle def 5
  writeini $char($1) basestats int 5 |  writeini $char($1) battle int 5
  writeini $char($1) basestats spd 5 |  writeini $char($1) battle spd 5

  ; Reset the shop level
  writeini $char($1) stuff ShopLevel 1.0

  ; Reset the orbs.  Orbs gained will be 10% of whatever you had spent.
  var %total.orbs.spent $readini($char($1), stuff, RedOrbsSpent)
  var %new.orbs $round($calc(%total.orbs.spent * .05),0)
  writeini $char($1) stuff RedOrbs %new.orbs
  writeini $char($1) stuff BlackOrbs 1
  writeini $char($1) stuff RedOrbsSpent 0
  writeini $char($1) stuff BlackOrbsSpent 0

  ; Remove all skills
  remini $char($1) skills

  ; Reset the weapons to just the fists
  var %fists.level $readini($char($1), weapons, fists)
  remini $char($1) weapons
  writeini $char($1) weapons equipped fists
  writeini $char($1) weapons Fists %fists.level

  ; Reset the techniques
  var %doublepunch.level $readini($char($1), techniques, doublepunch)
  remini $char($1) techniques
  writeini $char($1) techniques DoublePunch %doublepunch.level 

  var %number.of.resets $readini($char($1), stuff, NumberOfResets)
  if (%number.of.resets = $null) { var %number.of.resets 0 }
  inc %number.of.resets 1 
  writeini $char($1) stuff NumberOfResets %number.of.resets

  ; Remove the augments
  remini $char($1) augments
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create a treasure chest 
; with a random item inside.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
create_treasurechest {

  set %chest.type.random $rand(1,150)
  dec %chest.type.random $treasurehunter.check

  if (%portal.bonus = true) { %chest.type.random = $rand(1,35) }

  if (%chest.type.random <= 10)  { set %color.chest gold  }
  if ((%chest.type.random > 10) && (%chest.type.random <= 20)) { set %color.chest silver }
  if ((%chest.type.random > 20) && (%chest.type.random <= 35)) { set %color.chest purple }
  if ((%chest.type.random > 35) && (%chest.type.random <= 55)) { set %color.chest orange }
  if ((%chest.type.random > 55) && (%chest.type.random <= 70)) { set %color.chest green }
  if ((%chest.type.random > 70) && (%chest.type.random <= 90)) { set %color.chest blue  }
  if ((%chest.type.random > 90) && (%chest.type.random <= 120)) { set %color.chest brown  }
  if (%chest.type.random > 120) { set %color.chest red | set %chest.contents RedOrbs | set %chest.amount $rand(100,1000) }

  if (%color.chest != red) {
    set %total.items $readini(chests.lst, chests, %color.chest)
    set %random $rand(1, $numtok(%total.items,46))
    if (%random = $null) { var %random 1 }
    set %chest.contents $gettok(%total.items,%random,46)
    unset %total.items
  }

  if (%chest.amount = $null) { set %chest.amount 1 }
  if (%chest.contents = $null) { unset %chest.amount | unset %color.chest | unset %chest.contents | return } 

  if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, system, ChestDrops) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.global.message($readini(translation.dat, system, ChestDrops)) }

  writeini treasurechest.txt ChestInfo Color %color.chest
  writeini treasurechest.txt ChestInfo Contents %chest.contents
  writeini treasurechest.txt ChestInfo Amount %chest.amount

  unset %color.chest | unset %chest.contents | unset %chest.amount | unset %random | unset %chest.type.random
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Remove a treasure chest
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
destroy_treasurechest {
  if ($readini(treasurechest.txt, ChestInfo, Color) != $null) {
    $display.system.message($readini(translation.dat, system, ChestDestroyed),global) 
    .remove treasurechest.txt 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for the treasurehunter
; skill.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
treasurehunter.check {
  unset %battle.list | set %lines $lines(battle.txt) | set %l 1 | set %treasure.hunter.percent 0
  while (%l <= %lines) { 
    set %who.battle $read -l [ $+ [ %l ] ] battle.txt | set %status.battle $readini($char(%who.battle), Battle, Status)
    if (%status.battle = dead) { inc %l 1 }
    else { 
      var %treasurehunter.skill $readini($char(%who.battle), skills, treasurehunter) 
      if (%treasurehunter.skill > 0) { inc %treasure.hunter.percent %treasurehunter.skill }
      if ($augment.check($1, EnhanceTreasureHunter) = true) { inc %treasure.hunter.percent %augment.strength }
      inc %l 1 
    } 
  }
  unset %lines | unset %l 

  return %treasure.hunter.percent
}

backguard.check {
  unset %battle.list | set %lines $lines(battle.txt) | set %l 1
  while (%l <= %lines) { 
    set %who.battle $read -l [ $+ [ %l ] ] battle.txt 
    if ($readini($char($1), info, flag) != $null) { inc %l 1 }
    else { 
      var %backguard.skill $readini($char(%who.battle), skills,backguard) 
      if (%backguardskill > 0) { dec %surpriseattack.chance %backguard.skill }
      inc %l 1 
    } 
  }
  unset %lines | unset %l 
}


give_random_reward {
  if ($readini(battle2.txt, battle, bonusitem) != $null) {

    if (%battle.type = boss) { var %reward.chance 100 }
    if (%battle.type != boss) { 

      var %reward.chance $rand(1,100)
      inc %reward.chance $treasurehunter.check
    }

    if (%reward.chance < 65) { return }

    set %item.winner $read -l $+ 1 battle.txt 
    var %winner.flag $readini($char(%item.winner), info, flag)
    if ((%winner.flag != monster) && (%winner.flag != npc)) {
      set %boss.item.list $readini(battle2.txt, battle, bonusitem)

      if (%boss.item.list != $null) {

        set %boss.item.total $numtok(%boss.item.list,46)
        set %random.boss.item $rand(1, %boss.item.total) 
        set %boss.item $gettok(%boss.item.list,%random.boss.item,46)
        unset %boss.item.total | unset %boss.item.list | unset %random.boss.item
        set %item.total $readini($char(%item.winner), item_amount, %boss.item)
        if (%item.total = $null) { writeini $char(%item.winner) item_amount %boss.item 1 }
        else { inc %item.total 1 | writeini $char(%item.winner) item_amount %boss.item %item.total }
        $set_chr_name(%item.winner) 

        if ($readini(system.dat, system, botType) = IRC) { query %battlechan $readini(translation.dat, battle, BonusItemWin) }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, BonusItemWin)) }
        remini battle2.txt battle bonusitem
      }
    }
    unset %boss.item | unset %item.winner
  }
}

give_random_key_reward {
  var %random.key.chance $rand(1,100)

  if (%portal.bonus = true) { %random.key.chance = 100 }

  if (%random.key.chance <= 75) { return }

  unset %battle.list | set %lines $lines(battle.txt) | set %l 1
  while (%l <= %lines) { 
    set %who.battle $read -l [ $+ [ %l ] ] battle.txt | set %status.battle $readini($char(%who.battle), Battle, Status)
    if (%status.battle = dead) { inc %l 1 }
    else { 
      if ($readini($char(%who.battle), info, flag) = $null) { %players.list = $addtok(%players.list, %who.battle, 46) }
      inc %l 1 
    } 
  }
  unset %lines | unset %l 

  if (%players.list = $null) { return }

  set %random $rand(1, $numtok(%players.list,46))
  if (%random = $null) { var %random 1 }
  set %key.winner $gettok(%players.list,%random,46)

  set %key.list $readini(items.db, items, keys)
  set %random $rand(1, $numtok(%key.list,46))
  if (%random = $null) { var %random 1 }
  set %key.item $gettok(%key.list,%random,46)

  set %key.color $readini(items.db, %key.item, unlocks)

  $set_chr_name(%key.winner)
  if ($readini(system.dat, system, botType) = IRC) {  query %battlechan $readini(translation.dat, Battle, KeyWin) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, Battle, KeyWin) }

  set %current.amount $readini($char(%key.winner), item_amount, %key.item) 
  if (%current.amount = $null) { set %current.amount 0 }
  inc %current.amount 1 | writeini $char(%key.winner) item_amount %key.item %current.amount

  var %total.number.of.keys $readini($char(%key.winner), stuff, TotalNumberOfKeys) 
  if (%total.number.of.keys = $null) { var %total.number.of.keys 0 }
  inc %total.number.of.keys 1
  writeini $char(%key.winner) stuff TotalNumberOfKeys %total.number.of.keys
  $achievement_check(%key.winner, AreYouTheKeyMaster)


  unset %key.list | unset %key.item | unset %players.list | unset %random | unset %key.item | unset %current.amount | unset %key.winner | unset %key.color
}

system_defaults_check {
  if (%player_folder = $null) { set %player_folder characters\ }
  if (%boss_folder = $null) { set %boss_folder bosses\ }
  if (%monster_folder = $null) { set %monster_folder monsters\ }
  if (%zapped_folder = $null) { set %zapped_folder zapped\ }
  if (%npc_folder = $null) { set %npc_folder npcs\ }
  if (%summon_folder = $null) { set %summon_folder summons\ }
  if (%help_folder = $null) { set %help_folder help-files\ }
  if (%battleis = $null) { set %battleis off }
  if (%battleisopen = $null) { set %battleisopen off }

  if ($readini(system.dat, system, botType) = $null) { writeini system.dat system botType IRC }
  if ($readini(system.dat, system, automatedbattlesystem) = $null) { writeini system.dat system automatedbattlesystem on } 
  if ($readini(system.dat, system, aisystem) = $null) { writeini system.dat system aisystem on } 
  if ($readini(system.dat, system, basexp) = $null) { writeini system.dat system basexp 100 } 
  if ($readini(system.dat, system, basebossxp) = $null) { writeini system.dat system basebossxp 500 } 
  if ($readini(system.dat, system, startingorbs) = $null) { writeini system.dat system startingorbs 1000 } 
  if ($readini(system.dat, system, maxHP) = $null) { writeini system.dat system maxHP 2500 } 
  if ($readini(system.dat, system, maxTP) = $null) { writeini system.dat system maxTP 500 } 
  if ($readini(system.dat, system, maxIG) = $null) { writeini system.dat system maxIG 100 } 
  if ($readini(system.dat, system, maxOrbReward) = $null) { writeini system.dat system maxOrbReward 20000 } 
  if ($readini(system.dat, system, maxshoplevel) = $null) { writeini system.dat system maxshoplevel 25 } 
  if ($readini(battlestats.dat, battle, LevelAdjust) = $null) { writeini battlestats.dat battle LevelAdjust 0 }
  if ($readini(system.dat, system, EnableDoppelganger) = $null) { writeini system.dat system EnableDoppelganger true }
  if ($readini(system.dat, system, EnableWarmachine) = $null) { writeini system.dat system EnableWarmachine true }
  if ($readini(system.dat, system, AllowDemonwall) = $null) { writeini system.dat system AllowDemonwall yes }
  if ($readini(system.dat, system, EnableChests) = $null) { writeini system.dat system EnableChests true }
  if ($readini(system.dat, system, MaxCharacters) = $null) { writeini system.dat system MaxCharacters 2 }
  if ($readini(system.dat, system, TimeForIdle) = $null) { writeini system.dat system TimeForIdle 180 }
  if ($readini(system.dat, system, TimeToEnter) = $null) { writeini system.dat system TimeToEnter 120 }
  if ($readini(system.dat, system, ShowOrbsCmdInChannel) = $null) { writeini system.dat system ShowOrbsCmdInChannel true }
  if ($readini(system.dat, system, BattleDamageFormula) = $null) { writeini system.dat system BattleDamageFormula 2 }
  if ($readini(system.dat, system, EnableBattlefieldEvents) = $null) { writeini system.dat system EnableBattlefieldEvents true }
  if ($readini(system.dat, system, GuaranteedBossBattles) = $null) { writeini system.dat system GuaranteedBossBattles 10.15.20.30.60.100.150.180.220.280.320.350.401.440.460.501.560.601.670.705.780.810.890.920.999.1100.1199.1260. 1305.1464.1500.1650.1720.1880.1999.2050.2250.9999  }
  if ($readini(system.dat, system, BonusEvent) = $null) { writeini system.dat system BonusEvent false }
  if ($readini(system.dat, system, IgnoreDmgCap) = $null) { writeini system.dat system IgnoreDmgCap false }
  if ($readini(system.dat, system, MaxNumberOfMonsInBattle) = $null) { writeini system.dat system MaxNumberOfMonsInBattle 6 }

  if ($readini(system.dat, statprices, hp) = $null) { writeini system.dat statprices hp 150 }
  if ($readini(system.dat, statprices, tp) = $null) { writeini system.dat statprices tp 150 }
  if ($readini(system.dat, statprices, str) = $null) { writeini system.dat statprices str 250 }
  if ($readini(system.dat, statprices, def) = $null) { writeini system.dat statprices def 250 }
  if ($readini(system.dat, statprices, int) = $null) { writeini system.dat statprices int 250 }
  if ($readini(system.dat, statprices, spd) = $null) { writeini system.dat statprices spd 250 }
  if ($readini(system.dat, statprices, ig) = $null) { writeini system.dat statprices ig 800 }
}

get_boss_type {

  var %enable.doppelganger $readini(system.dat, system, EnableDoppelganger)
  var %enable.warmachine $readini(system.dat, system, EnableWarMachine)

  var %winning.streak.check $readini(battlestats.dat, battle, winningstreak)
  if (%mode.gauntlet.wave != $null) { inc %winning.streak.check %mode.gauntlet.wave }

  if (%winning.streak.check > 75) { var %enable.doppelganger false }
  if (%winning.streak.check >= 300) { var %enable.warmachine false } 
  if ((%winning.streak.check > 300) && (%winning.streak.check <= 600)) { 
    if ($readini(system.dat, system, AllowDemonwall) = yes) { var %enable.demonwall true }
  }
  if ((%winning.streak.check > 600) && (%winning.streak.check <= 5000)) { var %enable.elderdragon true }


  if (%mode.gauntlet = on) { var %enable.demonwall false }

  if ((((%enable.doppelganger != true) && (%enable.demonwall != true) && (%enable.warmachine != true) && (%enable.elderdragon != true)))) { set %boss.type normal | return }
  if ((%enable.doppelganger = true) && (%enable.warmachine = false)) {
    var %boss.chance $rand(1,100)
    if (%boss.chance <= 7) { set %boss.type doppelganger | return }
    else { set %boss.type normal | return }
  }
  if ((%enable.doppelganger = false) && (%enable.warmachine = true)) {
    var %boss.chance $rand(1,100)
    if (%boss.chance <= 20) { set %boss.type warmachine | return }
    else { set %boss.type normal | return }
  }
  if ((%enable.doppelganger = true) && (%enable.warmachine = true)) {
    var %boss.chance $rand(1,100)
    if (%boss.chance <= 7) { set %boss.type doppelganger | return }
    if ((%boss.chance > 7) && (%boss.chance <= 25)) { set %boss.type warmachine | return }
    if (%boss.chance >  25) {  set %boss.type normal | return }
  }
  if (%enable.demonwall = true) { 
    var %boss.chance $rand(1,100)
    if (%boss.chance <= 15) { set %boss.type demonwall | set %demonwall.fight on | return }
    else { set %boss.type normal | return }
  }

  if (%enable.elderdragon = true) { 
    var %boss.chance $rand(1,100)
    if (%boss.chance <= 15) { set %boss.type elderdragon | return }
    else { set %boss.type normal | return }
  }

}

augment.check {
  ; 1 = user
  ; 2 = augment name

  set %weapon.name.temp $readini($char($1), weapons, equipped)
  set %ignition.augment $readini($char($1), status, ignition.augment) 
  set %weapon.augment $readini($char($1), augments, %weapon.name.temp)

  set %equipment.head.augment $readini(equipment.db, $readini($char($1), equipment, head), augment)
  set %equipment.body.augment $readini(equipment.db, $readini($char($1), equipment, body), augment)
  set %equipment.legs.augment $readini(equipment.db, $readini($char($1), equipment, legs), augment)
  set %equipment.feet.augment $readini(equipment.db, $readini($char($1), equipment, feet), augment)
  set %equipment.hands.augment $readini(equipment.db, $readini($char($1), equipment, hands), augment)

  unset %weapon.name.temp
  set %augment.strength 0

  if ($istok(%ignition.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
  if ($istok(%weapon.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
  if ($istok(%equipment.head.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
  if ($istok(%equipment.body.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
  if ($istok(%equipment.legs.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
  if ($istok(%equipment.feet.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
  if ($istok(%equipment.hands.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }

  if (($readini($char($1), status, FinalGetsuga) = yes) && ($readini($char($1), info, flag) = $null)) { inc %augment.strength 5 | set %augment.found true }

  unset %weapon.augment  | unset %ignition.augment | unset %equipment.head.augment | unset %equipment.body.augment
  unset %equipment.legs.augment | unset %equipment.feet.augment | unset %equipment.hands.augment

  if (%augment.found != true) { return false }
  if (%augment.found = true) { unset %augment.found | return true }
}

orb.adjust {
  var %winning.streak $readini(battlestats.dat, battle, WinningStreak)
  if (%base.redorbs <= 1000) { return }

  if (%mode.gauntlet.wave != $null) { inc %winning.streak %mode.gauntlet.wave }      

  var %difficulty $readini(battle2.txt, BattleInfo, Difficulty)
  if (%difficulty != 0) {  inc %winning.streak %difficulty }

  if (%portal.bonus = true) {  var %winning.streak 500 }

  if (%winning.streak < 50) { set %base.redorbs $round($calc(1000 + (%base.redorbs * .35)),0) }
  if ((%winning.streak >= 50) && (%winning.streak < 100)) { set %base.redorbs $round($calc(1000 + (%base.redorbs * .40)),0) }
  if ((%winning.streak >= 100) && (%winning.streak < 200)) { return }
  if ((%winning.streak >= 200) && (%winning.streak < 300)) { set %base.redorbs $round($calc(%base.redorbs * 1.45),0) }
  if ((%winning.streak >= 300) && (%winning.streak < 500)) { set %base.redorbs $round($calc(%base.redorbs * 1.555),0) }
  if ((%winning.streak >= 500) && (%winning.streak < 800)) { set %base.redorbs $round($calc(%base.redorbs * 1.692),0) }
  if ((%winning.streak >= 800) && (%winning.streak < 1000)) { set %base.redorbs $round($calc(%base.redorbs * 1.798),0) }
  if ((%winning.streak >= 1000) && (%winning.streak < 1200)) { set %base.redorbs $round($calc(%base.redorbs * 2.190),0) }
  if ((%winning.streak >= 1200) && (%winning.streak < 1500)) { set %base.redorbs $round($calc(%base.redorbs * 2.5),0) }
  if ((%winning.streak >= 1500) && (%winning.streak < 2000)) { set %base.redorbs $round($calc(%base.redorbs * 2.95),0) }
  if (%winning.streak >= 2000) { set %base.redorbs $round($calc(%base.redorbs * 3.15),0) }
}

give_alliednotes {
  set %allied.notes $readini($char($1), stuff, alliednotes)
  if (%allied.notes = $null) { set %allied.notes 0 }
  inc %allied.notes $readini(battle2.txt, battle, alliednotes)
  writeini $char($1) stuff alliednotes %allied.notes
}

increase.death.tally {
  if ($readini($char($1), info, flag) = monster) {

    if ($isfile($boss($1)) = $true) { 
      var %boss.deaths $readini(monsterdeaths.lst, boss, $1) 
      if (%boss.deaths = $null) { var %boss.deaths 0 }
      inc %boss.deaths 1
      writeini monsterdeaths.lst boss $1 %boss.deaths
    }
    if ($isfile($mon($1)) = $true) { 
      var %monster.deaths $readini(monsterdeaths.lst, monster, $1) 
      if (%monster.deaths = $null) { var %monster.deaths 0 }
      inc %monster.deaths 1
      writeini monsterdeaths.lst monster $1 %monster.deaths
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

increase_death_tally {
  if ($readini($char($1), info, flag) = npc) { return }
  var %deaths $readini($char($1), stuff, TotalDeaths)
  if (%deaths = $null) { var %deaths 0 } 
  inc %deaths 1
  writeini $char($1) stuff TotalDeaths %deaths
}

check.clone.death {
  if ($isfile($char($1 $+ _clone)) = $true) { 
    if ($readini($char($1 $+ _clone), battle, status) != dead) { writeini $char($1 $+ _clone) battle status dead | writeini $char($1 $+ _clone) battle hp 0 | $set_chr_name($1 $+ _clone) 

      if ($readini(system.dat, system, botType) = IRC) {  /.timerCloneDeath $+ $1 1 1 /query %battlechan 4 $+ %real.name disappears back into $set_chr_name($1) %real.name $+ 's shadow.  }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(4 $+ %real.name disappears back into $set_chr_name($1) %real.name $+ 's shadow.) }
    }
  }
  if ($isfile($char($1 $+ _summon)) = $true) { 
    if ($readini($char($1 $+ _summon), battle, status) != dead) { writeini $char($1 $+ _summon) battle status dead | writeini $char($1 $+ _summon) battle hp 0 | $set_chr_name($1 $+ _summon) 

      if ($readini(system.dat, system, botType) = IRC) {  /.timerSummonDeath $+ $1 1 1 /query %battlechan 4 $+ %real.name fades away. }
      if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message(4 $+ %real.name fades away.) }
    }
  }
}
