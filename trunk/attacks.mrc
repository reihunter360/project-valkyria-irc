;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ATTACKS COMMAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON 2:ACTION:attacks *:#:{ 
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  $set_chr_name($nick) | $attack_cmd($nick , $2) 
} 
ON 2:TEXT:!attack *:#:{ 
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyCharmed) | halt }
  $set_chr_name($nick) | $attack_cmd($nick , $2) 
} 
ON 50:TEXT:*attacks *:*:{ 
  if ($2 != attacks) { halt } 
  else { 
    $charm.check($1, $nick) | unset %real.name 
    if $readini($char($1), Battle, HP) = $null) { halt }
    $set_chr_name($1) | $attack_cmd($1 , $3) 
  }
}

alias attack_cmd { $check_for_battle($1) | $person_in_battle($2) | $checkchar($2) | var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($2), info, flag)
  if ($is_charmed($1) = true) { var %user.flag monster }

  if (($2 = $1) && ($is_charmed($1) = false))  { query %battlechan $readini(translation.dat, errors, Can'tAttackYourself) | unset %real.name | halt  }
  if ((%user.flag != monster) && (%target.flag != monster)) { query %battlechan $readini(translation.dat, errors, CanOnlyAttackMonsters) | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, CanNotAttackWhileUnconcious)  | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, CanNotAttackSomeoneWhoIsDead) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { query %battlechan $readini(translation.dat, errors, CanNotAttackSomeoneWhoFled) | unset %real.name | halt } 

  ; Make sure the old attack damages have been cleared, and clear a few variables.
  unset %attack.damage | unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4
  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %drainsamba.on | unset %absorb
  unset %enemy | unset %user | unset %real.name

  ; Get the weapon equipped
  $weapon_equipped($1)

  ; Calculate, deal, and display the damage..
  $calculate_damage_weapon($1, %weapon.equipped, $2)
  $drain_samba_check($1)
  $deal_damage($1, $2, %weapon.equipped)
  $display_damage($1, $2, weapon, %weapon.equipped)

  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %critical.hit.chance

  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) }
}

alias calculate_damage_weapon {
  ; $1 = %user
  ; $2 = weapon equipped
  ; $3 = target / %enemy 

  set %attack.damage 0
  var %random.attack.damage.increase $rand(1,10)

  ; First things first, let's find out the base power.
  var %base.power $readini(weapons.db, $2, basepower)

  if (%base.power = $null) { var %base.power 1 }

  var %base.stat $readini($char($1), battle, str)
  var %weapon.base $readini($char($1), weapons, $2)
  inc %weapon.base $round($calc(%weapon.base * 1.5),0)

  ; If the weapon is a hand to hand, it will now receive a bonus based on your fists level.
  if ($readini(weapons.db, $2, type) = HandToHand) {
    inc %weapon.base $readini($char($1), weapons, fists)
  }

  inc %weapon.base %base.power

  ; If the target is weak to the element, double the attack power of the weapon. 
  ; If the target is strong to the element, cut the attack of the weapon by half.
  var %weapon.element $readini(weapons.db, $2, element)
  if ((%weapon.element != $null) && (%weapon.element != none)) {
    var %target.element.weak $readini($char($3), element, weakness)
    var %target.element.strong $readini($char($3), element, strong)

    if (%weapon.element isin %target.element.weak) { inc %weapon.base %weapon.base 
      var %def.of.monster $readini($char($3), battle, def) | dec %def.of.monster 1 
      if (%def.of.monster < 1) { inc %def.of.monster 1 }
      writeini $char($3) battle def %def.of.monster
    }
    if (%weapon.element isin %target.element.strong) { %weapon.base = $round($calc(%weapon.base / 2), 0) 
      var %str.of.monster $readini($char($3), battle, str) | inc %str.of.monster 1 | writeini $char($3) battle str %str.of.monster
    }
  }

  ; Check for weapon type weaknesses.
  var %weapon.weakness $readini($char($3), weapons, weakness)
  var %weapon.strengths $readini($char($3), weapons, strong)
  var %weapon.type $readini(weapons.db, $2, type)
  if ($istok(%weapon.weakness,%weapon.type,46) = $true) {  inc %weapon.base %weapon.base }
  if ($istok(%weapon.strengths,%weapon.type,46) = $true) { %weapon.base = $round($calc(%weapon.base / 2), 0)  }

  ; Does the user have any mastery of the weapon?
  $mastery_check($1, $2)

  ; Is the person using the WeaponMaster style?  If so, increase the mastery bonus.

  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
  if (%current.playerstyle = WeaponMaster) { 
    var %playerstyle.bonus $calc(%current.playerstyle.level * 2)
    inc %mastery.bonus %playerstyle.bonus
    inc %random.attack.damage.increase $calc(%current.playerstyle.level * 2)
  }

  ; Let's add the mastery bonus to the weapon base
  inc %weapon.base %mastery.bonus

  ; Let's add that to the base power and set it as the attack damage.
  inc %base.stat %weapon.base
  inc %attack.damage %base.stat

  set %current.playerstyle $readini($char($1), styles, equipped)
  set %current.playerstyle.level $readini($char($1), styles, %current.playerstyle)
  if (%current.playerstyle = HitenMitsurugi-ryu) {
    if ($readini(weapons.db, $2, type) = Katana) {
      var %amount.to.increase $round($calc((.10 * %current.playerstyle.level) * %attack.damage),0)
      inc %attack.damage %amount.to.increase
    }    
  }

  ;If the element is Light and the target has the ZOMBIE status, then we need to increase the damage
  if ($readini($char($3), status, zombie) = yes) { 
    if (%weapon.element = light) {  inc %attack.damage $round($calc(%attack.damage * .110),0) } 
    if (%weapon.element = fire) {  inc %attack.damage $round($calc(%attack.damage * .110),0) } 
  } 

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

  if ($readini($char($3), skills, utsusemi.on) = off) {
    ; does the target have RoyalGuard on?  If so, reduce the damage to 0.
    if ($readini($char($3), skills, royalguard.on) = on) { writeini $char($3) skills royalguard.on off | set %attack.damage 0 | $set_chr_name($3) | query %battlechan $readini(translation.dat, skill, RoyalGuardBlocked) | return }
  }
  if ($readini($char($3), skills, utsusemi.on) = on) {
    var %number.of.shadows $readini($char($3), skills, utsusemi.shadows)
    dec %number.of.shadows 1 
    writeini $char($3) skills utsusemi.shadows %number.of.shadows
    if (%number.of.shadows <= 0) { writeini $char($3) skills utsusemi.on off }
    $set_chr_name($3) | query %battlechan $readini(translation.dat, skill, UtsusemiBlocked) | set %attack.damage 0 | return 
  }

  ; Now we're ready to calculate the enemy's defense..  
  var %enemy.defense $readini($char($3), battle, def)

  ; Is the target using the Guardian style?  If so, we need to decrease the damage done.
  set %current.playerstyle $readini($char($3), styles, equipped)
  set %current.playerstyle.level $readini($char($3), styles, %current.playerstyle)
  if (%current.playerstyle = Guardian) { 
    var %block.value $calc(%current.playerstyle.level / 15.5)
    if (%block.value > .60) { var %block.value .60 }
    var %amount.to.block $round($calc(%attack.damage * %block.value),0)
    dec %attack.damage %amount.to.block
  }

  ; And let's get the final attack damage..
  dec %attack.damage %enemy.defense

  ; In this bot we don't want the attack to ever be lower than 1 except for rare instances...  
  if (%attack.damage <= 0) { set %attack.damage 1 }

  ; Check for a critical hit.
  var %critical.hit.chance $rand(1,100)

  ; check for the Impetus Passive Skill
  var %impetus.check $readini($char($1), skills, Impetus)
  if (%impetus.check != $null) { inc %critical.hit.chance %impetus.check }

  ; If the user is using a h2h weapon, increase the critical hit chance by 1.
  if ($readini(weapons.db, $2, type) = HandToHand) { inc %critical.hit.chance 1 }

  if (%critical.hit.chance >= 97) {
    $set_chr_name($1) |  query %battlechan $readini(translation.dat, battle, LandsACriticalHit)
    set %attack.damage $round($calc(%attack.damage * 1.5),0)
  }

  ; If a player is using a monster weapon, which is considered cheating, set the damage to 0.
  if ($readini(weapons.db, $2, cost) = 0) {
    var %current.flag $readini($char($1), info, flag)
    if (%current.flag = $null) {  set %attack.damage 0 }
  }

  ; Is the weapon a multi-hit weapon?  
  set %weapon.howmany.hits $readini(weapons.db, $2, hits)
  if (%weapon.howmany.hits = $null) || (%weapon.howmany.hits <= 0) { set %weapon.howmany.hits 1 | $double.attack.check($1, $3, $rand(1,100)) }
  if (%weapon.howmany.hits = 1) {  $double.attack.check($1, $3, $rand(1,100)) }
  if (%weapon.howmany.hits = 2) {  $double.attack.check($1, $3, 100) }
  if (%weapon.howmany.hits = 3) { $triple.attack.check($1, $3, 100) }
  if (%weapon.howmany.hits = 4) { set %weapon.howmany.hits 4 | $fourhit.attack.check($1, $3, 100) }
  if (%weapon.howmany.hits >= 5) { set %weapon.howmany.hits 5 | $fivehit.attack.check($1, $3, 100) }
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
  set %mastery.bonus $readini($char($1), skills, %mastery.type) 
  if (%mastery.bonus = $null) { set %mastery.bonus 0 }
  unset %mastery.type
}

alias mighty_strike_check {
  var %mightystrike $readini($char($1), skills, mightystrike.on)
  if (%mightystrike = on) { writeini $char($1) skills mightystrike.on off | return true }
  else { return false }
}

alias desperate_blows_check {
  if ($readini($char($1), skills, desperateblows) != $null) { return true }
  else { return false }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Multiple Attack Checks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias double.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage.total

  set %double.attack.chance $3
  if (%double.attack.chance >= 90) { set %double.attack true

    set %attack.damage1 %attack.damage
    set %attack.damage2 $abs($round($calc(%attack.damage / 3),0))

    if (%attack.damage2 <= 0) { set %attack.damage2 1 }

    var %attack.damage3 $calc(%attack.damage1 + %attack.damage2)
    if (%attack.damage3 > 0) {   
    set %attack.damage %attack.damage3 | $set_chr_name($1) | query %battlechan $readini(translation.dat, battle, PerformsADoubleAttack) } 
    unset %double.attack.chance
  }
  else { unset %double.attack.chance | return }
}

alias triple.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage.total
  set %triple.attack true

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%attack.damage / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%attack.damage.total / 2.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage %attack.damage.total | $set_chr_name($1) | query %battlechan $readini(translation.dat, battle, PerformsATripleAttack)
}

alias fourhit.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage.total
  set %fourhit.attack true

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%attack.damage / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%attack.damage.total / 2.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%attack.damage.total / 2.3),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage %attack.damage.total | $set_chr_name($1) | query %battlechan $readini(translation.dat, system, PerformsA4HitAttack)
}

alias fivehit.attack.check {
  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage.total
  set %fivehit.attack true

  set %attack.damage1 %attack.damage
  set %attack.damage2 $abs($round($calc(%attack.damage / 2.1),0))
  if (%attack.damage2 <= 0) { set %attack.damage2 1 }
  var %attack.damage.total $calc(%attack.damage1 + %attack.damage2)

  set %attack.damage3 $abs($round($calc(%attack.damage.total / 2.2),0))
  if (%attack.damage3 <= 0) { set %attack.damage3 1 }
  var %attack.damage.total $calc(%attack.damage3 + %attack.damage.total)

  set %attack.damage4 $abs($round($calc(%attack.damage.total / 2.3),0))
  if (%attack.damage4 <= 0) { set %attack.damage4 1 }
  var %attack.damage.total $calc(%attack.damage4 + %attack.damage.total)

  set %attack.damage5 $abs($round($calc(%attack.damage.total / 3.3),0))
  if (%attack.damage5 <= 0) { set %attack.damage5 1 }
  var %attack.damage.total $calc(%attack.damage5 + %attack.damage.total)

  set %attack.damage %attack.damage.total | $set_chr_name($1) | query %battlechan $readini(translation.dat, system,PerformsA5HitAttack)
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
    if (%drainsamba.turns > %drainsamba.turn.max) { $set_chr_name($1) | query %battlechan $readini(translation.dat, skill, DrainSambaWornOff) | writeini $char($1) skills drainsamba.turn 0 | writeini $char($1) skills drainsamba.on off | return }
    writeini $char($1) skills drainsamba.turn %drainsamba.turns   
    set %drainsamba.on on
  }
}
