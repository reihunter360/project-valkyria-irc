;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SKILLS 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 50:TEXT:*does *:*:{ $use.skill($1, $2, $3, $4) }

alias use.skill { 
  ; $1 = user
  ; $2 = does
  ; $3 = skill name
  ; $4 = target, if necessary

  if ($3 = elementalseal) { $skill.elementalseal($1) }
  if ($3 = mightystrike) { $skill.mightystrike($1) }
  if ($3 = manawall) { $skill.manawall($1) } 
  if ($3 = royalguard) { $skill.royalguard($1) }
  if ($3 = utsusemi) { $skill.utsusemi($1) }
  if ($3 = fullbring) { $skill.fullbring($1, $4) }
  if ($3 = doubleturn) { $skill.doubleturn($1) } 
  if ($3 = sugitekai) { $skill.doubleturn($1) } 
  if ($3 = meditate) { $skill.meditate($1) }
  if ($3 = conserveTP) { $skill.conserveTP($1) } 
  if ($3 = bloodboost) { $skill.bloodboost($1) } 
  if ($3 = bloodspirit) { $skill.bloodspirit($1) } 
  if ($3 = drainsamba) { $skill.drainsamba($1) } 
  if (($3 = regen) && ($4 = $null)) { $skill.regen($1) } 
  if (($3 = regen) && ($4 = stop)) { $skill.regen.stop($1) } 
  if ($3 = kikouheni) { $skill.kikouheni($1, $4) }
  if ($3 = shadowcopy) { $skill.clone($1) }  
  if ($3 = steal) { $skill.steal($1, $4, !steal) } 
  if ($3 = analysis) { $skill.analysis($1, $4) } 
  if ($3 = quicksilver) { $skill.quicksilver($1) } 
  if ($3 = cover) { $skill.cover($1, $4) } 
  if ($3 = aggressor) { $skill.aggressor($1) } 
  if ($3 = defender) { $skill.defender($1) }
  if ($3 = alchemy) { $skill.alchemy($1, $4) } 
  if ($3 = craft) { $skill.craft($1, $4) }  
  if ($3 = holyaura) { $skill.holyaura($1) } 
  if ($3 = provoke) { $skill.provoke($1, $4) }
  if ($3 = weaponlock) { $skill.weaponlock($1, $4) }  
  if ($3 = disarm) { $skill.disarm($1, $4) } 
  if ($3 = konzen-ittai) { $skill.konzen-ittai($1) } 
  if ($3 = sealbreak) { $skill.sealbreak($1) }
  if ($3 = magicmirror) { $skill.magicmirror($1) }
  if ($3 = gamble) { $skill.gamble($1) }
  if ($3 = thirdeye) { $skill.thirdeye($1) }
  if ($3 = scavenge) { $skill.scavenge($1) }
  if ($3 = perfectcounter) { $skill.perfectcounter($1) }
  if ($3 = justrelease) { $skill.justrelease($1, $4, !justrelease) } 

  ; Below are monster-only skills

  if ($3 = magicshift) { $skill.magic.shift($1) }
  if ($3 = demonportal) { $skill.demonportal($1) }
  if ($3 = cocoon) { $skill.cocoon.evolve($1) }
  if ($3 = cocoonevolve) { $skill.cocoon.evolve($1) }
  if ($3 = monsterconsume) { $skill.monster.consume($1, $4) }
}

;=================
; SPEED SKILL
;=================
on 3:TEXT:!speed*:*: { $skill.speedup($nick) }

alias skill.speedup { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  if ($skillhave.check($1, speed) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private) | halt }
  if (%battleis = off) { $display.system.message(4There is no battle currently!, private) | halt }
  $check_for_battle($1)

  if ($readini($char($1), skills, speed.on) = on) { $set_chr_name($1) | $display.system.message(4 $+ %real.name has already used this skill once this battle and cannot use it again until the next battle., private)  | halt }

  ; Display the desc. 
  if ($readini($char($1), descriptions, speed) = $null) { set %skill.description forces $gender($1) body to speed up! }
  else { set %skill.description $readini($char($1), descriptions, speed) }
  $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Increase the speed
  var %speed $readini($char($1), battle, spd)
  var %increase $round($calc(%speed * ($readini($char($1), skills, speed) / 10)),0)
  if (%increase < 1) { var %increase 1 }
  inc %speed %increase
  writeini $char($1) battle spd %speed

  ; Toggle the speed-on flag so players can't use it again in the same battle.
  writeini $char($1) skills speed.on on

  writeini battle2.txt style $1 $+ .lastaction speed

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}

;=================
; ELEMENTAL SEAL
;=================
on 3:TEXT:!elemental seal*:*: { $skill.elementalseal($nick) }
on 3:TEXT:!elementalseal*:*: { $skill.elementalseal($nick) }

alias skill.elementalseal { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, ElementalSeal) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(4There is no battle currently!, private) | halt }
  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, elementalseal.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  inc %time.difference $calc(%time.difference + ($readini($char($1), skills, elementalseal) * 60))

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, ElementalSeal, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, ElementalSeal) = $null) { set %skill.description uses an ancient technique to enhance $gender($1) next magical spell! }
    else { set %skill.description $readini($char($1), descriptions, ElementalSeal) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; Toggle the elementalseal-on flag & write the last used time.
    writeini $char($1) skills elementalseal.on on
    writeini $char($1) skills elementalseal.time $ctime

    writeini battle2.txt style $1 $+ .lastaction elementalseal

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private)  | $display.private.message(3You still have $calc($readini(skills.db, ElementalSeal, cooldown) - %time.difference) seconds before you can use !elemental seal again) | halt }
}

;=================
; MIGHTY STRIKE
;=================
on 3:TEXT:!mighty strike*:*: { $skill.mightystrike($nick) }
on 3:TEXT:!mightystrike*:*: { $skill.mightystrike($nick) }

alias skill.mightystrike { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, MightyStrike) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(4There is no battle currently!, private) | halt }


  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, mightystrike.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)
  inc %time.difference $calc(%time.difference + ($readini($char($1), skills, mightystrike)) * 60))

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, MightyStrike, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, MightyStrike) = $null) { set %skill.description forces energy into $gender($1) weapon, causing the next blow done with it to be double power }
    else { set %skill.description $readini($char($1), descriptions, MightyStrike) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; Toggle the flag & write the last used time.
    writeini $char($1) skills mightystrike.on on
    writeini $char($1) skills mightystrike.time $ctime

    writeini battle2.txt style $1 $+ .lastaction mightystrike

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private)  | $display.private.message(3You still have $calc($readini(skills.db, MightyStrike, cooldown) - %time.difference) seconds before you can use !mighty strike again) | halt }
}

;=================
; MANA WALL
;=================
on 3:TEXT:!mana wall*:*: { $skill.manawall($nick) }
on 3:TEXT:!manawall*:*: { $skill.manawall($nick) }

alias skill.manawall { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, ManaWall) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, ManaWall.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  inc %time.difference $calc(%time.difference + ($readini($char($1), skills, ManaWall) * 60))

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, ManaWall, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, ManaWall) = $null) { set %skill.description uses an ancient technique to produce a powerful magic-blocking barrier around $gender($1) body! }
    else { set %skill.description $readini($char($1), descriptions, ManaWall) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; Toggle the ManaWall-on flag & write the last used time.
    writeini $char($1) skills ManaWall.on on
    writeini $char($1) skills ManaWall.time $ctime

    writeini battle2.txt style $1 $+ .lastaction manawall

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private)  | $display.private.message(3You still have $calc($readini(skills.db, ManaWall, cooldown) - %time.difference) seconds before you can use !mana wall again) | halt }
}

;=================
; ROYAL GUARD
;=================
on 3:TEXT:!royal guard*:*: { $skill.royalguard($nick) }
on 3:TEXT:!royalguard*:*: { $skill.royalguard($nick) }

alias skill.royalguard { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, royalguard) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, royalguard.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  inc %time.difference $calc(%time.difference + ($readini($char($1), skills, royalguard) * 60))

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, RoyalGuard, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, royalguard) = $null) { set %skill.description uses an ancient style to negate the next melee attack towards $gender2($1) }
    else { set %skill.description $readini($char($1), descriptions, royalguard) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; Toggle the royalguard-on flag & write the last used time.
    writeini $char($1) skills royalguard.on on
    writeini $char($1) skills royalguard.time $ctime

    writeini battle2.txt style $1 $+ .lastaction royalguard

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, RoyalGuard, cooldown) - %time.difference) seconds before you can use !royal guard again) | halt }
}

;=================
; UTSUSEMI
;=================
on 3:TEXT:!utsusemi*:*: { $skill.utsusemi($nick) }

alias skill.utsusemi { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, utsusemi) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, utsusemi.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  inc %time.difference $calc(%time.difference + ($readini($char($1), skills, utsusemi) * 60))

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, Utsusemi, cooldown))) {

    ; Check for the item "Shihei" and consume it, or display an error if they don't have any.
    set %check.item $readini($char($1), item_amount, shihei)
    if ((%check.item = $null) || (%check.item <= 0)) { $set_chr_name($1) | $display.system.message(4Error: %real.name does not have enough shihei to perform this skill, private) | halt }
    $decrease_item($1, Shihei) 

    ; Display the desc. 
    if ($readini($char($1), descriptions, utsusemi) = $null) { set %skill.description uses an ancient ninjutsu technique to create shadow copies to absorb attacks. }
    else { set %skill.description $readini($char($1), descriptions, utsusemi) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; Toggle the utsusemi-on flag & write the last used time.
    writeini $char($1) skills utsusemi.on on
    writeini $char($1) skills utsusemi.time $ctime

    if ($augment.check($1, UtsusemiBonus) = true) { 
      writeini $char($1) skills utsusemi.shadows 4
    }
    if ($augment.check($1, UtsusemiBonus) = false) { 
      writeini $char($1) skills utsusemi.shadows 2
    }

    writeini battle2.txt style $1 $+ .lastaction utsusemi

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, Utsusemi, cooldown) - %time.difference) seconds before you can use !utsusemi again) | halt }
}

;=================
; FULL BRING SKILL
;=================
on 3:TEXT:!fullbring*:*: { $skill.fullbring($nick, $2) }

alias skill.fullbring { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }

  $set_chr_name($1) | $amnesia.check($1, skill) 

  set %check.item $readini($char($1), Item_Amount, $2) 
  if ((%check.item <= 0) || (%check.item = $null)) { $set_chr_name($1) | $display.system.message(4Error: %real.name does not have that item., private) | halt }

  set %fullbring.check $readini($char($1), skills, fullbring) | set %fullbring.needed $readini(items.db, $2, FullbringLevel)
  if (%fullbring.needed > %fullbring.check) { $display.system.message(4Error: %real.name does not have a high enough Fullbring skill level to perform Fullbring on this item!, private) | halt }

  $check_for_battle($nick)
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }

  set %fullbring.type $readini(items.db, $2, type) | set %fullbring.target $readini(items.db, $2, FullbringTarget)

  if (%fullbring.target = $null) { $display.system.message(4Error: This item does not have a fullbring ability attached to it!, private) | halt }
  $decrease_item($nick, $2)

  if (%fullbring.type = heal) {
    if (%fullbring.target = AOE) { $fullbring.aoeheal($1, $2) }
    else { $fullbring.singleheal($1, $2, $1) }
  }

  if (%fullbring.type = status) {
    $fullbring.aoestatus($1, $2) 
  }

  if (%fullbring.type = damage) { 
    $fullbring.aoedamage($1, $2)
  }

  if (%fullbring.type = tp) { 
    $fullbring.aoetp($1, $2)
  }

  writeini battle2.txt style $1 $+ .lastaction fullbring

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}

alias fullbring.singleheal { 
  ; $1 = user
  ; $2 = item
  ; $3 = target

  ; Display the fullbring desc
  $display.system.message(3 $+ %user  $+ $readini(items.db, $2, Fullbringdesc), battle)

  set %attack.damage 0

  ; First things first, let's find out the base power.
  var %item.base $readini(items.db, $2, FullbringAmount)
  inc %attack.damage %item.base

  ; If the person has the FieldMedic skill, increase the amount.
  var %field.medic.skill $readini($char($1), skills, FieldMedic) 
  if (%field.medic.skill != $null) {
    var %skill.increase.amount $calc(5 * %field.medic.skill)
    inc %attack.damage %skill.increase.amount
  }

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  ; In this bot we don't want the attack to ever be lower than 1.  
  if (%attack.damage <= 0) { set %attack.damage 1 }

  ;If the target is a zombie, do damage instead of healing it.
  if ($readini($char($3), status, zombie) = yes) { 
    $deal_damage($1, $3, $2)
    $display_damage($1, $3, fullbring, $2)
  } 

  else {   
    $heal_damage($1, $3, $2)
    $display_heal($1, $3, fullbring, $2)
  }
}

alias fullbring.aoeheal {
  ; $1 = user
  ; $2 = item

  unset %who.battle | set %number.of.hits 0
  set %attack.damage 0

  set %wait.your.turn on

  ; First things first, let's find out the base power.
  var %item.base $readini(items.db, $2, FullbringAmount)
  inc %attack.damage %item.base

  ; If the person has the FieldMedic skill, increase the amount.
  var %field.medic.skill $readini($char($1), skills, FieldMedic) 
  if (%field.medic.skill != $null) {
    var %skill.increase.amount $calc(5 * %field.medic.skill)
    inc %attack.damage %skill.increase.amount
  }

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  ; In this bot we don't want the attack to ever be lower than 1.  
  if (%attack.damage <= 0) { set %attack.damage 1 }

  ; Display the item description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  $display.system.message(3 $+ %user  $+ $readini(items.db, $2, Fullbringdesc), battle)


  ; If it's player, search out remaining players that are alive and deal damage and display damage
  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line battle.txt
    if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }
    else { 
      var %current.status $readini($char(%who.battle), battle, status)
      if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
      else { 
        inc %number.of.hits 1

        ;If the target is a zombie, do damage instead of healing it.
        if ($readini($char(%who.battle), status, zombie) = yes) { 
          $deal_damage($1, %who.battle, $2)
          $display_damage($1, %who.battle, fullbring, $2)
        } 

        else {   
          $heal_damage($1, %who.battle, $2)
          $display_heal($1, %who.battle, fullbring, $2)
        }

        inc %battletxt.current.line 1 
      } 
    }
  }


  return
}

alias fullbring.aoestatus {
  ; $1 = user
  ; $2 = item

  unset %who.battle | set %number.of.hits 0
  set %wait.your.turn on

  ; Display the item description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name
  $display.system.message(3 $+ %user  $+ $readini(items.db, $2, Fullbringdesc), battle)

  ; Get the fullbring status type
  set %fullbring.status $readini(items.db, $2, StatusType)

  if (%fullbring.status = stop) { set %status.type stop | var %tech.status.grammar frozen in time }
  if (%fullbring.status = poison) { set %status.type poison | var %tech.status.grammar poisoned }
  if (%fullbring.status = silence) { set %status.type silence | var %tech.status.grammar silenced }
  if (%fullbring.status = blind) { set %status.type blind | var %tech.status.grammar blind }
  if (%fullbring.status = virus) { set %status.type virus | var %tech.status.grammar inflicted with a virus }
  if (%fullbring.status = amnesia) { set %status.type amnesia | var %tech.status.grammar inflicted with amnesia }
  if (%fullbring.status = paralysis) { set %status.type paralysis | var %tech.status.grammar paralyzed }
  if (%fullbring.status = zombie) { set %status.type zombie | var %tech.status.grammar a zombie }
  if (%fullbring.status = slow) { set %status.type slow | var %tech.status.grammar slowed }
  if (%fullbring.status = stun) { set %status.type stun | var %tech.status.grammar stunned }
  if (%fullbring.status = curse) { set %status.type curse | var %tech.status.grammar cursed }
  if (%fullbring.status = charm) { set %status.type charm | var %tech.status.grammar charmed }
  if (%fullbring.status = intimidate) { set %status.type intimidate | var %tech.status.grammar intimidated }
  if (%fullbring.status = defensedown) { set %status.type defensedown | var %tech.status.grammar inflicted with defense down }
  if (%fullbring.status = strengthdown) { set %status.type strengthdown | var %tech.status.grammar inflicted with strength down }
  if (%fullbring.status = intdown) { set %status.type intdown | var %tech.status.grammar inflicted with int down }
  if (%fullbring.status = petrify) { set %status.type petrify  | var %tech.status.grammar petrified }
  if (%fullbring.status = bored) { set %status.type bored | var %tech.status.grammar bored of the battle  }
  if (%fullbring.status = confuse) { set %status.type confuse  | var %tech.status.grammar confused }



  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line battle.txt
    if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
    else { 
      inc %number.of.hits 1
      set %current.status $readini($char(%who.battle), battle, status)

      if (%current.status != dead) { 
        if ($readini($char(%who.battle), skills, utsusemi.on) = on) { set %chance 0  } 
        $calculate_damage_items($1, $2, %who.battle, fullbring)
        $deal_damage($1, %who.battle, $2)

        ; Check for resistance to that status type.
        var %chance $rand(1,100) | $set_chr_name($1) 
        set %resist.have resist- $+ %fullbring.status
        set %resist.skill $readini($char(%who.battle), skills, %resist.have)

        $ribbon.accessory.check(%who.battle)

        if (%status.type = charm) {
          if ($readini($char(%who.battle), status, zombie) != no) { set %resist.skill 100 }
          if ($readini($char(%who.battle), monster, type) = undead) { set %resist.skill 100 }
        }

        if ((%resist.skill != $null) && (%resist.skill > 0)) { 
          if (%resist.skill >= 100) { set %statusmessage.display 4 $+ %real.name is immune to the %fullbring.status status! }
          else { dec %chance %resist.skill }
        }


        if (%chance >= 50) {
          if ((%chance = 50) && (%fullbring.status = poison)) { $set_chr_name(%who.battle) | set %statusmessage.display 4 $+ %real.name is now %tech.status.grammar $+ !  | writeini $char(%who.battle) Status poison-heavy yes }
          if ((%chance = 50) && (%fullbring.status != poison)) { $set_chr_name(%who.battle) | set %statusmessage.display 4 $+ %real.name is now %tech.status.grammar $+ !  | writeini $char(%who.battle) Status %fullbring.status yes }
          else { $set_chr_name(%who.battle) | set %statusmessage.display 4 $+ %real.name is now %tech.status.grammar $+ !  | writeini $char(%who.battle) Status %fullbring.status yes 
            if (%fullbring.status = charm) { writeini $char(%who.battle) status charmed yes | writeini $char($2) status charmer $1 | writeini $char(%who.battle) status charm.timer $rand(2,3) }
            if (%fullbring.status = curse) { writeini $char(%who.battle) battle tp 0 }
          }
        }
        else {
          if (%resist.skill >= 100) { $set_chr_name(%who.battle) | set %statusmessage.display 4 $+ %real.name is immune to the %fullbring.status status! }
          if ((%resist.skill  >= 1) && (%resist.skill < 100)) { $set_chr_name(%who.battle) | set %statusmessage.display 4 $+ %real.name has resisted $set_chr_name($1) %real.name $+ 's $lower(%fullbring.status) status effect! }
          if ((%resist.skill <= 0) || (%resist.skill = $null)) { $set_chr_name($1) | set %statusmessage.display 4 $+ %real.name $+ 's $lower(%fullbring.status) status effect has failed against $set_chr_name(%who.battle) %real.name $+ ! }
        }


        ; If a monster, increase the resistance.
        if ($readini($char(%who.battle), info, flag) = monster) {
          if (%resist.skill = $null) { set %resist.skill 2 }
          else { inc %resist.skill 2 }
          writeini $char(%who.battle) skills %resist.have %resist.skill
        }
        unset %resist.have | unset %chance

        $display_Statusdamage_item($1, %who.battle, fullbring)
        inc %battletxt.current.line 1 
      }

      if ((%current.status = dead) || (%current.status = runaway)) {  inc %battletxt.current.line 1  }
    } 
  }

  set %timer.time $calc(%number.of.hits * 1) 
  unset %current.status

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt
}

alias fullbring.aoedamage {
  ; $1 = user
  ; $2 = item

  unset %who.battle | set %number.of.hits 0
  set %wait.your.turn on

  ; Display the item description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name
  $display.system.message(3 $+ %user  $+ $readini(items.db, $2, Fullbringdesc), battle)

  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line battle.txt
    if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
    else { 
      inc %number.of.hits 1
      var %current.status $readini($char(%who.battle), battle, status)
      if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
      else { 
        $calculate_damage_items($1, $2, %who.battle, fullbring)
        $deal_damage($1, %who.battle, $2)
        $display_aoedamage($1, %who.battle, $2)
        inc %battletxt.current.line 1 
      } 
    }
  }

  set %timer.time $calc(%number.of.hits * 1) 

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt
}

alias fullbring.aoetp {
  ; $1 = user
  ; $2 = item

  unset %who.battle | set %number.of.hits 0
  $set_chr_name($1) | set %user %real.name

  set %wait.your.turn on

  ; Display the item description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name
  $display.system.message(3 $+ %user  $+ $readini(items.db, $2, Fullbringdesc), battle)

  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line battle.txt
    if ($readini($char(%who.battle), info, flag) != monster) { 
      inc %number.of.hits 1
      var %current.status $readini($char(%who.battle), battle, status)
      if ((%current.status != dead) && (%current.status != runaway)) {  

        $set_chr_name(%who.battle) | set %enemy %real.name

        ; calculate amount
        var %tp.amount $readini(items.db, $3, fullbringamount)

        ; add TP to the target
        var %tp.current $readini($char(%who.battle), battle, tp) 
        inc %tp.current %tp.amount 

        if (%tp.current >= $readini($char(%who.battle), basestats, tp)) { writeini $char(%who.battle) battle tp $readini($char(%who.battle), basestats, tp) }
        else { writeini $char(%who.battle) battle tp %tp.current }

        $display.system.message(3 $+ %enemy has regained %tp.amount TP!, battle)
      }
    }
    inc %battletxt.current.line 1 
  }

  set %timer.time $calc(%number.of.hits * .5) 

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt
}

;=================
; DOUBLE TURN
;=================
on 3:TEXT:!double turn*:*: { $skill.doubleturn($nick) }
on 3:TEXT:!doubleturn*:*: { $skill.doubleturn($nick) }
on 3:TEXT:!sugitekai*:*: { $skill.doubleturn($nick) }

alias skill.doubleturn { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, sugitekai) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, doubleturn.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  inc %time.difference $calc(%time.difference + ($readini($char($1), skills, doubleturn) * 60))

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, Sugitekai, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, doubleturn) = $null) { set %skill.description becomes very focused and is able to do two actions next round! }
    else { set %skill.description $readini($char($1), descriptions, doubleturn) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; Toggle the doubleturn-on flag & write the last used time.
    writeini $char($1) skills doubleturn.on on
    writeini $char($1) skills doubleturn.time $ctime

    writeini battle2.txt style $1 $+ .lastaction sugitekai

    ; Time to go to the next turn
    if (%battleis = on)  { $next }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, Sugitekai, cooldown) - %time.difference) seconds before you can use !Sugitekai again) | halt }
}

;=================
; MEDITATE
;=================
on 3:TEXT:!meditate*:*: { $skill.meditate($nick) }

alias skill.meditate { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, meditate) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, meditate.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, Meditate, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, meditate) = $null) { set %skill.description meditates and feel $gender($1) TP being restored.  }
    else { set %skill.description $readini($char($1), descriptions, meditate) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; write the last used time.
    writeini $char($1) skills meditate.time $ctime

    ; get TP
    var %tp.current $readini($char($1), battle, tp)
    var %tp.max $readini($char($1), basestats, tp)

    ; Find out the increase amount
    var %tp.increase $calc(5 * $readini($char($1), skills, meditate))

    if ($augment.check($1, EnhanceMeditate) = true) { 
      inc %tp.increase $calc(10 * %augment.strength)
    }

    ; increase the tp and make sure it's not over the max
    inc %tp.current %tp.increase

    if (%tp.current >= %tp.max) { $display.system.message(3 $+ %real.name has restored all of $gender($1) TP!, battle) | writeini $char($1) battle tp %tp.max }
    if (%tp.current < %tp.max) { $display.system.message(3 $+ %real.name has restored %tp.increase TP!, battle) | writeini $char($1) battle tp %tp.current }

    writeini battle2.txt style $1 $+ .lastaction meditate

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private)  | $display.private.message(3You still have $calc($readini(skills.db, Meditate, cooldown) - %time.difference) seconds before you can use !meditate again) | halt }
}

;=================
; CONSERVE TP
;=================
on 3:TEXT:!conserve TP*:*: { $skill.conserveTP($nick) }
on 3:TEXT:!conserveTP*:*: { $skill.conserveTP($nick) }

alias skill.conserveTP { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, conserveTP) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, conserveTP.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  inc %time.difference $calc(%time.difference + ($readini($char($1), skills, conserveTP) * 60))

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, ConserveTP, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, conserveTP) = $null) { set %skill.description uses an ancient skill to reduce the cost of $gender($1) next technique to 0. }
    else { set %skill.description $readini($char($1), descriptions, conserveTP) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; Toggle the conserveTP-on flag & write the last used time.
    writeini $char($1) status conserveTP yes
    writeini $char($1) skills conserveTP.time $ctime

    writeini battle2.txt style $1 $+ .lastaction conserveTP

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private)  | $display.private.message(3You still have $calc($readini(skills.db, ConserveTP, cooldown) - %time.difference) seconds before you can use !conserve TP again) | halt }
}


;=================
; BLOOD BOOST
;=================
on 3:TEXT:!bloodboost*:*: { $skill.bloodboost($nick) }
on 3:TEXT:!blood boost*:*: { $skill.bloodboost($nick) }

alias skill.bloodboost { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, bloodboost) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  if ($readini($char($1), info, flag) = $null) { 
    var %hp.needed 100 | var %hp.current $readini($char($1), battle, hp)
    if (%hp.needed > %hp.current) { $display.system.message(4Error: %real.name does not have enough HP to use this skill!, private) | halt }
  }

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, bloodboost.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, BloodBoost, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, bloodboost) = $null) { set %skill.description sacrifices some of $gender($1) blood for raw strength.  }
    else { set %skill.description $readini($char($1), descriptions, bloodboost) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; write the last used time.
    writeini $char($1) skills bloodboost.time $ctime

    if ($readini($char($1), info, flag) = $null) { 
      ; Dec the HP
      dec %hp.current %hp.needed
      writeini $char($1) battle hp %hp.current
    }

    ; get STR
    var %str.current $readini($char($1), battle, str)

    ; Find out the increase amount. Bloodmoon increases the amount by a random amount.
    var %str.increase $calc(2 * $readini($char($1), skills, bloodboost))
    if (%bloodmoon = on) { inc %str.increase $rand(2,5) }

    if ($augment.check($1, EnhanceBloodboost) = true) {
      inc %str.increase $calc(10 + %augment.strength)
    }

    ; increase the str
    inc %str.current %str.increase

    $display.system.message(3 $+ %real.name has gained %str.increase STR!, battle)  |   writeini $char($1) battle str %str.current

    writeini battle2.txt style $1 $+ .lastaction bloodboost

    var %total.bloodboost $readini($char($1), stuff, BloodBoostTimes) 
    if (%total.bloodboost = $null) { var %total.bloodboost 0 }
    inc %total.bloodboost 1 
    writeini $char($1) stuff BloodBoostTimes %total.bloodboost
    $achievement_check($1, BloodGoneDry)


    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, BloodBoost, cooldown) - %time.difference) seconds before you can use !bloodboost again) | halt }
}

;=================
; BLOOD SPIRIT
;=================
on 3:TEXT:!bloodspirit*:*: { $skill.bloodspirit($nick) }
on 3:TEXT:!blood spirit*:*: { $skill.bloodspirit($nick) }

alias skill.bloodspirit { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, bloodspirit) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  if ($readini($char($1), info, flag) = $null) { 
    var %hp.needed 100 | var %hp.current $readini($char($1), battle, hp)
    if (%hp.needed > %hp.current) { $display.system.message(4Error: %real.name does not have enough HP to use this skill!, private) | halt }
  }

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, bloodspirit.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, BloodSpirit, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, bloodspirit) = $null) { set %skill.description sacrifices some of $gender($1) blood for raw intelligence.  }
    else { set %skill.description $readini($char($1), descriptions, bloodspirit) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; write the last used time.
    writeini $char($1) skills bloodspirit.time $ctime

    if ($readini($char($1), info, flag) = $null) { 
      ; Dec the HP
      dec %hp.current %hp.needed
      writeini $char($1) battle hp %hp.current
    }

    ; get INT
    var %int.current $readini($char($1), battle, int)

    ; Find out the increase amount. Bloodmoon increases the amount by a random amount.
    var %int.increase $calc(2 * $readini($char($1), skills, bloodspirit))
    if (%bloodmoon = on) { inc %int.increase $rand(2,5) }

    if ($augment.check($1, EnhanceBloodSpirit) = true) {
      inc %int.increase $calc(10 + %augment.strength)
    }

    ; increase the int
    inc %int.current %int.increase

    $display.system.message(3 $+ %real.name has gained %int.increase INT!, battle)  |   writeini $char($1) battle int %int.current

    writeini battle2.txt style $1 $+ .lastaction bloodspirit

    var %total.BloodSpirit $readini($char($1), stuff, BloodSpiritTimes) 
    if (%total.BloodSpirit = $null) { var %total.BloodSpirit 0 }
    inc %total.BloodSpirit 1 
    writeini $char($1) stuff BloodSpiritTimes %total.BloodSpirit
    $achievement_check($1, BloodGoneToHead)

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, BloodBoost, cooldown) - %time.difference) seconds before you can use !bloodboost again) | halt }
}


;=================
; DRAIN SAMBA
;=================
on 3:TEXT:!drainsamba*:*: { $skill.drainsamba($nick) }
on 3:TEXT:!drain samba*:*: { $skill.drainsamba($nick) }

alias skill.drainsamba { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, drainsamba) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  if ($readini($char($1), info, flag) = $null) { 
    var %tp.needed 15 | var %tp.current $readini($char($1), battle, tp)
    if (%tp.needed > %tp.current) { $display.system.message(4Error: %real.name does not have enough TP to use this skill!, private) | halt }
  }

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, drainsamba.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, DrainSamba, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, drainsamba) = $null) { set %skill.description performs a powerful samba that activates a draining technique on $gender($1) weapon!   }
    else { set %skill.description $readini($char($1), descriptions, drainsamba) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; write the last used time.
    writeini $char($1) skills drainsamba.time $ctime

    if ($readini($char($1), info, flag) = $null) { 
      ; Dec the TP
      dec %tp.current %tp.needed
      writeini $char($1) battle tp %tp.current
    }

    writeini $char($1) skills drainsamba.turn 0 | writeini $char($1) skills drainsamba.on on

    $display.system.message(3 $+ %real.name has gained the drain status for $readini($char($1), skills, drainsamba) melee attacks!, battle)

    writeini battle2.txt style $1 $+ .lastaction drainsamba

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, DrainSamba, cooldown) - %time.difference) seconds before you can use !drainsamba again) | halt }
}


;=================
; REGEN
;=================
on 3:TEXT:!regen*:* { $skill.regen($nick) }
on 3:TEXT:!regeneration*:* { $skill.regen($nick) }
on 3:TEXT:!stop regen*:*:{ $skill.regen.stop($nick) } 

alias skill.regen { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }

  $amnesia.check($1, skill) 

  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)
  if ($skillhave.check($1, regen) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }

  set %current.hp $readini($char($1), Battle, HP)  |  set %max.hp $readini($char($1), BaseStats, HP)
  if (%current.hp >= %max.hp) { $set_chr_name($1) | $display.system.message(3 $+ %real.name is already at full HP!, private) | halt }

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, regen.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, Regen, cooldown))) {

    ; write the last used time.
    writeini $char($1) skills regen.time $ctime

    if ($readini($char($1), descriptions, regen) = $null) { set %skill.description has gained the regeneration effect.  }
    else { set %skill.description $readini($char($1), descriptions, regen) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    var %regen.amount $skill.regen.calculate($1)
    inc %current.hp %regen.amount
    writeini $char($1) Battle HP %current.hp
    if (%current.hp > %max.hp) { writeini $char($1) Battle HP %max.hp | $display.system.message(12 $+ %real.name has regenerated all of $gender($1) HP!, battle)
      if (%battleis = on)  { $check_for_double_turn($1) | halt }
    }
    else { 
      $set_chr_name($1) | $display.system.message(12 $+ %real.name has regenerated %regen.amount HP!, battle)
      writeini $char($1) Status Regenerating yes | goto regenhalt 
    }
    :regenhalt
    writeini battle2.txt style $1 $+ .lastaction regen
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
    else { halt }
  }
  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, Regen, cooldown) - %time.difference) seconds before you can use !regen again) | halt }

}

alias skill.regen.calculate {
  var %skill.level $readini($char($1), skills, regen)
  if (%skill.level = $null) { var %skill.level 1 }
  if (%skill.level < 5) { set %amount 2 }
  if ((%skill.level >= 5) && (%skill.level <= 10)) { set %amount 3 }
  if ((%skill.level > 11) && (%skill.level <= 15)) { set %amount 4 }
  if (%skill.level > 15) { set %amount 5 }
  inc %amount $calc(%skill.level * %amount)
  return %amount
}

alias skill.TPregen.calculate {
  return 5
}

alias skill.zombieregen.calculate {
  var %temp.winning.streak $readini(battlestats.dat, battle, winningstreak)
  var %difficulty $readini(battle2.txt, BattleInfo, Difficulty)
  inc %temp.winning.streak %difficulty

  if (%temp.winning.streak < 10) { set %amount $rand(1,10) }
  if ((%temp.winning.streak >= 10) && (%temp.winning.streak < 50)) { set %amount $rand(20,50) }
  if ((%temp.winning.streak >= 50) && (%temp.winning.streak < 100)) { set %amount $rand(50,100) }
  if ((%temp.winning.streak >= 100) && (%temp.winning.streak < 300)) { set %amount $rand(75, 150) }
  if ((%temp.winning.streak >= 300) && (%temp.winning.streak <= 500)) { set %amount $rand(150, 250) }
  if (%temp.winning.streak > 500) { set %amount $rand(350,600) }

  return %amount
}

alias skill.tpregen {
  set %current.tp $readini($char($1), Battle, TP)  |  set %max.tp $readini($char($1), BaseStats, TP)
  if (%current.tp >= %max.tp) { $set_chr_name($1) | $display.system.message(3 $+ %real.name is already at full TP!, private) | halt }

  if ($readini($char($1), descriptions, TPregen) = $null) { set %skill.description has gained the tp regeneration effect.  }
  else { set %skill.description $readini($char($1), descriptions, TPregen) }
  $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

  var %regen.amount $skill.regen.calculate($1)
  inc %current.tp %regen.amount
  writeini $char($1) Battle TP %current.tp
  if (%current.tp > %max.tp) { writeini $char($1) Battle TP %max.tp | $display.system.message(12 $+ %real.name has regenerated all of $gender($1) TP!, battle)
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }
  else { 
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.desc | query %battlechan 12 $+ %real.name has regenerated %regen.amount TP!, battle)
    writeini $char($1) Status TPRegenerating yes | goto regenhalt 
  }
  :regenhalt
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
  else { halt }
}

alias skill.regen.stop {
  set %check $readini($char($1), Status, regenerating)
  if (%check = yes) { writeini $char($1) Status Regenerating no | $set_chr_name($1) | $display.system.message(3 $+ %real.name stops regenerating, battle) | halt }
  else { $set_chr_name($1) | $display.system.message(4Error: %real.name is not regenerating!, private) | halt }
}

;=================
; KIKOUHENI
;=================
on 3:TEXT:!kikouheni*:*: { $skill.kikouheni($nick, $2) }

alias skill.kikouheni { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, kikouheni) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  var %weather.list $readini(weather.lst, weather, list)
  if ($2 !isin %weather.list) { query $1 4Error: Not a valid weather.  Valid weather types are: %weather.list  | halt }

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, kikouheni.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, Kikouheni, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, kikouheni) = $null) { set %skill.description summons a mystical power that changes the weather! }
    else { set %skill.description $readini($char($1), descriptions, kikouheni) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; write the last used time.
    writeini $char($1) skills kikouheni.time $ctime

    writeini weather.lst weather current $2 
    $display.system.message(3The weather has changed! It is currently $2, battle)

    writeini battle2.txt style $1 $+ .lastaction kikouheni

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, Kikouheni, cooldown) - %time.difference) seconds before you can use !kikouheni again) | halt }
}


;=================
; SHADOW COPY (cloning)
;=================
on 3:TEXT:!clone*:*: { $skill.clone($nick) }
on 3:TEXT:!shadowcopy*:*: { $skill.clone($nick) }
on 3:TEXT:!shadow copy*:*: { $skill.clone($nick) }

alias skill.clone { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, shadowcopy) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  if ($isfile($char($1 $+ _clone)) = $true) { $set_chr_name($1) | $display.system.message(4Error: %real.name has already used this skill for this battle and cannot use it again!, private) | halt }

  ; Display the desc. 
  if ($readini($char($1), descriptions, shadowcopy) = $null) { set %skill.description releases $gender($1) shadow, which comes to life as a clone, ready to fight. }
  else { set %skill.description $readini($char($1), descriptions, shadowcopy) }
  $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

  .copy $char($1) $char($1 $+ _clone)
  if ($readini($char($1), info, flag) = $null) { writeini $char($1 $+ _clone) info flag npc }
  writeini $char($1 $+ _clone) info clone yes 
  writeini $char($1 $+ _clone) info cloneowner $1


  if ($2 = $null) {  writeini $char($1 $+ _clone) basestats name Clone of %real.name }
  if ($2 != $null) { writeini $char($1 $+ _clone) basestats name $2- }

  set %curbat $readini(battle2.txt, Battle, List)
  %curbat = $addtok(%curbat,$1 $+ _clone,46)
  writeini battle2.txt Battle List %curbat
  write battle.txt $1 $+ _clone

  set %current.hp $readini($char($1 $+ _clone), battle, hp)
  if ($readini($char($1), info, flag) = $null) {
    set %current.playerstyle $readini($char($1), styles, equipped)
    set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
    if (%current.playerstyle != Doppelganger) { set %hp $round($calc(%current.hp / 2.5),0) }
    if (%current.playerstyle = Doppelganger) { 
      var %value $calc(2 - (%current.playerstyle.level * .1)) 
      if (%value < 1) { var %value 1 } 
      set %hp $round($calc(%current.hp / %value),0) 
    }
  }

  if ($readini($char($1), info, flag) = npc) {
    set %hp $round($calc(%current.hp / 1.8),0)
    writeini $char($1) skills shadowcopy 0
  }

  if ($readini($char($1), info, flag) = monster) { 
    set %hp $round($calc(%current.hp / 1.5),0)
    writeini $char($1) skills shadowcopy 0
    var %number.of.monsters $readini(battle2.txt, BattleInfo, Monsters)
    inc %number.of.monsters 1
    writeini battle2.txt battleinfo monsters %number.of.monsters
  }

  if (%hp <= 1) { set %hp 1 }

  if ($readini($char($1 $+ _clone), status, ignition.on) = on) { $revert($1 $+ _clone, $readini($char($1 $+ _clone), status, ignition.name)) }
  if ($readini($char($1 $+ _clone), styles, equipped) = doppelganger) { 
    var %style.chance $rand(1,3)
    if (%style.chance = 1) { writeini $char($1 $+ _clone) styles equipped trickster }
    if (%style.chance = 2) { writeini $char($1 $+ _clone) styles equipped guardian }
    if (%style.chance = 3) { writeini $char($1 $+ _clone) styles equipped weaponmaster }
  }


  unset %current.playerstyle | unset %current.playerstyle.level

  writeini $char($1 $+ _clone) battle hp %hp
  writeini $char($1 $+ _clone) basestats hp %hp
  writeini $char($1 $+ _clone) skills shadowcopy 0
  writeini $char($1 $+ _clone) info password .8V%N)W1T;W5C:'1H:7,`1__.114

  unset %hp

  writeini battle2.txt style $1 $+ .lastaction shadowcopy

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}
;=================
; SHADOW CONTROL
;=================
on 3:TEXT:!shadow *:*: { $skill.clonecontrol($nick, $2, $3, $4) }

alias skill.clonecontrol {
  ; $1 = the user of the command
  ; $2 = the command issued
  ; $3 = either the target or the tech/skill to use.
  ; $4 = the target if $3 = tech or skill

  if ($isfile($char($1 $+ _clone)) != $true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, NoCloneToControl), private) | halt }

  $check_for_battle($1 $+ _clone)

  var %cloneowner $readini($char($1 $+ _clone), info, cloneowner)
  var %style.equipped $readini($char(%cloneowner), styles, equipped)

  if (%style.equipped != doppelganger) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, MustUseDoppelgangerStyleToControl), private) | halt }

  var %shadow.command $2 | $set_chr_name($1 $+ _clone)

  if (%shadow.command = taunt) {  $taunt($1 $+ _clone, $3) }
  if (%shadow.command = attack) { set %attack.target $3 | $covercheck($3) |  $attack_cmd($1 $+ _clone , %attack.target) }
  if (%shadow.command = tech) { set %attack.target $4 | $covercheck($4) |  $tech_cmd($1 $+ _clone, $3, %attack.target) }
  if (%shadow.command = skill) { $use.skill($1 $+ _clone, $2, $3, $4) } 

}

;=================
; STEAL
;=================
on 3:TEXT:!steal*:*: { $skill.steal($nick, $2, !steal) }

alias skill.steal { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, steal) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)
  $person_in_battle($2)

  var %target.flag $readini($char($2), info, flag)
  if (%target.flag != monster) { $set_chr_name($1) | $display.system.message(4 $+ %real.name can only steal from monsters!, private) | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message(4 $+ %real.name cannot steal while unconcious!, private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message(4 $+ %real.name cannot steal from someone who is dead!, private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { $display.system.message(4 $+ %real.name cannot steal from $set_chr_name($2) %real.name $+ , because %real.name has run away from the fight!, private) | unset %real.name | halt } 

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, steal.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, Steal, cooldown))) {

    ; Display the desc. 
    $set_chr_name($2) | set %enemy %real.name
    if ($readini($char($1), descriptions, steal) = $null) { set %skill.description sneaks around to %enemy in an attempt to steal something! }
    else { set %skill.description $readini($char($1), descriptions, steal) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; write the last used time.
    writeini $char($1) skills steal.time $ctime

    ; If we're using the Mugger's Belt accessory, let's do some damage.
    if ($readini($char($1), equipment, accessory) = mugger's-belt) {
      unset %attack.damage | unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4
      unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %drainsamba.on | unset %absorb
      unset %enemy | unset %user | unset %real.name

      ; Get the weapon equipped
      $weapon_equipped($1)

      ; Calculate, deal, and display the damage..
      $calculate_damage_weapon($1, %weapon.equipped, $2, mugger's-belt)
      $drain_samba_check($1)
      $deal_damage($1, $2, %weapon.equipped)
      $display_damage($1, $2, weapon, %weapon.equipped)

      unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %critical.hit.chance
    }

    ; Now to check to see if we steal something.
    var %steal.chance $rand(1,100)
    var %skill.steal $readini($char($1), skills, steal)
    inc %steal.chance %skill.steal

    if (%bloodmoon = on) { inc %steal.chance 25 }

    if ($readini($char($1), equipment, accessory) = thief-ring) {
      var %accessory.amount $readini(items.db, thief-ring, amount)
      inc %steal.chance %accessory.amount
    }

    ; Check augment
    if ($augment.check($1, EnhanceSteal) = true) {  inc %steal.chance $calc(2 * %augment.strength) }


    var %current.playerstyle $readini($char($1), styles, equipped)
    if (%current.playerstyle = Trickster) { inc %steal.chance $rand(5,10) }

    if (%steal.chance >= 95) {
      var %stolen.from.counter $readini($char($2), status, stolencounter)
      if (%stolen.from.counter > 5) { $set_chr_name($2) | $display.system.message(4 $+ %real.name  has nothing left to steal!, battle) | halt }

      inc %stolen.from.counter 1 | writeini $char($2) status stolencounter %stolen.from.counter 

      set %steal.pool $readini(steal.lst, stealpool, $2)
      var %steal.orb.amount $rand(1000,3000) 

      if (%steal.pool = $null) { 
        if ($readini($char($2), Info, flag) = monster) { set %steal.pool $readini(steal.lst, stealpool, monster) }
        if ($readini($char($2), Info, flag) = boss) { set %steal.pool $readini(steal.lst, stealpool, boss) }
      }

      if (%bloodmoon = on) { var %steal.orb.amount $rand(3000,5000) }

      set %total.items $numtok(%steal.pool, 46)
      set %random.item $rand(1,%total.items)
      set %steal.item $gettok(%steal.pool,%random.item,46)

      if (%steal.item = $null) { set %steal.item orbs }  
      if (%steal.item = orbs) { 
        if (%steal.orb.amount = $null) { var %steal.orb.amount $rand(100,300)  }
        var %current.orb.amount $readini($char($1), stuff, redorbs) | inc %current.orb.amount %steal.orb.amount | writeini $char($1) stuff redorbs %current.orb.amount 
        $set_chr_name($1) | $display.system.message(2 $+ %real.name has stolen %steal.orb.amount $readini(system.dat, system, currency) from $set_chr_name($2) %real.name $+ ! , battle)
      }
      else {
        set %current.item.total $readini($char($1), Item_Amount, %steal.item) 
        if (%current.item.total = $null) { var %current.item.total 0 }
        inc %current.item.total 1 | writeini $char($1) Item_Amount %steal.item %current.item.total 
        $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, StealItem), battle)
      }
    }
    else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableTosteal), battle) }

    writeini battle2.txt style $1 $+ .lastaction steal 

    unset %enemy | unset %steal.pool

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, Steal, cooldown) - %time.difference) seconds before you can use !steal again) | halt }
}

;=================
; ANALYSIS
;=================
on 3:TEXT:!analyze*:*: { $skill.analysis($nick, $2) }
on 3:TEXT:!analysis*:*: { $skill.analysis($nick, $2) }

alias skill.analysis { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  if ($skillhave.check($nick, analysis) = false) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private) | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1) | $person_in_battle($2) 

  var %analysis.flag $readini($char($2), info, flag) 
  if (%analysis.flag != monster) { $display.system.message($readini(translation.dat, errors, OnlyAnalyzeMonsters), private) | halt }
  ; Display the desc. 
  $set_chr_name($2) | set %enemy %real.name
  if ($readini($char($nick), descriptions, analysis) = $null) { set %skill.description focuses intently on %enemy in an attempt to analyze $gender2($2) $+ ! }
  else { set %skill.description $readini($char($nick), descriptions, analysis) }
  $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Get the level of the skill.  The level will determine the information we get from the skill.
  var %analysis.level $readini($char($1), skills, analysis)

  unset %analysis.weapon.weak | unset %analysis.weapon.strength | unset %analysis.element.weak | unset %analysis.element.strength | unset %analysis.element.absorb
  unset %analysis.element.heal

  ; Get the target info
  var %analysis.hp $readini($char($2), battle, hp) | var %analysis.tp $readini($char($2), battle, tp)
  var %analysis.str $readini($char($2), battle, str) | var %analysis.def $readini($char($2), battle, def)
  var %analysis.int $readini($char($2), battle, int) | var %analysis.spd $readini($char($2), battle, spd)

  ; Check for elemental weaknesses
  if (($readini($char($2), modifiers, earth) > 100) && ($istok($readini($char($2), modifiers, heal), earth, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, earth, 46) }
  if (($readini($char($2), modifiers, fire) > 100) && ($istok($readini($char($2), modifiers, heal), fire, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, fire, 46) }
  if (($readini($char($2), modifiers, wind) > 100) && ($istok($readini($char($2), modifiers, heal), wind, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, wind, 46) }
  if (($readini($char($2), modifiers, ice) > 100) && ($istok($readini($char($2), modifiers, heal), ice, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, ice, 46) }
  if (($readini($char($2), modifiers, water) > 100) && ($istok($readini($char($2), modifiers, heal), water, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, water, 46) }
  if (($readini($char($2), modifiers, lightning) > 100) && ($istok($readini($char($2), modifiers, heal), lightning, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, lightning, 46) }
  if (($readini($char($2), modifiers, light) > 100) && ($istok($readini($char($2), modifiers, heal), light, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, light, 46) }
  if (($readini($char($2), modifiers, dark) > 100) && ($istok($readini($char($2), modifiers, heal), dark, 46) = $false)) { %analysis.element.weak = $addtok(%analysis.element.weak, dark, 46) }

  ; Check for elemental healing
  if ($istok($readini($char($2), modifiers, heal), earth, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, earth, 46) }
  if ($istok($readini($char($2), modifiers, heal), fire, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, fire, 46) }
  if ($istok($readini($char($2), modifiers, heal), wind, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, wind, 46) }
  if ($istok($readini($char($2), modifiers, heal), ice, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, ice, 46) }
  if ($istok($readini($char($2), modifiers, heal), water, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, water, 46) }
  if ($istok($readini($char($2), modifiers, heal), lightning, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, lightning, 46) }
  if ($istok($readini($char($2), modifiers, heal), light, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, light, 46) }
  if ($istok($readini($char($2), modifiers, heal), dark, 46) = $true) { %analysis.element.heal = $addtok(%analysis.element.heal, dark, 46) }

  ;  Check for elemental resistances
  if ($readini($char($2), modifiers, earth) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, earth, 46) }
  if ($readini($char($2), modifiers, fire) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, fire, 46) }
  if ($readini($char($2), modifiers, wind) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, wind, 46) }
  if ($readini($char($2), modifiers, ice) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, ice, 46) }
  if ($readini($char($2), modifiers, water) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, water, 46) }
  if ($readini($char($2), modifiers, lightning) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, lightning, 46) }
  if ($readini($char($2), modifiers, light) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, light, 46) }
  if ($readini($char($2), modifiers, dark) < 100) { %analysis.element.strength = $addtok(%analysis.element.strength, dark, 46) }

  ;  Check for elemental absorb
  if ($readini($char($2), modifiers, earth) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, earth, 46) }
  if ($readini($char($2), modifiers, fire) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, fire, 46) }
  if ($readini($char($2), modifiers, wind) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, wind, 46) }
  if ($readini($char($2), modifiers, ice) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, ice, 46) }
  if ($readini($char($2), modifiers, water) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, water, 46) }
  if ($readini($char($2), modifiers, lightning) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, lightning, 46) }
  if ($readini($char($2), modifiers, light) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, light, 46) }
  if ($readini($char($2), modifiers, dark) = 0) { %analysis.element.absorb = $addtok(%analysis.element.absorb, dark, 46) }

  ; Check for weapon weaknesses
  if ($readini($char($2), modifiers, HandToHand) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, handtohand, 46) }
  if ($readini($char($2), modifiers, Whip) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, whip, 46) }
  if ($readini($char($2), modifiers, Sword) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, sword, 46) }
  if ($readini($char($2), modifiers, gun) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, gun, 46) }
  if ($readini($char($2), modifiers, rifle) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, rifle, 46) }
  if ($readini($char($2), modifiers, katana) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, katana, 46) }
  if ($readini($char($2), modifiers, wand) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, wand, 46) }
  if ($readini($char($2), modifiers, spear) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, spear, 46) }
  if ($readini($char($2), modifiers, scythe) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, scythe, 46) }
  if ($readini($char($2), modifiers, glyph) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, glyph, 46) }
  if ($readini($char($2), modifiers, greatsword) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, greatsword, 46) }
  if ($readini($char($2), modifiers, bow) > 100) { %analysis.weapon.weak = $addtok(%analysis.weapon.weak, bow, 46) }

  ; Check for weapon resistances
  if ($readini($char($2), modifiers, HandToHand) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, handtohand, 46) }
  if ($readini($char($2), modifiers, Whip) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, whip, 46) }
  if ($readini($char($2), modifiers, Sword) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, sword, 46) }
  if ($readini($char($2), modifiers, gun) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, gun, 46) }
  if ($readini($char($2), modifiers, rifle) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, rifle, 46) }
  if ($readini($char($2), modifiers, katana) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, katana, 46) }
  if ($readini($char($2), modifiers, wand) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, wand, 46) }
  if ($readini($char($2), modifiers, spear) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, spear, 46) }
  if ($readini($char($2), modifiers, scythe) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, scythe, 46) }
  if ($readini($char($2), modifiers, glyph) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, glyph, 46) }
  if ($readini($char($2), modifiers, greatsword) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, greatsword, 46) }
  if ($readini($char($2), modifiers, bow) < 100) { %analysis.weapon.strength = $addtok(%analysis.weapon.strength, bow, 46) }

  if (%analysis.weapon.strength = $null) { var %analysis.weapon.strength none }
  if (%analysis.weapon.weak = $null) { var %analysis.weapon.weak none }
  if (%analysis.element.weak = $null) { var %analysis.element.weak none }
  if (%analysis.element.strength = $null) { var %analysis.element.strength none }
  if (%analysis.element.absorb = $null) { var %analysis.element.absorb none }
  if (%analysis.element.heal = $null) { var %analysis.element.heal none }

  set %replacechar $chr(044) $chr(032)
  %analysis.weapon.weak = $replace(%analysis.weapon.weak, $chr(046), %replacechar)
  %analysis.weapon.strength = $replace(%analysis.weapon.strength, $chr(046), %replacechar)
  %analysis.element.weak = $replace(%analysis.element.weak, $chr(046), %replacechar)
  %analysis.element.strength = $replace(%analysis.element.strength, $chr(046), %replacechar)
  %analysis.element.absorb = $replace(%analysis.element.absorb, $chr(046), %replacechar)
  %analysis.element.heal = $replace(%analysis.element.heal, $chr(046), %replacechar)

  if (%analysis.level = 1) {  $set_chr_name($2) | $display.private.message(3You analyze %real.name and determine $gender3($2) has %analysis.hp HP left.) | goto next_turn_check }
  if (%analysis.level = 2) {  $set_chr_name($2) | $display.private.message(3You analyze %real.name and determine $gender3($2) has %analysis.hp HP and %analysis.tp TP left.) | goto next_turn_check }
  if (%analysis.level = 3) {  $set_chr_name($2) | $display.private.message(3You analyze %real.name and determine $gender3($2) has %analysis.hp HP and %analysis.tp TP left.)
    $display.private.message(3You also determine %real.name has the following stats: [str: %analysis.str $+ ] [def: %analysis.def $+ ] [int: %analysis.int $+ ] [spd: %analysis.spd $+ ])
    goto next_turn_check
  }
  if (%analysis.level = 4) {  $set_chr_name($2) | $display.private.message(3You analyze %real.name and determine $gender3($2) has %analysis.hp HP and %analysis.tp TP left.)
    $display.private.message(3You also determine %real.name has the following stats: [str: %analysis.str $+ ] [def: %analysis.def $+ ] [int: %analysis.int $+ ] [spd: %analysis.spd $+ ])
    $display.private.message(3 $+ %real.name is also resistant against the following weapon types: %analysis.weapon.strength and is resistant against the following elements: %analysis.element.strength)
    goto next_turn_check
  }
  if (%analysis.level = 5) {  $set_chr_name($2) | $display.private.message(3You analyze %real.name and determine $gender3($2) has %analysis.hp HP and %analysis.tp TP left.)
    $display.private.message(3You also determine %real.name has the following stats: [str: %analysis.str $+ ] [def: %analysis.def $+ ] [int: %analysis.int $+ ] [spd: %analysis.spd $+ ])
    $display.private.message(3 $+ %real.name is also resistant against the following weapon types: %analysis.weapon.strength and is resistant against the following elements: %analysis.element.strength  $+ $chr(124) %real.name is weak against the following weapon types: %analysis.weapon.weak and weak against the following elements: %analysis.element.weak) 
    goto next_turn_check
  }
  if (%analysis.level = 6) {  $set_chr_name($2) | $display.private.message(3You analyze %real.name and determine $gender3($2) has %analysis.hp HP and %analysis.tp TP left.)
    $display.private.message(3You also determine %real.name has the following stats: [str: %analysis.str $+ ] [def: %analysis.def $+ ] [int: %analysis.int $+ ] [spd: %analysis.spd $+ ])
    $display.private.message(3 $+ %real.name is also resistant against the following weapon types: %analysis.weapon.strength and is resistant against the following elements: %analysis.element.strength  $+ $chr(124) %real.name is weak against the following weapon types: %analysis.weapon.weak and weak against the following elements: %analysis.element.weak) 
    $display.private.message(3 $+ %real.name is completely immune to the following elements: %analysis.element.absorb)
    $display.private.message(3 $+ %real.name will be healed by the following elements: %analysis.element.heal)

    goto next_turn_check
  }

  unset %enemy

  :next_turn_check

  unset %analysis.weapon.weak | unset %analysis.weapon.strength | unset %analysis.element.weak | unset %analysis.element.strength | unset %analysis.element.absorb

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}

;=================
; QUICKSILVER
;=================
on 3:TEXT:!quicksilver*:*: { $skill.quicksilver($nick) }

alias skill.quicksilver { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  set %current.playerstyle $readini($char($1), styles, equipped)
  if (%current.playerstyle != Quicksilver) { $display.system.message(4Error: This command can only be used while the Quicksilver style is equipped!, private) | unset %current.playerstyle | halt }

  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
  set %quicksilver.used $readini($char($1), skills, quicksilver.used)
  set %quicksilver.turn $readini($char($1), skills, quicksilver.turn)
  if (%quicksilver.used = $null) { set %quicksilver.used 0 }
  if (%quicksilver.turn = $null) { set %quicksilver.turn -1 }

  if (%quicksilver.used >= %current.playerstyle.level) { $set_chr_name($1) | $display.system.message(4 $+ %real.name cannot use $gender($1) Quicksilver power again this battle!,private) | unset %current.playerstyle | halt }
  if (($calc(%quicksilver.turn + 1) = %current.turn) || (%quicksilver.turn = %current.turn)) { $set_chr_name($1) | $display.system.message(4 $+ %real.name cannot use $gender($1) Quicksilver power again so quickly!, private) | unset %current.playerstyle | halt }

  inc %quicksilver.used 1 | writeini $char($1) skills quicksilver.used %quicksilver.used
  writeini $char($1) skills quicksilver.turn %current.turn

  if ($readini($char($nick), descriptions, quicksilver) = $null) { $set_chr_name($1) | set %skill.description unleashes the power of Quicksilver! Time seems to stop for everyone except %real.name $+ ! }
  else { set %skill.description $readini($char($nick), descriptions, quicksilver) }
  $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line battle.txt
    if (%who.battle != $1) { writeini $char(%who.battle) status stop yes }

    inc %battletxt.current.line 1 
  }

  writeini $char($1) skills doubleturn.on on

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
  unset %current.playerstyle | unset %current.playerstyle.level | unset %quicksilver.used
}

;=================
; COVER
;=================
on 3:TEXT:!cover*:*: { $skill.cover($nick, $2) }

alias skill.cover { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($2)

  if ($readini($char($1), info, flag) = $null) {
    if ($skillhave.check($nick, cover) = false) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }
  }

  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1) | $person_in_battle($2) 

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, cover.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, Cover, cooldown))) {
    var %cover.status $readini($char($2), battle, status)
    if ((%cover.status = dead) || (%cover.status = runaway)) { $display.system.message($readini(translation.dat, skill, CoverTargetDead), private) | halt }

    var %cover.target $readini($char($2), skills, CoverTarget)
    if  ($readini($char($1), info, flag) = $null) {
      if ((%cover.target != none) && (%cover.target != $null)) { $display.system.message($readini(translation.dat, skill, AlreadyBeingCovered),private) | halt  }
    }

    var %user.flag $readini($char($1), info, flag) 
    if (%user.flag = $null) { var %user.flag player }
    var %target.flag $readini($char($2), info, flag)

    if (%user.flag = player) && (%target.flag = monster) { $readini(translation.dat, errors, CannotCoverMonsters) | halt }

    writeini $char($2) skills CoverTarget $1

    ; Display the desc. 
    $set_chr_name($2) | set %enemy %real.name
    if ($readini($char($1), descriptions, cover) = $null) { set %skill.description prepares to leap in front of %enemy in order to defend $gender2($2) }
    else { set %skill.description $readini($char($1), descriptions, cover) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; write the last used time.
    writeini $char($1) skills cover.time $ctime
    writeini battle2.txt style $1 $+ .lastaction cover

    unset %enemy

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, Cover, cooldown) - %time.difference) seconds before you can use !cover again) | halt }
}

;=================
; SNATCH
;=================
on 3:TEXT:!snatch*:*: { $skill.snatch($nick, $2) }

alias skill.snatch { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($2)

  ; Do we have an augment or something that lets us snatch a monster?

  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1) | $person_in_battle($2) 

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, snatch.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > 120)) {
    var %cover.status $readini($char($2), battle, status)
    if ((%cover.status = dead) || (%cover.status = runaway)) { $display.system.message($readini(translation.dat, skill, SnatchTargetDead), private) | halt }

    var %cover.target $readini($char($2), skills, CoverTarget)
    if ((%cover.target != none) && (%cover.target != $null)) { $display.system.message($readini(translation.dat, skill, AlreadyBeingHeld), private) | halt  }

    var %user.flag $readini($char($1), info, flag) 
    if (%user.flag = $null) { var %user.flag player }
    var %target.flag $readini($char($2), info, flag)

    if (%user.flag = player) && (%target.flag != monster) { 
      if (%mode.pvp != on) { $display.system.message($readini(translation.dat, errors, CannotSnatchPlayers), private) | halt }
    }

    if ($isfile($boss($2)) = $true) { $display.system.message($readini(translation.dat, errors, CannotSnatchBosses), private) | halt }

    ; Display the desc. 
    $set_chr_name($2) | set %enemy %real.name
    if ($readini($char($1), descriptions, snatch) = $null) { set %skill.description grabs onto %enemy and tries to use $gender2($2) as a shield! }
    else { set %skill.description $readini($char($1), descriptions, snatch) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    $do.snatch($1, $2)

    unset %enemy

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc(120 - %time.difference) seconds before you can use !snatch again) | halt }
}

alias do.snatch {
  var %snatch.chance $rand(1,100)

  var %user.speed $readini($char($1), battle, spd)
  var %target.speed $readini($char($2), battle, spd)
  var %user.level $get.level($1) | var %target.level $get.level($2)

  if (%user.speed > %target.speed) { inc %snatch.chance 10 }
  if (%user.speed < %target.speed) { dec %snatch.chance 10 }
  if (%user.level > %target.level) { inc %snatch.chance 5 }
  if (%user.level < %target.level) { inc %snatch.chance 5 }

  if ($augment.check($1, EnhanceSnatch) = true) { inc %snatch.chance $round($calc(3.5 * %augment.strength),0) }

  if (%snatch.chance >= 70) { 
    writeini $char($1) skills CoverTarget $2 
    $display.system.message($readini(translation.dat, battle, TargetSnatched), battle)
  }
  if (%snatch.chance < 70) {
    $display.system.message($readini(translation.dat, battle, TargetNotSnatched), battle)
  }

  ; write the last used time.
  writeini $char($1) skills snatch.time $ctime
  writeini battle2.txt style $1 $+ .lastaction snatch

  return

}


;=================
; AGGRESSOR 
;=================
on 3:TEXT:!aggressor*:*: { $skill.aggressor($nick) }

alias skill.aggressor { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  if ($skillhave.check($1, aggressor) = false) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private) | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  if ($readini($char($1), skills, aggressor.on) = on) { $set_chr_name($1) | $display.system.message(4 $+ %real.name has already used this skill once this battle and cannot use it again until the next battle., private) | halt }

  ; Display the desc. 
  if ($readini($char($1), descriptions, aggressor) = $null) { set %skill.description gives a loud battle warcry as $gender($1) strength is enhanced at the cost of $gender($1) defense! }
  else { set %skill.description $readini($char($1), descriptions, aggressor) }
  $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Increase the strength
  var %strength $readini($char($1), battle, str)
  var %defense $readini($char($1), battle, def)
  var %skill.level $readini($char($1), skills, aggressor)
  var %skill.increase.percent $calc(%skill.level * .10)

  if ($augment.check($1, EnhanceAggressor) = true) {  inc %skill.increase.percent $calc(%augment.strength * .10) }

  var %increase.amount $round($calc(%skill.increase.percent * %defense),0)
  inc %strength %increase.amount
  writeini $char($1) battle str %strength
  writeini $char($1) battle def 5

  ; Toggle the speed-on flag so players can't use it again in the same battle.
  writeini $char($1) skills aggressor.on on

  writeini battle2.txt style $1 $+ .lastaction aggressor

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}

;=================
; DEFENDER
;=================
on 3:TEXT:!defender*:*: { $skill.defender($nick) }

alias skill.defender { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  if ($skillhave.check($1, defender) = false) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  if ($readini($char($1), skills, defender.on) = on) { $set_chr_name($1) | $display.system.message(4 $+ %real.name has already used this skill once this battle and cannot use it again until the next battle.,private) | halt }

  ; Display the desc. 
  if ($readini($char($1), descriptions, aggressor) = $null) { set %skill.description decides that the best offense is a good defense and sacrifices $gender($1) strength for defense! }
  else { set %skill.description $readini($char($1), descriptions, defender) }
  $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Increase the defense
  var %strength $readini($char($1), battle, str)
  var %defense $readini($char($1), battle, def)
  var %skill.level $readini($char($1), skills, defender)
  var %skill.increase.percent $calc(%skill.level * .10)

  if ($augment.check($1, EnhanceDefender) = true) { 
    inc %skill.increase.percent $calc(%augment.strength * .10)
  }

  var %increase.amount $round($calc(%skill.increase.percent * %strength),0)
  inc %defense %increase.amount
  writeini $char($1) battle str 5
  writeini $char($1) battle def %defense

  ; Toggle the speed-on flag so players can't use it again in the same battle.
  writeini $char($1) skills defender.on on

  writeini battle2.txt style $1 $+ .lastaction defender

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}


;=================
; CRAFTING/ALCHEMY
;=================
on 3:TEXT:!alchemy*:*: { $skill.alchemy($nick, $2) }
on 3:TEXT:!craft*:*: { $skill.alchemy($nick, $2) }

alias skill.alchemy { 
  ; $1 = person crafting
  ; $2 = the item you're trying to craft.
  $set_chr_name($1)

  if ($skillhave.check($nick, alchemy) = false) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }

  set %gem.required $readini(crafting.db, $2, gem)
  if (%gem.required = $null) { .unset %gem.required | $display.system.message($readini(translation.dat, errors, CannotCraftThisItem),private) | halt }

  ; Does the user have the gem necessary to craft the item?
  set %player.gem.amount $readini($char($1), item_amount, %gem.required)  
  if (%player.gem.amount = $null) { set %player.gem.amount 0 } 
  if (%player.gem.amount < 1) { unset %player.gem.amount | unset %gem.required | $display.system.message($readini(translation.dat, errors, MissingCorrectGem),private) | halt } 

  ; Check each ingredient and add total ingredients vs needed ingredients.
  var %player.ingredients 0 |  var %ingredients $readini(crafting.db, $2, ingredients)
  var %total.ingredients $numtok(%ingredients, 46)

  var %value 1
  while (%value <= %total.ingredients) {
    set %item.name $gettok(%ingredients, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)
    set %item_type $readini(items.db, %item.name, type)
    set %amount.needed $readini(crafting.db, $2, %item.name)
    if (%amount.needed = $null) { set %amount.needed 1 }


    if (%item_type = accessory) { 
      var %equipped.accessory $readini($char($1), equipment, accessory) 
      if (%equipped.accessory = %item.name) { dec %item_amount 1 }
    }
    if (%item_type = $null) { 
      set %item_type $readini(equipment.db, %item.name, EquipLocation)
      if (%item_type = head) {
        var %equipped.armor $readini($char($1), equipment, head) 
        if (%equipped.armor = %item.name) { dec %item_amount 1 }
      }
      if (%item_type = body) {
        var %equipped.armor $readini($char($1), equipment, body) 
        if (%equipped.armor = %item.name) { dec %item_amount 1 }
      }
      if (%item_type = legs) {
        var %equipped.armor $readini($char($1), equipment, legs) 
        if (%equipped.armor = %item.name) { dec %item_amount 1 }
      }
      if (%item_type = feet) {
        var %equipped.armor $readini($char($1), equipment, feet) 
        if (%equipped.armor = %item.name) { dec %item_amount 1 }
      }
      if (%item_type = hands) {
        var %equipped.armor $readini($char($1), equipment, hands) 
        if (%equipped.armor = %item.name) { dec %item_amount 1 }
      }
    }

    if ((%item_amount != $null) && (%item_amount >= %amount.needed)) { 
      inc %player.ingredients 1
    }
    inc %value 1 
  }

  if (%player.ingredients < %total.ingredients) { $display.system.message($readini(translation.dat, errors, MissingIngredients),private)  | halt }

  ; Display the desc. 
  if ($readini($char($1), descriptions, aggressor) = $null) { set %skill.description uses the power of the gem to combine ingredients in an attempt to create something better! }
  else { set %skill.description $readini($char($1), descriptions, alchemy) }
  $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, global) 


  ; Check for success or not.
  set %base.success $readini(crafting.db, $2, successrate)
  inc %base.success $readini($char($1), skills, alchemy)
  var %random.chance $rand(1,100)

  if (%random.chance <= %base.success) { 
    $display.system.message($readini(translation.dat, skill, CraftingSuccess), global)
    var %player.amount.item $readini($char($1), item_amount, $2) 
    inc %player.amount.item $readini(crafting.db, $2, amount)
    writeini $char($1) item_amount $2 %player.amount.item

  }
  if (%random.chance > %base.success) {
    $display.system.message($readini(translation.dat, skill, CraftingFailure), global)
  }

  var %value 1
  while (%value <= %total.ingredients) {
    set %item.name $gettok(%ingredients, %value, 46)
    set %item_amount $readini($char($1), item_amount, %item.name)
    set %amount.needed $readini(crafting.db, $2, %item.name)

    if (%amount.needed = $null) { set %amount.needed 1 }
    dec %item_amount %amount.needed | writeini $char($1) item_amount %item.name %item_amount
    inc %value 1 
  }

  dec %player.gem.amount 1 | writeini $char($1) item_amount %gem.required %player.gem.amount

  unset %gem.required | unset %player.gem.amount | unset %item.name | unset %item_amount | unset %base.success | unset %item_type | unset %amount.needed
}

;=================
; HOLY AURA
;=================
on 3:TEXT:!holy aura*:*: { $skill.holyaura($nick) }
on 3:TEXT:!holyaura*:*: { $skill.holyaura($nick) }

alias skill.holyaura { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, holyaura) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  if (%battle.rage.darkness != $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DarknessAlreadyInEffect), private)  | halt }
  if (%holy.aura != $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, Skill, HolyAuraAlreadyOn), private)  | halt }

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, holyaura.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  inc %time.difference $calc(%time.difference + ($readini($char($1), skills, holyaura) * 60))

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, HolyAura, cooldown))) {

    set %holy.aura.time.lasts $calc($readini($char($1), skills, HolyAura) * 60)

    ; Display the desc. 
    if ($readini($char($1), descriptions, holyaura) = $null) { set %skill.description releases a holy aura that covers the battlefield and keeps the darkness at bay for $calc(%holy.aura.time.lasts / 60) minute(s). }
    else { set %skill.description $readini($char($1), descriptions, holyaura) }
    set %skill.description $replace(%skill.description,#time,$readini($char($1), skills, HolyAura))
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; Toggle the last time used
    writeini $char($1) skills holyaura.time $ctime

    set %total.darkness.timer $timer(BattleRage).secs 

    /.timerBattleRage off
    /.timerHolyAura 1 %holy.aura.time.lasts  /holy_aura_end $1 %total.darkness.timer
    set %holy.aura on

    unset %holy.aura.time.lasts

    writeini battle2.txt style $1 $+ .lastaction holyaura

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, HolyAura, cooldown) - %time.difference) seconds before you can use !holy aura again) | halt }
}

alias holy_aura_end {
  unset %holy.aura
  $set_chr_name($1) | $display.system.message($readini(translation.dat, skill,  HolyAuraEnd), private)
  unset %total.darkness.timer 

  if (%darkness.fivemin.warn = true) {    /.timerBattleRage 1 $2 /battle_rage }
  else {   /.timerBattleRage 1 $2 /battle_rage_warning }
}

;=================
; MONSTER COCOON/EVOLVE
;=================
alias skill.cocoon.evolve {
  $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private)   | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($readini($char($1), info, flag) = $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, PlayersCannotUseSkill),private) | halt } 

  ; Display the desc. 
  if ($readini($char($1), descriptions, cocoonevolve) = $null) { set %skill.description is enveloped by a large cocoon-like protective barrier as $gender3($1) prepares for an evolved state. }
  else { set %skill.description $readini($char($1), descriptions, cocoonevolve) }
  $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

  writeini $char($1) status cocoon yes
  writeini $char($1) status cocoon.timer 1
  writeini $char($1) skills cocoonevolve 0

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}

;=================
; MONSTER MAGIC SHIFT
;=================
alias skill.magic.shift {
  $set_chr_name($1)
  if ($is_charmed($1) = true) { return }
  if (no-skill isin %battleconditions) { return }
  if ($readini($char($1), status, amnesia) = yes) { return }

  $checkchar($1)
  if ($readini($char($1), info, flag) = $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, PlayersCannotUseSkill),private) | halt } 

  ; Display the desc. 
  if ($readini($char($1), descriptions, magicshift) = $null) { set %skill.description is covered with a rainbow-colored light that quickly fades. }
  else { set %skill.description $readini($char($1), descriptions, magicshift) }
  $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

  set %magic.types light.dark.fire.ice.water.lightning.wind.earth
  set %number.of.magic.types $numtok(%magic.types,46)

  writeini $char($1) modifiers light 100
  writeini $char($1) modifiers dark 100
  writeini $char($1) modifiers fire 100
  writeini $char($1) modifiers ice 100
  writeini $char($1) modifiers water 100
  writeini $char($1) modifiers lightning 100
  writeini $char($1) modifiers wind 100
  writeini $char($1) modifiers earth 100

  var %numberof.weaknesses $rand(1,3)

  var %value 1
  while (%value <= %numberof.weaknesses) {
    set %weakness.number $rand(1,%number.of.magic.types)
    %weakness = $gettok(%magic.types,%weakness.number,46)
    if (%weakness != $null) {  writeini $char($1) modifiers %weakness 120 }
    inc %value
  }

  var %numberof.strengths $rand(1,3)

  var %value 1
  while (%value <= %numberof.strengths) {
    set %strength.number $rand(1,%number.of.magic.types)
    %strengths = $gettok(%magic.types,%strength.number,46)
    if (%strengths != $null) {  writeini $char($1) modifiers %strengths 50 }
    inc %value
  }

  var %numberof.heal $rand(1,2)

  var %value 1
  while (%value <= %numberof.heal) {
    set %heal.number $rand(1,%number.of.magic.types)
    %heals = $addtok(%heals, $gettok(%magic.types,%heal.number,46),46)
    inc %value
  }

  if (%heals != $null) { writeini $char($1) modifiers Heal %heals }

  unset %heal.number | unset %heals
  unset %strengths | unset %strength.number
  unset %weakness | unset %weakness.number
  unset %number.of.magic.types | unset %magic.types

  return
}

;=================
; MONSTER CONSUME
;=================
alias skill.monster.consume {
  set %debug.location skill.monster.consume
  $set_chr_name($1)
  if ($is_charmed($1) = true) { return }

  $checkchar($1)
  if ($readini($char($1), info, flag) = $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, PlayersCannotUseSkill),private) | halt } 

  ; Display the desc. 
  if ($readini($char($1), descriptions, monsterconsume) = $null) { set %skill.description grabs $set_chr_name($2) $+ %real.name and eats $gender2($2) $+ , gaining some of %real.name $+ 's power in the process! }
  else { set %skill.description $readini($char($1), descriptions, monsterconsume) }
  $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Increase the user's stats

  var %tp $readini($char($1), battle, tp)
  var %str $readini($char($1), Battle, Str)
  var %def $readini($char($1), Battle, Def)
  var %int $readini($char($1), Battle, Int)
  var %spd $readini($char($1), Battle, Spd)

  inc %tp $round($calc($readini($char($2), battle, tp) * .45),0)
  inc %str $round($calc($readini($char($2), battle, str) * .45),0)
  inc %def $round($calc($readini($char($2), battle, def) * .45),0)
  inc %int $round($calc($readini($char($2), battle, int) * .45),0)
  inc %spd $round($calc($readini($char($2), battle, spd) * .45),0)

  writeini $char($1) Battle Tp %tp
  writeini $char($1) Battle Str %str
  writeini $char($1) Battle Def %def
  writeini $char($1) Battle Int %int
  writeini $char($1) Battle Spd %spd

  ; Set the other monster as dead
  writeini $char($2) battle status dead
  writeini $char($2) battle hp 0

  if (%battleis = on)  { $check_for_double_turn($1) }
}

;=================
; MONSTER DEMON PORTAL
;=================
alias skill.demonportal {
  $set_chr_name($1)
  if ($is_charmed($1) = true) { return }
  if (no-skill isin %battleconditions) { return }
  if ($readini($char($1), status, amnesia) = yes) { return }

  $checkchar($1)
  if ($readini($char($1), info, flag) = $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, PlayersCannotUseSkill),private) | halt } 

  if ($readini($char(demon_portal), battle, hp) <= 0) { 
    ; Portal is dead. Let's just return.
    return
  }

  if ($readini($char(demon_portal), battle, hp) > 0) { 
    ; Portal already exists, let's repair it.
    if ($readini($char(demon_portal), battle, hp) < $readini($char(demon_portal), basestats, hp)) { 
      $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ begins work on repairing the damaged portal., battle)
      set %attack.damage $round($calc($readini($char($1), battle, hp) / 2),0)
      $heal_damage($1, demon_portal, skill)
      $display_heal($1, demon_portal ,aoeheal, skill)
    }
    else { return }
  }

  if ($readini($char(demon_portal), battle, hp) = $null) {
    if ($readini($char($1), descriptions, demonportal) = $null) { set %skill.description runs to the edge of the battlefield and performs a powerful summoning spell that opens a demonic portal so that more reinforcements can arrive.  }
    else { set %skill.description $readini($char($1), descriptions, demonportal) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description,battle)
    $generate_demonportal
    set %multiple.wave yes
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  return
}

;=================
; MONSTER SUMMON
;=================
alias skill.monstersummon {
  ; $1 = user
  ; $2 = name of summon
  ; $3 = item used to summon

  if ($readini($char($1), info, flag) = $null) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, PlayersCannotUseSkill),private) | halt } 

  set %monster.name $2
  set %number.of.spawns.needed $readini($char($1), skills, monstersummon.numberspawn)

  if (%number.of.spawns.needed = $null) { var %number.of.spawns.needed 1 }

  ; Is it a valid monster? If not, return.
  if ($isfile($mon(%monster.name)) = $false) { return }


  ; Display the desc. 
  if ($readini($char($1), descriptions, monstersummon) = $null) { $set_chr_name($1) | set %skill.description %real.name opens a vortex and summons %number.of.spawns.needed $2 $+ (s) into the battle. }
  else { set %skill.description $readini($char($1), descriptions, monstersummon) }
  $display.system.message(4 $+ %skill.description, battle)

  var %spawn.current 1
  while (%spawn.current <= %number.of.spawns.needed) {
    ; Check to see if the monster already exists..  if so, just increase the # at the end of its name.
    if ($isfile($char(%monster.name)) = $true) {
      var %value 2

      while ($isfile($char(%monster.name)) = $true) {
        set %monster.name $2 $+ %value
        inc %value
      }
    }

    .copy -o $mon($2) $char(%monster.name)
    writeini $char(%monster.name) Basestats Name %monster.name

    ; Add to battle
    set %curbat $readini(battle2.txt, Battle, List)
    %curbat = $addtok(%curbat,%monster.name,46)
    writeini battle2.txt Battle List %curbat
    write battle.txt %monster.name

    var %number.of.monsters $readini(battle2.txt, battleinfo, Monsters)
    inc %number.of.monsters 1
    writeini battle2.txt battleinfo Monsters %number.of.monsters

    $set_chr_name($1) 
    $boost_monster_stats(%monster.name, monstersummon, $1)
    $fulls(%monster.name) 

    ; Display the desc of the monsters
    $set_chr_name(%monster.name) | $display.system.message(12 $+ %real.name  $+ $readini($char(%monster.name), descriptions, char), battle)

    writeini $char(%monster.name) skills Cover 100
    writeini $char(%monster.name) info master $1

    inc %spawn.current 1
  }

  unset %number.of.spawns.needed

  return
}


;=================
; PROVOKE
;=================
on 3:TEXT:!provoke*:*: { $skill.provoke($nick, $2) }

alias skill.provoke { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($2)
  if ($skillhave.check($nick, provoke) = false) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1) | $person_in_battle($2) 

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, provoke.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, provoke, cooldown))) {
    var %provoke.status $readini($char($2), battle, status)
    if ((%provoke.status = dead) || (%provoke.status = runaway)) { $display.system.message($readini(translation.dat, skill, provokeTargetDead),private) | halt }

    var %provoke.target $readini($char($2), skills, provoke.target)
    if (%provoke.target != $null) { $display.system.message($readini(translation.dat, skill, AlreadyBeingProvoked),private) | halt  }

    var %user.flag $readini($char($1), info, flag) 
    if (%user.flag = $null) { var %user.flag player }
    var %target.flag $readini($char($2), info, flag)

    if (%user.flag = player) && (%target.flag = player) { $readini(translation.dat, errors, CannotprovokePlayers) | halt }
    if (%user.flag = player) && (%target.flag = npc) { $readini(translation.dat, errors, CannotprovokePlayers) | halt }

    writeini $char($2) skills provoke.target $1

    ; Display the desc. 
    if ($readini($char($1), descriptions, provoke) = $null) { $set_chr_name($2) | set %skill.description makes a series of gestures towards %real.name in order to provoke $gender2($2) }
    else { set %skill.description $readini($char($1), descriptions, provoke) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; write the last used time.
    writeini $char($1) skills provoke.time $ctime

    writeini battle2.txt style $1 $+ .lastaction provoke

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, provoke, cooldown) - %time.difference) seconds before you can use !provoke again) | halt }
}

;=================
; WEAPON LOCK
;=================
on 3:TEXT:!weaponlock*:*: { $skill.weaponlock($nick, $2) }
on 3:TEXT:!weapon lock*:*: { $skill.weaponlock($nick, $3) }

alias skill.weaponlock { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  if ($readini($char($1), info, clone) = yes) { $display.system.message($readini(translation.dat, errors, ShadowClonesCan'tUseSkill,private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($2)
  if ($skillhave.check($1, weaponlock) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1) | $person_in_battle($2) 
  if (($2 = $1) && ($is_charmed($1) = false))  { $display.system.message($readini(translation.dat, errors, Can'tAttackYourself),private) | unset %real.name | halt  }

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, weaponlock.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, weaponlock, cooldown))) {
    var %wpnlck.status $readini($char($2), battle, status)
    if ((%wpnlck.status = dead) || (%wpnlck.status = runaway)) { $display.system.message($readini(translation.dat, skill, WeaponLockTargetDead),private) | halt }

    var %user.flag $readini($char($1), info, flag) 
    if (%user.flag = $null) { var %user.flag player }
    var %target.flag $readini($char($2), info, flag)

    if (%mode.pvp = on) { var %user.flag monster }

    if (%user.flag = player) && (%target.flag = player) { $readini(translation.dat, errors, CannotWeaponLockPlayers) | halt }
    if (%user.flag = player) && (%target.flag = npc) { $readini(translation.dat, errors, CannotWeaponLockPlayers) | halt }

    var %weapon.lock.target $readini($char($2), status, weapon.locked)
    if (%weapon.lock.target != $null) { $display.system.message($readini(translation.dat, skill, AlreadyWeaponLocked),private) | halt  }

    ; Check for the item "Sokubaku" and consume it, or display an error if they don't have any.
    set %check.item $readini($char($1), item_amount, Sokubaku)
    if ((%check.item = $null) || (%check.item <= 0)) { $display.system.message(4Error: %real.name does not have enough Sokubaku to perform this skill,private) | halt }
    $decrease_item($1, Sokubaku) 

    ; Display the desc. 
    if ($readini($char($1), descriptions, weaponlock) = $null) { $set_chr_name($2) | set %skill.description uses an ancient technique to place a powerful seal around %real.name $+ 's weapon, preventing $gender2($2) from removing or changing it. }
    else { set %skill.description $readini($char($1), descriptions, weaponlock) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; write the last used time.
    writeini $char($1) skills weaponlock.time $ctime

    writeini battle2.txt style $1 $+ .lastaction weaponlock


    if ($readini($char($2), info, flag) = monster) {
      ; Check for resistance to weaponlock
      set %resist.skill $readini($char($2), skills, resist-weaponlock)
      if (%resist.skill >= 100) { $set_chr_name($2) | $display.system.message(%real.name is immune to the weapon lock status!,battle) }

      else {    
        writeini $char($2) status weapon.locked yes 
        writeini $char($2) status weaponlock.timer 1 
      }


    }
    if (($readini($char($2), info, flag) = npc) || ($readini($char($2), info, flag) = $null)) {
      writeini $char($2) status weapon.locked yes 
      writeini $char($2) status weaponlock.timer 1 
    }


    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, weaponlock, cooldown) - %time.difference) seconds before you can use !weapon lock again) | halt }
}


;=================
; DISARM
;=================
on 3:TEXT:!disarm*:*: { $skill.disarm($nick, $2) }

alias skill.disarm { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($2)
  if ($skillhave.check($nick, disarm) = false) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1) | $person_in_battle($2) 
  if (($2 = $1) && ($is_charmed($1) = false))  { $display.system.message($readini(translation.dat, errors, Can'tAttackYourself),private) | unset %real.name | halt  }

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, disarm.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, disarm, cooldown))) {
    var %disarm.status $readini($char($2), battle, status)
    if ((%disarm.status = dead) || (%disarm.status = runaway)) { $display.system.message($readini(translation.dat, skill, DisarmTargetDead),private) | halt }

    var %user.flag $readini($char($1), info, flag) 
    if (%user.flag = $null) { var %user.flag player }
    var %target.flag $readini($char($2), info, flag)

    if (%mode.pvp = on) { var %user.flag monster }

    if (%user.flag = player) && (%target.flag = player) { $readini(translation.dat, errors, CannotDisarmPlayers) | halt }
    if (%user.flag = player) && (%target.flag = npc) { $readini(translation.dat, errors, CannotDisarmPlayers) | halt }

    ; Display the desc. 
    if ($readini($char($1), descriptions, disarm) = $null) { $set_chr_name($2) | set %skill.description grapples with %real.name in an attempt to disarm $gender2($2) }
    else { set %skill.description $readini($char($1), descriptions, disarm }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; write the last used time.
    writeini $char($1) skills disarm.time $ctime

    var %disarm.chance $rand(1,100)
    var %skill.disarm $readini($char($1), skills, disarm)
    inc %disarm.chance %skill.disarm

    if (%disarm.chance >= 60) {
      writeini $char($2) weapons equipped fists
      if ($readini($char($2), weapons, fists) = $null) { writeini $char($2) weapons fists $readini(battlestats.dat, battle, winningstreak) }
      $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, DisarmedTarget), battle)
    }
    if (%disarm.chance < 60) { 
      $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToDisarm), battle) 
    }

    writeini battle2.txt style $1 $+ .lastaction disarm

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, disarm, cooldown) - %time.difference) seconds before you can use !disarm again) | halt }
}


;=================
; KONZEN-ITTAI
;=================
on 3:TEXT:!konzen-ittai*:*: { $skill.konzen-ittai($nick) }

alias skill.konzen-ittai { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, Konzen-ittai) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill),private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, konzen-ittai.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)
  inc %time.difference $calc(%time.difference + ($readini($char($1), skills, konzen-ittai)) * 60))

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, Konzen-ittai, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, Konzen-ittai) = $null) { set %skill.description channels an ancient power of the samurai that helps increase the amount of renkei $gender($1) weapon is worth. }
    else { set %skill.description $readini($char($1), descriptions, Konzen-ittai) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; Toggle the flag & write the last used time.
    writeini $char($1) skills konzen-ittai.on on
    writeini $char($1) skills konzen-ittai.time $ctime

    writeini battle2.txt style $1 $+ .lastaction konzen-ittai

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private)  | $display.private.message(3You still have $calc($readini(skills.db, Konzen-ittai, cooldown) - %time.difference) seconds before you can use !Konzen-ittai again) | halt }
}

;=================
; Seal Break
;=================
on 3:TEXT:!sealbreak*:*: { $skill.sealbreak($nick) }
on 3:TEXT:!seal break*:*: { $skill.sealbreak($nick) }

alias skill.sealbreak { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if ($readini($char($1), info, clone) = yes) { $display.system.message($readini(translation.dat, errors, ShadowClonesCan'tUseSkill,private) | halt }

  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  if ($skillhave.check($1, sealbreak) = false) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill),private) | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  if ((no-tech !isin %battleconditions) && (no-techs !isin %battleconditions)) { $display.system.message($readini(translation.dat, errors, SkillWon'tWorkNotMeleeOnly), private) | halt }

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, sealbreak.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, sealbreak, cooldown))) {

    ; Check for the item "Hankai" and consume it, or display an error if they don't have any.
    set %check.item $readini($char($1), item_amount, Hankai)
    if ((%check.item = $null) || (%check.item <= 0)) { $set_chr_name($1) | $display.system.message(4Error: %real.name does not have enough Hankai to perform this skill, private) | halt }
    $decrease_item($1, Hankai) 

    ; Display the desc. 
    if ($readini($char($1), descriptions, sealbreak) = $null) { $set_chr_name($2) | set %skill.description lays some Hankai powder upon the seal and chants a powerful mantra in an attempt to break the seal. }
    else { set %skill.description $readini($char($1), descriptions, sealbreak) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; write the last used time.
    writeini $char($1) skills sealbreak.time $ctime
    writeini battle2.txt style $1 $+ .lastaction sealbreak

    var %random.chance $rand(1,100)
    var %chance.of.working $calc($readini($char($1), skills, sealbreak) * 10)
    if (%random.chance <= %chance.of.working) { $display.system.message($readini(translation.dat, skill, MeleeSealBreaks), battle) | unset %battleconditions }
    if (%random.chance > %chance.of.working) { $display.system.message($readini(translation.dat, skill, MeleeSealStays), battle) }

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, sealbreak, cooldown) - %time.difference) seconds before you can use !seal break again) | halt }
}

;=================
; MAGIC MIRROR
;=================
on 3:TEXT:!magicmirror*:*: { $skill.magicmirror($nick) }

alias skill.magicmirror { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, magicmirror) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill),private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, magicmirror.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  inc %time.difference $calc(%time.difference + ($readini($char($1), skills, magicmirror) * 60))

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, magicmirror, cooldown))) {

    ; Check for the item "Shihei" and consume it, or display an error if they don't have any.
    set %check.item $readini($char($1), item_amount, MirrorShard)
    if ((%check.item = $null) || (%check.item <= 0)) { $display.system.message(4Error: %real.name does not have enough MirrorShards to perform this skill, private) | halt }
    $decrease_item($1, MirrorShard) 

    ; Display the desc. 
    if ($readini($char($1), descriptions, magicmirror) = $null) { $set_chr_name($1) | set %skill.description pulls out a magic mirror shard which expands into a large reflective barrier around %real.name $+ 's body. }
    else { set %skill.description $readini($char($1), descriptions, magicmirror) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; Toggle the magicmirror-on flag & write the last used time.
    writeini $char($1) status reflect yes
    writeini $char($1) status reflect.timer 1
    writeini $char($1) skills magicmirror.time $ctime

    writeini battle2.txt style $1 $+ .lastaction magicmirror

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, magicmirror, cooldown) - %time.difference) seconds before you can use !magicmirror again) | halt }
}

;=================
; GAMBLE
;=================
on 3:TEXT:!gamble*:*: { $skill.gamble($nick) }

alias skill.gamble { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, gamble) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill),private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, gamble.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  inc %time.difference $calc(%time.difference + ($readini($char($1), skills, gamble) * 60))

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, gamble, cooldown))) {

    ; Check for 1k orbs
    set %check.item $readini($char($1), stuff, RedOrbs)
    if ((%check.item = $null) || (%check.item <= 1000)) { $display.system.message(4Error: %real.name does not have enough $readini(system.dat, system, currency) to perform this skill [need $calc(1000 - %check.item) more!], private) | halt }
    dec %check.item 1000
    writeini $char($1) stuff RedOrbs %check.item

    ; Display the desc. 
    if ($readini($char($1), descriptions, gamble) = $null) { $set_chr_name($1) | set %skill.description sacrficies 1000 $readini(system.dat, system, currency) to summon a magic slot machine. %real.name pulls the handle....  }
    else { set %skill.description $readini($char($1), descriptions, gamble) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; Toggle the last used flag
    writeini $char($1) skills gamble.time $ctime
    writeini battle2.txt style $1 $+ .lastaction gamble

    ; Time to gamble, baby!
    var %gamble.chance $rand(1,100) 

    if (%gamble.chance = 1) { $display.system.message(12JACKPOT! %real.name $+ 's health, tp, and Ignition Gauge are all filled!, battle)
      if ($readini($char($1), battle, hp) < $readini($char($1), basestats, hp)) {  writeini $char($1) battle hp $readini($char($1), basestats, hp) }
      writeini $char($1) battle tp $readini($char($1), basestats, tp)
      writeini $char($1) battle IgnitionGauge $readini($char($1), basestats, IgnitionGauge)
    }
    if ((%gamble.chance >= 2) && (%gamble.chance <= 10)) { $display.system.message(12The slot machine spins and %real.name wins! %real.name $+ 's HP has been restored!, battle)
      if ($readini($char($1), battle, hp) < $readini($char($1), basestats, hp)) {  writeini $char($1) battle hp $readini($char($1), basestats, hp) }
    }
    if ((%gamble.chance > 10) && (%gamble.chance <= 15)) { $display.system.message(12The slot machine spins and %real.name wins! %real.name $+ 's TP has been restored!, battle)
      writeini $char($1) battle tp $readini($char($1), basestats, tp)
    }
    if ((%gamble.chance > 15) && (%gamble.chance <= 45)) { $inflict_status(Slot Machine, $1, random, IgnoreResistance) | $set_chr_name($1) | $display.system.message(12The slot machine spins and %real.name loses!4  %statusmessage.display, battle)  | unset %statusmessage.display  }
    if ((%gamble.chance > 45) && (%gamble.chance <= 55)) { $clear_most_status($1) | $display.system.message(12The slot machine spins and %real.name wins! Most of %real.name $+ 's statuses have been removed!, battle) }
    if ((%gamble.chance > 55) && (%gamble.chance <= 65)) { 
      writeini $char($1) battle hp $round($calc($readini($char($1), battle, hp) /2),0)
      $display.system.message(12The slot machine spins and %real.name loses!4 %real.name loses half of $gender($1) current HP! , battle)
    }

    if ((%gamble.chance > 65) && (%gamble.chance <= 75)) {
      var %item.pool $readini(items.db, items, HealingItems) $+ . $+ $readini(items.db, items, misc) 
      set %total.items $numtok(%item.pool, 46)
      set %random.item $rand(1,%total.items)
      set %gamble.item $gettok(%item.pool,%random.item,46)
      set %current.item.total $readini($char($1), Item_Amount, %gamble.item) 
      if (%current.item.total = $null) { var %current.item.total 0 }
      inc %current.item.total 1 | writeini $char($1) Item_Amount %gamble.item %current.item.total 

      $display.system.message(12The slot machine spins and %real.name wins a(n) %gamble.item $+ !, battle)
    }
    if ((%gamble.chance > 75) && (%gamble.chance <= 80)) { 
      writeini $char($1) status orbbonus yes
      $display.system.message(12The slot machine spins and %real.name wins! %real.name will receive an orb bonus at the end of battle!, battle)
    }
    if ((%gamble.chance > 80) && (%gamble.chance <= 85)) {  $display.system.message(12The slot machine spins and %real.name breaks even!, battle)
      var %red.orbs $readini($char($1), stuff, RedOrbs)
      inc %red.orbs 1000
      writeini $char($1) stuff RedOrbs %red.orbs
    }
    if ((%gamble.chance > 85) && (%gamble.chance <= 95)) { $set_chr_name($1) | $display.system.message(12The slot machine spins and %real.name loses!  But nothing seems to happen!, battle) }
    if ((%gamble.chance > 95) && (%gamble.chance < 100)) {
      $inflict_status(Slot Machine, $1, random, IgnoreResistance) | $display.system.message(12BUST! %real.name $+ 's health and tp are cut in half! 4  %statusmessage.display, battle) | unset %statusmessage.display 
      writeini $char($1) battle hp $round($calc($readini($char($1), battle, hp) /2),0)
      writeini $char($1) battle tp $round($calc($readini($char($1), battle, tp) /2),0)
    }

    if (%gamble.chance = 100) { $display.system.message(12The slot machine spins and %real.name wins! %real.name $+ 's Ignition Gauge has been restored!, battle)
      writeini $char($1) battle IgnitionGauge $readini($char($1), basestats, IgnitionGauge)
    }


    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }


  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private) | $display.private.message(3You still have $calc($readini(skills.db, gamble, cooldown) - %time.difference) seconds before you can use !gamble again) | halt }
}

;=================
BLOODPACT
;=================
alias skill.bloodpact {
  ; $1 = user
  ; $2 = name of summon
  ; $3 = item used to summon

  .copy -o $summon($2) $char($1 $+ _summon)

  ; Add to battle
  set %curbat $readini(battle2.txt, Battle, List)
  %curbat = $addtok(%curbat,$1 $+ _summon,46)
  writeini battle2.txt Battle List %curbat
  write battle.txt $1 $+ _summon

  ; Show desc 

  ; Display the desc. 
  $set_chr_name($1) 
  if ($readini($char($1), descriptions, bloodpact) = $null) { $set_chr_name($1  $+ _summon) | set %skill.description The $3 explodes and summons %real.name $+ !   }
  else { set %skill.description  $+ %real.name  $+ $readini($char($1), descriptions, bloodpact) }
  $display.system.message(4 $+ %skill.description, battle)

  $set_chr_name($1 $+ _summon) | $display.system.message(12 $+ %real.name  $+ $readini($char($1 $+ _summon), descriptions, char), battle)
  writeini $char($1 $+ _summon) info summon yes

  if ($augment.check($1, EnhanceBloodpact) != true) {
    ; Set the user's TP to 0.
    writeini $char($1) Battle TP 0
  }

  if ($augment.check($1, EnhanceBloodpact) = true) {
    writeini $char($1) battle TP $round($calc($readini($char($1), battle, tp) / 2),0)
  }

  set %bloodpact.level $readini($char($1), skills, BloodPact)
  if (%bloodpact.level >= 1) { $boost_summon_stats($1, %bloodpact.level, $2)  }
  unset %bloodpact.level

  var %temp.flag $readini($char($1), info, flag)
  if (%temp.flag = monster) { 

    writeini $char($1 $+ _summon) info flag monster | remini $char($1) skills bloodpact 

  }
  if (%temp.flag = npc) { remini $char($1) skills bloodpact }

  return
}

;=================
; THIRD EYE
;=================
on 3:TEXT:!third eye*:*: { $skill.thirdeye($nick) }
on 3:TEXT:!thirdeye*:*: { $skill.thirdeye($nick) }

alias skill.thirdeye { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, ThirdEye) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, ThirdEye.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  inc %time.difference $calc(%time.difference + ($readini($char($1), skills, ThirdEye) * 60))

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, ThirdEye, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, ThirdEye) = $null) { set %skill.description uses an ancient Samurai skill to increase the odds of dodging attacks. }
    else { set %skill.description $readini($char($1), descriptions, ThirdEye) }
    $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

    ; Toggle the ThirdEye-on flag & write the last used time.
    writeini $char($1) skills ThirdEye.on on
    writeini $char($1) skills ThirdEye.time $ctime 

    var %thirdeye.dodges $rand(1,2)

    if ($augment.check($1, EnhanceThirdEye) = true) {
      inc %thirdeye.dodges %augment.strength
    }

    writeini $char($1) status Thirdeye.turn %thirdeye.dodges

    writeini battle2.txt style $1 $+ .lastaction ThirdEye

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, UnableToUseskillAgainSoSoon),private)  | $display.private.message(3You still have $calc($readini(skills.db, ThirdEye, cooldown) - %time.difference) seconds before you can use !third eye again) | halt }
}

;=================
; SCAVENGE
;=================
on 3:TEXT:!scavenge*:*: { $skill.scavenge($nick, $2, !scavenge) }

alias skill.scavenge { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, scavenge) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)

  ; Can we use scavenge again?
  if ($readini($char($1), skills, scavenge.on) = on) { $display.system.message($readini(translation.dat, skill, ScavengeAlreadyUsed), private) | halt }

  ; Check to see if the battlefield even has an item pool
  set %scavenge.pool $readini(battlefields.lst, %current.battlefield, scavenge)
  if ((%scavenge.pool = $null) || (%scavenge.pool = none)) { unset %scavenge.pool | $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, ScavengeNothingToGet), private) | halt }

  ; Display the desc. 
  $set_chr_name($2) | set %enemy %real.name
  if ($readini($char($1), descriptions, scavenge) = $null) { set %skill.description drops to the ground and begins digging, hoping to find something of use burried in the battlefield. }
  else { set %skill.description $readini($char($1), descriptions, scavenge) }
  $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Turn the used flag on
  writeini $char($1) skills scavenge.on on

  ; Now to check to see if we scavenge something.
  var %scavenge.chance $rand(1,100)
  var %skill.scavenge $readini($char($1), skills, scavenge)
  inc %scavenge.chance %skill.scavenge

  ; Check augment
  if ($augment.check($1, EnhanceScavenge) = true) {  inc %scavenge.chance $calc(2 * %augment.strength) }

  ; Did the player find anything?
  if (%scavenge.chance >= 55) {

    set %total.items $numtok(%scavenge.pool, 46)
    set %random.item $rand(1,%total.items)
    set %scavenge.item $gettok(%scavenge.pool,%random.item,46)

    set %current.item.total $readini($char($1), Item_Amount, %scavenge.item) 
    if (%current.item.total = $null) { var %current.item.total 0 }
    inc %current.item.total 1 | writeini $char($1) Item_Amount %scavenge.item %current.item.total 
    $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, ScavengeSuccessful), battle)
  }

  else { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, ScavengeFailed), battle) }

  writeini battle2.txt style $1 $+ .lastaction scavenge 

  unset %enemy | unset %total.items | unset %random.item | unset %scavenge.item | unset %current.item.total | unset %scavenge.pool 

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}

;=================
; PERFECT COUNTER
;=================
on 3:TEXT:!perfectcounter*:*: { $skill.perfectcounter($nick) }
on 3:TEXT:!perfect counter*:*: { $skill.perfectcounter($nick) }

alias skill.perfectcounter { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  set %current.playerstyle $readini($char($1), styles, equipped)
  if (%current.playerstyle != CounterStance) { $display.system.message(4Error: This command can only be used while the CounterStance style is equipped!, private) | unset %current.playerstyle | halt }

  if ($readini($char($1), skills, perfectcounter.on) != $null) { $display.system.message(4 $+ %real.name cannot use $gender($1) Perfect Counter again this battle!, private) | halt }

  writeini $char($1) skills perfectcounter.on on 

  if ($readini($char($nick), descriptions, PerfectCounter) = $null) { $set_chr_name($1) | set %skill.description performs an ancient technique perfected by monks to ensure a perfect melee counter! }
  else { set %skill.description $readini($char($nick), descriptions, perfectcounter) }
  $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
  unset %current.playerstyle | unset %current.playerstyle.level | unset %quicksilver.used
}

;=================
; JUST RELEASE
;=================
on 3:TEXT:!justrelease*:*: { $skill.justrelease($nick, $2, !justrelease) }
on 3:TEXT:!just release*:*: { $skill.justrelease($nick, $3, !justrelease) }

alias skill.justrelease { $set_chr_name($1)
  if ($is_charmed($1) = true) { $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused),private) | halt }
  if (no-skill isin %battleconditions) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt }
  if ($readini($char($1), info, clone) = yes) { $display.system.message($readini(translation.dat, errors, ShadowClonesCan'tUseSkill,private) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, JustRelease) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkill), private)  | halt }
  if (%battleis = off) { $display.system.message(There is no battle currently!, private) | halt }
  $check_for_battle($1)
  $person_in_battle($2)

  var %target.flag $readini($char($2), info, flag)
  if (($readini($char($1), info, flag) = $null) && (%target.flag != monster)) { $set_chr_name($1) | $display.system.message(4 $+ %real.name can only Just Release on monsters!, private) | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message(4 $+ %real.name cannot steal while unconcious!, private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message(4 $+ %real.name cannot steal from someone who is dead!, private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { $display.system.message(4 $+ %real.name cannot  Just Release on $set_chr_name($2) %real.name $+ , because %real.name has run away from the fight!, private) | unset %real.name | halt } 

  ; Display the desc. 
  $set_chr_name($2) | set %enemy %real.name
  if ($readini($char($1), descriptions, JustRelease) = $null) { set %skill.description unleashes all of $gender($1) blocked damage upon %enemy $+ ! }
  else { set %skill.description $readini($char($1), descriptions, JustRelease) }
  $set_chr_name($1) | $display.system.message(12 $+ %real.name  $+ %skill.description, battle) 

  ; Get the attack damage.

  var %block.damage $readini($char($1), skills, royalguard.dmgblocked)
  if (%block.damage = $null) { var %block.damage 0 }

  ; Clear the blocked damage meter.
  writeini $char($1) skills royalguard.dmgblocked 0

  ; Calculate the total damage we'll do.
  set %attack.damage $round($calc(($readini($char($1), skills, JustRelease) /100) * %block.damage),0)  

  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4
  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %drainsamba.on | unset %absorb
  unset %enemy | unset %user | unset %real.name

  ; Calculate, deal, and display the damage..
  $deal_damage($1, $2, JustRelease)
  $display_damage($1, $2, skill, JustRelease)

  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %critical.hit.chance

  writeini battle2.txt style $1 $+ .lastaction JustRelease

  unset %enemy

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}
