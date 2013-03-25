;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ATTACKS COMMAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON 3:ACTION:attacks *:#:{ 
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, status, CurrentlyConfused), private) | halt }
  $set_chr_name($nick) | set %attack.target $2 | $covercheck($2)
  $attack_cmd($nick , %attack.target) 
} 
on 3:TEXT:!attack *:#:{ 
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, status, CurrentlyConfused), private) | halt }
  $set_chr_name($nick) | set %attack.target $2
  $attack_cmd($nick , %attack.target) 
} 
ON 50:TEXT:*attacks *:*:{ 
  if ($2 != attacks) { halt } 
  else { 
    if ($is_charmed($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
    if ($is_confused($1) = true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, status, CurrentlyConfused), private) | halt }
    $charm.check($1, $nick) | unset %real.name 
    if $readini($char($1), Battle, HP) = $null) { halt }
    $set_chr_name($1) | set %attack.target $3 | $covercheck($3)
    $attack_cmd($1 , %attack.target) 
  }
}

alias attack_cmd { 
  set %debug.location alias attack_cmd
  $check_for_battle($1) | $person_in_battle($2) | $checkchar($2) | var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($2), info, flag)
  if ($is_charmed($1) = true) { var %user.flag monster }
  if ($is_confused($1) = true) { var %user.flag monster } 
  if (%mode.pvp = on) { var %user.flag monster }

  if ((%ai.type != berserker) && (%covering.someone != on)) {
    if (%mode.pvp != on) {
      if ($2 = $1) {
        if (($is_confused($1) = false) && ($is_charmed($1) = false))  { $display.system.message($readini(translation.dat, errors, Can'tAttackYourself), private) | unset %real.name | halt  }
      }
    }
  }

  if (%covering.someone = on) { var %user.flag monster }

  if ((%user.flag = $null) && (%target.flag != monster)) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, CanOnlyAttackMonsters),private) | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, CanNotAttackWhileUnconcious),private)  | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoIsDead),private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoFled),private) | unset %real.name | halt } 

  ; Make sure the old attack damages have been cleared, and clear a few variables.
  unset %attack.damage | unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4
  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %drainsamba.on | unset %absorb
  unset %enemy | unset %user | unset %real.name | unset %trickster.dodged | unset %counterattack | unset %covering.someone

  ; Get the weapon equipped
  $weapon_equipped($1)

  ; Calculate, deal, and display the damage..

  $calculate_damage_weapon($1, %weapon.equipped, $2)

  set %wpn.element $readini(weapons.db, %weapon.equipped, element)
  if ((%wpn.element != none) && (%wpn.element != $null)) { 
    var %target.element.heal $readini($char($2), modifiers, heal)
    if ($istok(%target.element.heal,%wpn.element,46) = $true) { 
      unset %wpn.element
      unset %counterattack
      $heal_damage($1, $2, %weapon.equipped)
      $display_heal($1, $2, weapon, %weapon.equipped)
      if (%battleis = on)  { $check_for_double_turn($1) | halt } 
    }
  }
  unset %wpn.element

  if (%counterattack != on) { 
    $drain_samba_check($1)
    $deal_damage($1, $2, %weapon.equipped)
    $display_damage($1, $2, weapon, %weapon.equipped)
  }

  if (%counterattack = on) { 
    $deal_damage($2, $1, %weapon.equipped)
    $display_damage($1, $2, weapon, %weapon.equipped)
  }


  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %critical.hit.chance

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
}

alias calculate_damage_weapon {
  set %debug.location alias calculate_damage_weapon
  ; $1 = %user
  ; $2 = weapon equipped
  ; $3 = target / %enemy 

  unset %absorb
  set %attack.damage 0
  var %random.attack.damage.increase $rand(1,10)

  ; First things first, let's find out the base power.
  var %base.power $readini(weapons.db, $2, basepower)

  if (%base.power = $null) { var %base.power 1 }

  set %base.stat $readini($char($1), battle, str)
  $strength_down_check($1)

  if ($readini(system.dat, system, BattleDamageFormula) = 1) {
    if (%base.stat > 10) {  
      if ($readini($char($1), info, flag) = $null) {  set %base.stat $round($calc(%base.stat / 2.5),0) }
      if ($readini($char($1), info, flag) != $null) { set %base.stat $round($calc(%base.stat / 5),0) }
    }
  }

  if ($readini(system.dat, system, BattleDamageFormula) = 2) {
    if (%base.stat > 999) {  
      if ($readini($char($1), info, flag) = $null) {  set %base.stat $round($calc(999 + %base.stat / 10),0) }
      if ($readini($char($1), info, flag) != $null) { set %base.stat $round($calc(999 + %base.stat / 5),0) }
    }
  }

  set %true.base.stat %base.stat

  var %weapon.base $readini($char($1), weapons, $2)
  inc %weapon.base $round($calc(%weapon.base * 1.5),0)

  ; If the weapon is a hand to hand, it will now receive a bonus based on your fists level.
  if ($readini(weapons.db, $2, type) = HandToHand) {  inc %weapon.base $readini($char($1), weapons, fists) }

  inc %weapon.base %base.power

  set %current.accessory $readini($char($3), equipment, accessory) 
  set %current.accessory.type $readini(items.db, %current.accessory, accessorytype)

  ; Does the user have any mastery of the weapon?
  $mastery_check($1, $2)

  ; Let's add the mastery bonus to the weapon base
  inc %weapon.base %mastery.bonus

  ; Let's add that to the base power and set it as the attack damage.
  inc %base.stat %weapon.base
  inc %attack.damage %base.stat

  ; Let's check for some offensive style enhancements
  $offensive.style.check($1, $2, melee)

  ;If the element is Light and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if (%weapon.element = light) {  inc %attack.damage $round($calc(%attack.damage * .110),0) } 
    if (%weapon.element = fire) {  inc %attack.damage $round($calc(%attack.damage * .110),0) } 
  } 

  ; Check to see if we have an accessory or augment that enhances the weapon type
  $melee.weapontype.enhancements($1)
  unset %weapon.type

  ; Check for the skill "MightyStrike"
  if ($mighty_strike_check($1) = true) { 
    ; Double the attack.
    %attack.damage = $calc(%attack.damage * 2)
  }

  ; Check for the "DesperateBlows" skill.
  if ($desperate_blows_check($1) = true) {
    var %hp.percent $calc(($readini($char($1), Battle, HP) / $readini($char($1), BaseStats, HP)) *100)
    if ((%hp.percent >= 10) && (%hp.percent <= 25)) { %attack.damage = $round($calc(%attack.damage * 1.5),0) }
    if ((%hp.percent > 2) && (%hp.percent < 10)) { %attack.damage = $round($calc(%attack.damage * 2),0) }
    if ((%hp.percent > 0) && (%hp.percent <= 2)) { %attack.damage = $round($calc(%attack.damage * 2.5),0) }
  }

  ; Let's increase the attack by a random amount.
  inc %attack.damage %random.attack.damage.increase
  unset %current.playerstyle | unset %current.playerstyle.level

  ;  Check for the miser ring accessory
  if ($readini($char($1), equipment, accessory) = miser-ring) {
    var %accessory.amount $readini(items.db, miser-ring, amount)
    var %redorb.amount $readini($char($1), stuff, redorbs)
    var %miser-ring.increase $round($calc(%redorb.amount * %accessory.amount),0)

    if (%miser-ring.increase <= 0) { var %miser-ring.increase 1 }
    if (%miser-ring.increase > 500) { var %miser-ring.increase 500 }
    inc %attack.damage %miser-ring.increase
  }

  ;  Check for the fool's tablet accessory
  if ($readini($char($1), equipment, accessory) = Fool's-Tablet) {
    var %accessory.amount $readini(items.db, fool's-tablet, amount)
    inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
  }

  if ($augment.check($1, MeleeBonus) = true) { 
    set %melee.bonus.augment $calc(%augment.strength * .25)
    var %augment.power.increase.amount $round($calc(%melee.bonus.augment * %attack.damage),0)
    inc %attack.damage %augment.power.increase.amount
    unset %melee.bonus.augment
  }

  unset %current.accessory.type

  $weapon_parry_check($3, $1, $2)
  $trickster_dodge_check($3, $1)
  $royalguard.check($1, $2, $3)
  $utsusemi.check($1, $2, $3)

  ; Check to see if the melee attack will hurt an ethereal monster
  $melee.ethereal.check($1, $2, $3)

  unset %statusmessage.display
  set %status.type.list $readini(weapons.db, $2, StatusType)

  if (%status.type.list != $null) { 
    set %number.of.statuseffects $numtok(%status.type.list, 46) 

    if (%number.of.statuseffects = 1) { $inflict_status($1, $3, %status.type.list) | unset %number.of.statuseffects | unset %status.type.list }
    if (%number.of.statuseffects > 1) {
      var %status.value 1
      while (%status.value <= %number.of.statuseffects) { 
        set %current.status.effect $gettok(%status.type.list, %status.value, 46)
        $inflict_status($1, $3, %current.status.effect)
        inc %status.value 1
      }  
      unset %number.of.statuseffects | unset %current.status.effect
    }
  }
  unset %status.type.list


  var %weapon.element $readini(weapons.db, $2, element)
  if ((%weapon.element != $null) && (%weapon.element != none)) {
    $modifer_adjust($3, %weapon.element)
  }

  ; Check for weapon type weaknesses.
  set %weapon.type $readini(weapons.db, $2, type)
  $modifer_adjust($3, %weapon.type)

  ; Elementals are strong to melee
  if ($readini($char($3), monster, type) = elemental) { %attack.damage = $round($calc(%attack.damage - (%attack.damage * .30)),0) } 

  ; Now we're ready to calculate the enemy's defense..  
  set %enemy.defense $readini($char($3), battle, def)

  $defense_down_check($3)

  ; Check to see if the weapon has an "IgnoreDefense=" flag.  If so, cut the def down.
  var %ignore.defense.percent $readini(weapons.db, $2, IgnoreDefense)

  if ($augment.check($1, IgnoreDefense) = true) {   inc %ignore.defense.percent $calc(%augment.strength * 2) }

  if (%ignore.defense.percent > 0) { 
    var %def.ignored $round($calc(%enemy.defense * (%ignore.defense.percent * .010)),0)
    dec %enemy.defense %def.ignored
    if (%enemy.defense <= 0) { set %enemy.defense 1 }
  }

  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  var %flag $readini($char($1), info, flag) 

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL DAMAGE.
  ;;; FORMULA 1
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if ($readini(system.dat, system, BattleDamageFormula) = 1) {

    ; Set the level ratio

    if (%flag = monster) { 
      set %temp.strength %base.stat
      if (%temp.strength > 800) { set %temp.strength $calc(700 + (%temp.strength / 40))
        set %temp.strength $round(%temp.strength,0)
        set %level.ratio $calc(%temp.strength / %enemy.defense)
      }
      if (%temp.strength <= 800) {  set %level.ratio $calc(%temp.strength / %enemy.defense) }
    }

    if ((%flag = $null) || (%flag = npc))  { 
      set %temp.strength %base.stat
      if (%temp.strength > 6000) { set %temp.strength $calc(6000 + (%temp.strength / 3))
        set %temp.strength $round(%temp.strength,0)
        set %level.ratio $calc(%temp.strength / %enemy.defense)
        unset %temp.strength
      }
      if (%temp.strength <= 6000) {  set %level.ratio $calc(%temp.strength / %enemy.defense) }
    }

    ; Calculate the Level Ratio
    set %level.ratio $calc($readini($char($1), battle, str) / %enemy.defense)

    var %attacker.level $get.level($1)
    var %defender.level $get.level($3)

    if (%attacker.level > %defender.level) { inc %level.ratio .3 }
    if (%attacker.level < %defender.level) { dec %level.ratio .3 }

    if (%level.ratio > 2) { set %level.ratio 2 }
    if (%level.ratio <= .02) { set %level.ratio .02 }

    unset %temp.strength

    ; And let's get the final attack damage..
    %attack.damage = $round($calc(%attack.damage * %level.ratio),0)
  }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL DAMAGE.
  ;;; FORMULA 2
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if ($readini(system.dat, system, BattleDamageFormula) = 2) { 
    $calculate_pDIF($1, $3, melee)

    if (%flag != $null) { 
      if ($get.level($1) >= $get.level($3)) {   set %attack.damage $round($calc(%attack.damage / 3.5),0)  }
      if ($get.level($1) < $get.level($3)) {   set %attack.damage $round($calc(%attack.damage / 4.2),0)  }
    }
    if (%flag = $null) {
      if ($get.level($1) >= $get.level($3)) {   set %attack.damage $round($calc(%attack.damage / 2.8),0)  }
      if ($get.level($1) < $get.level($3)) {   set %attack.damage $round($calc(%attack.damage / 3.9),0)  }
    }

    %attack.damage = $round($calc(%attack.damage  * %pDIF),0)
    unset %pdif 
  }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; ADJUST THE TOTAL DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if ((%flag = $null) || (%flag = npc)) {
    if ($readini(system.dat, system, IgnoreDmgCap) != true) { 
      if (%attack.damage > 10000) {
        set %temp.damage $calc(%attack.damage / 100) 
        set %attack.damage $calc(10000 + %temp.damage)
        unset %temp.damage
        if (%attack.damage >= 50000) { set %attack.damage $rand(45000,47000) }
      }
    }

    if (%attack.damage <= 1) {
      var %base.weapon $readini(weapons.db, $2, BasePower)
      var %str.increase.amount $round($calc(%true.base.stat * .10),0)
      inc %base.weapon %str.increase.amount
      var %min.damage %base.weapon
      set %attack.damage $readini(weapons.db, $2, BasePower)

      var %attacker.level $get.level($1)
      var %defender.level $get.level($3)
      var %level.difference $calc(%defender.level - %attacker.level)

      if (%level.difference >= 300) { 
        set %attack.damage 1
        set %min.damage $round($calc(%min.damage / 2),0)
      }

      set %attack.damage $rand(%min.damage, %attack.damage)
    }

    inc %attack.damage $rand(1,10)
  }

  if ((%flag = monster) && ($readini($char($3), info, flag) = $null)) {
    var %min.damage $round($calc(%true.base.stat / 15),0)

    if (%attack.damage <= 0) { 
      var %base.weapon $readini(weapons.db, $2, BasePower)
      var %str.increase.amount $round($calc(%true.base.stat * .02),0)

      inc %base.weapon %str.increase.amount
      var %min.damage %base.weapon

      set %attack.damage $readini(weapons.db, $2, BasePower)

      var %attacker.level $get.level($1)
      var %defender.level $get.level($3)
      var %level.difference $calc(%defender.level - %attacker.level)

      if (%level.difference >= 300) { 
        set %attack.damage 1
        set %min.damage $round($calc(%min.damage / 2),0)
      }
    }

    set %attack.damage $rand(%attack.damage, %min.damage)
    if ($readini(battlestats.dat, battle, winningstreak) <= 0) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  }

  unset %true.base.stat


  if ((%attack.damage > 2000) && ($readini($char($1), info, flag) = monster)) { 
    if ($readini(system.dat, system, IgnoreDmgCap) != true) { 
      if (%battle.rage.darkness != on) { set %attack.damage $rand(1000,2100) }
    }
  }


  if (%guard.message = $null) {  inc %attack.damage $rand(1,3) }
  unset %enemy.defense | unset %level.ratio

  ; Check for the Guardian style
  $guardian_style_check($3)

  ; To be fair to players, we'll limit the damage if it has the ability to ignore guardian.
  if ($augment.check($1, IgnoreGuardian) = true) { 
    var %user.flag $readini($char($1), info, flag)
    if (%user.flag = monster) { 
      if ($readini($char($3), info, flag) = $null) {
        if (%attack.damage > 2000) { set %attack.damage $rand(1000, 2100) } 
      }
    }
  }

  ; Check for metal defense.  If found, set the damage to 1.
  $metal_defense_check($3, $1)

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances...  
  if (%guard.message = $null) {
    if (%attack.damage <= 0) { set %attack.damage 1 }
  }

  ; Check for a critical hit.
  var %critical.hit.chance $rand(1,100)

  ; check for the Impetus Passive Skill
  var %impetus.check $readini($char($1), skills, Impetus)
  if (%impetus.check != $null) { inc %critical.hit.chance %impetus.check }

  ; If the user is using a h2h weapon, increase the critical hit chance by 1.
  if ($readini(weapons.db, $2, type) = HandToHand) { inc %critical.hit.chance 1 }

  set %player.accessory $readini($char($1), equipment, accessory)

  if (%player.accessory != $null) { 
    set %accessory.type $readini(items.db, %player.accessory, AccessoryType)
    if (%accessory.type = IncreaseCriticalHits) {
      set %accessory.amount $readini(items.db, %player.accessory, amount)
      if (%accessory.amount = $null) { var %accessory.amount 1 }
      inc %critical.hit.chance %accessory.amount
    }
  }

  unset %player.accessory | unset %accessory.type | unset %accessory.amount

  if ($augment.check($1, EnhanceCriticalHits) = true) { inc %critical.hit.chance %augment.strength }

  if (%critical.hit.chance >= 97) {
    $set_chr_name($1) |  $display.system.message($readini(translation.dat, battle, LandsACriticalHit), battle)
    set %attack.damage $round($calc(%attack.damage * 1.5),0)
  }

  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  if ($readini(weapons.db, $2, cost) = 0) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %attack.damage 0 }
  }

  set %current.accessory $readini($char($1), equipment, accessory) 
  set %current.accessory.type $readini(items.db, %current.accessory, accessorytype)

  if (%current.accessory.type = CurseAddDrain) { set %absorb absorb }

  if ($augment.check($1, Drain) = true) {  set %absorb absorb }

  unset %current.accessory | unset %current.accessory.type | writeini $char($1) skills mightystrike.on off

  ; Is the weapon a multi-hit weapon?  
  set %weapon.howmany.hits $readini(weapons.db, $2, hits)

  if ($augment.check($1, AdditionalHit) = true) { inc %weapon.howmany.hits %augment.strength }

  if ($1 = demon_wall) {  $demon.wall.boost($1) }

  $first_round_dmg_chk($1, $3)

  ; check for melee counter
  $counter_melee($1, $3, $2)

  ; Check for the weapon bash skill
  $weapon_bash_check($1, $3)

  var %current.element $readini(weapons.db, $2, element)
  if ((%current.element != $null) && (%tech.element != none)) {
    set %target.element.null $readini($char($3), modifiers, %current.element)
    if (%target.element.null <= 0) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 
    }
    unset %target.element.null
  }

  var %weapon.type $readini(weapons.db, $2, type)
  if (%weapon.type != $null) {
    set %target.weapon.null $readini($char($3), modifiers, %weapon.type)
    if (%target.weapon.null <= 0) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToWeaponType) 
      set %attack.damage 0 
    }
    unset %target.weapon.null
  }

  ; If the target has Protect on, it will cut  melee damage in half.
  if ($readini($char($3), status, protect) = yes) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CHECK FOR MULTI-HITS
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if (%weapon.howmany.hits = $null) || (%weapon.howmany.hits <= 0) { set %weapon.howmany.hits 1
    if (%counterattack != on) { $double.attack.check($1, $3, $rand(1,100)) }
  }
  if (%weapon.howmany.hits = 1) {  
    if (%counterattack != on) { $double.attack.check($1, $3, $rand(1,100)) }
  }

  if (%weapon.howmany.hits = 2) {  $double.attack.check($1, $3, 100) }
  if (%weapon.howmany.hits = 3) { $triple.attack.check($1, $3, 100) }
  if (%weapon.howmany.hits = 4) { set %weapon.howmany.hits 4 | $fourhit.attack.check($1, $3, 100) }
  if (%weapon.howmany.hits = 5) { set %weapon.howmany.hits 5 | $fivehit.attack.check($1, $3, 100) }
  if (%weapon.howmany.hits >= 6) { set %weapon.howmany.hits 6 | $sixhit.attack.check($1, $3, 100) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Skill and Mastery checks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias mastery_check {
  var %type.of.weapon $readini(weapons.db, $2, type)
  set %mastery.type nonexistant 
  if (%type.of.weapon = handtohand) { set %mastery.type MartialArts }
  if (%type.of.weapon = nunchuku) { set %mastery.type MartialArts }
  if (%type.of.weapon = katana) { set %mastery.type Swordmaster }
  if (%type.of.weapon = sword) { set %mastery.type Swordmaster }
  if (%type.of.weapon = greatsword) { set %mastery.type Swordmaster }
  if (%type.of.weapon = gun) { set %mastery.type Gunslinger }
  if (%type.of.weapon = rifle) { set %mastery.type Gunslinger }
  if (%type.of.weapon = wand) { set %mastery.type Wizardry }
  if (%type.of.weapon = stave) { set %mastery.type Wizardry }
  if (%type.of.weapon = glyph) { set %mastery.type Wizardry }
  if (%type.of.weapon = spear) { set %mastery.type Polemaster }
  if (%type.of.weapon = bow) { set %mastery.type Archery }

  set %mastery.bonus $readini($char($1), skills, %mastery.type) 
  if (%mastery.bonus = $null) { set %mastery.bonus 0 }
  unset %mastery.type
}

alias mighty_strike_check {
  var %mightystrike $readini($char($1), skills, mightystrike.on)
  if (%mightystrike = on) { return true }
  else { return false }
}

alias desperate_blows_check {
  if ($readini($char($1), skills, desperateblows) != $null) { return true }
  else { return false }
}

alias weapon_bash_check {
  if (%counterattack = on) { return }

  if ($readini($char($1), skills, WeaponBash) > 0) {

    set %resist.skill $readini($char($2), skills, resist-stun)
    $ribbon.accessory.check($2)
    if (%resist.skill = 100) { return }
    unset %resist.skill

    if (%guard.message != $null) { return }
    if ($readini($char($2), skills, royalguard.on) = on) { return }
    if ($readini($char($2), skills, utsusemi.on) = on) { return }
    if (%trickster.dodged = on) { return }


    var %stun.chance $rand(1,100)
    var %weapon.bash.chance $calc($readini($char($1), skills, weaponbash) * 10)

    if ($augment.check($1, EnhanceWeaponBash) = true) { inc %weapon.bash.chance %augment.strength  } 

    if (%stun.chance <= %weapon.bash.chance) {
      writeini $char($2) status stun yes | $set_chr_name($2) | set %statusmessage.display 4 $+ %real.name has been stunned by the blow!
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Drain Samba check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias drain_samba_check {
  unset %drainsamba.on
  if ($readini($char($1), skills, drainsamba.on) = on) {
    ; Check to see how many turns its been..  
    set %drainsamba.turns $readini($char($1), skills, drainsamba.turn)
    if (%drainsamba.turns = $null) { set %drainsamba.turns 0 }
    set %drainsamba.turn.max $readini($char($1), skills, drainsamba)
    inc %drainsamba.turns 1 
    if (%drainsamba.turns > %drainsamba.turn.max) { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, DrainSambaWornOff), battle) | writeini $char($1) skills drainsamba.turn 0 | writeini $char($1) skills drainsamba.on off | return }
    writeini $char($1) skills drainsamba.turn %drainsamba.turns   
    set %drainsamba.on on
  }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for augments and accessories
; that enhance weapon types.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias melee.weapontype.enhancements {

  ; Hand To Hand
  if (%weapon.type = HandToHand) {

    ;  Check for a +h2h damage accessory
    if ($readini(items.db, %current.accessory, accessorytype) = IncreaseH2HDamage) {
      set %accessory.amount $readini(items.db, %current.accessory, amount)
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceHandtoHand) = true) {  inc %attack.damage $round($calc(%attack.damage + (%augment.strength * 50)),0)  } 
  }


  ; Spears
  if (%weapon.type = spear) {

    ;  Check for a +spear damage accessory
    set %current.accessory $readini($char($1), equipment, accessory) 
    if ($readini(items.db, %current.accessory, accessorytype) = IncreaseSpearDamage) {
      set %accessory.amount $readini(items.db, %current.accessory, amount)
      inc %attack.damage $round($calc(%attack.damage * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for an augment
    if ($augment.check($1, EnhanceSpear) = true) {  inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = sword) {
    ; Check for an augment
    if ($augment.check($1, EnhanceSword) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = greatsword) {
    ; Check for an augment
    if ($augment.check($1, EnhanceSword) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = whip) {
    ; Check for an augment
    if ($augment.check($1, EnhanceWhip) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = gun) {
    ; Check for an augment
    if ($augment.check($1, EnhanceRanged) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = bow) {
    ; Check for an augment
    if ($augment.check($1, EnhanceRanged) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = glyph) {
    ; Check for an augment
    if ($augment.check($1, EnhanceGlyph) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = Katana) {
    ; Check for an augment
    if ($augment.check($1, EnhanceKatana) = true) {  inc %attack.damage $calc(%augment.strength * 100)   } 
  }

  if (%weapon.type = Wand) {
    ; Check for an augment
    if ($augment.check($1, EnhanceWand) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }
  if (%weapon.type = Staff) {
    ; Check for an augment
    if ($augment.check($1, EnhanceStaff) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = Scythe) {
    ; Check for an augment
    if ($augment.check($1, EnhanceScythe) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = Axe) {
    ; Check for an augment
    if ($augment.check($1, EnhanceAxe) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }

  if (%weapon.type = Dagger) {
    ; Check for an augment
    if ($augment.check($1, EnhanceDagger) = true) { inc %attack.damage $calc(%augment.strength * 100)  } 
  }


}
