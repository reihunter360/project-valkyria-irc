;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ITEMS COMMAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!use*:*: {  unset %real.name | unset %enemy
  if ($is_charmed($nick) = true) { query %battlechan query %battlechan $readini(translation.dat, status, CurrentlyCharmed)  | halt }
  if ((no-item isin %battleconditions) || (no-items isin %battleconditions)) { query %battlechan $readini(translation.dat, battle, NotAllowedBattleCondition)   | halt }

  var %item.type $readini(items.db, $2, type)
  if ((%item.type != summon) && (%item.type != key)) {
    if (($3 != on) || ($3 = $null)) { .msg $nick $readini(translation.dat, errors, ItemUseCommandError) | halt }
    if ($4 = me) { .msg $nick $readini(translation.dat, errors, MustSpecifyName) | halt }
    if ($readini($char($4), battle, status) = dead) { query %battlechan $readini(translation.dat, errors, CannotUseItemOnDead) | halt }
    $checkchar($4) 
    if (%battleis = on) { $person_in_battle($4) }
  }

  set %check.item $readini($char($nick), Item_Amount, $2) 
  if ((%check.item <= 0) || (%check.item = $null)) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, errors, DoesNotHaveThatItem) | halt }

  var %user.flag $readini($char($nick), info, flag) | var %target.flag $readini($char($4), info, flag)
  if (%item.type = food) { 
    if (%battleis = on) { $check_for_battle($nick)   }

    if (%target.flag = monster) { query %battlechan $readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers)  | halt }
    $item.food($nick, $4, $2) | $decrease_item($nick, $2) 
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
    halt
  }
  if (%item.type = key) { $item.key($nick, $4, $2) |  $decrease_item($nick, $2)  | halt }
  if (%item.type = consume) { query %battlechan $readini(translation.dat, errors, ItemIsUsedInSkill) | halt }
  if (%item.type = accessory) { query %battlechan $readini(translation.dat, errors, ItemIsAccessoryEquipItInstead)  | halt }

  if (%item.type = shopreset) {
    if (%battleis = on) { $check_for_battle($nick)   }

    if (%target.flag = monster) { query %battlechan $readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers) | halt }
    $item.shopreset($nick, $4, $2) | $decrease_item($nick, $2) 
    halt  
  }

  $check_for_battle($nick) 
  if (%battleis = off) { query %battlechan $readini(translation.dat, errors, NoBattleCurrently) | halt }

  if (%mode.pvp = on) { var %target.flag monster | var %user.flag monster }

  if (%item.type = damage) {
    if (%target.flag != monster) { query %battlechan $readini(translation.dat, errors, ItemCanOnlyBeUsedOnMonsters) | halt }
    $item.damage($nick, $4, $2)
  }

  if (%item.type = heal) {
    $checkchar($4)
    if ((%target.flag = monster) && ($readini($char($4), monster, type) != zombie)) { query %battlechan $readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers) | halt }
    $item.heal($nick, $4, $2)
  }
  if (%item.type = CureStatus) {
    if ((%target.flag = monster) && ($readini($char($4), monster, type) != zombie)) { query %battlechan $readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers)  | halt }
    $set_chr_name($4) | var %enemy %real.name
    $item.curestatus($nick, $4, $2)
    $decrease_item($nick, $2)
    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($nick) | halt }
  }

  if (%item.type = tp) { 
    if (%target.flag = monster) { query %battlechan $readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers) | halt }
    ; Show the desc
    $set_chr_name($4) | var %enemy %real.name | $set_chr_name($nick) 
    query %battlechan 3 $+ %real.name  $+ $readini(items.db, $2, desc)
    $item.tp($nick, $4, $2)
    $decrease_item($nick, $2) 
    if (%battleis = on)  { $check_for_double_turn($nick) | halt }
  }

  if (%item.type = status) {
    if (%target.flag != monster) { query %battlechan $readini(translation.dat, errors, ItemCanOnlyBeUsedOnMonsters) | halt }
    $item.status($nick, $4, $2)
  }

  if (%item.type = revive) {  
    $check_for_battle($nick)
    if (%target.flag = monster) { query %battlechan $readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers) | halt }
    if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, CanNotAttackWhileUnconcious)  | unset %real.name | halt }
    if ($readini($char($4), Battle, Status) = dead) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, CanNotAttackSomeoneWhoIsDead) | unset %real.name | halt }

    $set_chr_name($4) | var %enemy %real.name | $set_chr_name($nick) 
    query %battlechan 3 $+ %real.name  $+ $readini(items.db, $2, desc)
    $item.revive($nick, $4, $2) 

    $decrease_item($nick, $2) 
    if (%battleis = on)  { $check_for_double_turn($nick) | halt }
  }

  if (%item.type = summon) { $item.summon($nick, $2) }
  $decrease_item($nick, $2)
  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($nick) | halt }
}


alias decrease_item {
  ; Subtract the item and tell the new total
  set %check.item $readini($char($1), item_amount, $2)
  dec %check.item 1 
  writeini $char($1) item_amount $2 %check.item
  unset %check.item
}

alias item.summon {
  ; $1 = user
  ; $2 = item used

  ; Check to make sure the monster isn't already summoned and the user has the skill needed.
  if ($skillhave.check($1, BloodPact) = false) { $set_chr_name($1) | query %battlechan $readini(translation.dat, errors, DoNotHaveSkillNeeded) | halt }
  if ($isfile($char($nick $+ _summon)) = $true) { $set_chr_name($1) | query %battlechan $readini(translation.dat, skill, AlreadyUsedBloodPact)  | halt }

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

  set %bloodpact.level $readini($char($1), skills, BloodPact)
  if (%bloodpact.level > 1) { $boost_summon_stats($1, %bloodpact.level)  }
  unset %bloodpact.level

  unset %summon.name
}

alias item.key {
  ; $1 = user
  ; $2 = target
  ; $3 = item used

  var %chest.color $readini(treasurechest.txt, ChestInfo, Color)
  if (%chest.color = $null) { query %battlechan $readini(translation.dat, errors, NoChestExists) | halt }
  if ($readini(items.db, $3, Unlocks) != %chest.color) { query %battlechan $readini(translation.dat, errors, WrongChestKey) | halt }

  set %chest.item $readini(treasurechest.txt, ChestInfo, Contents)
  set %chest.amount $readini(treasurechest.txt, ChestInfo, Amount)

  if (%chest.item = blackorb) { 
    set %chest.item Black Orb
    var %current.orbs $readini($char($1), stuff, BlackOrbs)
    inc %current.orbs %chest.amount
    writeini $char($1) stuff BlackOrbs %current.orbs
  }
  if (%chest.item = RedOrbs) {
    set %chest.item $readini(system.dat, system, currency)
    var %current.orbs $readini($char($1), stuff, RedOrbs)
    inc %current.orbs %chest.amount
    writeini $char($1) stuff RedOrbs %current.orbs
  }
  if ((%chest.item != BlackOrb) && (%chest.item != RedOrbs)) {
    set %current.items $readini($char($1), item_amount, %chest.item)
    if (%current.items = $null) { set %current.items 0 }
    inc %current.items %chest.amount
    writeini $char($1) item_amount %chest.item %current.items
  }

  $set_chr_name($1)
  query %battlechan $readini(translation.dat, system, ChestOpened)
  /.timerChestDestroy off
  .remove treasurechest.txt 

  var %number.of.chests $readini($char($1), stuff, ChestsOpened)
  if (%number.of.chests = $null) { var %number.of.chests 0 }
  inc %number.of.chests 1
  writeini $char($1) stuff ChestsOpened %number.of.chests
  $achievement_check($1, MasterOfUnlocking)

  unset %chest.item | unset %current.items | unset %chest.amount
  return
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
  if (%status.type != $null) { $inflict_status($1, $2, %status.type) }

  $calculate_damage_items($1, $3, $2)
  $deal_damage($1, $2, $3)
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

  if (%guard.message = $null) { query %battlechan The attack did4 $bytes(%attack.damage,b) damage %style.rating }
  if (%guard.message != $null) { query %battlechan %guard.message | unset %guard.message }

  ; Did the person die?  If so, show the death message.
  if ($readini($char($2), battle, HP) <= 0) { 
    writeini $char($2) battle status dead 
    writeini $char($2) battle hp 0
    $check.clone.death($2)
    $increase_death_tally($2)
    $achievement_check($2, SirDiesALot)
    query %battlechan $readini(translation.dat, battle, EnemyDefeated)
    $goldorb_check($2) 
    $spawn_after_death($2)
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
  if ($readini($char($2), battle, hp) >= $readini($char($2), battlestats, hp)) { $set_chr_name($2) | query %battlechan $readini(translation.dat, errors, DoesNotNeedHealing) | halt }

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

alias item.revive {
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name
  writeini $char($2) status revive yes 
  return 
}

alias item.curestatus {
  ; $1 = user
  ; $2 = target
  ; $3 = item

  writeini $char($2) Status poison no | writeini $char($2) Status HeavyPoison no | writeini $char($2) Status blind no
  writeini $char($2) Status Heavy-Poison no | writeini $char($2) status poison-heavy no | writeini $char($2) Status curse no 
  writeini $char($2) Status weight no | writeini $char($2) status virus no | writeini $char($2) status poison.timer 0
  writeini $char($2) Status drunk no | writeini $char($2) Status amnesia no | writeini $char($2) status paralysis no | writeini $char($2) status amnesia.timer 1 | writeini $char($2) status paralysis.timer 1 | writeini $char($2) status drunk.timer 1
  writeini $char($2) status zombie no | writeini $char($2) Status slow no | writeini $char($2) Status sleep no | writeini $char($2) Status stun no
  writeini $char($2) status boosted no  | writeini $char($2) status curse.timer 1 | writeini $char($2) status slow.timer 1 | writeini $char($2) status zombie.timer 1
  writeini $char($2) status zombieregenerating no | writeini $char($2) status silence no | writeini $char($2) status petrified no

  $set_chr_name($2) | query %battlechan $readini(translation.dat, status, MostStatusesCleared)
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
  set %enemy.defense $readini($char($3), battle, def)

  ; Because it's an item, the enemy's int will play a small part too.
  var %int.bonus $round($calc($readini($char($3), battle, int) / 2),0)
  inc  %enemy.defense %int.bonus

  $guardian_style_check($3)

  $defense_down_check($3)

  ; And let's get the final attack damage..
  dec %attack.damage %enemy.defense

  unset %enemy.defense

  ; In this bot we don't want the attack to ever be lower than 1 except for shadows
  if (%attack.damage <= 0) { set %attack.damage 1 }

  if ($readini($char($3), skills, utsusemi.on) = on) {
    var %number.of.shadows $readini($char($3), skills, utsusemi.shadows)
    dec %number.of.shadows 1 
    writeini $char($3) skills utsusemi.shadows %number.of.shadows
    if (%number.of.shadows <= 0) { writeini $char($3) skills utsusemi.on off }
    $set_chr_name($3) | set %guard.message $readini(translation.dat, skill, UtsusemiBlocked) | set %attack.damage 0 | return 
  }

  if ($readini($char($3), status, ethereal) = yes) {
    $set_chr_name($1) | set %guard.message $readini(translation.dat, status, EtherealBlocked) | set %attack.damage 0 | return
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
  set %player.shop.level $readini($char($2), stuff, shoplevel)

  if (%shop.reset.amount != $null) {
    dec %player.shop.level %shop.reset.amount
    if (%player.shop.level <= 1) { writeini $char($2) stuff shoplevel 1.0 }
    if (%player.shop.level > 1) { writeini $char($2) stuff shoplevel %player.shop.level }
  }

  if (%user = %enemy ) { set %enemy $gender2($1) $+ self }
  $set_chr_name($1) | query %battlechan 3 $+ %real.name $+  $readini(items.db, $3, desc)
  query $2 $readini(translation.dat, system,ShopLevelLowered)

  var %discounts.used $readini($char($2), stuff, DiscountsUsed)
  inc %discounts.used 1 
  writeini $char($2) stuff DiscountsUsed %discounts.used

  $achievement_check($1, Cheapskate)

  unset %player.shop.level |  unset %enemy
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
      var %player.max.hp $readini(system.dat, system, maxHP)
      if (%player.current.hp >= %player.max.hp) { .msg $1 $readini(translation.dat, errors, MaxHPAllowedOthers) | halt }
    }

    if (%food.type = tp) {
      var %player.current.tp $readini($char($2), basestats, tp)
      var %player.max.tp $readini(system.dat, system, maxTP)
      if (%player.current.tp >= %player.max.tp) { .msg $1 $readini(translation.dat, errors, MaxTPAllowedOthers)  | halt }
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


  query $2 $readini(translation.dat, system,FoodStatIncrease)
  unset %food.bonus | unset %target.stat | unset %food.type
  return
}


;=========================================
; Equip an accessory via the !wear command.
;=========================================
on 2:TEXT:!wear*:*: {  $set_chr_name($nick)
  var %item.type $readini(items.db, $2, type)
  if (%item.type != accessory) { query %battlechan $readini(translation.dat, errors, ItemIsNotAccessory) | halt }
  set %check.item $readini($char($nick), Item_Amount, $2) 
  if ((%check.item <= 0) || (%check.item = $null)) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, errors, DoesNotHaveThatItem) | halt }
  if ((%battleis = on) && ($nick isin $readini(battle2.txt, Battle, List))) { query %battlechan $readini(translation.dat, errors, CanOnlySwitchAccessoriesOutsideBattle) | halt }
  writeini $char($nick) equipment accessory $2
  query %battlechan $readini(translation.dat, system, EquippedAccessory)
}
on 2:TEXT:!remove*:*: {  $set_chr_name($nick)
  var %equipped.accessory $readini($char($nick), equipment, accessory)
  if ($2 != %equipped.accessory) { query %equipped.accessory $readini(translation.dat, system, NotWearingThatAccessory)  }
  if ((%battleis = on) && ($nick isin $readini(battle2.txt, Battle, List))) { query %battlechan $readini(translation.dat, errors, CanOnlySwitchAccessoriesOutsideBattle) | halt }
  else { writeini $char($nick) equipment accessory none } 
  query %battlechan $readini(translation.dat, system, RemovedAccessory)
}
