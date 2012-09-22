battle.version { return 1.3 }
quitmsg { return Battle Arena version $battle.version written by James  "Iyouboushi" }
checkscript {
  if (| isin $1-) { msg $nick $readini(translation.dat, errors, NoScriptsWithCommands) | halt }
  else { return | halt } 
}
checkchar {
  var %check $readini($char($1), Stuff, ShopLevel)
  if (%check = $null) { query %battlechan $readini(translation.dat, errors, NotInDataBank) | halt }
  else { return }
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
player.status { unset %all_status | $set_chr_name($1) 
  if ($readini($char($1), Battle, Status) = dead) { set %all_status dead | return } 
  else { 
    if ($readini($char($1), Battle, Status) = rage) { $status_message_check(rage) } 
    if ($readini($char($1), Status, poison) = yes) {  $status_message_check(poisoned) }
    if ($readini($char($1), Status, HeavyPoison) = yes) { $status_message_check(poisoned heavily) }
    if ($readini($char($1), Status, Poison-heavy) = yes) { $status_message_check(poisoned heavily) }
    if ($readini($char($1), Status, Blind) = yes) { $status_message_check(blind) } 
    if ($readini($char($1), Status, Regenerating) = yes) { $status_message_check(regenerating) }
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
    if ($readini($char($1), skills, drainsamba.on) = on) { $status_message_check(using Drain Samba) }
    if (%all_status = $null) { %all_status = 3Normal }
    return
  }
  unset %real.name | unset %status 
}

status_message_check { 
  if (%all_status = $null) { %all_status = 4 $+ $1- | return }
  else { %all_status = 4 $+ %all_status $+ $chr(0160) $+ 3 $+ $chr(124) $+ 4 $+ $chr(0160) $+ $1- | return }
}
is_charmed {
  if ($readini($char($1), status, charmed) = yes) { return true }
  else { return false }
}

amnesia.check {
  var %amnesia.check $readini($char($1), status, amnesia)
  if (%amnesia.check = no) { return }
  else { 
    $set_chr_name($1) 
    query %battlechan $readini(translation.dat, status, CurrentlyAmnesia) | halt 
  }
}

id_login { set %idwho $1 | unset %newbie | unset %password | unset %userlevel | unset %character.description | .dns %idwho | $clr_passhurt($1) | writeini $char($1) Info LastSeen $fulldate | .close -m* |  unset %guess  | unset %gender | halt }
okdesc { .msg $1 $readini(translation.dat, system,OKDesc) | return }
set_chr_name {
  set %real.name $readini($char($1), BaseStats, Name)
  if (%real.name = $null) { set %real.name $1 | return }
  else { return }
}

battle_stats { set %str $readini($char($1), Battle, Str) | set %def $readini($char($1), Battle, Def) | set %int $readini($char($1), Battle, int) | set %spd $readini($char($1), Battle, spd) | return }  
weapon_equipped { set %weapon.equipped $readini($char($1), Weapons, Equipped) | return }
weapon.list { 
  set %weapon.list $weapons.get.list($1)

  ; CLEAN UP THE LIST
  if ($chr(046) isin %weapon.list) { set %replacechar $chr(044) $chr(032)
    %weapon.list = $replace(%weapon.list, $chr(046), %replacechar)
  }

  return
}
weapons.get.list { 
  unset %weapon.list | unset %weapons | unset %number.of.weapons
  set %weapons $readini(weapons.db, Weapons, HandToHand)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Swords)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Whips)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Guns)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Wands)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Katanas)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Spears)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Scythes)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, GreatSwords)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Glyphs)
  set %weapons %weapons $+ . $+ $readini(weapons.db, Weapons, Rifles)
  set %weapons2 $readini(weapons.db, Weapons, MonsterWpns)
  set %weapons3 $readini(weapons.db, Weapons, MonsterWpns2)
  set %weapons4 $readini(weapons.db, Weapons, MonsterWpns4)
  var %number.of.weapons $numtok(%weapons, 46)

  var %value 1
  while (%value <= %number.of.weapons) {
    set %weapon.name $gettok(%weapons, %value, 46)
    set %weapon_level $readini($char($1), weapons, %weapon.name)

    if ((%weapon_level != $null) && (%weapon_level >= 1)) { 
      ; add the weapon level to the weapon list
      var %weapon_to_add  $+ %weapon.name $+ $chr(040) $+ %weapon_level $+ $chr(041) $+ 
      %weapon.list = $addtok(%weapon.list,%weapon_to_add,46)
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
    }
    inc %value 1 
  }
  unset %value | unset %weapon.name | unset %weapon_level | unset %weapons2 | unset %weapons3

  var %number.of.weapons $numtok(%weapons4, 46)
  var %value 1
  while (%value <= %number.of.weapons) {
    set %weapon.name $gettok(%weapons4, %value, 46)
    set %weapon_level $readini($char($1), weapons, %weapon.name)

    if ((%weapon_level != $null) && (%weapon_level >= 1)) { 
      ; add the weapon level to the weapon list
      var %weapon_to_add  $+ %weapon.name $+ $chr(040) $+ %weapon_level $+ $chr(041) $+ 
      %weapon.list = $addtok(%weapon.list,%weapon_to_add,46)
    }
    inc %value 1 
  }
  unset %value | unset %weapon.name | unset %weapon_level | unset %weapons2 | unset %weapons3 | unset %weapons4


  return %weapon.list
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
  set %passive.skills.list $passive.skills.list($1)
  set %active.skills.list $active.skills.list($1)
  set %resists.skills.list $resists.skills.list($1)
  return
}

passive.skills.list { 
  ; CHECKING PASSIVE SKILLS
  unset %passive.skills.list
  var %passive.skills $readini(skills.db, Skills, PassiveSkills)
  var %number.of.skills $numtok(%passive.skills, 46)

  var %value 1
  while (%value <= %number.of.skills) {
    set %skill.name $gettok(%passive.skills, %value, 46)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      %passive.skills.list = $addtok(%passive.skills.list,%skill_to_add,46)
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %passive.skills.list) { set %replacechar $chr(044) $chr(032)
    %passive.skills.list = $replace(%passive.skills.list, $chr(046), %replacechar)
  }

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  return %passive.skills.list
}

active.skills.list {
  ; CHECKING ACTIVE SKILLS
  unset %active.skills.list
  var %active.skills $readini(skills.db, Skills, activeSkills)
  var %number.of.skills $numtok(%active.skills, 46)

  var %value 1
  while (%value <= %number.of.skills) {
    set %skill.name $gettok(%active.skills, %value, 46)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      %active.skills.list = $addtok(%active.skills.list,%skill_to_add,46)
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %active.skills.list) { set %replacechar $chr(044) $chr(032)
    %active.skills.list = $replace(%active.skills.list, $chr(046), %replacechar)
  }

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  return %active.skills.list
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

items.list {
  ; CHECKING HEALING ITEMS
  unset %items.list
  var %healing.items $readini(items.db, items, HealingItems)
  var %number.of.items $numtok(%healing.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%healing.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %items.list = $addtok(%items.list,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CHECKING BATTLE ITEMS
  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  var %battle.items $readini(items.db, items, BattleItems)
  var %number.of.items $numtok(%battle.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%battle.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %items.list = $addtok(%items.list,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CHECKING FOOD ITEMS
  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  var %food.items $readini(items.db, items, FoodItems)
  var %number.of.items $numtok(%food.items, 46)

  var %value 1
  while (%value <= %number.of.items) {
    set %item.name $gettok(%food.items, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
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
    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %items.list = $addtok(%items.list,%item_to_add,46)
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
    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      ; add the item and the amount to the item list
      var %item_to_add %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
      %items.list = $addtok(%items.list,%item_to_add,46)
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %items.list) { set %replacechar $chr(044) $chr(032)
    %items.list = $replace(%items.list, $chr(046), %replacechar)
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


; Fulls command (brings everyone back to max hp and regular stats)
fulls {  
  writeini $char($1) Battle Hp $readini($char($1), BaseStats, HP)
  writeini $char($1) Battle Tp $readini($char($1), BaseStats, TP)
  writeini $char($1) Battle Str $readini($char($1), BaseStats, Str)
  writeini $char($1) Battle Def $readini($char($1), BaseStats, Def)
  writeini $char($1) Battle Int $readini($char($1), BaseStats, Int)
  writeini $char($1) Battle Spd $readini($char($1), BaseStats, Spd)
  writeini $char($1) Battle Status alive

  $clear_status($1) 
  if (($readini($char($1), info, flag) != monster) && ($readini($char($1), info, flag) != npc)) { $clear_skills($1) | var %stylelist $styles.get.list($1) }
}

clear_skills {
  writeini $char($1) skills speed.on no | writeini $char($1) skills doubleturn.on off | writeini $char($1) status charmed no | writeini $char($1) status charmer noonethatIknowlol
  writeini $char($1) skills soulvoice.on off | writeini $char($1) skills manawall.on off | writeini $char($1) skills elementalseal.on off
  writeini $char($1) skills mightystrike.on off | writeini $char($1) skills royalguard.on off | writeini $char($1) skills conservetp.on off
  writeini $char($1) skills drainsamba.turn 0 | writeini $char($1) skills drainsamba.on off | writeini $char($1) skills utsusemi.on off
  writeini $char($1) skills utsusemi.shadows 0 | writeini $char($1) skills Quicksilver.turn 0 | writeini $char($1) skills CoverTarget none
}
clear_status {
  if ($readini($char($1), status, finalgetsuga) = yes) {
    $reset_char($1) | $set_chr_name($1)
    query %battlechan 4 $+ %real.name feels all of $gender($1) power leaving $gender($1) body, resetting him back to level 1.
    unset %real.name
  }

  writeini $char($1) Status poison no | writeini $char($1) Status HeavyPoison no | writeini $char($1) Status Regenerating no |  writeini $char($1) Status blind no
  writeini $char($1) Status frozen no | writeini $char($1) status freezing no | writeini $char($1) Status shock no | writeini $char($1) Status burning no | writeini $char($1) Status drowning no | writeini $char($1) Status tornado no
  writeini $char($1) Status earth-quake no | writeini $char($1) Status Heavy-Poison no | writeini $char($1) status poison-heavy no | writeini $char($1) Status curse no | writeini $char($1) Status intimidated no
  writeini $char($1) Status weight no | writeini $char($1) status virus no | writeini $char($1) status poison.timer 1 | writeini $char($1) status charmer noOneThatIKnow | writeini $char($1) status charm.timer 1 | writeini $char($1) status charmed no 
  writeini $char($1) Status drunk no | writeini $char($1) Status amnesia no | writeini $char($1) status paralysis no | writeini $char($1) status amnesia.timer 1 | writeini $char($1) status paralysis.timer 1 | writeini $char($1) status drunk.timer 1
  writeini $char($1) status zombie no | writeini $char($1) Status slow no | writeini $char($1) Status sleep no | writeini $char($1) Status stun no | writeini $char($1) Status MPRegenerating no | writeini $char($1) Status KiRegenerating no
  writeini $char($1) status boosted no  | writeini $char($1) status curse.timer 1 | writeini $char($1) status slow.timer 1 | writeini $char($1) status zombie.timer 1 | writeini $char($1) status FinalGetsuga no
  writeini $char($1) status zombieregenerating no | writeini $char($1) status intimidate no | writeini $char($1) status revive no
  ; Monsters that are zombies need to be reset as zombies.
  if ($readini($char($1), monster, type) = zombie) {  writeini $char($1) status zombie yes | writeini $char($1) status zombieregenerating yes } 

  if ($readini($char($1), equipment, accessory) = Fool's-Tablet) {
    writeini $char($1) status poison yes
    writeini $char($1) status poison.timer 0
  }
}


; Get the monster list

get_mon_list {
  unset %monster.list
  var %value 1
  while ($findfile( $mon_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($mon_path ,*.char,%value)) 
    set %name $remove(%file,.char)
    if ((%name = new_mon) || (%name = $null)) { inc %value 1 } 
    else { 
      inc %value 1
      write temporary_mlist.txt %name
    }
  }
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

get_boss_list {
  unset %monster.list
  var %value 1
  while ($findfile( $boss_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($boss_path ,*.char,%value)) 
    set %name $remove(%file,.char)
    if (((%name = new_mon) || (%name = new_boss) || (%name = $null))) { inc %value 1 } 
    else { 
      inc %value 1
      write temporary_mlist.txt %name
    }
  }
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

sort_mlist {
  ; get rid of the Monster Table and the now un-needed file
  if ($isfile(MonsterTable.file) = $true) { 
    hfree MonsterTable
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

hp_status { 
  set %current.hp $readini($char($1), Battle, HP) | set %max.hp $readini($char($1), BaseStats, HP) | set %hp.percent $calc((%current.hp / %max.hp)*100) |  unset %current.hp | unset %max.hp 
  if (%hp.percent >= 100) { set %hstats $readini(translation.dat, health, perfect)  | return }
  if ((%hp.percent < 100) && (%hp.percent >= 80)) { set %hstats $readini(translation.dat, health, decent) | return }
  if ((%hp.percent < 80) && (%hp.percent >= 70)) { set %hstats $readini(translation.dat, health, good) | return }
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
  if ((%hp.percent < 100) && (%hp.percent >= 80)) { set %hstats $readini(translation.dat, health, decent) | return }
  if ((%hp.percent < 80) && (%hp.percent >= 70)) { set %hstats $readini(translation.dat, health, good)  | return }
  if ((%hp.percent < 70) && (%hp.percent >= 60)) { set %hstats $readini(translation.dat, health, scratched)  | return }
  if ((%hp.percent < 60) && (%hp.percent >= 50)) { set %hstats $readini(translation.dat, health, bruised) | return }
  if ((%hp.percent < 50) && (%hp.percent >= 40)) { set %hstats $readini(translation.dat, health, hurt) | return }
  if ((%hp.percent < 40) && (%hp.percent >= 30)) { set %hstats $readini(translation.dat, health, injured) | return }
  if ((%hp.percent < 30) && (%hp.percent >= 15)) { set %hstats $readini(translation.dat, health, injuredbadly) | return } 
  if ((%hp.percent < 15) && (%hp.percent > 2)) { set %hstats $readini(translation.dat, health, critical) | return }
  if ((%hp.percent <= 2) && (%hp.percent > 0)) { set %hstats $readini(translation.dat, health, AliveHairBredth) | return }
  if (%hp.percent <= 0) { set %hstats $readini(translation.dat, health, Dead)  | return }
}

clear_variables { 
  unset %bloodmoon |  unset %line | unset %file | unset %name | unset %curbat | unset %real.name | unset %attack.target
  unset %battle.type | unset %number.of.monsters.needed | unset %who
  unset %next.person | unset %status | unset %hstats | unset %baseredorbs | unset %hp.percent
  unset %monster.list | unset %monsters.total | unset %random.monster | unset %monster.name
  unset %ai.target | unset %resist.skill | unset %value | unset %mastery.bonus
  unset %user | unset %enemy | unset %handtohand.wpn.list | unset %sword.wpn.list | unset %monster.wpn.list
  unset %base.redorbs | unset %tech.type | unset %whoturn | unset %replacechar | unset %status.battle 
  unset %number.of.hits | unset %timer.time | unset %help.topics3 | unset %skill.name
  unset %skill_level | unset %action | unset %idwho | unset %currentshoplevel | unset %totalplayers
  unset %life.max | unset %passive.skills.list | unset %active.skills.list | unset %reists.skills.list
  unset %items.list | unset %techs.list | unset %tech.name | unset %tech_level | unset %multiplier
  unset %number.of.techs | unset %tech.list | unset %ai.tech | unset %who.battle | unset %weapon.equipped
  unset %ai.targetlist | unset %all_status | unset %status.message | unset %stylepoints.toremove
  unset %resist.have | unset %bonus.orbs | unset %attack.damage | unset %style.multiplier
  unset %style.rating | unset %file | unset %name | unset %weapon.howmany.hits | unset %element.desc
  unset %monster.to.remove | unset %burning | unset %hp | unset %drowning | unset %weapon.price
  unset %tornado | unset %tech.to.remove | unset %upgrade.list | unset %tech.price | unset %total.price
  unset %skill.price | unset %shop.list.passiveskills | unset %shop.list.activeskills
  unset %skill.list | unset %shop.list.resistanceskills | unset %resists.skills.list | unset %shop.statbonus
  unset %password | unset %passhurt | unset %userlevel | unset %comma_replace | unset %comma_new
  unset %freezing | unset %file | unset %name | unset %inc.shoplevel
  unset %poison.timer | unset %skill.description | unset %item.total | unset %black.orb.winners
  unset %file | unset %name | unset %bosschance | unset %fullbring.check | unset %check.item
  unset %fourhit.attack | unset %weapon.name | unset %shock | unset %skill.max | unset %skill.have
  unset %weapon.list | unset %tp.current | unset %drainsamba.turn | unset %absorb | unset %drainsamba.turns
  unset %drainsamba.turn.max | unset %life.target | unset %drainsamba.on
  unset %amount | unset %current.shoplevel | unset %shop.list | unset %battletxt.lines | unset %battletxt.current.lint
  unset %opponent.flag | unset %spell.element | unset %timer.time |   unset %battletxt.currentline
  unset %npc.list | unset %random.npc | unset %npc.to.remove | unset %npc.name
  unset %shaken | unset %info.fullbringmsg | unset %basepower | unset %fullbring.needed
  unset %fullbring.type | unset %fullbring.target | unset %fullbring.status | unset %item.base | unset %timer.time
  unset %real.name | unset %weapon.name | unset %weapon.price | unset %steal.item
  unset %attacker.spd | unset %playerstyle.* | unset %stylepoints.to.add | unset %current.playerstyle.* | unset %styles
  unset %styles.list | unset %style.name | unset %style.level | unset %player.style.level | unset %style.price | unset %styles
  unset %ai.skill | unset %weapon.name.used | unset %weapon.used.type | unset %quicksilver.used | unset %upgrade.list2
  unset %upgrade.list3 | unset %ai.skilllist | unset %ai.type
}

skillhave.check {
  if ($readini($char($1), skills, $2) > 0) { return true }
  else { return false }
}

zap_char {
  .copy $char($1) $zapped($1)
  .rename $zapped($1) $mircdir $+ %player_folder $+ %zapped_folder $+ $1 $+ _ $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,100) $+ .char
  .remove $char($1) 
  return 
}


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


}
