; Shop commands here (list, buy, etc)

on 2:TEXT:!shop*:*: { 

  ; For now let's check to make sure the shop level isn't over 25.
  var %shop.level $readini($char($nick), stuff, shoplevel) 
  if (%shop.level > 25) { writeini $char($nick) stuff shoplevel 25.0 }

  $set_chr_name($nick) 
  unset %shop.list
  if ($2 = $null) { $gamehelp(Shop, $nick)  | halt  }
  if ($2 = level) { .msg $nick 2Your current shop level is $readini($char($nick), stuff, shoplevel) | halt }


  if ($2 = sell) {
    if (($3 != items) && ($3 != item)) { .msg $nick 4Error: You can only sell items. | halt }
    var %amount.to.sell $abs($5)
    if (%amount.to.sell = $null) { var %amount.to.sell 1 }
    $shop.items($nick, sell, $4, %amount.to.sell)
    halt
  }

  if (($2 = buy) || ($2 = purchase)) { 
    if (%battleis = on) { 
      if ($nick isin $readini(battle2.txt, Battle, List)) { .msg $nick 4Error: You must wait til you're out of battle to use the shop. | halt }
    }

    if ($3 = $null) { .msg $nick 4Error: Use !shop buy <items/techs/skills/stats/weapons/styles/orbs> <what to buy>  }
    var %amount.to.purchase $abs($5)
    if (%amount.to.purchase = $null) { var %amount.to.purchase 1 }

    if (($3 = items) || ($3 = item))  { $shop.items($nick, buy, $4, %amount.to.purchase) | halt }
    if (($3 = techs) || ($3 = techniques)) { $shop.techs($nick, buy, $4, %amount.to.purchase) | halt  }
    if (($3 = skills) || ($3 = skill)) { $shop.skills($nick, buy, $4, %amount.to.purchase) | halt  }
    if (($3 = stats) || ($3 = stat))  {  $shop.stats($nick, buy, $4, %amount.to.purchase) | halt  }
    if (($3 = weapons) || ($3 = weapon)) { $shop.weapons($nick, buy, $4, %amount.to.purchase) }
    if ($3 = orbs) { 
      var %amount.to.purchase $abs($4)
      if (%amount.to.purchase = $null) { var %amount.to.purchase 1 }
      $shop.orbs($nick, buy, %amount.to.purchase) 
    }
    if (($3 = style) || ($3 = styles))  { $shop.styles($nick, buy, $4) | halt }
    else { .msg $nick 4Error: Use !shop list <items/techs/skills/stats/weapons/orbs/styles>  or !shop buy <items/techs/skills/stats/weapons/orbs/style> <what to buy>  | halt }
  }

  if ($2 = list) { 
    if (($3 = stats) || ($3 = stat)) { $shop.stats($nick, list) }
    if (($3 = items) || ($3 = item)) { $shop.items($nick, list) }
    if (($3 = techs) || ($3 = techniques))  { $shop.techs($nick, list) }
    if (($3 = skills) || ($3 = skill)) { $shop.skills($nick, list) }
    if (($3 = weapons) || ($3 = weapon)) { $shop.weapons($nick, list) }
    if ($3 = orbs) { $shop.orbs($nick, list) }
    if (($3 = style) || ($3 = styles))  { $shop.styles($nick, list, $4) | halt }
  }
  else { .msg $nick 4Error: Use !shop list <items/techs/skills/stats/weapons/styles/orbs>  or !shop buy <items/techs/skills/stats/weapons/styles/orbs> <what to buy> | halt }

}

alias shop.items {
  if ($2 = list) {
    ; get the list of all the shop items..

    ; CHECKING HEALING ITEMS
    unset %shop.list
    var %healing.items $readini(items.db, items, HealingItems)
    var %number.of.items $numtok(%healing.items, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %item.name $gettok(%healing.items, %value, 46)
      set %item.price $readini(items.db, %item.name, cost)
      %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46)
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerHealingItems $+ $nick 1 1 /.msg $nick 2Healing Items: %shop.list
    }

    ; CHECKING BATTLE ITEMS
    unset %shop.list | unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %item.price
    var %battle.items $readini(items.db, items, BattleItems)
    var %number.of.items $numtok(%battle.items, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %item.name $gettok(%battle.items, %value, 46)
      set %item.price $readini(items.db, %item.name, cost)
      %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46)
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerBattleItems $+ $nick 1 1 /.msg $nick 2Battle Items: %shop.list
    }

    ; CHECKING CONSUMABLE ITEMS
    unset %shop.list | unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %item.price | unset %consume.items
    var %consume.items $readini(items.db, items, ConsumeItems)
    var %number.of.items $numtok(%consume.items, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %item.name $gettok(%consume.items, %value, 46)
      set %item.price $readini(items.db, %item.name, cost)
      %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46)
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerConsumeItems $+ $nick 1 1 /.msg $nick 2Items Used For Skills: %shop.list
    }

    ; CHECKING SUMMON ITEMS
    unset %shop.list | unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %item.price | unset %consume.items
    var %summon.items $readini(items.db, items, SummonItems)
    var %number.of.items $numtok(%summon.items, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %item.name $gettok(%summon.items, %value, 46)
      set %item.price $readini(items.db, %item.name, cost)
      %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46)
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerSummonItems $+ $nick 1 1 /.msg $nick 2Items Used For Summons: %shop.list
    }

    ; CHECKING SHOP RESET ITEMS
    unset %shop.list | unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %item.price | unset %summon.items
    var %shopreset.items $readini(items.db, items, ShopReset)
    var %number.of.items $numtok(%shopreset.items, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %item.name $gettok(%shopreset.items, %value, 46)
      set %item.price $readini(items.db, %item.name, cost)
      %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46)
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerShopResetItems $+ $nick 1 1 /.msg $nick 2Items Used To Lower Shop Levels: %shop.list
    }


    unset %item.price | unset %item.name
  }

  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid item?
    if ($readini(items.db, $3, type) = $null) { .msg $nick 4Error: Invalid item. Use! !shop list items to get a valid list | halt }

    ; do you have enough to buy it?
    var %player.redorbs $readini($char($1), stuff, redorbs)
    var %total.price $readini(items.db, $3, cost)
    %total.price = $calc($4 * %total.price)

    if (%player.redorbs < %total.price) { .msg $nick 4You do not have enough red orbs to purchase this item! | halt }

    ; if so, increase the amount and add the item
    var %player.items $readini($char($1), Item_Amount, $3)
    inc %player.items $4
    writeini $char($1) Item_Amount $3 %player.items

    ; decrease amount of orbs you have.
    dec %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs

    .msg $nick 3You spend %total.price  $+ $readini(system.dat, system, currency) for $4 $3 $+ (s)!
    $inc.redorbsspent($1, %total.price)
  }

  if ($2 = sell) {
    ; is it a valid item?
    if ($readini(items.db, $3, type) = $null) { .msg $nick 4Error: Invalid item. Use! !shop list items to get a valid list | halt }

    ; Does the player have it?
    var %player.items $readini($char($1), Item_Amount, $3)
    if (%player.items = $null) { .msg $nick 4Error: You do not have this item to sell! | halt }
    if (%player.items < $4) { .msg $nick 4Error: You do not have $4 of this item to sell! | halt }

    ; If so, decrease the amount
    dec %player.items $4
    writeini $char($1) item_amount $3 %player.items

    var %total.price $readini(items.db, $3, cost)

    %total.price = $round($calc(%total.price / 2.5),0)


    if ($readini($char($1), skills, haggling) > 0) { 
      inc %total.price $calc($readini($char($1), skills, Haggling) * 20)
    }

    if (%total.price <= 0) { %total.price = 1 }
    if (%total.price >= $readini(items.db, $3, cost)) { %total.price = $readini(items.db, $3, cost) }
    if (%total.price > 500) { %total.price = 500 }

    %total.price = $calc($4 * %total.price)

    var %player.redorbs $readini($char($1), stuff, redorbs)
    inc %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs

    .msg $nick 3A shop keeper wearing a green and white bucket hat takes $4 $3 $+ (s) from you and gives you %total.price $readini(system.dat, system, currency) $+ !
  }
}

alias shop.techs {
  if ($2 = list) {
    unset %shop.list
    ; get the list of the techs for the weapon you have equipped
    $weapon_equipped($1)
    var %shop.level $readini($char($1), stuff, shoplevel)

    ; CHECKING TECHS
    unset %shop.list
    set %tech.list $readini(weapons.db, %weapon.equipped, Abilities)
    var %number.of.items $numtok(%tech.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %tech.name $gettok(%tech.list, %value, 46)
      set %tech.price $round($calc(%shop.level * $readini(techniques.db, %tech.name, cost)),0)
      %shop.list = $addtok(%shop.list, $+ %tech.name $+ +1 ( $+ %tech.price $+ ),46)
      inc %value 1 
    }

    ; display the list with the prices.
    $shop.cleanlist
    .msg $nick 2Stat Prices in $readini(system.dat, system, currency) $+ : %shop.list
  }

  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid tech?
    $weapon_equipped($1)
    if ($3 !isin $readini(weapons.db, %weapon.equipped, abilities)) { .msg $nick 4Error: Invalid item. Use! !shop list techs to get a valid list | halt }

    var %shop.level $readini($char($1), stuff, shoplevel)
    ; do you have enough to buy it?
    var %player.redorbs $readini($char($1), stuff, redorbs)
    var %base.cost $readini(techniques.db, $3, cost)

    set %total.price $shop.calculate.totalcost($1, $4, %base.cost)

    if (%player.redorbs < %total.price) { .msg $nick 4You do not have enough $readini(system.dat, system, currency) to purchase this item! | halt }

    ; if so, increase the amount and add it to the list
    var %current.techlevel $readini($char($1), techniques, $3))
    inc %current.techlevel $4
    writeini $char($1) techniques $3 %current.techlevel

    .msg $nick 3You spend $bytes(%total.price,b)  $+  $readini(system.dat, system, currency) for + $+ $4 to your $3 technique $+ !

    ; decrease amount of orbs you have.
    dec %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs
    $inc.redorbsspent($1, %total.price)

    ; Increase the shop level.
    $inc.shoplevel($1, $4)
  }
}

alias shop.skills {
  unset %shop.list.activeskills | unset %shop.list.passiveskills | unset %shop.list.resistanceskills
  if ($2 = list) {
    ; get the list of the skills
    var %shop.level $readini($char($1), stuff, shoplevel)

    ; CHECKING PASSIVE SKILLS
    unset %shop.list | unset %skill.list
    set %skill.list $readini(skills.db, Skills, PassiveSkills)
    var %number.of.items $numtok(%skill.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %skill.name $gettok(%skill.list, %value, 46)
      set %skill.max $readini(skills.db, %skill.name, max)
      set %skill.have $readini($char($1), skills, %skill.name)

      if (%skill.have >= %skill.max) { inc %value 1 }
      else { 
        set %skill.price $round($calc(%shop.level * $readini(skills.db, %skill.name, cost)),0)
        %shop.list.passiveskills = $addtok(%shop.list.passiveskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46)
        inc %value 1 
      }
    }

    set %replacechar $chr(044) $chr(032) |  %shop.list.passiveskills = $replace(%shop.list.passiveskills, $chr(046), %replacechar)

    ; CHECKING ACTIVE SKILLS
    unset %skill.list | unset %value
    set %skill.list $readini(skills.db, Skills, ActiveSkills)
    var %number.of.items $numtok(%skill.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %skill.name $gettok(%skill.list, %value, 46)
      set %skill.max $readini(skills.db, %skill.name, max)
      set %skill.have $readini($char($1), skills, %skill.name)

      if (%skill.have >= %skill.max) { inc %value 1 }
      else { 
        set %skill.price $round($calc(%shop.level * $readini(skills.db, %skill.name, cost)),0)
        %shop.list.activeskills = $addtok(%shop.list.activeskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46)
        inc %value 1 
      }
    }

    set %replacechar $chr(044) $chr(032) |  %shop.list.activeskills = $replace(%shop.list.activeskills, $chr(046), %replacechar)

    ; CHECKING RESISTANCES
    unset %skill.list | unset %value
    set %skill.list $readini(skills.db, Skills, Resists)
    var %number.of.items $numtok(%skill.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %skill.name $gettok(%skill.list, %value, 46)
      set %skill.max $readini(skills.db, %skill.name, max)
      set %skill.have $readini($char($1), skills, %skill.name)

      if (%skill.have >= %skill.max) { inc %value 1 }
      else { 
        set %skill.price $round($calc(%shop.level * $readini(skills.db, %skill.name, cost)),0)
        %shop.list.resistanceskills = $addtok(%shop.list.resistanceskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46)
        inc %value 1 
      }
    }

    set %replacechar $chr(044) $chr(032) |  %shop.list.resistanceskills = $replace(%shop.list.resistanceskills, $chr(046), %replacechar)

    ; display the list with the prices.
    if (%shop.list.activeskills != $null) {  .msg $nick 2Active Skill Prices in $readini(system.dat, system, currency) $+ : %shop.list.activeskills }
    if (%shop.list.passiveskills != $null) {  .msg $nick 2Passive Skill Prices in $readini(system.dat, system, currency) $+ : %shop.list.passiveskills }
    if (%shop.list.resistanceskills != $null) {  .msg $nick 2Resistance Skill Prices in $readini(system.dat, system, currency) $+ : %shop.list.resistanceskills }

    unset %shop.list.activeskills | unset %shop.list.passiveskills | unset %shop.list.resistanceskills
  }


  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid skill?
    if ($readini(skills.db, $3, type) = $null) { .msg $nick 4Error: Invalid . Use! !shop list skills to get a valid list | halt }

    var %current.skilllevel $readini($char($1), skills, $3))
    inc %current.skilllevel $4
    var %max.skilllevel $readini(skills.db, $3, max)
    if (%max.skilllevel = $null) { var %max.skilllevel 100000 }
    if (%current.skilllevel > %max.skilllevel) { .msg $nick 4You cannot buy any more levels into this skill as you have already hit or will go over the max amount with this purchase amount. | halt }

    var %shop.level $readini($char($1), stuff, shoplevel)
    ; do you have enough to buy it?
    var %player.redorbs $readini($char($1), stuff, redorbs)
    var %base.cost $readini(skills.db, $3, cost)

    set %total.price $shop.calculate.totalcost($1, $4, %base.cost)

    if (%player.redorbs < %total.price) { .msg $nick 4You do not have enough $readini(system.dat, system, currency) to purchase this item! | halt }

    writeini $char($1) skills $3 %current.skilllevel

    .msg $nick 3You spend $bytes(%total.price,b)  $+ $readini(system.dat, system, currency) for + $+ $4 to your $3 skill $+ !

    ; decrease amount of orbs you have.
    dec %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs
    $inc.redorbsspent($1, %total.price)

    ; Increase the shop level.
    $inc.shoplevel($1, $4)
  }
}

alias shop.stats {
  if ($2 = list) {
    ; get the list of all the shop items..
    var %shop.level $readini($char($1), stuff, shoplevel)
    var %hp.price $round($calc(%shop.level * $readini(system.dat, statprices, hp)),0)
    var %tp.price $round($calc(%shop.level * $readini(system.dat, statprices, tp)),0)
    var %str.price $round($calc(%shop.level * $readini(system.dat, statprices, str)),0)
    var %def.price $round($calc(%shop.level * $readini(system.dat, statprices, def)),0)
    var %int.price $round($calc(%shop.level * $readini(system.dat, statprices, int)),0)
    var %spd.price $round($calc(%shop.level * $readini(system.dat, statprices, spd)),0)

    var %player.current.hp $readini($char($1), basestats, hp)
    if (%player.current.hp < $readini(system.dat, system, maxHP)) { 
      %shop.list = $addtok(%shop.list,HP+50 ( $+ %hp.price $+ ),46)
    }

    var %player.current.tp $readini($char($1), basestats, tp)
    if (%player.current.tp < $readini(system.dat, system, maxTP)) {
      %shop.list = $addtok(%shop.list,TP+5 ( $+ %tp.price $+ ),46)
    }


    %shop.list = $addtok(%shop.list,Str+1 ( $+ %str.price $+ ),46)
    %shop.list = $addtok(%shop.list,Def+1 ( $+ %def.price $+ ),46)
    %shop.list = $addtok(%shop.list,Int+1 ( $+ %int.price $+ ),46)
    %shop.list = $addtok(%shop.list,Spd+1 ( $+ %spd.price $+ ),46)

    ; display the list with the prices.
    $shop.cleanlist
    .msg $nick 2Stat Prices in $readini(system.dat, system, currency) $+ : %shop.list
  }

  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid item?
    if ($readini(system.dat, statprices, $3) = $null) { .msg $nick 4Error: Invalid stat! Use! !shop list stats to get a valid list | halt }

    ; do you have enough to buy it?
    var %shop.level $readini($char($1), stuff, shoplevel)
    var %base.cost $readini(system.dat, StatPrices, $3)
    var %player.redorbs $readini($char($1), stuff, redorbs)

    set %total.price $shop.calculate.totalcost($1, $4, %base.cost)

    if ($3 = hp) {
      var %player.current.hp $readini($char($1), basestats, hp)
      if (%player.current.hp >= 2500) { .msg $nick 4Error: You have the maximum amount of HP allowed! | halt }
    }

    if ($3 = tp) {
      var %player.current.tp $readini($char($1), basestats, tp)
      if (%player.current.tp >= 500) {  .msg $nick 4Error: You have the maximum amount of TP allowed! | halt }
    }

    if (%player.redorbs < %total.price) { .msg $nick 4You do not have enough $readini(system.dat, system, currency) to purchase this upgrade! | halt }

    ; if so, increase the amount and add the stat bonus
    var %basestat.to.increase $readini($char($1), basestats, $3)
    set %shop.statbonus 0

    if (($3 = str) || ($3 = def)) { set %shop.statbonus 1 }
    if (($3 = int) || ($3 = spd)) { set %shop.statbonus 1 }
    if ($3 = hp) { set %shop.statbonus 50  }
    if ($3 = tp) { set %shop.statbonus 5 }

    %shop.statbonus = $calc(%shop.statbonus * $4)
    inc %basestat.to.increase %shop.statbonus


    if ($3 = hp) {
      if (%base.stat.to.increase > 2500) { .msg $nick 4Error: This amount will push you over the 2500 limit allowed for HP. Please lower the amount and try again. | halt }
    }

    if ($3 = tp) {
      if (%base.stat.to.increase > 00) { .msg $nick 4Error: This amount will push you over the 500 limit allowed for TP. Please lower the amount and try again. | halt }
    }


    writeini $char($1) basestats $3 %basestat.to.increase
    $fulls($1)

    .msg $nick 3You spend $bytes(%total.price,b)  $+ $readini(system.dat, system, currency) for + $+ $bytes(%shop.statbonus,b) to your $3 $+ !

    ; decrease amount of orbs you have.
    dec %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs
    $inc.redorbsspent($1, %total.price)

    ; Increase the shop level.
    $inc.shoplevel($1, $4)
  }
}

alias shop.weapons {
  if ($2 = list) {
    .msg $nick 2New weapon prices are in Black Orbs.  Upgrades are listed in $readini(system.dat, system, currency)
    unset %shop.list | unset %upgrade.list | unset %upgrade.list2 | unset %upgrade.list3
    ; get the list of the weapons.
    var %shop.level $readini($char($1), stuff, shoplevel)

    ; CHECKING H2H
    unset %shop.list | unset %weapon.list
    set %weapon.list $readini(weapons.db, Weapons, HandToHand)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) {
        set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
        %upgrade.list = $addtok(%upgrade.list, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerH2H $+ $nick 1 1 /.msg $nick 2New Hand to Hand Weapons: %shop.list
    }

    unset %shop.list

    ; CHECKING Swords
    unset %weapon.list
    set %weapon.list $readini(weapons.db, Weapons, Swords)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) {
        set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
        %upgrade.list = $addtok(%upgrade.list, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerSwords $+ $nick 1 1 /.msg $nick 2New Sword Weapons: %shop.list
    }

    unset %shop.list

    ; CHECKING Whips
    unset %weapon.list
    set %weapon.list $readini(weapons.db, Weapons, Whips)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) {
        set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
        %upgrade.list = $addtok(%upgrade.list, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerWhips $+ $nick 1 1 /.msg $nick 2New Whip Weapons: %shop.list
    }

    unset %shop.list

    ; CHECKING Guns
    unset %weapon.list
    set %weapon.list $readini(weapons.db, Weapons, Guns)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) {
        set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
        %upgrade.list = $addtok(%upgrade.list, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerGuns $+ $nick 1 1 /.msg $nick 2New Gun Weapons:  %shop.list
    }

    unset %shop.list

    ; CHECKING Rifles
    unset %weapon.list
    set %weapon.list $readini(weapons.db, Weapons, Rifles)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) {
        set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
        %upgrade.list2 = $addtok(%upgrade.list2, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerRifles $+ $nick 1 1 /.msg $nick 2New Rifle Weapons:  %shop.list
    }

    unset %shop.list

    ; CHECKING Katanas
    unset %weapon.list 
    set %weapon.list $readini(weapons.db, Weapons, Katanas)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) {
        set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
        %upgrade.list2 = $addtok(%upgrade.list2, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerKatanas $+ $nick 1 1 /.msg $nick 2New Katana Weapons:  %shop.list
    }

    unset %shop.list

    ; CHECKING Wands
    unset %weapon.list 
    set %weapon.list $readini(weapons.db, Weapons, Wands)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) {
        set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
        %upgrade.list2 = $addtok(%upgrade.list2, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerWands $+ $nick 1 1 /.msg $nick 2New Wand/Staff Weapons:  %shop.list
    }

    unset %shop.list

    ; CHECKING Spears
    unset %weapon.list
    set %weapon.list $readini(weapons.db, Weapons, Spears)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) {
        set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
        %upgrade.list2 = $addtok(%upgrade.list2, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerSpears $+ $nick 1 1 /.msg $nick 2New Spear Weapons: %shop.list
    }

    unset %shop.list

    ; CHECKING Scythes
    unset %weapon.list
    set %weapon.list $readini(weapons.db, Weapons, Scythes)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) {
        set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
        %upgrade.list2 = $addtok(%upgrade.list2, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerScythes $+ $nick 1 2 /.msg $nick 2New Scythe Weapons: %shop.list
    }

    unset %shop.list

    ; CHECKING GreatSwords
    unset %weapon.list
    set %weapon.list $readini(weapons.db, Weapons, GreatSwords)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) {
        set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
        %upgrade.list3 = $addtok(%upgrade.list3, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerGreatSwords $+ $nick 1 2 /.msg $nick 2New Great Sword Weapons: %shop.list
    }

    unset %shop.list

    ; CHECKING Glyphs
    unset %weapon.list
    set %weapon.list $readini(weapons.db, Weapons, Glyphs)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) {
        set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
        %upgrade.list3 = $addtok(%upgrade.list3, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerGlyphs $+ $nick 1 1 /.msg $nick 2New Glyph Weapons: %shop.list
    }

    unset %shop.list

    if (((%upgrade.list != $null) || (%upgrade.list2 != $null) || (%upgrade.list3 != $null))) {  
      /.timerUpgradeList $+ $nick 1 2 /.msg $nick 2Weapons you can upgrade:
      set %replacechar $chr(044) $chr(032) 
      if (%upgrade.list != $null) {
        %upgrade.list = $replace(%upgrade.list, $chr(046), %replacechar)
        /.timerUpgradeList1 $+ $nick 1 2 /.msg $nick 2 $+ %upgrade.list
      }
      if (%upgrade.list2 != $null) {
        %upgrade.list2 = $replace(%upgrade.list2, $chr(046), %replacechar)
        /.timerUpgradeList2 $+ $nick 1 2 /.msg $nick 2 $+ %upgrade.list2
      }
      if (%upgrade.list3 != $null) {
        %upgrade.list3 = $replace(%upgrade.list3, $chr(046), %replacechar)
        /.timerUpgradeList3 $+ $nick 1 2 /.msg $nick 2 $+ %upgrade.list3
      }

    }
  }
  if (($2 = buy) || ($2 = purchase)) {
    if ($readini(weapons.db, $3, type) = $null) { .msg $nick 4Error: Invalid weapon! Use! !shop list weapons to get a valid list | halt }
    if ($readini(weapons.db, $3, cost) = 0) { .msg $nick 4Error: You cannot purchase this weapon! | halt }
    var %weapon.level $readini($char($1), weapons, $3)
    if (%weapon.level != $null) { 
      var %shop.level $readini($char($1), stuff, shoplevel)
      ; do you have enough to buy it?
      var %player.redorbs $readini($char($1), stuff, redorbs)
      var %base.cost $readini(weapons.db, $3, upgrade)
      set %total.price $shop.calculate.totalcost($1, $4, %base.cost)
      if (%player.redorbs < %total.price) { .msg $nick 4You do not have enough $readini(system.dat, system, currency) to purchase this weapon upgrade! | halt }
      dec %player.redorbs %total.price
      $inc.redorbsspent($1, %total.price)
      inc %weapon.level $4
      writeini $char($1) stuff redorbs %player.redorbs
      writeini $char($1) weapons $3 %weapon.level
      .msg $nick 3You spend $bytes(%total.price,b)  $+ $readini(system.dat, system, currency) to upgrade your $3 $+ !
      $inc.shoplevel($1, $4)
      halt
    }
    else {
      var %shop.level $readini($char($1), stuff, shoplevel)
      ; do you have enough to buy it?
      var %player.blackorbs $readini($char($1), stuff, blackorbs) 
      var %total.price $readini(weapons.db, $3, cost)
      if (%player.blackorbs < %total.price) { .msg $nick 4You do not have enough black orbs to purchase this item! | halt }
      dec %player.blackorbs %total.price
      writeini $char($1) stuff blackorbs %player.blackorbs
      $inc.blackorbsspent($1, %total.price)
      writeini $char($1) weapons $3 1
      .msg $nick 3You spend %total.price black orb(s) to purchase $3 $+ !
      halt
    }
  }
}

alias shop.styles {
  if ($2 = list) {
    .msg $nick 2New style prices are in Black Orbs.
    unset %shop.list | unset %upgrade.list
    ; get the list of the styles
    unset %shop.list | unset %styles.list
    set %styles.list $readini(playerstyles.lst, Styles, List)
    var %number.of.items $numtok(%styles.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %style.name $gettok(%styles.list, %value, 46)
      ; Does the player own this style? 
      set %player.style.level $readini($char($1), styles, %style.name)
      if ((%player.style.level = $null) || (%player.style.level <= 0)) {
        set %style.price $readini(playerstyles.lst, Costs, %style.name)
        %shop.list = $addtok(%shop.list, $+ %style.name $+  ( $+ %style.price $+ ),46)
        inc %value 1 
      }
      else {  
        inc %value 1
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      /.timerStyles $+ $nick 1 1 /.msg $nick 2New Styles: %shop.list
    }

    if (%shop.list = $null) { .msg $nick 4There are no more styles for you to purchase. | halt }

    unset %shop.list
  }
  if (($2 = buy) || ($2 = purchase)) {
    if ($readini(playerstyles.lst, costs, $3) = $null) { .msg $nick 4Error: Invalid style! Use !shop list styles to get a valid list | halt }
    if ($readini(playerstyles.lst, costs, $3) = 0) { .msg $nick 4Error: You cannot purchase this style! Use !shop list styles to get a valid list | halt }
    var %style.level $readini($char($1), styles, $3)
    ; do you have enough to buy it?
    var %player.blackorbs $readini($char($1), stuff, blackorbs) 
    var %total.price $readini(playerstyles.lst, costs, $3)
    if (%player.blackorbs < %total.price) { .msg $nick 4You do not have enough black orbs to purchase this item! | halt }
    dec %player.blackorbs %total.price
    writeini $char($1) stuff blackorbs %player.blackorbs
    $inc.blackorbsspent($1, %total.price)
    writeini $char($1) styles $3 1
    writeini $char($1) styles $3 $+ XP 0
    .msg $nick 3You spend %total.price black orb(s) to purchase $3 $+ !
    unset %styles.list | unset %style.name | unset %style.level | unset %style.price | unset %styles
    halt
  }
}

alias shop.orbs {
  if ($2 = list) { .msg $nick 2You can exchange 1 black orb for 500 $readini(system.dat, system, currency) $+ .  To do so, use the command: !shop buy orbs  }

  if (($2 = buy) || ($2 = purchase)) {
    ; do you have enough to buy it?
    %total.price = $calc($3 * 1)

    var %player.blackorbs $readini($char($1), stuff, blackorbs)
    if (%player.blackorbs < %total.price) { .msg $nick 4You do not have enough black orbs to do the exchange! | halt }

    ; if so, increase the amount
    var %player.redorbs $readini($char($1), stuff, redorbs)
    var %orb.increase.amount $calc(500 * $3)
    inc %player.redorbs %orb.increase.amount
    dec %player.blackorbs %total.price
    $inc.blackorbsspent($1, %total.price)
    writeini $char($1) stuff redorbs %player.redorbs
    writeini $char($1) stuff blackorbs %player.blackorbs

    .msg $nick 3You spend %total.price black orb(s) for  $+ %orb.increase.amount $readini(system.dat, system, currency) $+ !
    halt
  }
}
alias inc.shoplevel {   
  var %shop.level $readini($char($1), stuff, shoplevel) 
  if (($2 = $null) || ($2 <= 0)) { var %amount.to.increase .1 }
  if ($2 != $null) && ($2 > 0)) { var %amount.to.increase $calc(.1 * $2) }
  inc %shop.level %amount.to.increase 
  if (%shop.level >= 25) { writeini $char($1) stuff shoplevel 25 | .msg $1 2Your Shop Level has been capped at 25 | halt }
  else { 
    writeini $char($1) stuff shoplevel %shop.level  
    .msg $1 2Your Shop Level has been increased to %shop.level 
  }
}

alias shop.cleanlist {
  ; CLEAN UP THE LIST
  if ($chr(046) isin %shop.list) { set %replacechar $chr(044) $chr(032)
    %shop.list = $replace(%shop.list, $chr(046), %replacechar)
  }
}

alias inc.redorbsspent {  
  var %orbs.spent $readini($char($1), stuff, RedOrbsSpent)
  inc %orbs.spent $2
  writeini $char($1) stuff RedOrbsSpent %orbs.spent
  return
}
alias inc.blackorbsspent {
  var %orbs.spent $readini($char($1), stuff, BlackOrbsSpent)
  inc %orbs.spent $2
  writeini $char($1) stuff BlackOrbsSpent %orbs.spent
  return
}
alias shop.calculate.totalcost {
  var %value 1
  var %total.price.calculate 0
  var %shop.level $readini($char($1), stuff, shoplevel)
  while (%value <= $2) { 
    inc %total.price.calculate $round($calc(%shop.level * $3),0)
    if (%shop.level < 25) {  inc %shop.level .1 }
    inc %value 1
  }
  return %total.price.calculate
}
