;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  SHOP COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

on 3:TEXT:!shop*:*: { $shop.start($1, $2, $3, $4, $5) }

alias shop.start {

  ; For now let's check to make sure the shop level isn't over 25.
  var %max.shop.level $readini(system.dat, system, maxshoplevel)
  if (%max.shop.level = $null) { var %max.shop.level 25 }

  var %shop.level $readini($char($nick), stuff, shoplevel) 
  if (%shop.level > %max.shop.level) { writeini $char($nick) stuff shoplevel %max.shop.level }

  $set_chr_name($nick) 
  unset %shop.list
  if ($2 = $null) { $gamehelp(Shop, $nick)  | halt  }
  if ($2 = level) { $display.private.message($readini(translation.dat, system, CurrentShopLevel)) | halt }

  if ($5 = 0) {  $display.private.message($readini(translation.dat, errors, Can'tBuy0ofThat)) | halt }


  if ($2 = sell) {
    var %sellable.stuff items.accessories.accessory.gems.techs
    if ($3 !isin %sellable.stuff) { $display.private.message($readini(translation.dat, errors, Can'tSellThat)) | halt }
    var %amount.to.sell $abs($5)
    if (%amount.to.sell = $null) { var %amount.to.sell 1 }
    if (($3 = item) || ($3 = items)) { $shop.items($nick, sell, $4, %amount.to.sell) | halt }
    if (($3 = key) || ($3 = keys)) { $shop.items($nick, sell, $4, %amount.to.sell) | halt }
    if (($3 = accessories) || ($3 = accessory))  { $shop.accessories($nick, sell, $4, %amount.to.sell) | halt }
    if (($3 = gems) || ($3 = gem))  { $shop.items($nick, sell, $4, %amount.to.sell) | halt }
    if (($3 = tech) || ($3 = techs)) { $shop.techs($nick, sell, $4, %amount.to.sell) | halt }
  }

  if (($2 = buy) || ($2 = purchase)) { 
    if (%battleis = on) { 
      if ($nick isin $readini(battle2.txt, Battle, List)) {  $display.private.message($readini(translation.dat, errors, Can'tUseShopInBattle)) | halt }
    }

    if ($3 = $null) {  $display.private.message(4Error: Use !shop buy <items/techs/skills/stats/weapons/styles/ignitions/orbs/portal/misc> <what to buy>)  }
    var %amount.to.purchase $abs($5)
    if (%amount.to.purchase = $null) { var %amount.to.purchase 1 }

    if (($3 = items) || ($3 = item))  { $shop.items($nick, buy, $4, %amount.to.purchase) | halt }
    if (($3 = techs) || ($3 = techniques)) { $shop.techs($nick, buy, $4, %amount.to.purchase) | halt  }
    if (($3 = skills) || ($3 = skill)) { $shop.skills($nick, buy, $4, %amount.to.purchase) | halt  }
    if (($3 = stats) || ($3 = stat))  {  $shop.stats($nick, buy, $4, %amount.to.purchase) | halt  }
    if (($3 = portal) || ($3 = portalitem))  { $shop.portal($nick, buy, $4, %amount.to.purchase) | halt }
    if (($3 = alchemy) || ($3 = misc))  { $shop.alchemy($nick, buy, $4, %amount.to.purchase) | halt }
    if (($3 = alliednotes) || ($3 = gems))  { $shop.alchemy($nick, buy, $4, %amount.to.purchase) | halt }
    if (($3 = weapons) || ($3 = weapon)) { $shop.weapons($nick, buy, $4, %amount.to.purchase) }
    if ($3 = orbs) { 
      var %amount.to.purchase $abs($4)
      if (%amount.to.purchase = $null) { var %amount.to.purchase 1 }
      $shop.orbs($nick, buy, %amount.to.purchase) 
    }
    if (($3 = style) || ($3 = styles))  { $shop.styles($nick, buy, $4) | halt }
    if (($3 = ignition) || ($3 = ignitions))  { $shop.ignitions($nick, buy, $4) | halt }

    else {  $display.private.message(4Error: Use !shop list <items/techs/skills/stats/weapons/orbs/ignitions/styles/portal/misc>  or !shop buy <items/techs/skills/stats/weapons/orbs/style/ignitions/portal/misc> <what to buy>)  | halt }
  }

  if ($2 = list) { 
    if (($3 = stats) || ($3 = stat)) { $shop.stats($nick, list) }
    if (($3 = items) || ($3 = item)) { $shop.items($nick, list) }
    if (($3 = techs) || ($3 = techniques))  { $shop.techs($nick, list) }
    if (($3 = skills) || ($3 = skill)) { 
      if ($4 = passive) { $shop.skills.passive($nick) }
      if ($4 = active) { $shop.skills.active($nick) }
      if (($4 = resists) || ($4 = resistances)) { $shop.skills.resists($nick) }
      if ($4 = $null) { $shop.skills($nick, list) }
    }

    if (($3 = weapons) || ($3 = weapon)) { $shop.weapons($nick, list) }
    if ($3 = orbs) { $shop.orbs($nick, list) }
    if (($3 = style) || ($3 = styles))  { $shop.styles($nick, list, $4) | halt }
    if (($3 = ignition) || ($3 = ignitions))  { $shop.ignitions($nick, list, $4) | halt }
    if (($3 = portal) || ($3 = portals)) { $shop.portal($nick, list) }
    if (($3 = alchemy) || ($3 = misc)) { $shop.alchemy($nick, list) }
    if (($3 = alliednotes) || ($3 = gems)) { $shop.alchemy($nick, list) }
  }
  else {  $display.private.message(4Error: Use !shop list <items/techs/skills/stats/weapons/orbs/ignitions/styles/portal/misc>  or !shop buy <items/techs/skills/stats/weapons/orbs/style/ignitions/portal/misc> <what to buy>)  | halt }

}

alias shop.accessories {
  if ($2 = sell) {
    ; is it a valid item?
    if ($readini(items.db, $3, type) = $null) { $display.private.message(4Error: Invalid accessory.) | halt }

    ; Does the player have it?
    var %player.items $readini($char($1), Item_Amount, $3)
    if (%player.items = $null) { $display.private.message($readini(translation.dat, errors, DoNotHaveAccessoryToSell)) | halt }
    if (%player.items < $4) { $display.private.message($readini(translation.dat, errors, DoNotHaveEnoughItemToSell)) | halt }

    var %equipped.accessory $readini($char($1), equipment, accessory)
    if (%equipped.accessory = $3) {
      if (%player.items = 1) { $display.private.message($readini(translation.dat, errors, StillWearingAccessory)) | halt }
    }
    ; If so, decrease the amount
    dec %player.items $4
    writeini $char($1) item_amount $3 %player.items

    var %total.price $readini(items.db, $3, cost)

    %total.price = $round($calc(%total.price / 2.5),0)

    if ($readini($char($1), skills, haggling) > 0) { 
      inc %total.price $calc($readini($char($1), skills, Haggling) * 20)
    }


    if (%total.price >= $readini(items.db, $3, cost)) { %total.price = $readini(items.db, $3, cost) }
    if (%total.price > 500) { %total.price = 500 }
    if ((%total.price = 0) || (%total.price = $null)) {  set %total.price 100  }

    %total.price = $calc($4 * %total.price)

    var %player.redorbs $readini($char($1), stuff, redorbs)
    inc %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs

    $display.private.message($readini(translation.dat, system, SellMessage))
  }
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
      if (%item.price > 0) {  %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(3Healing Items:2 %shop.list)
    }

    ; CHECKING BATTLE ITEMS
    unset %shop.list | unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %item.price
    var %battle.items $readini(items.db, items, BattleItems)
    var %number.of.items $numtok(%battle.items, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %item.name $gettok(%battle.items, %value, 46)
      set %item.price $readini(items.db, %item.name, cost)
      if (%item.price > 0) {  %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(4Battle Items:2 %shop.list)
    }

    ; CHECKING CONSUMABLE ITEMS
    unset %shop.list | unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %item.price | unset %consume.items
    var %consume.items $readini(items.db, items, ConsumeItems)
    var %number.of.items $numtok(%consume.items, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %item.name $gettok(%consume.items, %value, 46)
      set %item.price $readini(items.db, %item.name, cost)
      if (%item.price > 0) {  %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(14Items Used For Skills:2 %shop.list)
    }

    ; CHECKING SUMMON ITEMS
    unset %shop.list | unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %item.price | unset %consume.items
    var %summon.items $readini(items.db, items, SummonItems)
    var %number.of.items $numtok(%summon.items, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %item.name $gettok(%summon.items, %value, 46)
      set %item.price $readini(items.db, %item.name, cost)
      if (%item.price > 0) {  %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(10Items Used For Summons:2 %shop.list)
    }

    ; CHECKING SHOP RESET ITEMS
    unset %shop.list | unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %item.price | unset %summon.items
    var %shopreset.items $readini(items.db, items, ShopReset)
    var %number.of.items $numtok(%shopreset.items, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %item.name $gettok(%shopreset.items, %value, 46)
      set %item.price $readini(items.db, %item.name, cost)
      if (%item.price > 0) {  %shop.list = $addtok(%shop.list, $+ %item.name $+ ( $+ %item.price $+ ),46) }
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(12Items Used To Lower Shop Levels:2 %shop.list)
    }

    unset %item.price | unset %item.name
  }

  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid item?
    if ($readini(items.db, $3, type) = $null) { $display.private.message(4Error: Invalid item. Use! !shop list items to get a valid list) | halt }

    if ($readini(items.db, $3, currency) != $null) { $display.private.message(4Error: You cannot buy this item via this command!) | halt }

    ; do you have enough to buy it?
    var %player.redorbs $readini($char($1), stuff, redorbs)
    var %total.price $readini(items.db, $3, cost)
    %total.price = $calc($4 * %total.price)
    if (%total.price = 0) {  $display.private.message(4You cannot buy this item!) | halt }

    if (%player.redorbs < %total.price) { $display.private.message(4You do not have enough red orbs to purchase this item!) | halt }

    ; if so, increase the amount and add the item
    var %player.items $readini($char($1), Item_Amount, $3)
    inc %player.items $4
    writeini $char($1) Item_Amount $3 %player.items

    ; decrease amount of orbs you have.
    dec %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs

    $display.private.message(3You spend %total.price  $+ $readini(system.dat, system, currency) for $4 $3 $+ (s)!)
    $inc.redorbsspent($1, %total.price)
  }

  if ($2 = sell) {
    ; is it a valid item?
    if ($readini(items.db, $3, type) = $null) { $display.private.message(4Error: Invalid item. Use! !shop list items to get a valid list) | halt }

    ; Does the player have it?
    var %player.items $readini($char($1), Item_Amount, $3)
    if (%player.items = $null) { $display.private.message(4Error: You do not have this item to sell!) | halt }
    if (%player.items < $4) { $display.private.message(4Error: You do not have $4 of this item to sell!) | halt }

    var %total.price $readini(items.db, $3, cost)
    %total.price = $round($calc(%total.price / 2.5),0)
    if ((%total.price = 0) || (%total.price = $null)) {  set %total.price 50  }

    ; If so, decrease the amount
    dec %player.items $4
    writeini $char($1) item_amount $3 %player.items

    if ($readini($char($1), skills, haggling) > 0) { 
      inc %total.price $calc($readini($char($1), skills, Haggling) * 20)
    }

    if (%total.price >= $readini(items.db, $3, cost)) { %total.price = $readini(items.db, $3, cost) }
    if (%total.price > 500) { %total.price = 500 }
    if (%total.price <= 0) { %total.price = 50 }

    %total.price = $calc($4 * %total.price)

    var %player.redorbs $readini($char($1), stuff, redorbs)
    inc %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs

    var %number.of.items.sold $readini($char($1), stuff, ItemsSold)
    if (%number.of.items.sold = $null) { var %number.of.items.sold 0 }
    inc %number.of.items.sold $4
    writeini $char($1) stuff ItemsSold %number.of.items.sold
    $achievement_check($1, MakeMoney)
    $display.private.message(3A shop keeper wearing a green and white bucket hat takes $4 $3 $+ (s) from you and gives you %total.price $readini(system.dat, system, currency) $+ !)
    unset %total.price
  }
}

alias shop.techs {
  if ($2 = list) {
    unset %shop.list
    ; get the list of the techs for the weapon you have equipped
    $weapon_equipped($1)
    $shop.get.shop.level($1)

    ; CHECKING TECHS
    unset %shop.list
    set %tech.list $readini(weapons.db, %weapon.equipped, Abilities)
    var %number.of.items $numtok(%tech.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %tech.name $gettok(%tech.list, %value, 46)
      set %tech.price $round($calc(%shop.level * $readini(techniques.db, %tech.name, cost)),0)

      if ($readini(techniques.db, %tech.name, type) = boost) {
        set %player.amount $readini($char($1), techniques, %tech.name)
        if ((%player.amount <= 500) || (%player.amount = $null)) { %shop.list = $addtok(%shop.list, $+ %tech.name $+ +1 ( $+ %tech.price $+ ),46) }
      }
      if ($readini(techniques.db, %tech.name, type) != boost) {  
        if ($readini(techniques.db, %tech.name, type) = buff) {  
          set %player.amount $readini($char($1), techniques, %tech.name)
          if ((%player.amount < 1) || (%player.amount = $null)) { %shop.list = $addtok(%shop.list, $+ %tech.name $+ +1 ( $+ %tech.price $+ ),46) }
        }
        if ($readini(techniques.db, %tech.name, type) != buff) { %shop.list = $addtok(%shop.list, $+ %tech.name $+ +1 ( $+ %tech.price $+ ),46) }
      }

      inc %value 1 
    }

    ; display the list with the prices.
    $shop.cleanlist
    $display.private.message(2Tech Prices in $readini(system.dat, system, currency) $+ : %shop.list ) 
    unset %player.amount
  }

  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid tech?
    $weapon_equipped($1)
    set %weapon.abilities $readini(weapons.db, %weapon.equipped, abilities)
    if ($istok(%weapon.abilities,$3,46) = $false) { $display.private.message(4Error: Invalid item. Use! !shop list techs to get a valid list ) | halt }
    unset %weapon.abilities

    ; do you have enough to buy it?
    var %player.redorbs $readini($char($1), stuff, redorbs)
    var %base.cost $readini(techniques.db, $3, cost)

    set %total.price $shop.calculate.totalcost($1, $4, %base.cost)

    if (%player.redorbs < %total.price) { $display.private.message(4You do not have enough $readini(system.dat, system, currency) to purchase this item!) | halt }

    var %current.techlevel $readini($char($1), techniques, $3)

    if ($readini(techniques.db, $3, type) = buff) { var %max.techlevel 1 }
    if ($readini(techniques.db, $3, type) != buff) {  var %max.techlevel 500 }

    if (%current.techlevel >= %max.techlevel) {  $display.private.message(4You cannot buy any more levels of $3 $+ .) | halt }

    ; if so, increase the amount and add it to the list
    inc %current.techlevel $4

    if (%current.techlevel > %max.techlevel) {  $display.private.message(4Purchasing this amount will put you over the max limit. Please lower the amount and try again.) | halt }

    writeini $char($1) techniques $3 %current.techlevel

    $display.private.message(3You spend $bytes(%total.price,b)  $+  $readini(system.dat, system, currency) for + $+ $4 to your $3 technique $+ !)

    ; decrease amount of orbs you have.
    dec %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs
    $inc.redorbsspent($1, %total.price)

    ; Increase the shop level.
    $inc.shoplevel($1, $4)
  }

  if ($2 = sell) {
    ; is it a valid item?
    if ($readini(techniques.db, $3, type) = $null) {  $display.private.message(4Error: Invalid tech. Use! !techs to get a valid list of techs you own.) | halt }

    ; Does the player have it?
    var %player.items $readini($char($1), techniques, $3)
    if (%player.items = $null) {  $display.private.message(4Error: You do not have this tech to sell!) | halt }
    if (%player.items < $4) {  $display.private.message(4Error: You do not have $4 levels of this tech to sell!) | halt }

    set %total.price $readini(techniques.db, $3, cost)

    %total.price = $round($calc(%total.price / 2.5),0)
    if ((%total.price = 0) || (%total.price = $null)) {  set %total.price 50  }

    ; If so, decrease the amount
    dec %player.items $4
    writeini $char($1) techniques $3 %player.items

    if ($readini($char($1), skills, haggling) > 0) { 
      inc %total.price $calc($readini($char($1), skills, Haggling) * 20)
    }

    if (%total.price >= $readini(techniques.db, $3, cost)) { set %total.price $readini(techniques.db, $3, cost) }
    if (%total.price > 500) { %total.price = 500 }
    if ((%total.price <= 0) || (%total.price = $null)) { %total.price = 50 }

    %total.price = $calc($4 * %total.price)

    var %player.redorbs $readini($char($1), stuff, redorbs)
    inc %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs

    $display.private.message(3A shop keeper wearing a green and white bucket hat uses a special incantation to take $4 level(s) of $3 $+  from you and gives you %total.price $readini(system.dat, system, currency) $+ !)
    unset %total.price
  }
}

alias shop.skills {
  unset %shop.list.activeskills | unset %shop.list.passiveskills | unset %shop.list.resistanceskills | unset %total.passive.skills | unset %total.active.skills
  if ($2 = list) {
    ; get the list of the skills
    $shop.get.shop.level($1)

    ; CHECKING PASSIVE SKILLS
    unset %shop.list | unset %skill.list | unset %shop.list.passiveskills2 | unset %total.passive.skills
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
        if ((%total.passive.skills <= 15) || (%total.passive.skills = $null)) {  %shop.list.passiveskills = $addtok(%shop.list.passiveskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
        if (%total.passive.skills > 15) {  %shop.list.passiveskills2 = $addtok(%shop.list.passiveskills2, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
        inc %value 1 | inc %total.passive.skills 1
      }
    }

    unset %skill.list 
    set %skill.list $readini(skills.db, Skills, PassiveSkills2)
    var %number.of.items $numtok(%skill.list, 46)
    var %value 1
    while (%value <= %number.of.items) {
      set %skill.name $gettok(%skill.list, %value, 46)
      set %skill.max $readini(skills.db, %skill.name, max)
      set %skill.have $readini($char($1), skills, %skill.name)

      if (%skill.have >= %skill.max) { inc %value 1 }
      else { 
        set %skill.price $round($calc(%shop.level * $readini(skills.db, %skill.name, cost)),0)
        if ((%total.passive.skills <= 15) || (%total.passive.skills = $null)) {  %shop.list.passiveskills = $addtok(%shop.list.passiveskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
        if (%total.passive.skills > 15) {  %shop.list.passiveskills2 = $addtok(%shop.list.passiveskills2, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
        inc %value 1 | inc %total.passive.skills 1
      }
    }


    set %replacechar $chr(044) $chr(032) |  %shop.list.passiveskills = $replace(%shop.list.passiveskills, $chr(046), %replacechar) | %shop.list.passiveskills2 = $replace(%shop.list.passiveskills2, $chr(046), %replacechar)

    ; CHECKING ACTIVE SKILLS
    unset %skill.list | unset %value | unset %shop.list.activeskills2 | unset %total.active.skills
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
        if ((%total.active.skills <= 15) || (%total.active.skills = $null)) {   %shop.list.activeskills = $addtok(%shop.list.activeskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
        if (%total.active.skills > 15) {   %shop.list.activeskills2 = $addtok(%shop.list.activeskills2, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }

        inc %value 1 |  inc %total.active.skills 1
      }
    }

    unset %skill.list 
    set %skill.list $readini(skills.db, Skills, ActiveSkills2)
    var %number.of.items $numtok(%skill.list, 46)
    var %value 1
    while (%value <= %number.of.items) {
      set %skill.name $gettok(%skill.list, %value, 46)
      set %skill.max $readini(skills.db, %skill.name, max)
      set %skill.have $readini($char($1), skills, %skill.name)

      if (%skill.have >= %skill.max) { inc %value 1 }
      else { 
        set %skill.price $round($calc(%shop.level * $readini(skills.db, %skill.name, cost)),0)
        if ((%total.active.skills <= 15) || (%total.active.skills = $null)) {   %shop.list.activeskills = $addtok(%shop.list.activeskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
        if (%total.active.skills > 15) {   %shop.list.activeskills2 = $addtok(%shop.list.activeskills2, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }

        inc %value 1 |  inc %total.active.skills 1
      }
    }

    set %replacechar $chr(044) $chr(032) |  %shop.list.activeskills = $replace(%shop.list.activeskills, $chr(046), %replacechar) | %shop.list.activeskills2 = $replace(%shop.list.activeskills2, $chr(046), %replacechar)

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
    if (%shop.list.activeskills != $null) {  $display.private.message(2Active Skill Prices in $readini(system.dat, system, currency) $+ : %shop.list.activeskills) }
    if (%shop.list.activeskills2 != $null) {  $display.private.message(2 $+ %shop.list.activeskills2) }

    if (%shop.list.passiveskills != $null) {  $display.private.message(2Passive Skill Prices in $readini(system.dat, system, currency) $+ : %shop.list.passiveskills) }
    if (%shop.list.passiveskills2 != $null) {  $display.private.message(2 $+ %shop.list.passiveskills2) }

    if (%shop.list.resistanceskills != $null) {  $display.private.message(2Resistance Skill Prices in $readini(system.dat, system, currency) $+ : %shop.list.resistanceskills) }

    unset %shop.list.activeskills | unset %shop.list.passiveskills | unset %shop.list.resistanceskills | unset %shop.list.activeskills2 | unset %shop.list.passiveskills2 | unset %total.active.skills | unset %total.passives.skills
  }


  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid skill?
    if ($readini(skills.db, $3, type) = $null) { $display.private.message(4Error: Invalid . Use! !shop list skills to get a valid list) | halt }

    var %current.skilllevel $readini($char($1), skills, $3))
    inc %current.skilllevel $4
    var %max.skilllevel $readini(skills.db, $3, max)
    if (%max.skilllevel = $null) { var %max.skilllevel 100000 }
    if (%current.skilllevel > %max.skilllevel) { $display.private.message(4You cannot buy any more levels into this skill as you have already hit or will go over the max amount with this purchase amount.) | halt }

    ; do you have enough to buy it?
    var %player.redorbs $readini($char($1), stuff, redorbs)
    var %base.cost $readini(skills.db, $3, cost)

    set %total.price $shop.calculate.totalcost($1, $4, %base.cost)

    if (%player.redorbs < %total.price) { $display.private.message(4You do not have enough $readini(system.dat, system, currency) to purchase this item!) | halt }

    writeini $char($1) skills $3 %current.skilllevel

    $display.private.message(3You spend $bytes(%total.price,b)  $+ $readini(system.dat, system, currency) for + $+ $4 to your $3 skill $+ !)

    ; decrease amount of orbs you have.
    dec %player.redorbs %total.price
    writeini $char($1) stuff redorbs %player.redorbs
    $inc.redorbsspent($1, %total.price)

    ; Increase the shop level.
    $inc.shoplevel($1, $4)
  }
}

alias shop.skills.passive {
  unset %shop.list.passiveskills | unset %shop.list.passiveskills2
  ; get the list of the skills
  $shop.get.shop.level($1)

  ; CHECKING PASSIVE SKILLS
  unset %shop.list | unset %skill.list | unset %shop.list.passiveskills2 | unset %total.passive.skills
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
      if ((%total.passive.skills <= 11) || (%total.passive.skills = $null)) {  %shop.list.passiveskills = $addtok(%shop.list.passiveskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
      if (%total.passive.skills > 11) {  %shop.list.passiveskills2 = $addtok(%shop.list.passiveskills2, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
      inc %value 1 | inc %total.passive.skills 1
    }
  }
  unset %skill.list 
  set %skill.list $readini(skills.db, Skills, PassiveSkills2)
  var %number.of.items $numtok(%skill.list, 46)
  var %value 1
  while (%value <= %number.of.items) {
    set %skill.name $gettok(%skill.list, %value, 46)
    set %skill.max $readini(skills.db, %skill.name, max)
    set %skill.have $readini($char($1), skills, %skill.name)

    if (%skill.have >= %skill.max) { inc %value 1 }
    else { 
      set %skill.price $round($calc(%shop.level * $readini(skills.db, %skill.name, cost)),0)
      if ((%total.passive.skills <= 15) || (%total.passive.skills = $null)) {  %shop.list.passiveskills = $addtok(%shop.list.passiveskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
      if (%total.passive.skills > 15) {  %shop.list.passiveskills2 = $addtok(%shop.list.passiveskills2, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
      inc %value 1 | inc %total.passive.skills 1
    }
  }
  set %replacechar $chr(044) $chr(032) |  %shop.list.passiveskills = $replace(%shop.list.passiveskills, $chr(046), %replacechar) | %shop.list.passiveskills2 = $replace(%shop.list.passiveskills2, $chr(046), %replacechar)

  ; display the list with the prices.
  if (%shop.list.passiveskills != $null) {  $display.private.message(2Passive Skill Prices in $readini(system.dat, system, currency) $+ : %shop.list.passiveskills) }
  if (%shop.list.passiveskills2 != $null) { $display.private.message(2 $+ %shop.list.passiveskills2) }

  unset %shop.list.passiveskills |   unset %shop.list.passiveskills2 | unset %total.passive.skills
}

alias shop.skills.active {
  unset %shop.list.activeskills | unset %shop.list.activeskills2
  ; get the list of the skills
  $shop.get.shop.level($1)

  ; CHECKING ACTIVE SKILLS
  unset %skill.list | unset %value | unset %shop.list.activeskills2 | unset %total.active.skills
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
      if ((%total.active.skills <= 13) || (%total.active.skills = $null)) {   %shop.list.activeskills = $addtok(%shop.list.activeskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
      if (%total.active.skills > 13) {   %shop.list.activeskills2 = $addtok(%shop.list.activeskills2, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }

      inc %value 1 |  inc %total.active.skills 1
    }
  }

  unset %skill.list 
  set %skill.list $readini(skills.db, Skills, ActiveSkills2)
  var %number.of.items $numtok(%skill.list, 46)
  var %value 1
  while (%value <= %number.of.items) {
    set %skill.name $gettok(%skill.list, %value, 46)
    set %skill.max $readini(skills.db, %skill.name, max)
    set %skill.have $readini($char($1), skills, %skill.name)

    if (%skill.have >= %skill.max) { inc %value 1 }
    else { 
      set %skill.price $round($calc(%shop.level * $readini(skills.db, %skill.name, cost)),0)
      if ((%total.active.skills <= 15) || (%total.active.skills = $null)) {   %shop.list.activeskills = $addtok(%shop.list.activeskills, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }
      if (%total.active.skills > 15) {   %shop.list.activeskills2 = $addtok(%shop.list.activeskills2, $+ %skill.name $+ +1 ( $+ %skill.price $+ ),46) }

      inc %value 1 |  inc %total.active.skills 1
    }
  }

  set %replacechar $chr(044) $chr(032) |  %shop.list.activeskills = $replace(%shop.list.activeskills, $chr(046), %replacechar) | %shop.list.activeskills2 = $replace(%shop.list.activeskills2, $chr(046), %replacechar)

  ; display the list with the prices.
  if (%shop.list.activeskills != $null) {  $display.private.message(2Active Skill Prices in $readini(system.dat, system, currency) $+ : %shop.list.activeskills) }
  if (%shop.list.activeskills2 != $null) {  $display.private.message(2 $+ %shop.list.activeskills2) }

  unset %shop.list.activeskills |   unset %shop.list.activeskills2 | unset %total.active.skills
}

alias shop.skills.resists {
  unset %shop.list.resistanceskills
  ; get the list of the skills
  $shop.get.shop.level($1)

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
  if (%shop.list.resistanceskills != $null) { $display.private.message(2Resistance Skill Prices in $readini(system.dat, system, currency) $+ : %shop.list.resistanceskills) }

  unset %shop.list.resistanceskills
}

alias shop.stats {
  if ($2 = list) {
    ; get the list of all the shop items..
    $shop.get.shop.level($1)
    var %hp.price $round($calc(%shop.level * $readini(system.dat, statprices, hp)),0)
    var %tp.price $round($calc(%shop.level * $readini(system.dat, statprices, tp)),0)
    var %str.price $round($calc(%shop.level * $readini(system.dat, statprices, str)),0)
    var %def.price $round($calc(%shop.level * $readini(system.dat, statprices, def)),0)
    var %int.price $round($calc(%shop.level * $readini(system.dat, statprices, int)),0)
    var %spd.price $round($calc(%shop.level * $readini(system.dat, statprices, spd)),0)
    var %ig.price $round($calc(%shop.level * $readini(system.dat, statprices, ig)),0)

    var %player.current.hp $readini($char($1), basestats, hp)
    var %player.max.hp $readini(system.dat, system, maxHP)
    if (%player.current.hp < %player.max.hp) { 
      %shop.list = $addtok(%shop.list,HP+50 ( $+ %hp.price $+ ),46)
    }

    var %player.current.tp $readini($char($1), basestats, tp)
    var %player.max.tp $readini(system.dat, system, maxTP)
    if (%player.current.tp < %player.max.tp) {
      %shop.list = $addtok(%shop.list,TP+5 ( $+ %tp.price $+ ),46)
    }

    var %player.current.ig $readini($char($1), basestats, IgnitionGauge)
    var %player.max.ig $readini(system.dat, system, maxIG)
    if (%player.max.ig = $null) { var %player.max.ig 100 }
    if (%player.current.ig < %player.max.ig) {
      %shop.list = $addtok(%shop.list,IG [Ignition Gauge]+1 ( $+ %ig.price $+ ),46)
    }

    %shop.list = $addtok(%shop.list,Str+1 ( $+ %str.price $+ ),46)
    %shop.list = $addtok(%shop.list,Def+1 ( $+ %def.price $+ ),46)
    %shop.list = $addtok(%shop.list,Int+1 ( $+ %int.price $+ ),46)
    %shop.list = $addtok(%shop.list,Spd+1 ( $+ %spd.price $+ ),46)

    ; display the list with the prices.
    $shop.cleanlist
    $display.private.message(2Stat Prices in $readini(system.dat, system, currency) $+ : %shop.list)
  }

  if (($2 = buy) || ($2 = purchase)) {
    ; is it a valid item?
    if ($readini(system.dat, statprices, $3) = $null) { $display.private.message(4Error: Invalid stat! Use! !shop list stats to get a valid list) | halt }

    ; do you have enough to buy it?

    var %base.cost $readini(system.dat, StatPrices, $3)
    var %player.redorbs $readini($char($1), stuff, redorbs)

    set %total.price $shop.calculate.totalcost($1, $4, %base.cost)

    if ($3 = hp) {
      var %player.current.hp $readini($char($1), basestats, hp)
      if (%player.current.hp >= $readini(system.dat, system, maxHP)) { $display.private.message(4Error: You have the maximum amount of HP allowed!) | halt }
    }

    if ($3 = tp) {
      var %player.current.tp $readini($char($1), basestats, tp)
      if (%player.current.tp >= $readini(system.dat, system, maxTP)) {  $display.private.message(4Error: You have the maximum amount of TP allowed!) | halt }
    }

    if (($3 = ig) || ($3 = IgnitionGauge)) {
      var %player.current.ig $readini($char($1), basestats, IgitionGauge)
      if (%player.current.ig >= $readini(system.dat, system, maxig)) {  $display.private.message(4Error: You have the maximum amount of Ignition Gauge allowed!) | halt }
    }

    if (%player.redorbs < %total.price) { $display.private.message(4You do not have enough $readini(system.dat, system, currency) to purchase this upgrade!) | halt }

    ; if so, increase the amount and add the stat bonus
    if (($3 != IG) && ($3 != IgnitionGauge)) {  var %basestat.to.increase $readini($char($1), basestats, $3) }
    if (($3 = IG) || ($3 = IgnitionGauge)) { var %basestat.to.increase $readini($char($1), basestats, IgnitionGauge) }

    set %shop.statbonus 0

    if (($3 = str) || ($3 = def)) { set %shop.statbonus 1 }
    if (($3 = int) || ($3 = spd)) { set %shop.statbonus 1 }
    if ($3 = hp) { set %shop.statbonus 50  }
    if ($3 = tp) { set %shop.statbonus 5 }
    if (($3 = ig) || ($3 = IgnitionGauge)) { set %shop.statbonus 1 }

    %shop.statbonus = $calc(%shop.statbonus * $4)
    inc %basestat.to.increase %shop.statbonus

    if ($3 = hp) {
      if (%basestat.to.increase > $readini(system.dat, system, maxHP)) { $display.private.message(4Error: This amount will push you over the limit allowed for HP. Please lower the amount and try again.) | halt }
    }

    if ($3 = tp) {
      if (%basestat.to.increase > $readini(system.dat, system, maxTP)) {  $display.private.message(4Error: This amount will push you over the limit allowed for TP. Please lower the amount and try again.) | halt }
    }

    if (($3 = ig) || ($3 = IgnitionGauge)) {
      if (%basestat.to.increase > $readini(system.dat, system, maxIG)) { $display.private.message(4Error: This amount will push you over the limit allowed for the Ignition Gauge. Please lower the amount and try again.) | halt }
    }

    if (($3 != IG) && ($3 != IgnitionGauge)) {  writeini $char($1) basestats $3 %basestat.to.increase }
    if (($3 = IG) || ($3 = IgnitionGauge)) { writeini $char($1) basestats IgnitionGauge %basestat.to.increase }

    $fulls($1)

    $display.private.message(3You spend $bytes(%total.price,b)  $+ $readini(system.dat, system, currency) for + $+ $bytes(%shop.statbonus,b) to your $3 $+ !)

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
    $display.private.message(2New weapon prices are in Black Orbs.  Upgrades are listed in $readini(system.dat, system, currency))
    unset %shop.list | unset %upgrade.list | unset %upgrade.list2 | unset %upgrade.list3
    ; get the list of the weapons.
    $shop.get.shop.level($1)

    ; CHECKING H2H
    unset %shop.list | unset %weapon.list
    set %weapon.list $readini(weapons.db, Weapons, HandToHand)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) { 
        set %weapon.level $readini($char($1), weapons, %weapon.name)
        if (%weapon.level < 500) { 
          set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
          %upgrade.list = $addtok(%upgrade.list, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        }
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Hand to Hand Weapons: %shop.list)
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
        set %weapon.level $readini($char($1), weapons, %weapon.name)
        if (%weapon.level < 500) { 
          set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
          %upgrade.list = $addtok(%upgrade.list, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        }
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Sword Weapons: %shop.list)
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
        set %weapon.level $readini($char($1), weapons, %weapon.name)
        if (%weapon.level < 500) { 
          set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
          %upgrade.list = $addtok(%upgrade.list, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        }
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Whip Weapons: %shop.list)
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
        set %weapon.level $readini($char($1), weapons, %weapon.name)
        if (%weapon.level < 500) { 
          set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
          %upgrade.list = $addtok(%upgrade.list, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        }
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Gun Weapons:  %shop.list)
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
        set %weapon.level $readini($char($1), weapons, %weapon.name)
        if (%weapon.level < 500) { 
          set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
          %upgrade.list2 = $addtok(%upgrade.list2, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        }
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Rifle Weapons:  %shop.list)
    }

    unset %shop.list

    ; CHECKING Bows
    unset %weapon.list
    set %weapon.list $readini(weapons.db, Weapons, Bows)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) {
        set %weapon.level $readini($char($1), weapons, %weapon.name)
        if (%weapon.level < 500) { 
          set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
          %upgrade.list2 = $addtok(%upgrade.list2, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        }
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Bow Weapons:  %shop.list)
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
        set %weapon.level $readini($char($1), weapons, %weapon.name)
        if (%weapon.level < 500) { 
          set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
          %upgrade.list2 = $addtok(%upgrade.list2, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        }
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Katana Weapons:  %shop.list)
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
        set %weapon.level $readini($char($1), weapons, %weapon.name)
        if (%weapon.level < 500) { 
          set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
          %upgrade.list2 = $addtok(%upgrade.list2, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        }
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Wand/Staff/Glyph Weapons:  %shop.list)
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
        set %weapon.level $readini($char($1), weapons, %weapon.name)
        if (%weapon.level < 500) { 
          set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
          %upgrade.list2 = $addtok(%upgrade.list2, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        }
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Spear Weapons: %shop.list)
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
        set %weapon.level $readini($char($1), weapons, %weapon.name)
        if (%weapon.level < 500) { 
          set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
          %upgrade.list2 = $addtok(%upgrade.list2, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        }
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Scythe Weapons: %shop.list)
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
        set %weapon.level $readini($char($1), weapons, %weapon.name)
        if (%weapon.level < 500) { 
          set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
          %upgrade.list3 = $addtok(%upgrade.list3, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        }
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Great Sword Weapons: %shop.list)
    }

    unset %shop.list

    ; CHECKING Axes
    unset %weapon.list
    set %weapon.list $readini(weapons.db, Weapons, Axes)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) {
        set %weapon.level $readini($char($1), weapons, %weapon.name)
        if (%weapon.level < 500) { 
          set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
          %upgrade.list3 = $addtok(%upgrade.list3, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        }
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Axe Weapons: %shop.list)
    }

    unset %shop.list

    ; CHECKING Daggers
    unset %weapon.list
    set %weapon.list $readini(weapons.db, Weapons, Daggers)
    var %number.of.items $numtok(%weapon.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %weapon.name $gettok(%weapon.list, %value, 46)
      ; Does the player own this weapon?  If so, add it to the upgrade list.  If not,add it to the new weapon list.
      if ($readini($char($1), weapons, %weapon.name) != $null) {
        set %weapon.level $readini($char($1), weapons, %weapon.name)
        if (%weapon.level < 500) { 
          set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
          %upgrade.list3 = $addtok(%upgrade.list3, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        }
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Dagger Weapons: %shop.list)
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
        set %weapon.level $readini($char($1), weapons, %weapon.name)
        if (%weapon.level < 500) { 
          set %weapon.price $round($calc(%shop.level * $readini(weapons.db, %weapon.name, upgrade)),0)
          %upgrade.list3 = $addtok(%upgrade.list3, $+ %weapon.name $+ +1 ( $+ %weapon.price $+ ),46)
        }
        inc %value 1 
      }
      else {  
        set %weapon.price $readini(weapons.db, %weapon.name, cost)
        %shop.list = $addtok(%shop.list, $+ %weapon.name $+  ( $+ %weapon.price $+ ),46)
        inc %value 1 
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New Glyph Weapons: %shop.list)
    }

    unset %shop.list |  unset %weapon.level

    if (((%upgrade.list != $null) || (%upgrade.list2 != $null) || (%upgrade.list3 != $null))) {  
      $display.private.message(2Weapons you can upgrade:)
      set %replacechar $chr(044) $chr(032) 
      if (%upgrade.list != $null) {
        %upgrade.list = $replace(%upgrade.list, $chr(046), %replacechar)
        $display.private.message(2 $+ %upgrade.list)
      }
      if (%upgrade.list2 != $null) {
        %upgrade.list2 = $replace(%upgrade.list2, $chr(046), %replacechar)
        $display.private.message(2 $+ %upgrade.list2)
      }
      if (%upgrade.list3 != $null) {
        %upgrade.list3 = $replace(%upgrade.list3, $chr(046), %replacechar)
        $display.private.message(2 $+ %upgrade.list3)
      }

      unset %upgrade.list | unset %upgrade.list2 | unset %upgrade.list3

    }
  }
  if (($2 = buy) || ($2 = purchase)) {
    if ($readini(weapons.db, $3, type) = $null) { $display.private.message(4Error: Invalid weapon! Use! !shop list weapons to get a valid list ) | halt }
    if ($readini(weapons.db, $3, cost) = 0) { $display.private.message(4Error: You cannot purchase this weapon!) | halt }
    var %weapon.level $readini($char($1), weapons, $3)
    if (%weapon.level != $null) { 

      if (%weapon.level >= 500) {  $display.private.message(4You cannot buy any more levels into this weapon.) | halt }

      ; do you have enough to buy it?
      var %player.redorbs $readini($char($1), stuff, redorbs)
      var %base.cost $readini(weapons.db, $3, upgrade)
      set %total.price $shop.calculate.totalcost($1, $4, %base.cost)
      if (%player.redorbs < %total.price) { $display.private.message(4You do not have enough $readini(system.dat, system, currency) to purchase this weapon upgrade!) | halt }
      dec %player.redorbs %total.price
      $inc.redorbsspent($1, %total.price)
      inc %weapon.level $4

      if (%weapon.level > 500) {   $display.private.message(4Purchasing this amount will put you over the max limit. Please lower the amount and try again.) | halt }

      writeini $char($1) stuff redorbs %player.redorbs
      writeini $char($1) weapons $3 %weapon.level
      $display.private.message(3You spend $bytes(%total.price,b)  $+ $readini(system.dat, system, currency) to upgrade your $3 $+ !)
      $inc.shoplevel($1, $4)
      halt
    }
    else {
      ; do you have enough to buy it?
      var %player.blackorbs $readini($char($1), stuff, blackorbs) 
      var %total.price $readini(weapons.db, $3, cost)
      if (%player.blackorbs < %total.price) { $display.private.message(4You do not have enough black orbs to purchase this item!) | halt }
      dec %player.blackorbs %total.price
      writeini $char($1) stuff blackorbs %player.blackorbs
      $inc.blackorbsspent($1, %total.price)
      writeini $char($1) weapons $3 1
      $display.private.message(3You spend %total.price black orb(s) to purchase $3 $+ !)
      halt
    }
  }
}

alias shop.styles {
  if ($2 = list) {
    $display.private.message(2New style prices are in Black Orbs.)
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
      $display.private.message(2New Styles: %shop.list)
    }

    if (%shop.list = $null) { $display.private.message(4There are no more styles for you to purchase at this time.) | halt }

    unset %shop.list
  }
  if (($2 = buy) || ($2 = purchase)) {
    if ($readini(playerstyles.lst, costs, $3) = $null) { $display.private.message(4Error: Invalid style! Use !shop list styles to get a valid list) | halt }
    if ($readini(playerstyles.lst, costs, $3) = 0) { $display.private.message(4Error: You cannot purchase this style! Use !shop list styles to get a valid list) | halt }
    var %style.level $readini($char($1), styles, $3)
    ; do you have enough to buy it?
    var %player.blackorbs $readini($char($1), stuff, blackorbs) 
    var %total.price $readini(playerstyles.lst, costs, $3)
    if (%player.blackorbs < %total.price) { $display.private.message(4You do not have enough black orbs to purchase this item!) | halt }
    dec %player.blackorbs %total.price
    writeini $char($1) stuff blackorbs %player.blackorbs
    $inc.blackorbsspent($1, %total.price)
    writeini $char($1) styles $3 1
    writeini $char($1) styles $3 $+ XP 0
    $display.private.message(3You spend %total.price black orb(s) to purchase $3 $+ !)
    unset %styles.list | unset %style.name | unset %style.level | unset %style.price | unset %styles
    halt
  }
}

alias shop.ignitions {
  if ($2 = list) {
    $display.private.message(2New ignition prices are in Black Orbs.)
    unset %shop.list | unset %upgrade.list
    ; get the list of the ignitions
    unset %shop.list | unset %ignitions.list
    set %ignitions.list $readini(ignitions.db, ignitions, List)
    var %number.of.items $numtok(%ignitions.list, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %ignition.name $gettok(%ignitions.list, %value, 46)
      ; Does the player own this ignition? 
      set %player.ignition.level $readini($char($1), ignitions, %ignition.name)
      if ((%player.ignition.level = $null) || (%player.ignition.level <= 0)) {
        set %ignition.price $readini(ignitions.db, %ignition.name, cost)
        if (%ignition.price > 0) { %shop.list = $addtok(%shop.list, $+ %ignition.name $+  ( $+ %ignition.price $+ ),46) }
        inc %value 1 
      }
      else {  
        inc %value 1
      }
    }

    if (%shop.list != $null) {  $shop.cleanlist 
      $display.private.message(2New ignitions: %shop.list)
    }

    if (%shop.list = $null) { $display.private.message(4There are no more ignitions for you to purchase.) | halt }

    unset %shop.list
  }
  if (($2 = buy) || ($2 = purchase)) {
    if ($readini(ignitions.db, $3, cost) = $null) { $display.private.message(4Error: Invalid ignition! Use !shop list ignitions to get a valid list) | halt }
    if ($readini(ignitions.db, $3, cost) = 0) { $display.private.message(4Error: You cannot purchase this ignition! Use !shop list ignitions to get a valid list) | halt }
    var %ignition.level $readini($char($1), ignitions, $3)
    ; do you have enough to buy it?
    var %player.blackorbs $readini($char($1), stuff, blackorbs) 
    var %total.price $readini(ignitions.db, $3, cost)
    if (%player.blackorbs < %total.price) { $display.private.message(4You do not have enough black orbs to purchase this item!) | halt }
    dec %player.blackorbs %total.price
    writeini $char($1) stuff blackorbs %player.blackorbs
    $inc.blackorbsspent($1, %total.price)
    writeini $char($1) ignitions $3 1
    $display.private.message(3You spend %total.price black orb(s) to purchase $3 $+ !)
    unset %ignitions.list | unset %ignition.name | unset %ignition.level | unset %ignition.price | unset %ignitions
    halt
  }
}

alias shop.portal {
  if ($2 = list) {
    unset %shop.list | unset %item.name | unset %item_amount | unset portals.bstmen | unset %portals.kindred

    unset %item.name | unset %item_amount | unset %number.of.items | unset %value
    var %portal.items $readini(items.db, items, PortalItems)
    var %number.of.items $numtok(%portal.items, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %item.name $gettok(%portal.items, %value, 46)
      set %item_amount $readini(items.db, %item.name, cost)
      if ((%item_amount != $null) && (%item_amount >= 1)) { 
        ; add the item and the amount to the item list

        if ($readini(items.db, %item.name, currency) = BeastmenSeal) { 
          var %item_to_add 14 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
          %shop.list = $addtok(%shop.list,%item_to_add,46)

        }
      }
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist | set %portals.bstmen %shop.list  }

    if (%portals.bstmen != $null) {  $display.private.message(2These portal items are paid for with BeastmenSeals: %portals.bstmen)  }

    unset %shop.list | unset %item.name | unset %item_amount

    unset %item.name | unset %item_amount | unset %number.of.items | unset %value
    var %portal.items $readini(items.db, items, PortalItems)
    var %number.of.items $numtok(%portal.items, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %item.name $gettok(%portal.items, %value, 46)
      set %item_amount $readini(items.db, %item.name, cost)
      if ((%item_amount != $null) && (%item_amount >= 1)) { 
        ; add the item and the amount to the item list

        if ($readini(items.db, %item.name, currency) = KindredSeal) { 
          var %item_to_add 14 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
          %shop.list = $addtok(%shop.list,%item_to_add,46)
        }
      }
      inc %value 1 
    }

    if (%shop.list != $null) {  $shop.cleanlist | set %portals.kindred %shop.list  }

    if (%portals.kindred != $null) {  $display.private.message(2These portal items are paid for with KindredSeals: %portals.kindred)  }

    if (%portals.kindred = $null) && (%portals.bstmen = $null) { $display.private.message(4There are no portal items available for purchase right now)  }

    unset %shop.list
  }
  if (($2 = buy) || ($2 = purchase)) {
    if ($readini(items.db, $3, cost) = $null) {  $display.private.message(4Error: Invalid portal item! Use !shop list portal to get a valid list) | halt }
    if ($readini(items.db, $3, cost) = 0) { $display.private.message(4Error: You cannot purchase this portal item! Use !shop list portal to get a valid list) | halt }

    set %currency $readini(items.db, $3, currency)  

    ; do you have enough to buy it?
    set %player.currency $readini($char($1), item_amount, %currency)
    set %total.price $calc($readini(items.db, $3, cost) * $4)

    if (%player.currency = $null) { set %player.currency 0 }

    if (%player.currency < %total.price) {  $display.private.message(4You do not have enough %currency $+ s to purchase $4 of this item!) | unset %currency | unset %player.currency | unset %total.price |  halt }
    dec %player.currency %total.price
    writeini $char($1) item_amount %currency %player.currency
    var %item.amount $readini($char($1), item_amount, $3)
    if (%item.amount = $null) { var %item.amount 0 }
    inc %item.amount $4
    writeini $char($1) item_amount $3 %item.amount
    $display.private.message(3A strange merchant by the name of Shami takes %total.price %currency $+ s and trades it for $4 $3 $+ (s)!  "Thank you for your patronage. (heh heh heh, sucker)")
    unset %shop.list | unset %currency | unset %player.currency | unset %total.price
    halt
  }
}

alias shop.alchemy {
  if ($2 = list) {
    unset %shop.list | unset %item.name | unset %item_amount | unset %gems | unset %misc

    unset %item.name | unset %item_amount | unset %number.of.items | unset %value
    var %misc.items $readini(items.db, items, Misc)
    var %number.of.items $numtok(%misc.items, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %item.name $gettok(%misc.items, %value, 46)
      set %item_amount $readini(items.db, %item.name, cost)
      if ((%item_amount != $null) && (%item_amount >= 1)) { 
        ; add the item and the amount to the item list

        if ($readini(items.db, %item.name, currency) = AlliedNotes) { 
          var %item_to_add %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
          %shop.list = $addtok(%shop.list,%item_to_add,46)
        }
      }
      inc %value 1 
    }


    if (%shop.list != $null) {  $shop.cleanlist | set %misc %shop.list  }

    unset %shop.list | unset %item.name | unset %item_amount

    unset %item.name | unset %item_amount | unset %number.of.items | unset %value
    var %gem.items $readini(items.db, items, Gems)
    var %number.of.items $numtok(%gem.items, 46)

    var %value 1
    while (%value <= %number.of.items) {
      set %item.name $gettok(%gem.items, %value, 46)
      set %item_amount $readini(items.db, %item.name, cost)
      if ((%item_amount != $null) && (%item_amount >= 1)) { 
        ; add the item and the amount to the item list

        if ($readini(items.db, %item.name, currency) = AlliedNotes) { 
          var %item_to_add 7 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041) 
          %shop.list = $addtok(%shop.list,%item_to_add,46)
        }
      }
      inc %value 1 
    }

    if (%shop.list != $null) { $shop.cleanlist | set %gems %shop.list  }

    if ((%misc != $null) || (%gems != $null)) { 
      $display.private.message(2These items are paid for with Allied Notes:)
      if (%misc != $null) { $display.private.message(%misc) }
      if (%gems != $null) { $display.private.message(%gems) }
    }

    if (%misc = $null) && (%gems = $null) {  $display.private.message(4There are no items available for purchase right now)  }

    unset %shop.list | unset %misc | unset %gems
  }

  if (($2 = buy) || ($2 = purchase)) {
    if ($readini(items.db, $3, cost) = $null) { $display.private.message(4Error: Invalid item! Use !shop list alchemy to get a valid list) | halt }
    if ($readini(items.db, $3, cost) = 0) { $display.private.message(4Error: You cannot purchase this item! Use !shop list alchemy to get a valid list) | halt }

    ; do you have enough to buy it?

    if ($readini(items.db, $3, currency) != AlliedNotes) {  $display.private.message(4You cannot buy this item in this shop.) | halt }

    set %player.currency $readini($char($1), stuff, alliednotes)
    set %total.price $calc($readini(items.db, $3, cost) * $4)

    if (%player.currency = $null) { set %player.currency 0 }

    if (%player.currency < %total.price) {  $display.private.message(4You do not have enough Allied Notes to purchase $4 of this item!) | unset %currency | unset %player.currency | unset %total.price |  halt }
    dec %player.currency %total.price
    writeini $char($1) stuff AlliedNotes %player.currency

    var %item.amount $readini($char($1), item_amount, $3)
    if (%item.amount = $null) { var %item.amount 0 }
    inc %item.amount $4
    writeini $char($1) item_amount $3 %item.amount
    $display.private.message(3A merchant of the Allied Forces takes your %total.price Allied Notes and gives you $4 $3 $+ (s)!)
    unset %shop.list | unset %currency | unset %player.currency | unset %total.price
    halt
  }

}


alias shop.orbs {
  if ($2 = list) { $display.private.message(2You can exchange 1 black orb for 500 $readini(system.dat, system, currency) $+ .  To do so, use the command: !shop buy orbs)  }

  if (($2 = buy) || ($2 = purchase)) {
    ; do you have enough to buy it?
    %total.price = $calc($3 * 1)

    var %player.blackorbs $readini($char($1), stuff, blackorbs)
    if (%player.blackorbs < %total.price) {  $display.private.message(4You do not have enough black orbs to do the exchange!) | halt }

    ; if so, increase the amount
    var %player.redorbs $readini($char($1), stuff, redorbs)
    var %orb.increase.amount $calc(500 * $3)
    inc %player.redorbs %orb.increase.amount
    dec %player.blackorbs %total.price
    $inc.blackorbsspent($1, %total.price)
    writeini $char($1) stuff redorbs %player.redorbs
    writeini $char($1) stuff blackorbs %player.blackorbs

    $display.private.message(3You spend %total.price black orb(s) for  $+ %orb.increase.amount $readini(system.dat, system, currency) $+ !)
    halt
  }
}
alias inc.shoplevel {   
  var %shop.level $readini($char($1), stuff, shoplevel) 
  if (($2 = $null) || ($2 <= 0)) { var %amount.to.increase .1 }
  if ($2 != $null) && ($2 > 0)) { var %amount.to.increase $calc(.1 * $2) }
  inc %shop.level %amount.to.increase 
  var %max.shop.level $readini(system.dat, system, maxshoplevel)
  if (%max.shop.level = $null) { var %max.shop.level 25 }

  if (%shop.level >= %max.shop.level) { writeini $char($1) stuff shoplevel %max.shop.level |  $display.private.message(2Your Shop Level has been capped at %max.shop.level)  }
  else { 
    writeini $char($1) stuff shoplevel %shop.level  
    $display.private.message(2Your Shop Level has been increased to %shop.level)
  }
  $achievement_check($1, Don'tYouHaveaHome)
  unset %shop.level

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
  $achievement_check($1, BigSpender)
  $achievement_check($1, BattleArenaAnon)
  $achievement_check($1, Don'tForgetYourFriendsAndFamily)
  return
}
alias inc.blackorbsspent {
  var %orbs.spent $readini($char($1), stuff, BlackOrbsSpent)
  inc %orbs.spent $2
  writeini $char($1) stuff BlackOrbsSpent %orbs.spent

  $achievement_check($1, BossKiller)
  return
}

alias shop.calculate.totalcost {
  var %value 1
  var %total.price.calculate 0
  set %shop.level $readini($char($1), stuff, shoplevel)
  var %max.shoplevel $readini(system.dat, system, Maxshoplevel)

  set %current.accessory $readini($char($3), equipment, accessory)
  set %current.accessory.type $readini(items.db, %current.accessory, accessorytype)

  while (%value <= $2) {
    set %true.shop.level %shop.level

    ; Check for the  VIP-MemberCard accessory
    if (%current.accessory.type = ReduceShopLevel) {
      var %accessory.amount $readini(items.db, %current.accessory, amount)
      dec %true.shop.level %accessory.amount
    }

    if (%true.shop.level < 1) { set %true.shop.level 1.0 }

    inc %total.price.calculate $round($calc(%true.shop.level * $3),0)

    if (%max.shoplevel = $null) { var %max.shoplevel 25 }
    if (%shop.level < %max.shoplevel) {  inc %shop.level .1 }
    inc %value 1
  }
  unset %true.shop.level
  return %total.price.calculate
}


alias shop.get.shop.level {
  set %shop.level $readini($char($1), stuff, shoplevel)

  ; Check for the  VIP-MemberCard accessory
  if ($readini($char($1), equipment, accessory) = VIP-MemberCard) {
    var %accessory.amount $readini(items.db, VIP-MemberCard, amount)
    dec %shop.level %accessory.amount
  }

  if (%shop.level < 1) { set %shop.level 1.0 }
}
