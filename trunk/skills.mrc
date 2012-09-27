;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SKILLS 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;=================
; SPEED SKILL
;=================
on 2:TEXT:!speed*:*: { 
  if ($is_charmed($nick) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition) | halt }
  $amnesia.check($nick, skill) 
  $checkchar($nick)
  if ($skillhave.check($nick, speed) = false) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill) | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
  $check_for_battle($nick)

  if ($readini($char($nick), skills, speed.on) = on) { $set_chr_name($nick) | query %battlechan 4 $+ %real.name has already used this skill once this battle and cannot use it again until the next battle. | halt }

  ; Display the desc. 
  if ($readini($char($nick), descriptions, speed) = $null) { set %skill.description forces $gender($nick) body to speed up! }
  else { set %skill.description $readini($char($nick), descriptions, speed) }
  $set_chr_name($nick) | query %battlechan 12 $+ %real.name  $+ %skill.description

  ; Increase the speed
  var %speed $readini($char($nick), battle, spd)
  var %increase $round($calc(%speed * ($readini($char($nick), skills, speed) / 10)),0)
  if (%increase < 1) { var %increase 1 }
  inc %speed %increase
  writeini $char($nick) battle spd %speed

  ; Toggle the speed-on flag so players can't use it again in the same battle.
  writeini $char($nick) skills speed.on on

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($nick) }
}

;=================
; ELEMENTAL SEAL
;=================
on 2:TEXT:!elemental seal*:*: { $skill.elementalseal($nick) }
on 2:TEXT:!elementalseal*:*: { $skill.elementalseal($nick) }

alias skill.elementalseal {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)  | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, ElementalSeal) = false) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill)  | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
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
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

    ; Toggle the elementalseal-on flag & write the last used time.
    writeini $char($1) skills elementalseal.on on
    writeini $char($1) skills elementalseal.time $ctime

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | query %battlechan $readini(translation.dat, skill, UnableToUseskillAgainSoSoon)  | .msg $1 3You still have $calc($readini(skills.db, ElementalSeal, cooldown) - %time.difference) seconds before you can use !elemental seal again | halt }
}


;=================
; MIGHTY STRIKE
;=================
on 2:TEXT:!mighty strike*:*: { $skill.mightystrike($nick) }
on 2:TEXT:!mightystrike*:*: { $skill.mightystrike($nick) }

alias skill.mightystrike {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, MightyStrike) = false) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill)  | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
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
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

    ; Toggle the flag & write the last used time.
    writeini $char($1) skills mightystrike.on on
    writeini $char($1) skills mightystrike.time $ctime

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | query %battlechan $readini(translation.dat, skill, UnableToUseskillAgainSoSoon)  | .msg $1 3You still have $calc($readini(skills.db, MightyStrike, cooldown) - %time.difference) seconds before you can use !mighty strike again | halt }
}


;=================
; MANA WALL
;=================
on 2:TEXT:!mana wall*:*: { $skill.manawall($nick) }
on 2:TEXT:!manawall*:*: { $skill.manawall($nick) }

alias skill.manawall {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition) | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, ManaWall) = false) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill)  | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
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
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

    ; Toggle the ManaWall-on flag & write the last used time.
    writeini $char($1) skills ManaWall.on on
    writeini $char($1) skills ManaWall.time $ctime

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | query %battlechan $readini(translation.dat, skill, UnableToUseskillAgainSoSoon)  | .msg $1 3You still have $calc($readini(skills.db, ManaWall, cooldown) - %time.difference) seconds before you can use !mana wall again | halt }
}

;=================
; ROYAL GUARD
;=================
on 2:TEXT:!royal guard*:*: { $skill.royalguard($nick) }
on 2:TEXT:!royalguard*:*: { $skill.royalguard($nick) }

alias skill.royalguard {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)   | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, royalguard) = false) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill)  | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
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
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

    ; Toggle the royalguard-on flag & write the last used time.
    writeini $char($1) skills royalguard.on on
    writeini $char($1) skills royalguard.time $ctime

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { query %battlechan $readini(translation.dat, skill, UnableToUseskillAgainSoSoon) | .msg $1 3You still have $calc($readini(skills.db, RoyalGuard, cooldown) - %time.difference) seconds before you can use !royal guard again | halt }
}



;=================
; UTSUSEMI
;=================
on 2:TEXT:!utsusemi*:*: { $skill.utsusemi($nick) }

alias skill.utsusemi {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)   | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, utsusemi) = false) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill)  | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, utsusemi.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  inc %time.difference $calc(%time.difference + ($readini($char($1), skills, utsusemi) * 60))

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, Utsusemi, cooldown))) {

    ; Check for the item "Shihei" and consume it, or display an error if they don't have any.
    set %check.item $readini($char($1), item_amount, shihei)
    if ((%check.item = $null) || (%check.item <= 0)) { query %battlechan 4Error: %real.name does not have enough shihei to perform this skill | halt }
    $decrease_item($1, Shihei) 

    ; Display the desc. 
    if ($readini($char($1), descriptions, utsusemi) = $null) { set %skill.description uses an ancient ninjutsu technique to create shadow copies to absorb attacks. }
    else { set %skill.description $readini($char($1), descriptions, utsusemi) }
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

    ; Toggle the utsusemi-on flag & write the last used time.
    writeini $char($1) skills utsusemi.on on
    writeini $char($1) skills utsusemi.time $ctime
    writeini $char($1) skills utsusemi.shadows 2

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | query %battlechan $readini(translation.dat, skill, UnableToUseskillAgainSoSoon) | .msg $1 3You still have $calc($readini(skills.db, Utsusemi, cooldown) - %time.difference) seconds before you can use !utsusemi again | halt }
}


;=================
; FULL BRING SKILL
;=================
on 2:TEXT:!fullbring*:*: { $skill.fullbring($nick, $2) }


alias skill.fullbring {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  $set_chr_name($1)
  if ((no-item isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)   | halt }

  set %check.item $readini($char($1), Item_Amount, $2) 
  if ((%check.item <= 0) || (%check.item = $null)) { $set_chr_name($1) | query %battlechan 4Error: %real.name does not have that item. | halt }

  set %fullbring.check $readini($char($1), skills, fullbring) | set %fullbring.needed $readini(items.db, $2, FullbringLevel)
  if (%fullbring.needed > %fullbring.check) { query %battlechan 4Error: %real.name does not have a high enough Fullbring skill level to perform Fullbring on this item! | halt }

  $check_for_battle($nick)
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }

  set %fullbring.type $readini(items.db, $2, type) | set %fullbring.target $readini(items.db, $2, FullbringTarget)

  if (%fullbring.target = $null) { query %battlechan 4Error: This item does not have a fullbring ability attached to it! | halt }
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

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}

alias fullbring.singleheal { 
  ; $1 = user
  ; $2 = item
  ; $3 = target

  ; Display the fullbring desc
  query %battlechan 3 $+ %user  $+ $readini(items.db, $2, Fullbringdesc)

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
  query %battlechan 3 $+ %user  $+ $readini(items.db, $2, Fullbringdesc)

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

  ; Display the item description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name
  query %battlechan 3 $+ %user  $+ $readini(items.db, $2, Fullbringdesc)

  ; Get the fullbring status type
  set %fullbring.status $readini(items.db, $2, StatusType)

  if (%fullbring.status = stop) { var %tech.status.grammar frozen in time }
  if (%fullbring.status = poison) { var %tech.status.grammar poisoned }
  if (%fullbring.status = silence) { var %tech.status.grammar silenced }
  if (%fullbring.status = blind) { var %tech.status.grammar blind }
  if (%fullbring.status = virus) { var %tech.status.grammar inflicted with a virus }
  if (%fullbring.status = amnesia) { var %tech.status.grammar inflicted with amnesia }
  if (%fullbring.status = paralysis) { var %tech.status.grammar paralyzed }
  if (%fullbring.status = zombie) { var %tech.status.grammar a zombie }
  if (%fullbring.status = slow) { var %tech.status.grammar slowed }
  if (%fullbring.status = stun) { var %tech.status.grammar stunned }
  if (%fullbring.status = curse) { var %tech.status.grammar cursed }
  if (%fullbring.status = intimidate) { var %tech.status.grammar intimidated }

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

  ; Display the item description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name
  query %battlechan 3 $+ %user  $+ $readini(items.db, $2, Fullbringdesc)

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

  ; Display the item description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name
  query %battlechan 3 $+ %user  $+ $readini(items.db, $2, Fullbringdesc)

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

        query %battlechan 3 $+ %enemy has regained %tp.amount TP!
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
on 2:TEXT:!double turn*:*: { $skill.doubleturn($nick) }
on 2:TEXT:!doubleturn*:*: { $skill.doubleturn($nick) }
on 2:TEXT:!sugitekai*:*: { $skill.doubleturn($nick) }

alias skill.doubleturn {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)   | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, sugitekai) = false) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill)  | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
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
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

    ; Toggle the doubleturn-on flag & write the last used time.
    writeini $char($1) skills doubleturn.on on
    writeini $char($1) skills doubleturn.time $ctime

    ; Time to go to the next turn
    if (%battleis = on)  { $next }
  }

  else { query %battlechan $readini(translation.dat, skill, UnableToUseskillAgainSoSoon) | .msg $1 3You still have $calc($readini(skills.db, Sugitekai, cooldown) - %time.difference) seconds before you can use !Sugitekai again | halt }
}

;=================
; MEDITATE
;=================
on 2:TEXT:!meditate*:*: { $skill.meditate($nick) }

alias skill.meditate {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)   | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, meditate) = false) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill)  | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
  $check_for_battle($1)

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, meditate.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, Meditate, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, meditate) = $null) { set %skill.description meditates and feel $gender($1) TP being restored.  }
    else { set %skill.description $readini($char($1), descriptions, meditate) }
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

    ; write the last used time.
    writeini $char($1) skills meditate.time $ctime

    ; get TP
    var %tp.current $readini($char($1), battle, tp)
    var %tp.max $readini($char($1), basestats, tp)

    ; Find out the increase amount
    var %tp.increase $calc(5 * $readini($char($1), skills, meditate))

    ; increase the tp and make sure it's not over the max
    inc %tp.current %tp.increase

    if (%tp.current >= %tp.max) { query %battlechan 3 $+ %real.name has restored all of $gender($1) TP! | writeini $char($1) battle tp %tp.max }
    if (%tp.current < %tp.max) { query %battlechan 3 $+ %real.name has restored %tp.increase TP! | writeini $char($1) battle tp %tp.current }

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { query %battlechan $readini(translation.dat, skill, UnableToUseskillAgainSoSoon)  | .msg $1 3You still have $calc($readini(skills.db, Meditate, cooldown) - %time.difference) seconds before you can use !meditate again | halt }
}

;=================
; CONSERVE TP
;=================
on 2:TEXT:!conserve TP*:*: { $skill.conserveTP($nick) }
on 2:TEXT:!conserveTP*:*: { $skill.conserveTP($nick) }

alias skill.conserveTP {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)   | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, conserveTP) = false) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill)  | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
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
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

    ; Toggle the conserveTP-on flag & write the last used time.
    writeini $char($1) skills conserveTP.on on
    writeini $char($1) skills conserveTP.time $ctime

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { $set_chr_name($1) | query %battlechan $readini(translation.dat, skill, UnableToUseskillAgainSoSoon)  | .msg $1 3You still have $calc($readini(skills.db, ConserveTP, cooldown) - %time.difference) seconds before you can use !conserve TP again | halt }
}


;=================
; BLOOD BOOST
;=================
on 2:TEXT:!bloodboost*:*: { $skill.bloodboost($nick) }
on 2:TEXT:!blood boost*:*: { $skill.bloodboost($nick) }

alias skill.bloodboost {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)   | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, bloodboost) = false) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill)  | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
  $check_for_battle($1)

  if ($readini($char($1), info, flag) = $null) { 
    var %hp.needed 100 | var %hp.current $readini($char($1), battle, hp)
    if (%hp.needed > %hp.current) { query %battlechan 4Error: %real.name does not have enough HP to use this skill! | halt }
  }

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, bloodboost.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, BloodBoost, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, bloodboost) = $null) { set %skill.description sacrifices some of $gender($1) blood for raw strength.  }
    else { set %skill.description $readini($char($1), descriptions, bloodboost) }
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

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

    ; increase the str
    inc %str.current %str.increase

    query %battlechan 3 $+ %real.name has gained %str.increase STR!  |   writeini $char($1) battle str %str.current

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { query %battlechan $readini(translation.dat, skill, UnableToUseskillAgainSoSoon) | .msg $1 3You still have $calc($readini(skills.db, BloodBoost, cooldown) - %time.difference) seconds before you can use !bloodboost again | halt }
}

;=================
; DRAIN SAMBA
;=================
on 2:TEXT:!drainsamba*:*: { $skill.drainsamba($nick) }
on 2:TEXT:!drain samba*:*: { $skill.drainsamba($nick) }

alias skill.drainsamba {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)   | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, drainsamba) = false) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill)  | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
  $check_for_battle($1)

  if ($readini($char($1), info, flag) = $null) { 
    var %tp.needed 15 | var %tp.current $readini($char($1), battle, tp)
    if (%tp.needed > %tp.current) { query %battlechan 4Error: %real.name does not have enough TP to use this skill! | halt }
  }

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, drainsamba.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, DrainSamba, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, drainsamba) = $null) { set %skill.description performs a powerful samba that activates a draining technique on $gender($1) weapon!   }
    else { set %skill.description $readini($char($1), descriptions, drainsamba) }
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

    ; write the last used time.
    writeini $char($1) skills drainsamba.time $ctime

    if ($readini($char($1), info, flag) = $null) { 
      ; Dec the TP
      dec %tp.current %tp.needed
      writeini $char($1) battle tp %tp.current
    }

    writeini $char($1) skills drainsamba.turn 0 | writeini $char($1) skills drainsamba.on on

    query %battlechan 3 $+ %real.name has gained the drain status for $readini($char($1), skills, drainsamba) melee attacks!

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { query %battlechan $readini(translation.dat, skill, UnableToUseskillAgainSoSoon) | .msg $1 3You still have $calc($readini(skills.db, DrainSamba, cooldown) - %time.difference) seconds before you can use !drainsamba again | halt }
}


;=================
; REGEN
;=================
on 2:TEXT:!regen*:* { $skill.regen($nick) }
on 2:TEXT:!regeneration*:* { $skill.regen($nick) }
on 2:TEXT:!stop regen*:*:{ $skill.regen.stop($nick) } 

alias skill.regen {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  $amnesia.check($1, skill) 
  set %current.hp $readini($char($1), Battle, HP)  |  set %max.hp $readini($char($1), BaseStats, HP)
  if (%current.hp >= %max.hp) { $set_chr_name($1) | query %battlechan 3 $+ %real.name is already at full HP! | halt }

  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, regen.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, Regen, cooldown))) {

    ; write the last used time.
    writeini $char($1) skills regen.time $ctime

    if ($readini($char($1), descriptions, regen) = $null) { set %skill.description has gained the regeneration effect.  }
    else { set %skill.description $readini($char($1), descriptions, regen) }
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

    var %regen.amount $skill.regen.calculate($1)
    inc %current.hp %regen.amount
    writeini $char($1) Battle HP %current.hp
    if (%current.hp > %max.hp) { writeini $char($1) Battle HP %max.hp | query %battlechan 12 $+ %real.name has regenerated all of $gender($1) HP!
      if (%battleis = on)  { $check_for_double_turn($1) | halt }
    }
    else { 
      $set_chr_name($1) | query %battlechan 12 $+ %real.name has regenerated %regen.amount HP! 
      writeini $char($1) Status Regenerating yes | goto regenhalt 
    }
    :regenhalt
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
    else { halt }
  }
  else { query %battlechan $readini(translation.dat, skill, UnableToUseskillAgainSoSoon) | .msg $1 3You still have $calc($readini(skills.db, Regen, cooldown) - %time.difference) seconds before you can use !regen again | halt }

}

alias skill.regen.calculate {
  var %skill.level $readini($char($1), skills, regen)
  if (%skill.level < 5) { set %amount 2 }
  if ((%skill.level >= 5) && (%skill.level <= 10)) { set %amount 3 }
  if ((%skill.level > 11) && (%skill.level <= 15)) { set %amount 4 }
  if (%skill.level > 15) { set %amount 5 }
  inc %amount $calc(%skill.level * %amount)
  return %amount
}

alias skill.zombieregen.calculate {
  set %amount $rand(5,30)
  return %amount
}

alias skill.tpregen {
  set %current.tp $readini($char($1), Battle, TP)  |  set %max.tp $readini($char($1), BaseStats, TP)
  if (%current.tp >= %max.tp) { $set_chr_name($1) | query %battlechan 3 $+ %real.name is already at full TP! | halt }

  if ($readini($char($1), descriptions, TPregen) = $null) { set %skill.description has gained the tp regeneration effect.  }
  else { set %skill.description $readini($char($1), descriptions, TPregen) }
  $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

  var %regen.amount $skill.regen.calculate($1)
  inc %current.tp %regen.amount
  writeini $char($1) Battle TP %current.tp
  if (%current.tp > %max.tp) { writeini $char($1) Battle TP %max.tp | query %battlechan 12 $+ %real.name has regenerated all of $gender($1) TP!
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }
  else { 
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.desc | query %battlechan 12 $+ %real.name has regenerated %regen.amount TP! 
    writeini $char($1) Status TPRegenerating yes | goto regenhalt 
  }
  :regenhalt
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
  else { halt }
}

alias skill.regen.stop {
  set %check $readini($char($1), Status, regenerating)
  if (%check = yes) { writeini $char($1) Status Regenerating no | $set_chr_name($1) | query %battlechan 3 $+ %real.name stops regenerating | halt }
  else { $set_chr_name($1) | query %battlechan 4Error: %real.name is not regenerating! | halt }
}

;=================
; KIKOUHENI
;=================
on 2:TEXT:!kikouheni*:*: { $skill.kikouheni($nick, $2) }

alias skill.kikouheni {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if (no-skill isin %battleconditions) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)   | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, kikouheni) = false) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill)  | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
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
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

    ; write the last used time.
    writeini $char($1) skills kikouheni.time $ctime

    writeini weather.lst weather current $2 
    query %questchan 3The weather has changed! It is currently $2 

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { query %battlechan $readini(translation.dat, skill, UnableToUseskillAgainSoSoon) | .msg $1 3You still have $calc($readini(skills.db, Kikouheni, cooldown) - %time.difference) seconds before you can use !kikouheni again | halt }
}


;=================
; SHADOW COPY (cloning)
;=================
on 2:TEXT:!clone*:*: { $skill.clone($nick) }
on 2:TEXT:!shadowcopy*:*: { $skill.clone($nick) }
on 2:TEXT:!shadow copy*:*: { $skill.clone($nick) }

alias skill.clone {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if (no-skill isin %battleconditions) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)   | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, shadowcopy) = false) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill)  | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
  $check_for_battle($1)

  if ($isfile($char($nick $+ _clone)) = $true) { $set_chr_name($1) | query %battlechan 4Error: %real.name has already used this skill for this battle and cannot use it again! | halt }

  ; Display the desc. 
  if ($readini($char($1), descriptions, shadowcopy) = $null) { set %skill.description releases $gender($1) shadow, which comes to life as a clone, ready to fight. }
  else { set %skill.description $readini($char($1), descriptions, shadowcopy) }
  $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

  .copy $char($1) $char($1 $+ _clone)
  if ($readini($char($1), info, flag) = $null) { writeini $char($1 $+ _clone) info flag npc }

  if ($2 = $null) {  writeini $char($1 $+ _clone) basestats name Clone of $1 }
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

  if ($readini($char($1), info, flag) != $null) { 
    set %hp $round($calc(%current.hp / 1.5),0)
    writeini $char($1) skills shadowcopy 0
    var %number.of.monsters $readini(battle2.txt, BattleInfo, Monsters)
    inc %number.of.monsters 1
    writeini battle2.txt battleinfo monsters %number.of.monsters
  }

  if (%hp <= 1) { set %hp 1 }

  unset %current.playerstyle | unset %current.playerstyle.level

  writeini $char($1 $+ _clone) battle hp %hp
  writeini $char($1 $+ _clone) basestats hp %hp
  writeini $char($1 $+ _clone) skills shadowcopy 0

  unset %hp

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}


;=================
; STEAL
;=================
on 2:TEXT:!steal*:*: { $skill.steal($nick, $2, !steal) }

alias skill.steal {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if (no-skill isin %battleconditions) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)   | halt }
  $amnesia.check($1, skill) 

  $checkchar($1)
  if ($skillhave.check($1, steal) = false) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill)  | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
  $check_for_battle($1)
  $person_in_battle($2)

  var %target.flag $readini($char($2), info, flag)
  if (%target.flag != monster) { $set_chr_name($1) | query %battlechan 4 $+ %real.name can only steal from monsters! | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | query %battlechan 4 $+ %real.name cannot steal while unconcious! | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | query %battlechan 4 $+ %real.name cannot steal from someone who is dead! | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { query %battlechan 4 $+ %real.name cannot steal from $set_chr_name($2) %real.name $+ , because %real.name has run away from the fight! | unset %real.name | halt } 


  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, steal.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, Steal, cooldown))) {

    ; Display the desc. 
    if ($readini($char($1), descriptions, steal) = $null) { set %skill.description sneaks around to $set_chr_name($2) %real.name in an attempt to steal something! }
    else { set %skill.description $readini($char($1), descriptions, steal) }
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

    ; write the last used time.
    writeini $char($1) skills steal.time $ctime

    ; Now to check to see if we steal something.
    var %steal.chance $rand(1,100)
    var %skill.steal $readini($char($1), skills, steal)
    inc %steal.chance %skill.steal

    if (%bloodmoon = on) { inc %steal.chance 25 }

    if ($readini($char($1), equipment, accessory) = miser-ring) {
      var %accessory.amount $readini(items.db, thief-ring, amount)
      inc %steal.chance %accessory.amount
    }


    var %current.playerstyle $readini($char($1), styles, equipped)
    if (%current.playerstyle = Trickster) { inc %steal.chance $rand(5,10) }

    if (%steal.chance >= 85) {
      var %stolen.from.counter $readini($char($2), status, stolencounter)
      if (%stolen.from.counter > 10) { $set_chr_name($2) | query %battlechan 4 $+ %real.name  has nothing left to steal! | halt }

      inc %stolen.from.counter 1 | writeini $char($2) status stolencounter %stolen.from.counter 

      inc %stolen.from.counter 1 | writeini $char($2) status stolencounter %stolen.from.counter 

      if ($readini($char($2), Info, flag) = monster) { var %steal.pool orbs.vitalstar.orbs.potion.x-potion.holy_water.Pizza.PotRoast.Ramen.Cavier.BisonDollar.DragonMeat.SuperMushroom.FireDragonWine.Ambrosia.FoieGras.KnowledgeSource.SoulPainting.FishAndChips.Slurm.CerberusMeat.SilverApple | var %steal.orb.amount $rand(1000,4000) }
      if ($readini($char($2), Info, Flag) = boss) { var %steal.pool orbs.senzu.Red_Fang.Thunder_Orb.Tonic.Superpotion.DarkMagicianCard.BusterBladerCard.BlueEyesCard.FishOilBroth.ElvishMedallian.AlexanderMateria.BahamutMateria.BahamutZeroMateria.CarbuncleMateria.SolomonRing.LuckyBroth.FenrirMateria.GarudaMateria.IfritMateria.LeviathanMateria.RamuhMateria.ShivaMateria.TitanMateria.Pizza.PotRoast.Ramen.Cavier.BisonDollar.DragonMeat.SuperMushroom.FireDragonWine.Ambrosia.FoieGras.KnowledgeSource.SoulPainting.FishAndChips.Slurm.CerberusMeat.SilverApple | var %steal.orb.amount $rand(8400,15000) }
      if ($2 = orb_fountain) { var %steal.pool orbs.orbs.orbs.orbs | var %steal.orb.amount $rand(8000,12100) }
      if (%bloodmoon = on) { var %steal.pool orbs.orbs.orbs.orbs | var %steal.orb.amount $rand(6000,10000) }

      set %total.items $numtok(%steal.pool, 46)
      set %random.item $rand(1,%total.items)
      set %steal.item $gettok(%steal.pool,%random.item,46)

      if (%steal.item = orbs) { var %current.orb.amount $readini($char($1), stuff, redorbs) | inc %current.orb.amount %steal.orb.amount | writeini $char($1) stuff redorbs %current.orb.amount 
        $set_chr_name($1) | query %battlechan 2 $+ %real.name has stolen %steal.orb.amount $readini(system.dat, system, currency) from $set_chr_name($2) %real.name $+ ! 
      }
      else {
        set %current.item.total $readini($char($1), Item_Amount, %steal.item) 
        if (%current.item.total = $null) { var %current.item.total 0 }
        inc %current.item.total 1 | writeini $char($1) Item_Amount %steal.item %current.item.total 
        $set_chr_name($1) | query %battlechan $readini(translation.dat, skill, StealItem)
      }
    }
    else { $set_chr_name($1) | query %battlechan $readini(translation.dat, skill, UnableTosteal) }

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { query %battlechan $readini(translation.dat, skill, UnableToUseskillAgainSoSoon) | .msg $1 3You still have $calc($readini(skills.db, Steal, cooldown) - %time.difference) seconds before you can use !steal again | halt }
}

;=================
; ANALYSIS
;=================
on 2:TEXT:!analyze*:*: { $skill.analysis($nick, $2) }
on 2:TEXT:!analysis*:*: { $skill.analysis($nick, $2) }

alias skill.analysis {
  if ($is_charmed($nick) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)  | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  if ($skillhave.check($nick, analysis) = false) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill) | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
  $check_for_battle($1) | $person_in_battle($2) 

  var %analysis.flag $readini($char($2), info, flag) 
  if (%analysis.flag != monster) { query %battlechan $readini(translation.dat, errors, OnlyAnalyzeMonsters) | halt }
  ; Display the desc. 
  if ($readini($char($nick), descriptions, analysis) = $null) { set %skill.description focuses intently on $2 in an attempt to analyze $gender2($2) $+ ! }
  else { set %skill.description $readini($char($nick), descriptions, analysis) }
  $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

  ; Get the level of the skill.  The level will determine the information we get from the skill.
  var %analysis.level $readini($char($1), skills, analysis)

  ; Get the target info
  var %analysis.hp $readini($char($2), battle, hp) | var %analysis.tp $readini($char($2), battle, tp)
  var %analysis.str $readini($char($2), battle, str) | var %analysis.def $readini($char($2), battle, def)
  var %analysis.int $readini($char($2), battle, int) | var %analysis.spd $readini($char($2), battle, spd)
  var %analysis.weapon.strength $readini($char($2), weapons, strong) | var %analysis.weapon.weak $readini($char($2), weapons, weakness)
  var %analysis.element.strength $readini($char($2), element, strong) | var %analysis.element.weak $readini($char($2), element, weakness)
  var %analysis.element.absorb = $readini($char($2), element, heal)
  if (%analysis.weapon.strength = $null) { var %analysis.weapon.strength none }
  if (%analysis.weapon.weak = $null) { var %analysis.weapon.weak none }
  if (%analysis.element.weak = $null) { var %analysis.element.weak none }
  if (%analysis.element.strength = $null) { var %analysis.element.strength none }
  if (%analysis.element.absorb = $null) { var %analysis.element.absorb none }

  set %replacechar $chr(044) $chr(032)
  %analysis.weapon.weak = $replace(%analysis.weapon.weak, $chr(046), %replacechar)
  %analysis.weapon.strength = $replace(%analysis.weapon.strength, $chr(046), %replacechar)
  %analysis.element.weak = $replace(%analysis.element.weak, $chr(046), %replacechar)
  %analysis.element.strength = $replace(%analysis.element.strength, $chr(046), %replacechar)
  %analysis.element.absorb = $replace(%analysis.element.absorb, $chr(046), %replacechar)


  if (%analysis.level = 1) {  $set_chr_name($2) | .msg $1 3You analyze %real.name and determine $gender3($2) has %analysis.hp HP left. | goto next_turn_check }
  if (%analysis.level = 2) {  $set_chr_name($2) | .msg $1 3You analyze %real.name and determine $gender3($2) has %analysis.hp HP and %analysis.tp TP left. | goto next_turn_check }
  if (%analysis.level = 3) {  $set_chr_name($2) | .msg $1 3You analyze %real.name and determine $gender3($2) has %analysis.hp HP and %analysis.tp TP left.
    .msg $1 3You also determine %real.name has the following stats: [str: %analysis.str $+ ] [def: %analysis.def $+ ] [int: %analysis.int $+ ] [spd: %analysis.spd $+ ]
    goto next_turn_check
  }
  if (%analysis.level = 4) {  $set_chr_name($2) | .msg $1 3You analyze %real.name and determine $gender3($2) has %analysis.hp HP and %analysis.tp TP left.
    .msg $1 3You also determine %real.name has the following stats: [str: %analysis.str $+ ] [def: %analysis.def $+ ] [int: %analysis.int $+ ] [spd: %analysis.spd $+ ]
    .msg $1 3 $+ %real.name is also strong against the following weapon types: %analysis.weapon.strength and is strong against the following elements: %analysis.element.strength
    goto next_turn_check
  }
  if (%analysis.level = 5) {  $set_chr_name($2) | .msg $1 3You analyze %real.name and determine $gender3($2) has %analysis.hp HP and %analysis.tp TP left.
    .msg $1 3You also determine %real.name has the following stats: [str: %analysis.str $+ ] [def: %analysis.def $+ ] [int: %analysis.int $+ ] [spd: %analysis.spd $+ ]
    .msg $1 3 $+ %real.name is also strong against the following weapon types: %analysis.weapon.strength and is strong against the following elements: %analysis.element.strength  $+ $chr(124) %real.name is weak against the following weapon types: %analysis.weapon.weak and weak against the following elements: %analysis.element.weak 
    goto next_turn_check
  }
  if (%analysis.level = 6) {  $set_chr_name($2) | .msg $1 3You analyze %real.name and determine $gender3($2) has %analysis.hp HP and %analysis.tp TP left.
    .msg $1 3You also determine %real.name has the following stats: [str: %analysis.str $+ ] [def: %analysis.def $+ ] [int: %analysis.int $+ ] [spd: %analysis.spd $+ ]
    .msg $1 3 $+ %real.name is also strong against the following weapon types: %analysis.weapon.strength and is strong against the following elements: %analysis.element.strength  $+ $chr(124) %real.name is weak against the following weapon types: %analysis.weapon.weak and weak against the following elements: %analysis.element.weak 
    .msg $1 3 $+ %real.name will absorb and be healed by the following elements: %analysis.element.absorb
    goto next_turn_check
  }

  :next_turn_check
  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($nick) }
}

;=================
; QUICKSILVER
;=================
on 2:TEXT:!quicksilver*:*: { $skill.quicksilver($nick) }

alias skill.quicksilver {
  set %current.playerstyle $readini($char($1), styles, equipped)
  if (%current.playerstyle != Quicksilver) { query %battlechan 4Error: This command can only be used while the Quicksilver style is equipped! | unset %current.playerstyle | halt }

  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
  set %quicksilver.used $readini($char($1), skills, quicksilver.turn)
  if (%quicksilver.used = $null) { set %quicksilver.used 0 }

  if (%quicksilver.used >= %current.playerstyle.level) { $set_chr_name($1) | query %battlechan 4 $+ %real.name cannot use $gender($1) Quicksilver power again this battle! | unset %current.playerstyle | halt }
  inc %quicksilver.used 1 | writeini $char($1) skills quicksilver.turn %quicksilver.used

  if ($readini($char($nick), descriptions, quicksilver) = $null) { $set_chr_name($1) | set %skill.description unleashes the power of Quicksilver! Time seems to stop for everyone except %real.name $+ ! }
  else { set %skill.description $readini($char($nick), descriptions, quicksilver) }
  $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

  var %battletxt.lines $lines(battle.txt) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line battle.txt
    if (%who.battle != $1) { writeini $char(%who.battle) status stop yes }

    inc %battletxt.current.line 1 
  }

  writeini $char($1) skills doubleturn.on on

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($nick) }
  unset %current.playerstyle | unset %current.playerstyle.level | unset %quicksilver.used
}

;=================
; COVER
;=================
on 2:TEXT:!cover*:*: { $skill.cover($nick, $2) }

alias skill.cover {
  if ($is_charmed($nick) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)  | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  if ($skillhave.check($nick, cover) = false) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill) | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
  $check_for_battle($1) | $person_in_battle($2) 


  ; Check to see if enough time has elapsed
  var %last.used $readini($char($1), skills, cover.time)
  var %current.time $ctime
  var %time.difference $calc(%current.time - %last.used)

  if ((%time.difference = $null) || (%time.difference > $readini(skills.db, Cover, cooldown))) {
    var %cover.status $readini($char($2), battle, status)
    if ((%cover.status = dead) || (%cover.status = runaway)) { query %battlechan $readini(translation.dat, skill, CoverTargetDead) | halt }

    var %cover.target $readini($char($2), skills, CoverTarget)
    if ((%cover.target != none) && (%cover.target != $null)) { query %battlechan $readini(translation.dat, skill, AlreadyBeingCovered) | halt  }

    var %user.flag $readini($char($1), info, flag) 
    if (%user.flag = $null) { var %user.flag player }
    var %target.flag $readini($char($2), info, flag)

    if (%user.flag = player) && (%target.flag = monster) { $readini(translation.dat, errors, CannotCoverMonsters) | halt }

    writeini $char($2) skills CoverTarget $1

    ; Display the desc. 
    if ($readini($char($1), descriptions, steal) = $null) { set %skill.description prepares to leap in front of $set_chr_name($2) %real.name in order to defend $gender2($2) }
    else { set %skill.description $readini($char($1), descriptions, cover) }
    $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

    ; write the last used time.
    writeini $char($1) skills cover.time $ctime

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) }
  }

  else { query %battlechan $readini(translation.dat, skill, UnableToUseskillAgainSoSoon) | .msg $1 3You still have $calc($readini(skills.db, Cover, cooldown) - %time.difference) seconds before you can use !cover again | halt }
}

;=================
; AGGRESSOR 
;=================
on 2:TEXT:!aggressor*:*: { $skill.aggressor($nick) }

alias skill.aggressor {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition) | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  if ($skillhave.check($1, aggressor) = false) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill) | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
  $check_for_battle($1)

  if ($readini($char($1), skills, aggressor.on) = on) { $set_chr_name($1) | query %battlechan 4 $+ %real.name has already used this skill once this battle and cannot use it again until the next battle. | halt }

  ; Display the desc. 
  if ($readini($char($1), descriptions, aggressor) = $null) { set %skill.description gives a loud battle warcry as $gender($1) strength is enhanced at the cost of $gender($1) defense! }
  else { set %skill.description $readini($char($1), descriptions, aggressor) }
  $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

  ; Increase the strength
  var %strength $readini($char($1), battle, str)
  var %defense $readini($char($1), battle, def)
  var %skill.level $readini($char($1), skills, aggressor)
  var %skill.increase.percent $calc(%skill.level * .10)
  var %increase.amount $round($calc(%skill.increase.percent * %defense),0)
  inc %strength %increase.amount
  writeini $char($1) battle str %strength
  writeini $char($1) battle def 5

  ; Toggle the speed-on flag so players can't use it again in the same battle.
  writeini $char($1) skills aggressor.on on

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}

;=================
; DEFENDER
;=================
on 2:TEXT:!defender*:*: { $skill.defender($nick) }

alias skill.defender {
  if ($is_charmed($1) = true) { query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  if ((no-skill isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition) | halt }
  $amnesia.check($1, skill) 
  $checkchar($1)
  if ($skillhave.check($1, defender) = false) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkill) | halt }
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }
  $check_for_battle($1)

  if ($readini($char($1), skills, defender.on) = on) { $set_chr_name($1) | query %battlechan 4 $+ %real.name has already used this skill once this battle and cannot use it again until the next battle. | halt }

  ; Display the desc. 
  if ($readini($char($1), descriptions, aggressor) = $null) { set %skill.description decides that the best offense is a good defense and sacrifices $gender($1) strength for defense! }
  else { set %skill.description $readini($char($1), descriptions, defender) }
  $set_chr_name($1) | query %battlechan 12 $+ %real.name  $+ %skill.description

  ; Increase the defense
  var %strength $readini($char($1), battle, str)
  var %defense $readini($char($1), battle, def)
  var %skill.level $readini($char($1), skills, defender)
  var %skill.increase.percent $calc(%skill.level * .10)
  var %increase.amount $round($calc(%skill.increase.percent * %strength),0)
  inc %defense %increase.amount
  writeini $char($1) battle str 5
  writeini $char($1) battle def %defense

  ; Toggle the speed-on flag so players can't use it again in the same battle.
  writeini $char($1) skills defender.on on

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}
