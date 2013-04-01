;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ITEMS COMMAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 3:TEXT:!use*:*: {  unset %real.name | unset %enemy
  if ($is_charmed($nick) = true) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, status, CurrentlyCharmed), private) | halt }
  if ($is_confused($nick) = true) { $set_chr_name($nick) | $display.system.message($readini(translation.dat, status, CurrentlyConfused), private) | halt }
  if ((no-item isin %battleconditions) || (no-items isin %battleconditions)) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition), private)   | halt }
  $uses_item($nick, $2, $3, $4)
}

ON 50:TEXT:*uses item * on *:*:{ 
  if ($1 = uses) { halt }
  if ($5 != on) { halt }
  if ($is_charmed($1) = true) { query %battlechan query %battlechan $readini(translation.dat, status, CurrentlyCharmed)  | halt }
  if ($is_confused($1) = true) { $set_chr_name($nick) | query %battlechan $readini(translation.dat, status, CurrentlyConfused) | halt }
  if ((no-item isin %battleconditions) || (no-items isin %battleconditions)) { $display.system.message($readini(translation.dat, battle, NotAllowedBattleCondition), battle)  | halt }
  $uses_item($1, $4, $5, $6)
}

alias uses_item {
  var %item.type $readini(items.db, $2, type)

  if (((%item.type != summon) && (%item.type != key) && (%item.type != portal))) {
    if (($3 != on) || ($3 = $null)) {   $display.system.message($readini(translation.dat, errors, ItemUseCommandError), private) | halt }
    if ($4 = me) {  $display.system.message($1 $readini(translation.dat, errors, MustSpecifyName), private) | halt }
    if ($readini($char($4), battle, status) = dead) { $display.system.message($readini(translation.dat, errors, CannotUseItemOnDead), private) | halt }
    $checkchar($4) 
    if (%battleis = on) { $person_in_battle($4) }
  }

  set %check.item $readini($char($1), Item_Amount, $2) 
  if ((%check.item <= 0) || (%check.item = $null)) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoesNotHaveThatItem), private) | halt }

  var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($4), info, flag)
  if (%item.type = food) { 
    if (%battleis = on) { $check_for_battle($1) }
    $item.food($1, $4, $2) | $decrease_item($1, $2) 
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
    halt
  }

  if (%item.type = portal) {
    if (%battleis = on) { $check_for_battle($1)   }
    if (%battleis = off) { $display.system.message($readini(translation.dat, errors, NoBattleCurrently), private) | halt }

    if (%portal.bonus = true) { $display.system.message($readini(translation.dat, errors, AlreadyInPortal), private) | halt }

    set %monster.to.spawn $readini(items.db, $2, Monster)

    if ($numtok(%monster.to.spawn,46) = 1) {  $portal.item.onemonster }
    if ($numtok(%monster.to.spawn,46) > 1) { $portal.item.multimonsters }

    set %current.battlefield $readini(items.db, $2, Battlefield)
    writeini weather.lst weather current $readini(items.db, $2, weather)
    set %current.turn 1

    ; Show the description
    $set_chr_name($1) | $display.system.message( $+ %real.name  $+ $readini(items.db, $2, desc), battle)

    ; Set the allied notes value
    var %allied.notes $readini(items.db, $2, alliednotes) 
    writeini battle2.txt battle alliednotes %allied.notes

    ; Reduce the item
    $decrease_item($1, $2) 

    $battlelist(public)

    ; Go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }

  if (%item.type = key) { $item.key($1, $4, $2) |  $decrease_item($1, $2)  | halt }
  if (%item.type = consume) { $display.system.message($readini(translation.dat, errors, ItemIsUsedInSkill), private) | halt }
  if (%item.type = accessory) { $display.system.message($readini(translation.dat, errors, ItemIsAccessoryEquipItInstead), private) | halt }
  if (%item.type = random) { $item.random($1, $4, $2) | $decrease_item($1, $2) | halt }

  if (%item.type = shopreset) {
    if (%battleis = on) { $check_for_battle($1)   }

    if (%target.flag = monster) { $display.system.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers), private) | halt }
    $item.shopreset($1, $4, $2) | $decrease_item($1, $2) 
    halt  
  }

  $check_for_battle($1) 
  if (%battleis = off) { $display.system.message($readini(translation.dat, errors, NoBattleCurrently), private) | halt }

  if (%mode.pvp = on) { var %target.flag monster | var %user.flag monster }

  if (%item.type = damage) {
    if (%target.flag != monster) { $display.system.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnMonsters), private) | halt }
    $item.damage($1, $4, $2)
  }

  if (%item.type = snatch) {
    if (%target.flag != monster) { $display.system.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnMonsters), private) | halt }
    $item.snatch($1, $4, $2)
  }

  if (%item.type = heal) {
    $checkchar($4)
    if ((%target.flag = monster) && ($readini($char($4), monster, type) != zombie)) { $display.system.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers), private) | halt }
    $item.heal($1, $4, $2)
  }
  if (%item.type = CureStatus) {
    if ((%target.flag = monster) && ($readini($char($4), monster, type) != zombie)) { $display.system.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers), private) | halt }
    $set_chr_name($4) | var %enemy %real.name
    $item.curestatus($1, $4, $2)
    $decrease_item($1, $2)
    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }

  if (%item.type = tp) { 
    if (%target.flag = monster) { $display.system.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers), private) | halt }
    ; Show the desc
    $set_chr_name($4) | var %enemy %real.name | $set_chr_name($1) 
    $display.system.message(3 $+ %real.name  $+ $readini(items.db, $2, desc), battle)
    $item.tp($1, $4, $2)
    $decrease_item($1, $2) 
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }

  if (%item.type = ignitiongauge) { 
    if (%target.flag = monster) { $display.system.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers), private) | halt }
    ; Show the desc
    $set_chr_name($4) | var %enemy %real.name | $set_chr_name($1) 
    $display.system.message(3 $+ %real.name  $+ $readini(items.db, $2, desc), battle)
    $item.ig($1, $4, $2)
    $decrease_item($1, $2) 
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }

  if (%item.type = status) {
    if (%target.flag != monster) { $display.system.message($readini(translation.dat, errors, ItemCanOnlyBeUsedOnMonsters), private) | halt }
    $item.status($1, $4, $2)
  }

  if (%item.type = revive) {  
    $check_for_battle($1)
    if (%target.flag = monster) { query %battlechan $readini(translation.dat, errors, ItemCanOnlyBeUsedOnPlayers) | halt }
    if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, CanNotAttackWhileUnconcious), private)  | unset %real.name | halt }
    if ($readini($char($4), Battle, Status) = dead) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, CanNotAttackSomeoneWhoIsDead), private) | unset %real.name | halt }

    $set_chr_name($4) | var %enemy %real.name | $set_chr_name($1) 
    $display.system.message(3 $+ %real.name  $+ $readini(items.db, $2, desc), battle)
    $item.revive($1, $4, $2) 

    $decrease_item($1, $2) 
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }

  if (%item.type = summon) { $item.summon($1, $2) }
  $decrease_item($1, $2)
  ; Time to go to the next turn
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
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
  if ($skillhave.check($1, BloodPact) = false) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoNotHaveSkillNeeded), private) | halt }
  if ($isfile($char($nick $+ _summon)) = $true) { $set_chr_name($1) | $display.system.message($readini(translation.dat, skill, AlreadyUsedBloodPact), private)  | halt }

  ; Get the summon via the item.
  set %summon.name $readini(items.db, $2, summon)

  $skill.bloodpact($1, %summon.name, $2)

  unset %summon.name
}

alias item.key {
  ; $1 = user
  ; $2 = target
  ; $3 = item used

  var %chest.color $readini(treasurechest.txt, ChestInfo, Color)
  if (%chest.color = $null) { $display.system.message($readini(translation.dat, errors, NoChestExists), private) | halt }
  if ($readini(items.db, $3, Unlocks) != %chest.color) { $display.system.message($readini(translation.dat, errors, WrongChestKey), private) | halt }

  set %chest.item $readini(treasurechest.txt, ChestInfo, Contents)
  set %chest.amount $readini(treasurechest.txt, ChestInfo, Amount)

  if (%chest.item = BlackOrb) { 
    set %chest.item Black Orb
    var %current.orbs $readini($char($1), stuff, BlackOrbs)
    inc %current.orbs %chest.amount
    writeini $char($1) stuff BlackOrbs %current.orbs
    remini $char($1) item_amount Black
  }
  else if (%chest.item = RedOrbs) {
    set %chest.item $readini(system.dat, system, currency)
    var %current.orbs $readini($char($1), stuff, RedOrbs)
    inc %current.orbs %chest.amount
    writeini $char($1) stuff RedOrbs %current.orbs
    remini $char($1) item_amount Red
  }

  else {
    set %current.items $readini($char($1), item_amount, %chest.item)
    if (%current.items = $null) { set %current.items 0 }
    inc %current.items %chest.amount
    writeini $char($1) item_amount %chest.item %current.items
  }

  $set_chr_name($1)
  $display.system.message($readini(translation.dat, system, ChestOpened), global)
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

alias item.random {
  ; $1 = user
  ; $2 = target
  ; $3 = item used

  var %food.items $readini(items.db, items, FoodItems)
  var %accessories $readini(items.db, items, accessories)
  var %gems $readini(items.db, items, gems)
  var %shop.reset $readini(items.db, items, ShopReset)
  var %total.items blackorb. $+ %food.items $+ . $+ %accessories $+ . $+ %gems . $+ %shop.reset
  set %random $rand(1, $numtok(%total.items,46))
  if (%random = $null) { var %random 1 }
  set %random.item.contents $gettok(%total.items,%random,46)


  if (%random.item.contents = blackorb) { 
    set %random.item.name Black Orb
    var %current.orbs $readini($char($2), stuff, BlackOrbs)
    inc %current.orbs %chest.amount
    writeini $char($2) stuff BlackOrbs %current.orbs
  }

  if (%random.item.contents != blackorb) { 
    set %random.item.name %random.item.contents
    set %current.reward.items $readini($char($1), item_amount, %chest.item)
    if (%current.reward.items = $null) { set %current.reward.items 0 }
    inc %current.reward.items %chest.amount
    writeini $char($1) item_amount %random.item.contents %current.reward.items
    unset %current.reward.items
  }

  ; Display the desc of the item
  $set_chr_name($2) | var %enemy %real.name | $set_chr_name($1) 
  $display.system.message(3 $+ %real.name  $+ $readini(items.db, $3, desc), global) 

  unset %random.item.name 
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


alias item.snatch {
  ; $1 = user
  ; $2 = target
  ; $3 = item used

  if (%battleis = off) { $display.system.message(4There is no battle currently!, private) | halt }
  $check_for_battle($1) | $person_in_battle($2) 

  var %cover.status $readini($char($2), battle, status)
  if ((%cover.status = dead) || (%cover.status = runaway)) { $display.system.message($readini(translation.dat, skill, SnatchTargetDead), private) | halt }

  var %user.flag $readini($char($1), info, flag) 
  if (%user.flag = $null) { var %user.flag player }
  var %target.flag $readini($char($2), info, flag)

  if (%user.flag = player) && (%target.flag != monster) { 
    if (%mode.pvp != on) { $display.system.message($readini(translation.dat, errors, CannotSnatchPlayers), private) | halt }
  }

  if ($isfile($boss($2)) = $true) { $display.system.message($readini(translation.dat, errors, CannotSnatchBosses), private) | halt }

  $set_chr_name($2) | var %enemy %real.name

  ; Display the item's description
  $set_chr_name($1) | $display.system.message(10 $+ %real.name  $+ $readini(items.db, $3, desc), battle)

  ; Try to grab the target
  $do.snatch($1 , $2) 

  return
}

alias item.status {
  ; $1 = user
  ; $2 = target
  ; $3 = item used

  unset %statusmessage.display
  set %status.type.list $readini(items.db, $3, StatusType) 

  if (%status.type.list != $null) { 
    set %number.of.statuseffects $numtok(%status.type.list, 46) 

    if (%number.of.statuseffects = 1) { $inflict_status($1, $2, %status.type.list) | unset %number.of.statuseffects | unset %status.type.list }
    if (%number.of.statuseffects > 1) {
      var %status.value 1
      while (%status.value <= %number.of.statuseffects) { 
        set %current.status.effect $gettok(%status.type.list, %status.value, 46)
        $inflict_status($1, $2, %current.status.effect)
        inc %status.value 1
      }  
      unset %number.of.statuseffects | unset %current.status.effect
    }
  }
  unset %status.type.list

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
    $display.system.message(3 $+ %user $+  $readini(items.db, $4, desc), battle)
  }

  if (%guard.message = $null) { $display.system.message(The attack did4 $bytes(%attack.damage,b) damage %style.rating, battle) }
  if (%guard.message != $null) { $display.system.message(%guard.message, battle) | unset %guard.message }

  ; Did the person die?  If so, show the death message.
  if ($readini($char($2), battle, HP) <= 0) { 
    writeini $char($2) battle status dead 
    writeini $char($2) battle hp 0
    $check.clone.death($2)
    $increase_death_tally($2)
    $achievement_check($2, SirDiesALot)
    $display.system.message($readini(translation.dat, battle, EnemyDefeated), battle)
    $increase.death.tally($2) 
    $goldorb_check($2) 
    $spawn_after_death($2)
    if ($readini($char($1), info, flag) != monster) {
      if (%battle.type = monster) {  $add.stylepoints($1, $2, mon_death, $3) | $add.style.orbbonus($1, monster) }
      if (%battle.type = boss) { $add.stylepoints($1, $2, boss_death, $3) | $add.style.orbbonus($1, boss) }
    }
  }

  ; If the person isn't dead, display the status message.
  if ($readini($char($2), battle, hp) >= 1) {  $display.system.message(%statusmessage.display, battle) }

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

  $display.system.message(3 $+ %enemy has regained %tp.amount TP!, battle)
  return 
}

alias item.ig {
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  ; calculate amount
  var %ig.amount $readini(items.db, $3, amount)

  ; add IG to the target
  var %ig.current $readini($char($2), battle, IgnitionGauge) 
  inc %ig.current %ig.amount 

  if (%ig.current >= $readini($char($2), basestats, IgnitionGauge)) { writeini $char($2) battle IgnitionGauge $readini($char($2), basestats, IgnitionGauge) }
  else { writeini $char($2) battle IgnitionGauge %ig.current }

  $display.system.message(3 $+ %enemy has regained %ig.amount Ignition Gauge!, battle)
  return 
}

alias item.heal {
  ; $1 = user
  ; $2 = target
  ; $3 = item

  var %item.current.hp $readini($char($2), battle, HP) |   var %item.max.hp $readini($char($2), basestats, HP)
  if (%item.current.hp >= %item.max.hp) { $set_chr_name($2) | $display.system.message($readini(translation.dat, errors, DoesNotNeedHealing), private) | halt }

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

  $clear_most_status($2)

  $set_chr_name($2) | $display.system.message($readini(translation.dat, status, MostStatusesCleared), battle)
  return
}


alias calculate_damage_items {
  ; $1 = user
  ; $2 = item used
  ; $3 = target
  ; $4  = item or fullbring

  set %attack.damage 0

  ; First things first, let's find out the base power.

  if ($4 = fullbring) { set %item.base $readini(items.db, $2, FullbringAmount) }
  if (($4 = item) || ($4 = $null)) { set %item.base $readini(items.db, $2, Amount) }

  inc %attack.damage %item.base

  ; Now we want to increase the base damage by a small fraction of the user's int.
  if ($readini(system.dat, system, BattleDamageFormula) = 1) {   var %base.stat $round($calc($readini($char($1), battle, int) / 20),0) }
  if ($readini(system.dat, system, BattleDamageFormula) = 2) {  
    var %base.stat $readini($char($1), battle, int)
    if (%base.stat >= 999) { var %base.stat $round($calc(999 + (%base.stat / 500)),0) }
    else {  var %base.stat $round($calc($readini($char($1), battle, int) / 20),0) }
  }

  inc %attack.damage %base.stat

  var %current.element $readini(items.db, $2, element)
  if ((%current.element != $null) && (%current.element != none)) {
    $modifer_adjust($3, %current.element)
  }

  ; Let's increase the attack by a random amount.
  inc %attack.damage $rand(1,10)

  ; Check for an EnhanceItems augment that will increase the damage by 30% per augment equipped.
  if ($augment.check($1, EnhanceItems) = true) {  inc %attack.damage $round($calc(%attack.damage *  (%augment.strength *.30)),0) }

  ; Now we're ready to calculate the enemy's defense..  
  set %enemy.defense $readini($char($3), battle, def)
  $defense_down_check($3)


  if (%enemy.defense <= 0) { set %enemy.defense 1 }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL DAMAGE.
  ;;; FORMULA 1
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if ($readini(system.dat, system, BattleDamageFormula) = 1) { 

    ; Because it's an item, the enemy's int will play a small part too.
    var %int.bonus $round($calc($readini($char($3), battle, int) / 2),0)
    inc %enemy.defense %int.bonus

    ; Set the level ratio
    if ($readini($char($1), info, flag) = $null) { 
      set %level.ratio $calc($readini($char($1), battle, %base.stat) / %enemy.defense)
    }

    if (%level.ratio > 2.5) { set %level.ratio 2 }

    ; And let's get the final attack damage..
    %attack.damage = $round($calc(%attack.damage * %level.ratio),0)
    if ((%attack.damage > 30000) && ($readini($char($1), info, flag) = $null)) { 
      set %temp.damage $calc(%attack.damage / 100) 
      set %attack.damage $calc(30000 + %temp.damage)
      unset %temp.damage
      if (%attack.damage >= 50000) { set %attack.damage $rand(45000,46000) }
    }
    if ((%attack.damage > 2500) && ($readini($char($1), info, flag) = monster)) { set %attack.damage 2000 }
  }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CALCULATE TOTAL DAMAGE.
  ;;; FORMULA 2
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if ($readini(system.dat, system, BattleDamageFormula) = 2) { 
    var %minimum.damage %item.base 
    var %ratio $calc(%attack.damage / %enemy.defense)

    if (%ratio >= 1.3) { set %ratio 1.3 | set %minimum.damage $round($calc(%item.base * 1.5),0) } 

    var %maximum.damage $round($calc(%attack.damage * %ratio),0)
    if (%maximum.damage >= $calc(%minimum.damage * 18)) { set %maximum.damage $calc(%minimum.damage * 18),0) }
    if (%maximum.damage <= %minimum.damage) { set %maximum.damage %minimum.damage }

    set %attack.damage $rand(%minimum.damage, %maximum.damage) 
  }
  inc %attack.damage $rand(1,10)

  unset %enemy.defense

  $guardian_style_check($3)
  $metal_defense_check($3, $1)

  ; In this bot we don't want the attack to ever be lower than 1
  if (%attack.damage <= 0) { set %attack.damage 1 }

  if (%current.element != $null) {
    var %target.element.null $readini($char($3), element, null)
    if ($istok(%target.element.null,%current.element,46) = $true) { $set_chr_name($3)
      set %guard.message $readini(translation.dat, battle, ImmuneToElement) 
      set %attack.damage 0 
    }
  }


  $trickster_dodge_check($3, $1)
  $utsusemi.check($1, $2, $3)
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

  if ($augment.check($1, EnhanceItems) = true) { 
    inc %attack.damage $round($calc(%attack.damage * .3),0)
  }

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
  $set_chr_name($1) | $display.system.message(3 $+ %real.name $+  $readini(items.db, $3, desc), battle)
  $display.private.message($readini(translation.dat, system,ShopLevelLowered)

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

    if (($readini($char($2), info, flag) != $null) && ($readini($char($2), status, ignition.on) = on)) {  set %target.stat $readini($char($2), battle, %food.type)  }
    else { set %target.stat $readini($char($2), basestats, %food.type) }


    if (%food.type = hp) {
      var %player.current.hp $readini($char($2), basestats, hp)
      var %player.max.hp $readini(system.dat, system, maxHP)
      if (%player.current.hp >= %player.max.hp) { $display.system.message($readini(translation.dat, errors, MaxHPAllowedOthers), private) | halt }
    }

    if (%food.type = tp) {
      var %player.current.tp $readini($char($2), basestats, tp)
      var %player.max.tp $readini(system.dat, system, maxTP)
      if (%player.current.tp >= %player.max.tp) { $display.system.message($readini(translation.dat, errors, MaxTPAllowedOthers), private)  | halt }
    }

    inc %target.stat %food.bonus

    if (%target.stat < 5) { var %target.stat 5 }

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
  $set_chr_name($1) 
  if (%battleis = on) { $display.system.message(3 $+ %real.name $+  $readini(items.db, $3, desc), battle) }
  if (%battleis = off) { $display.system.message(3 $+ %real.name $+  $readini(items.db, $3, desc), global) }

  if ($readini($char($2), info, flag) = $null) { 
    if ($readini(system.dat, system, botType) = IRC) {  query $2 $readini(translation.dat, system,FoodStatIncrease) }
    if ($readini(system.dat, system, botType) = DCCchat) { $dcc.private.message($2, $readini(translation.dat, system,FoodStatIncrease) }
  }
  unset %food.bonus | unset %target.stat | unset %food.type
  return
}


;=========================================
; Equip an accessory via the !wear command.
;=========================================
on 3:TEXT:!wear*:*: {  
  if ($3 = $null) { $display.private.message(4Error: !wear <accessory/armor> <what to wear>, private) | halt }
  if ($2 = accessory) { $wear.accessory($nick, $3) }
  if ($2 = armor) { $wear.armor($nick, $3) }
}
on 3:TEXT:!remove*:*: {  
  if ($3 = $null) { $display.private.message(4Error: !remove <accessory/armor> <what to remove>, private) | halt }
  if ($2 = accessory) { $remove.accessory($nick, $3) }
  if ($2 = armor) { $remove.armor($nick, $3) }
}

alias wear.accessory {
  $set_chr_name($1)
  var %item.type $readini(items.db, $2, type)
  if (%item.type != accessory) { $display.system.message($readini(translation.dat, errors, ItemIsNotAccessory), private) | halt }
  set %check.item $readini($char($1), Item_Amount, $2) 
  if ((%check.item <= 0) || (%check.item = $null)) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoesNotHaveThatItem), private) | halt }
  if ((%battleis = on) && ($nick isin $readini(battle2.txt, Battle, List))) { $display.system.message($readini(translation.dat, errors, CanOnlySwitchAccessoriesOutsideBattle), private) | halt }
  writeini $char($1) equipment accessory $2
  $display.system.message($readini(translation.dat, system, EquippedAccessory), global)
}
alias remove.accessory {
  $set_chr_name($1)
  var %equipped.accessory $readini($char($1), equipment, accessory)
  if ($2 != %equipped.accessory) { $display.system.message($readini(translation.dat, system, NotWearingThatAccessory), private)  | halt }
  if ((%battleis = on) && ($nick isin $readini(battle2.txt, Battle, List))) { $display.system.message($readini(translation.dat, errors, CanOnlySwitchAccessoriesOutsideBattle), private) | halt }
  else { writeini $char($1) equipment accessory none } 
  $display.system.message($readini(translation.dat, system, RemovedAccessory), global)
}

alias wear.armor {
  $set_chr_name($1)
  var %item.location $readini(equipment.db, $2, EquipLocation)
  if (%item.location = $null) { $display.system.message($readini(translation.dat, errors, ItemIsNotArmor), private) | halt }
  if ((%battleis = on) && ($nick isin $readini(battle2.txt, Battle, List))) { $display.system.message($readini(translation.dat, errors, CanOnlySwitchArmorOutsideBattle), private) | halt }

  set %current.armor $readini($char($1), equipment, %item.location) 
  if ((%current.armor = $null) || (%current.armor = nothing)) {

    set %check.item $readini($char($1), Item_Amount, $2) 
    if ((%check.item <= 0) || (%check.item = $null)) { $set_chr_name($1) | $display.system.message($readini(translation.dat, errors, DoesNotHaveThatItem), private) | halt }

    ; Increase the stats
    var %hp $round($calc($readini($char($1), Basestats, hp) + $readini(equipment.db, $2, hp)),0)
    var %tp $round($calc($readini($char($1), Basestats, tp) + $readini(equipment.db, $2, tp)),0)
    var %str $round($calc($readini($char($1), Basestats, Str)  + $readini(equipment.db, $2, str)),0)
    var %def $round($calc($readini($char($1), Basestats, def)  + $readini(equipment.db, $2, def)),0)
    var %int $round($calc($readini($char($1), Basestats, int) + $readini(equipment.db, $2, int)),0)
    var %spd $round($calc($readini($char($1), Basestats, spd)  + $readini(equipment.db, $2, spd)),0)

    writeini $char($1) Basestats Hp %hp
    writeini $char($1) Basestats Tp %tp
    writeini $char($1) Basestats Str %str
    writeini $char($1) Basestats Def %def
    writeini $char($1) Basestats Int %int
    writeini $char($1) Basestats Spd %spd

    $fulls($1)

    ; Equip the armor and tell the world
    writeini $char($1) equipment %item.location $2
    $display.system.message($readini(translation.dat, system, EquippedArmor), global)

    unset %current.armor
  }
  else {  unset %current.armor 

    if ($readini(system.dat, system, botType) = IRC) {  .msg $1 $readini(translation.dat, errors, AlreadyWearingArmorThere) }
    if ($readini(system.dat, system, botType) = DCCchat) {  $display.system.message($readini(translation.dat, errors, AlreadyWearingArmorThere), private) }
    halt 
  }
}

alias remove.armor {
  $set_chr_name($1)
  set %item.location $readini(equipment.db, $2, EquipLocation)
  set %worn.item $readini($char($1), equipment, %item.location)
  if (%worn.item != $2) {  unset %item.location | unset %worn.item | $display.system.message($readini(translation.dat, system, NotWearingThatArmor), private)  }
  if ((%battleis = on) && ($nick isin $readini(battle2.txt, Battle, List))) { $display.system.message($readini(translation.dat, errors, CanOnlySwitchArmorOutsideBattle), private) | halt }

  ; Decrease the stats
  var %hp $round($calc($readini($char($1), Basestats, hp) - $readini(equipment.db, $2, hp)),0)
  var %tp $round($calc($readini($char($1), Basestats, tp) - $readini(equipment.db, $2, tp)),0)
  var %str $round($calc($readini($char($1), Basestats, Str)  - $readini(equipment.db, $2, str)),0)
  var %def $round($calc($readini($char($1), Basestats, def)  - $readini(equipment.db, $2, def)),0)
  var %int $round($calc($readini($char($1), Basestats, int) - $readini(equipment.db, $2, int)),0)
  var %spd $round($calc($readini($char($1), Basestats, spd) - $readini(equipment.db, $2, spd)),0)

  writeini $char($1) Basestats Hp %hp
  writeini $char($1) Basestats Tp %tp
  writeini $char($1) Basestats Str %str
  writeini $char($1) Basestats Def %def
  writeini $char($1) Basestats Int %int
  writeini $char($1) Basestats Spd %spd

  $fulls($1)

  ; Clear the armor and tell the world
  writeini $char($1) equipment %item.location nothing

  $display.system.message($readini(translation.dat, system, RemovedArmor), global)

  unset %item.location | unset %worn.item
}

alias portal.item.onemonster {

  var %isboss $isfile($boss(%monster.to.spawn))
  var %ismonster $isfile($mon(%monster.to.spawn))

  if ((%isboss != $true) && (%ismonster != $true)) { 
  $display.system.message($readini(translation.dat, errors, PortalItemNotWorking) , private) | halt  }  

  ; Clear the battlefield.
  set %battle.type boss | set %portal.bonus true
  $multiple_wave_clearmonsters

  ; Now summon the special boss

  if ($isfile($boss(%monster.to.spawn)) = $true) {  .copy -o $boss(%monster.to.spawn) $char(%monster.to.spawn)  }
  if ($isfile($mon(%monster.to.spawn)) = $true) {  .copy -o $mon(%monster.to.spawn) $char(%monster.to.spawn)  }

  ; increase the total # of monsters
  set %battlelist.toadd $readini(battle2.txt, Battle, List) | %battlelist.toadd = $addtok(%battlelist.toadd,%monster.to.spawn,46) | writeini battle2.txt Battle List %battlelist.toadd | unset %battlelist.toadd
  write battle.txt %monster.to.spawn
  var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters

  ; display the description of the spawned monster
  $set_chr_name(%monster.to.spawn) 
  $display.system.message($readini(translation.dat, battle, EnteredTheBattle), battle)
  $display.system.message(12 $+ %real.name  $+ $readini($char(%monster.to.spawn), descriptions, char), battle)
  var %bossquote $readini($char(%monster.to.spawn), descriptions, bossquote)
  if (%bossquote != $null) {   $display.system.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%monster.to.spawn), descriptions, BossQuote) $+ ", battle) }

  ; Boost the monster
  $boost_monster_stats(%monster.to.spawn,portal) 
  $fulls(%monster.to.spawn)

  set %multiple.wave.bonus yes
  set %first.round.protection yes

  ; Get the boss item.
  var %boss.item $readini($char(%monster.to.spawn), stuff, drops)
  if (%boss.item != $null) { 
    var %boss.item $readini($char(%monster.to.spawn), stuff, drops)
    if (%boss.item != $null) { writeini battle2.txt battle bonusitem %boss.item | unset %boss.item }
  }

  unset %monster.to.spawn
  /.timerBattleRage 1 1200 /battle_rage_warning

  return
}

alias portal.item.multimonsters {
  var %value 1 | set %number.of.monsters $numtok(%monster.to.spawn,46)
  while (%value <= %number.of.monsters) {
    set %current.monster.to.spawn $gettok(%monster.to.spawn,%value,46)

    var %isboss $isfile($boss(%current.monster.to.spawn))
    var %ismonster $isfile($mon(%current.monster.to.spawn))

    if ((%isboss != $true) && (%ismonster != $true)) { inc %value }
    else { 
      set %found.monster true 
      if (%cleared.battlefield != true) {  set %battle.type boss | set %portal.bonus true |  set %cleared.battlefield true | $multiple_wave_clearmonsters }

      if ($isfile($boss(%current.monster.to.spawn)) = $true) { .copy -o $boss(%current.monster.to.spawn) $char(%current.monster.to.spawn)  }
      if ($isfile($mon(%current.monster.to.spawn)) = $true) {  .copy -o $mon(%current.monster.to.spawn) $char(%current.monster.to.spawn)  }

      ; increase the total # of monsters
      set %battlelist.toadd $readini(battle2.txt, Battle, List) | %battlelist.toadd = $addtok(%battlelist.toadd,%current.monster.to.spawn,46) | writeini battle2.txt Battle List %battlelist.toadd | unset %battlelist.toadd
      write battle.txt %current.monster.to.spawn
      var %battlemonsters $readini(battle2.txt, BattleInfo, Monsters) | inc %battlemonsters 1 | writeini battle2.txt BattleInfo Monsters %battlemonsters

      ; display the description of the spawned monster
      $set_chr_name(%current.monster.to.spawn) 

      if ($readini(system.dat, system, botType) = IRC) {
        /.timerThrottle $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,100000) 1 1 /query %battlechan $readini(translation.dat, battle, EnteredTheBattle)
        /.timerThrottle $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,100000) 1 1 /query %battlechan 12 $+ %real.name  $+ $readini($char(%current.monster.to.spawn), descriptions, char)
        var %bossquote $readini($char(%current.monster.to.spawn), descriptions, bossquote)
        if (%bossquote != $null) {   /.timerThrottle $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,100000) 1 1 /query %battlechan 2 $+ %real.name looks at the heroes and says " $+ $readini($char(%current.monster.to.spawn), descriptions, BossQuote) $+ " }
      }

      if ($readini(system.dat, system, botType) = DCCchat) {
        $display.system.message($readini(translation.dat, battle, EnteredTheBattle), battle)
        $display.system.message(12 $+ %real.name  $+ $readini($char(%current.monster.to.spawn), descriptions, char), battle)
        if (%bossquote != $null) {   $display.system.message(2 $+ %real.name looks at the heroes and says " $+ $readini($char(%current.monster.to.spawn), descriptions, BossQuote) $+ ", battle) }
      }

      ; Boost the monster
      $boost_monster_stats(%current.monster.to.spawn,portal) 
      $fulls(%current.monster.to.spawn)

      set %multiple.wave.bonus yes
      set %first.round.protection yes

      ; Get the boss item.
      var %boss.item $readini($char(%current.monster.to.spawn), stuff, drops)
      if (%boss.item != $null) { 
        var %boss.item $readini($char(%current.monster.to.spawn), stuff, drops)
        var %boss.drop.list $readini(battle2.txt, battle, bonusitem)
        if (%boss.drop.list != $null) { writeini battle2.txt battle bonusitem %boss.drop.list $+ . $+ %boss.item | unset %boss.item }
        if (%boss.drop.list = $null) { writeini battle2.txt battle bonusitem %boss.item | unset %boss.item }
      }

      inc %value

    }
  }

  if (%found.monster != true) { $display.system.message($readini(translation.dat, errors, PortalItemNotWorking), private)  | halt  }  

  /.timerBattleRage 1 1200 /battle_rage_warning

  unset %found.monster | unset %cleared.battlefield | return

}
