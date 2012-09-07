;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ITEMS COMMAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!use*:*: {  unset %real.name | unset %enemy
  if ($is_charmed($nick) = true) { query %battlechan 4 %real.name is currently charmed and cannot perform any of $gender($nick) own actions! | halt }
  if ((no-item isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan 4 $+ %real.name is not allowed to do that action due to the current battle conditions! | halt }

  var %item.type $readini(items.db, $2, type)
  if (%item.type != summon) {
    if (($3 != on) || ($3 = $null)) { .msg $nick 4Error: !use <item> ON <person> | halt }
    if ($4 = me) { .msg $nick 4Error: You must specify a name, rather than "me" | halt }
    if ($readini($char($4), battle, status) = dead) { query %battlechan 4This item cannot be used on someone who's dead. | halt }
    $checkchar($4)
  }

  set %check.item $readini($char($nick), Item_Amount, $2) 
  if ((%check.item <= 0) || (%check.item = $null)) { $set_chr_name($nick) | query %battlechan 4Error: %real.name does not have that item. | halt }

  var %user.flag $readini($char($nick), info, flag) | var %target.flag $readini($char($4), info, flag)
  if (%item.type = food) { 
    if (%battleis = on) { $check_for_battle($nick)   }

    if (%target.flag = monster) { query %battlechan 4Error: This item can only be used on players! | halt }
    $item.food($nick, $4, $2) | $decrease_item($nick, $2) 
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
    halt
  }

  if (%item.type = consume) { query %battlechan 4Error: This item is used via performing a skill. | halt }

  if (%item.type = shopreset) {
    if (%battleis = on) { $check_for_battle($nick)   }

    if (%target.flag = monster) { query %battlechan 4Error: This item can only be used on players! | halt }
    $item.shopreset($nick, $4, $2) | $decrease_item($nick, $2) 
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
    halt  
  }

  $check_for_battle($nick) 
  if (%battleis = off) { query %battlechan 4There is no battle currently! | halt }

  if (%item.type = damage) {
    if (%target.flag != monster) { query %battlechan 4Error: This item can only be used on monsters! | halt }
    $item.damage($nick, $4, $2)
  }

  if (%item.type = heal) {
    if ((%target.flag = monster) && ($readini($char($4), monster, type) != zombie)) { query %battlechan 4Error: This item can only be used on players! | halt }
    $item.heal($nick, $4, $2)
  }

  if (%item.type = tp) { 
    if (%target.flag = monster) { query %battlechan 4Error: This item can only be used on players! | halt }
    ; Show the desc
    $set_chr_name($4) | var %enemy %real.name | $set_chr_name($nick) 
    query %battlechan 3 $+ %real.name  $+ $readini(items.db, $2, desc)
    $item.tp($nick, $4, $2)
    $decrease_item($nick, $2) 
    if (%battleis = on)  { $check_for_double_turn($nick) | halt }
  }

  if (%item.type = status) {
    if (%target.flag != monster) { query %battlechan 4Error: This item can only be used on monsters! | halt }
    $item.status($nick, $4, $2)
  }

  if (%item.type = revive) {  query %battlechan 4This item will automatically take effect when needed. | halt }

  if (%item.type = summon) { $item.summon($nick, $2) }
  $decrease_item($nick, $2)
  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($nick) | halt }
}


alias decrease_item {
  ; Subtract the item and tell the new total
  dec %check.item 1 
  writeini $char($1) item_amount $2 %check.item
  unset %check.item
}

alias item.summon {
  ; $1 = user
  ; $2 = item used

  ; Check to make sure the monster isn't already summoned and the user has the skill needed.
  if ($skillhave.check($1, BloodPact) = false) { $set_chr_name($1) | query %battlechan 4Error: %real.name does not have the appropriate skill to use this item. | halt }
  if ($isfile($char($nick $+ _summon)) = $true) { $set_chr_name($1) | query %battlechan 4Error: %real.name has already used Blood Pact for this battle and cannot use it again! | halt }

  ; Get the summon via the item.
  set %summon.name $readini(items.db, $2, summon)
  .copy $summon(%summon.name) $char($1 $+ _summon)

  ; Add to battle
  set %curbat $readini(battle2.txt, Battle, List)
  %curbat = $addtok(%curbat,$1 $+ _summon,46)
  writeini battle2.txt Battle List %curbat
  write battle.txt $1 $+ _summon

  ; Show desc 
  $set_chr_name($1 $+ _summon) | query %battlechan 4The $2 explodes and summons %real.name $+ ! 12 $+ %real.name  $+ $readini($char($1 $+ _summon), descriptions, char)

  ; Set the user's TP to 0.
  writeini $char($1) Battle TP 0

  unset %summon.name
}

alias item.damage {
  ; $1 = user
  ; $2 = target
  ; $3 = item used
  $calculate_damage_items($1, $3, $2)
  $deal_damage($1, $2, $3)
  $display_damage($1, $2, item, $3)

  return
}

alias item.status {
  ; $1 = user
  ; $2 = target
  ; $3 = item used

  var %status.type $readini(items.db, $3, StatusType) 

  if (%status.type = random) { 
    var %random.status.type $rand(1,11)
    if (%random.status.type = 1) { set %status.type poison | var %tech.status.grammar poisoned }
    if (%random.status.type = 2) { set %status.type stop | var %tech.status.grammar weighed down }
    if (%random.status.type = 3) { set %status.type silence | var %tech.status.grammar silenced }
    if (%random.status.type = 4) { set %status.type blind | var %tech.status.grammar blinded }
    if (%random.status.type = 5) { set %status.type virus | var %tech.status.grammar inflicted with a virus }
    if (%random.status.type = 6) { set %status.type amnesia | var %tech.status.grammar inflicted with amnesia }
    if (%random.status.type = 7) { set %status.type paralysis | var %tech.status.grammar paralyzed }
    if (%random.status.type = 8) { set %status.type zombie | var %tech.status.grammar a zombie }
    if (%random.status.type = 9) { set %status.type slow | var %tech.status.grammar slowed }
    if (%random.status.type = 10) { set %status.type stun | var %tech.status.grammar stunned }
    if (%random.status.type = 11) { set %status.type intimidate | var %tech.status.grammar intimidated }
  }

  if (%status.type = stop) { var %tech.status.grammar frozen in time }
  if (%status.type = poison) { var %tech.status.grammar poisoned }
  if (%status.type = silence) { var %tech.status.grammar silenced }
  if (%status.type = blind) { var %tech.status.grammar blind }
  if (%status.type = virus) { var %tech.status.grammar inflicted with a virus }
  if (%status.type = amnesia) { var %tech.status.grammar inflicted with amnesia }
  if (%status.type = paralysis) { var %tech.status.grammar paralyzed }
  if (%status.type = zombie) { var %tech.status.grammar a zombie }
  if (%status.type = slow) { var %tech.status.grammar slowed }
  if (%status.type = stun) { var %tech.status.grammar stunned }
  if (%status.type = curse) { var %tech.status.grammar cursed }
  if (%status.type = intimidate) { var %tech.status.grammar intimidated }

  if ($readini($char($2), skills, utsusemi.on) = on) { set%chance 0 } 

  $calculate_damage_items($1, $3, $2)
  $deal_damage($1, $2, $3)

  ; Check for resistance to that status type.
  var %chance $rand(1,100) | $set_chr_name($1) 
  set %resist.have resist- $+ %status.type
  set %resist.skill $readini($char($2), skills, %resist.have)

  if (%status.type = charm) {
    if ($readini($char($2), status, zombie) != no) { set %resist.skill 100 }
    if ($readini($char($2), monster, type) = undead) { set %resist.skill 100 }
  }

  if ((%resist.skill != $null) && (%resist.skill > 0)) { 
    if (%resist.skill >= 100) { set %statusmessage.display 4 $+ %real.name is immune to the %status.type status! }
    else { dec %chance %resist.skill }
  }

  if ((%resist.skill < 100) || (%resist.skill = $null)) {
    if ((%resist.skill != $null) && (%resist.skill > 0)) { dec %chance %resist.skill }

    if (%chance >= 50) {
      $set_chr_name($2) 
      if ((%chance = 50) && (%status.type = poison)) { $set_chr_name($3) | set %statusmessage.display 4 $+ %real.name is now %tech.status.grammar $+ !  | writeini $char($2) Status poison-heavy yes }
      if ((%chance = 50) && (%status.type != poison)) { $set_chr_name($3) | set %statusmessage.display 4 $+ %real.name is now %tech.status.grammar $+ !  | writeini $char($2) Status %status.type yes }
      else { $set_chr_name($2) | set %statusmessage.display 4 $+ %real.name is now %tech.status.grammar $+ !  | writeini $char($2) Status %status.type yes 
        if (%status.type = charm) { writeini $char($2) status charmed yes | writeini $char($2) status charmer $1 | writeini $char($2) status charm.timer $rand(2,3) }
        if (%status.type = curse) { writeini $char($2) battle tp 0 }
      }
    }
    else {
      if (%resist.skill >= 100) { $set_chr_name($2) | set %statusmessage.display 4 $+ %real.name is immune to the %status.type status! }
      if ((%resist.skill  >= 1) && (%resist.skill < 100)) { $set_chr_name($2) | set %statusmessage.display 4 $+ %real.name has resisted $set_chr_name($1) %real.name $+ 's $lower(%status.type) status effect! }
      else { $set_chr_name($1) | set %statusmessage.display 4 $+ %real.name $+ 's $lower(%status.type) status effect has failed against $set_chr_name($3) %real.name $+ ! }
    }
  }

  ; If a monster, increase the resistance.
  if ($readini($char($2), info, flag) = monster) {
    if (%resist.skill = $null) { set %resist.skill 2 }
    else { inc %resist.skill 2 }
    writeini $char($2) skills %resist.have %resist.skill
  }
  unset %resist.have | unset %chance 

  $display_Statusdamage_item($1, $2, item, $3) 
  return
}



alias display_Statusdamage_item {
  unset %style.rating
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  ; Show the damage
  $calculate.stylepoints($1)
  if ($3 != fullbring) {
    query %battlechan 3 $+ %user $+  $readini(items.db, $4, desc)
  }
  query %battlechan The attack did4 %attack.damage damage %style.rating
  ; Did the person die?  If so, show the death message.
  if ($readini($char($2), battle, HP) <= 0) { 
    writeini $char($2) battle status dead 
    writeini $char($2) battle hp 0
    $check.clone.death($2)
    query %battlechan 4 $+ %enemy has been defeated by %user $+ !  
    if ($readini($char($1), info, flag) != monster) {
      if (%battle.type = monster) {  $add.stylepoints($1, $2, mon_death, $3) | $add.style.orbbonus($1, monster) }
      if (%battle.type = boss) { $add.stylepoints($1, $2, boss_death, $3) | $add.style.orbbonus($1, boss) }
    }
  }

  ; If the person isn't dead, display the status message.
  if ($readini($char($2), battle, hp) >= 1) {  query %battlechan %statusmessage.display }

  unset %statusmessage.display

  return 
}

alias item.tp {
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  ; calculate amount
  var %tp.amount $readini(items.db, $3, amount)

  ; add TP to the target
  var %tp.current $readini($char($2), battle, tp) 
  inc %tp.current %tp.amount 

  if (%tp.current >= $readini($char($2), basestats, tp)) { writeini $char($2) battle tp $readini($char($2), basestats, tp) }
  else { writeini $char($2) battle tp %tp.current }

  query %battlechan 3 $+ %enemy has regained %tp.amount TP!
  return 
}

alias item.heal {
  ; $1 = user
  ; $2 = target
  ; $3 = item
  if ($readini($char($2), battle, hp) >= $readini($char($2), battlestats, hp)) { $set_chr_name($2) | query %battlechan 4 $+ %real.name does not need any healing right now! | hatl }

  $calculate_heal_items($1, $3, $2)

  ;If the target is a zombie, do damage instead of healing it.
  if ($readini($char($2), status, zombie) = yes) { 
    $deal_damage($1, $2, $3)
    $display_damage($1, $2, item, $3)
  } 

  else {   
    $heal_damage($1, $2, $3)
    $display_heal($1, $2, item, $3)
  }

  return
}


alias calculate_damage_items {
  ; $1 = user
  ; $2 = item used
  ; $3 = target
  ; $4  = item or fullbring

  set %attack.damage 0

  ; First things first, let's find out the base power.
  var %base.stat $readini($char($1), battle, int)

  if ($4 = fullbring) { set %item.base $readini(items.db, $2, FullbringAmount) }
  if (($4 = item) || ($4 = $null)) { set %item.base $readini(items.db, $2, Amount) }

  ; If we have a skill that enhances items, check it here
  ; TBA

  ; If the target is weak to the element, double the attack power of the base item
  ; If the target is strong to the element, cut the attack of the item by half.
  var %item.element $readini(items.db, $2, element)
  if ((%weapon.element != $null) && (%tech.element != none)) {
    var %target.element.weak $readini($char($3), element, weakness)
    var %target.element.strong $readini($char($3), element, strong)

    if (%target.element.weak = %item.element) { inc %item.base %item.base 
      var %def.of.monster $readini($char($3), battle, def) | dec %def.of.monster 1 | writeini $char($3) battle def %def.of.monster
    }
    if (%target.element.strong = %item.element) { %item.base = $round($calc(%item.base / 2), 0) 
      var %str.of.monster $readini($char($3), battle, str) | inc %str.of.monster 1 | writeini $char($3) battle str %str.of.monster
    }
  }

  inc %base.stat %item.base
  inc %attack.damage %base.stat

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  ; Now we're ready to calculate the enemy's defense..  
  var %enemy.defense $readini($char($3), battle, def)

  ; Because it's an item, the enemy's int will play a small part too.
  var %int.bonus $round($calc($readini($char($3), battle, int) / 2),0)
  inc  %enemy.defense %int.bonus

  ; And let's get the final attack damage..
  dec %attack.damage %enemy.defense

  ; In this bot we don't want the attack to ever be lower than 1 except for shadows
  if (%attack.damage <= 0) { set %attack.damage 1 }

  if ($readini($char($3), skills, utsusemi.on) = on) {
    var %number.of.shadows $readini($char($3), skills, utsusemi.shadows)
    dec %number.of.shadows 1 
    writeini $char($3) skills utsusemi.shadows %number.of.shadows
    if (%number.of.shadows <= 0) { writeini $char($3) skills utsusemi.on off }
    $set_chr_name($3) | query %battlechan 7One of %real.name $+ 's shadows absorbs the attack and disappears! | set %attack.damage 0 | return 
  }
}

alias calculate_heal_items {
  ; $1 = user
  ; $2 = item
  ; $3 = target

  set %attack.damage 0

  ; First things first, let's find out the base power.
  var %item.base $readini(items.db, $2, Amount)

  ; If we have a skill that enhances healing items, check it here
  var %field.medic.skill $readini($char($1), skills, FieldMedic) 

  if (%field.medic.skill != $null) {
    var %skill.increase.amount $calc(5 * %field.medic.skill)
    inc %attack.damage %skill.increase.amount
  }

  inc %attack.damage %item.base

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  ; If the blood moon is in effect, healing items won't work as well.
  if (%bloodmoon = on) { %attack.damage = $round($calc(%attack.damage / 2),0) }

  ; This should never go below 0, but just in case..
  if (%attack.damage <= 0) { set %attack.damage 1 }
}

alias item.shopreset {
  ; $1 = user
  ; $2 = target
  ; $3 = item

  var %shop.reset.amount $readini(items.db, $3, amount)
  var %player.shop.level $readini($char($2), stuff, shoplevel)

  if (%shop.reset.amount != $null) {
    dec %player.shop.level %shop.reset.amount
    if (%player.shop.level <= 0) { writeini $char($2) stuff shoplevel 1.0 }
    if (%player.shop.level > 0) { writeini $char($2) stuff shoplevel %player.shop.level }
  }

  if (%user = %enemy ) { set %enemy $gender2($1) $+ self }
  $set_chr_name($1) | query %battlechan 3 $+ %real.name $+  $readini(items.db, $3, desc)
  query $2 2Your shop level has been lowered.  It is now $readini($char($2), stuff, shoplevel) $+ !
  unset %enemy
  return
}

alias item.food {
  ; $1 = user
  ; $2 = target
  ; $3 = item

  set %food.type $readini(items.db, $3, target)
  set %food.bonus $readini(items.db, $3, amount)

  if (%food.type != style) {

    ; Increase the base stat..
    set %target.stat $readini($char($2), basestats, %food.type)

    if (%food.type = hp) {
      var %player.current.hp $readini($char($2), basestats, hp)
      if (%player.current.hp >= 2500) { .msg $1 4Error: $2 has the maximum amount of HP allowed! | halt }
    }

    if (%food.type = tp) {
      var %player.current.tp $readini($char($2), basestats, tp)
      if (%player.current.tp >= 500) { .msg $1 4Error: $2 has the maximum amount of TP allowed! | halt }
    }

    inc %target.stat %food.bonus
    writeini $char($2) basestats %food.type %target.stat

    ; Now we do this in case it's used in battle and the target is boosted.
    set %target.stat $readini($char($2), battle, %food.type)
    inc %target.stat %food.bonus
    writeini $char($2) battle %food.type %target.stat 
  }

  if (%food.type = style) { 
    $add.playerstyle.xp($2, %food.bonus)
  }

  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  if (%user = %enemy ) { set %enemy $gender2($1) $+ self }
  $set_chr_name($1) | query %battlechan 3 $+ %real.name $+  $readini(items.db, $3, desc)


  query $2 2Your %food.type has permanantly increased by %food.bonus $+ !
  unset %food.bonus | unset %target.stat | unset %food.type
  return
}
