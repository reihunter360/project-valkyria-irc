ON 1:TEXT:!help*:*: { $gamehelp($2, $nick) }
alias gamehelp { 
  set %help.topics $readini %help_folder $+ topics.help Help List | set %help.topics2 $readini %help_folder $+ topics.help Help List2 | set %help.topics3 $readini %help_folder $+ topics.help Help List3
  if ($1 = $null) {  .msg $2 14::[Current Help Topics]::  | .msg $nick 2 $+ %help.topics | .msg $nick 2 $+ %help.topics2 | unset %help.topics | unset %help.topics2 | .msg $nick 14::[Type !help <topic> (without the <>) to view the topic]:: | halt }
  if ($1 isin %help.topics) || ($1 isin %help.topics2) || ($1 isin %help.topics3) {  set %topic %help_folder $+ $1 $+ .help |  set %lines $lines(%topic) | set %l 0 | goto help }
  else { .msg $2 3The Librarian searchs through the ancient texts but returns with no results for your inquery!  Please try again | halt }
  :help
  inc %l 1
  if (%l <= %lines) {  /.timerHelp $+ $1 $+ $rand(a,z) $+ $rand(1,1000) 1 1 /.msg $2 $read(%topic, %l) | goto help  }
  else { goto endhelp }
  :endhelp
  unset %topic | unset %help.topics | unset %help.topics2 | unset %lines | unset %l | unset %help
}

ON 1:TEXT:!view-info*:*: { 
  if ($2 = $null) { query $nick 4Error: The command is missing what you want to view.  Use it like:  !view-info <tech, item, skill, weapon, armor, accessory, ignition> <name> (and remember to remove the < >) | halt }
  if ($3 = $null) { query $nick 4Error: The command is missing the name of what you want to view.   Use it like:  !view-info <tech, item, skill, weapon, armor, accessory, ignition> <name> (and remember to remove the < >) | halt }

  if ($2 = tech) { 
    if ($readini(techniques.db, $3, type) = $null) { query $nick 4Error: Invalid technique | halt }
    var %info.type $readini(techniques.db, $3, type) |   var %info.tp $readini(techniques.db, $3, TP)
    var %info.basePower $readini(techniques.db, $3, BasePower) | var %info.basecost $readini(techniques.db, $3, Cost)
    var %info.element $readini(techniques.db, $3, Element)
    var %info.ignoredef $readini(techniques.db, $3, IgnoreDefense)
    var %info.hits $readini(techniques.db, n, $3, hits)
    if (%info.hits = $null) { var %info.hits 1 }
    if ($readini(techniques.db, $3, magic) = yes) { var %info.magic  [4Magic12 Yes $+ 1] }
    if ($readini(techniques.db, $3, type) = status) { var %info.statustype [4Stats Type12 $readini(techniques.db, $3, StatusType) $+ 1] }

    if (%info.ignoredef != $null) { var %info.ignoredefense  [4Ignore Target Defense by12 %info.ignoredef $+ $chr(37) $+ 1] }

    .msg $nick [4Name12 $3 $+ 1] [4Target Type12 %info.type $+ 1] [4TP needed to use12 %info.tp $+ 1]  [4# of Hits12 %info.hits $+ 1] %info.statustype %info.magic %info.ignoredefense
    .msg $nick [4Base Power12 %info.basepower $+ 1] [4Base Cost (before Shop Level)12 %info.basecost red orbs1] [4Element of Tech12 %info.element $+ 1] 

    if (%info.type = FinalGetsuga) { .msg $nick $readini(translation.dat, system, FinalGetsugaWarning) }
  }

  if ($2 = ignition) { 
    if ($readini(ignitions.db, $3, name) = $null) { query $nick 4Error: Invalid ignition | halt }
    var %info.name $readini(ignitions.db, $3, name)
    var %info.augment $readini(ignitions.db, $3, Augment)
    var %info.effect $readini(ignitions.db, $3, Effect)
    if (%info.effect = status) { var %info.status.type ( $+ $readini(ignitions.db, $3, StatusType) $+ ) }
    var %info.trigger $readini(ignitions.db, $3, IgnitionTrigger)
    var %info.consume $readini(ignitions.db, $3, IgnitionConsume)
    var %info.hp $readini(ignitions.db, $3, hp)
    var %info.str $readini(ignitions.db, $3, str)
    var %info.def $readini(ignitions.db, $3, def)
    var %info.int $readini(ignitions.db, $3, int)
    var %info.spd $readini(ignitions.db, $3, spd)


    if ($chr(046) isin %info.augment) { set %replacechar $chr(044) $chr(032)
      %info.augment = $replace(%info.augment, $chr(046), %replacechar)
    }

    .msg $nick [4Name12 %info.name $+ 1] [4Amount of Ignition Gauge Consumed Upon Use12 %info.trigger $+ 1] [4Amount of Ignition Gauge Needed Each Round12 %info.consume $+ 1] [4Bonus Augment12 %info.augment $+ 1] [4Trigger Effect12 %info.effect %info.status.type $+ 1]   
    .msg $nick [4Stat Multipliers $+ 1] 4Health x12 %info.hp  $+ $chr(124) 4 $+ Strength x12 %info.str  $+ $chr(124) 4 $+ Defense x12 %info.def  $+ $chr(124) 4Intelligence x12 %info.int  $+ $chr(124) 4Speed x12 %info.spd
  }

  if ($2 = accessory) { 
    if ($readini(items.db, $3, type) = $null) { query $nick 4Invalid item | halt }
    .msg $nick [4Name12 $3 $+ 1] [4Type12 Accessory $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1] 
  }
  if ($2 = gem) { 
    if ($readini(items.db, $3, type) = $null) { query $nick 4Invalid item | halt }
    .msg $nick [4Name12 $3 $+ 1] [4Type12 Gem $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1] 
  }

  if ($2 = key) { 
    if ($readini(items.db, $3, type) = $null) { query $nick 4Invalid item | halt }
    .msg $nick [4Name12 $3 $+ 1] [4Type12 Key $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1] 
  }

  if ($2 = rune) { 
    if ($readini(items.db, $3, augment) = $null) { query $nick 4Invalid item | halt }
    .msg $nick [4Name12 $3 $+ 1] [4Type12 Rune $+ 1] [4Augment12 $readini(items.db, $3, augment) $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1] 
  }

  if ($2 = item) { 

    unset %info.fullbring
    if ($readini(items.db, $3, type) = $null) { query $nick 4Invalid item | halt }
    var %info.type $readini(items.db, $3, type) | var %info.amount $readini(items.db, $3, amount)
    var %info.cost $bytes($readini(items.db, $3, cost),b) | var %info.element $readini(items.db, $3, element)
    var %info.target $readini(items.db, $3, target)
    var %info.fullbring $readini(items.db, $3, fullbringlevel)
    var %info.status $readini(items.db, $3, statustype) | var %info.amount $readini(items.db, $3, amount)
    if (%info.fullbring != $null) { set %info.fullbringmsg  [4Fullbring Level12 %info.fullbring $+ 1] } 
    if (%info.target = AOE-monster) { var %info.target All monsters }

    if (%info.type = heal) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Healing $+ 1] [4Heal Amount12 %info.amount $+ 1]  [4Item Cost12 %info.cost red orbs1] %info.fullbringmsg }
    if (%info.type = IgnitionGauge) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Ignition Gauge Restore $+ 1] [4Restore Amount12 %info.amount $+ 1]  [4Item Cost12 %info.cost red orbs1] %info.fullbringmsg }
    if (%info.type = Damage) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Damage $+ 1] [4Target12 %info.target $+ 1]  [4Damage Amount12 %info.amount $+ 1] [4Item Cost12 %info.cost red orbs1] %info.fullbringmsg  }
    if (%info.type = Status) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Status $+ 1] [4Target12 %info.target $+ 1]  [4Damage Amount12 %info.amount $+ 1] [4Status Type12 %info.status $+ 1] [4Item Cost12 %info.cost red orbs1] %info.fullbringmsg }
    if (%info.type = Food) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Stat Increase $+ 1] [4Stat to Increase12 %info.target $+ 1] [4Increase Amount12 $chr(43) $+ %info.amount $+ 1]   }
    if (%info.type = Consume) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Skill Consumable $+ 1] [4Skill That Uses This Item12 $readini(items.db, $3, skill) $+ 1] [4Item Cost12 %info.cost red orbs1]    }
    if (%info.type = Summon) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Summon $+ 1] [4This item summons12 $readini(items.db, $3, summonname) 4to fight with you $+ 1] [4Item Cost12 %info.cost red orbs1]    }
    if (%info.type = ShopReset) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Shop Level Change $+ 1] [4When used this item reduces your shop level by %info.amount $+ 1] [4Item Cost12 %info.cost red orbs1]    }
    if (%info.type = tp) { .msg $nick [4Name12 $3 $+ 1] [4Type12 TP Restore $+ 1] [4TP Restored Amount12 %info.amount $+ 1]  [4Item Cost12 %info.cost red orbs1] %info.fullbringmsg }
    if (%info.type = CureStatus) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Cure Status $+ 1] [4Item Cost12 %info.cost red orbs1] [4Note12 This item will not cure Charm or Intimidation $+ 1] %info.fullbringmsg }
    if (%info.type = accessory) {  .msg $nick [4Name12 $3 $+ 1] [4Type12 Accessory $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1]  }
    if (%info.type = revive) {  .msg $nick [4Name12 $3 $+ 1] [4Type12 Automatic Revival $+ 1] [4Description12 When used this item will activate the "Automatic Revive" status.  If you die in battle, you will be revived with 1/2 HP.  $+ 1]  }
    if (%info.type = key) {  .msg $nick [4Name12 $3 $+ 1] [4Type12 Key $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1]  }
    if (%info.type = gem) {  .msg $nick [4Name12 $3 $+ 1] [4Type12 Gem $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1]  }
    if (%info.type = misc) {  .msg $nick [4Name12 $3 $+ 1] [4Type12 Crafting Ingredient $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1]  }
    if (%info.type = trade) {  .msg $nick [4Name12 $3 $+ 1] [4Type12 Trading Item $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1]  }
    if (%info.type = random) {  .msg $nick [4Name12 $3 $+ 1] [4Type12 Random item inside! $+ 1] }
    if (%info.type = rune) { 
      if ($readini(items.db, $3, augment) = $null) { query $nick 4Invalid item | halt }
      .msg $nick [4Name12 $3 $+ 1] [4Type12 Rune $+ 1] [4Augment12 $readini(items.db, $3, augment) $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1] 
    }
    unset %info.fullbringmsg
  }
  if (%info.type = portal) {  .msg $nick [4Name12 $3 $+ 1] [4Type12 Portal $+ 1] [4Lair12 $readini(items.db, $3, Battlefield) $+ 1] [4Description12 This item will teleport all players on the battlefield through a portal to the lair of a strong boss! $+ 1]  }



  if ($2 = skill) { 
    if ($readini(skills.db, $3, type) = $null) { query $nick 4Invalid skill  | halt }
    var %info.type $readini(skills.db, $3, type) | var %info.desc $readini(skills.db, $3, info)
    var %info.cost $readini(skills.db, $3, cost) | var %info.maxlevel $readini(skills.db, $3, max)
    .msg $nick [4Name12 $3 $+ 1] [4Skill Type12 %info.type $+ 1] [4Base Cost (before shop level)12 %info.cost $+ 1] [4Max Level12 %info.maxlevel $+ 1] 
    .msg $nick [4Skill Info12 %info.desc $+ 1]
  }


  if ($2 = armor) { 
    if ($readini(equipment.db, $3, name) = $null) { query $nick 4Error: Invalid Armor | halt }
    var %info.name $readini(equipment.db, $3, name)
    var %info.augment $readini(equipment.db, $3, Augment)
    var %info.hp $readini(equipment.db, $3, hp)
    var %info.tp $readini(equipment.db, $3, tp)
    var %info.str $readini(equipment.db, $3, str)
    var %info.def $readini(equipment.db, $3, def)
    var %info.int $readini(equipment.db, $3, int)
    var %info.spd $readini(equipment.db, $3, spd)
    var %info.location $readini(equipment.db, $3, EquipLocation)

    if ($chr(046) isin %info.augment) { set %replacechar $chr(044) $chr(032)
      %info.augment = $replace(%info.augment, $chr(046), %replacechar)
    }

    .msg $nick [4Name12 %info.name $+ 1] [4Armor Location12 %info.location $+ 1]  [4Armor Augment12 %info.augment $+ 1] 
    .msg $nick [4Stats on Armor $+ 1] 4Health12 %info.hp  $+ $chr(124) 4TP12 %info.tp   $+ $chr(124) 4 $+ Strength12 %info.str  $+ $chr(124) 4 $+ Defense12 %info.def  $+ $chr(124) 4Intelligence12 %info.int  $+ $chr(124) 4Speed12 %info.spd
    if (%info.augment = AutoReraise) { .msg $nick 4The Auto Reraise Augment only works if you have 5 pieces of armor that all have the same augment.  In other words, the augment strength must be at least 5 in order to work } 
  }


  if ($2 = weapon ) {
    if ($readini(weapons.db, $3, type) = $null) { query $nick 4Invalid weapon | halt }
    var %info.type $readini(weapons.db, $3, type) | var %info.hits $readini(weapons.db, n, $3, hits)
    var %info.basePower $readini(weapons.db, $3, BasePower) | var %info.basecost $readini(weapons.db, $3, Cost)
    var %info.element $readini(weapons.db, $3, Element) | var %info.abilities $readini(weapons.db, $3, abilities)
    var %info.ignoredef $readini(techniques.db, $3, IgnoreDefense)

    if ($chr(046) isin %info.abilities) { set %replacechar $chr(044) $chr(032)
      %info.abilities = $replace(%info.abilities, $chr(046), %replacechar)
    }

    if (%info.ignoredef != $null) { var %info.ignoredefense  [4Ignore Target Defense by12 %info.ignoredef $+ $chr(37) $+ 1] }

    .msg $nick [4Name12 $3 $+ 1] [4Weapon Type12 %info.type $+ 1] [4# of Hits12 %info.hits $+ 1] 
    .msg $nick [4Base Power12 %info.basepower $+ 1] [4Cost12 %info.basecost black orb(s)1] [4Element of Weapon12 %info.element $+ 1] 
    .msg $nick [4Abilities of the Weapon12 %info.abilities $+ 1] %info.ignoredefense
    .msg $nick [4Weapon Description12 $readini(weapons.db, $3, Info) $+ 1]
  }

  if ($2 = alchemy) {

    if ($3 = list) { 
      var %crafted.items $readini(items.db, items, crafteditems)
      var %crafted.armor $readini(items.db, items, craftedArmor)

      if ($chr(046) isin %crafted.items) { set %replacechar $chr(044) $chr(032)
        %crafted.items = $replace(%crafted.items, $chr(046), %replacechar)
      }
      if ($chr(046) isin %crafted.armor) { set %replacechar $chr(044) $chr(032)
        %crafted.armor = $replace(%crafted.armor, $chr(046), %replacechar)
      }
      if (%crafted.items != $null) { .msg $nick 3Items that can be crafted: %crafted.items }
      if (%crafted.armor != $null) { .msg $nick 3Armor that can be crafted: %crafted.armor }

      halt
    }


    var %gem.required $readini(crafting.db, $3, gem)
    if (%gem.required = $null) { .msg $nick $readini(translation.dat, errors, CannotCraftThisItem) | halt }

    var %ingredients $readini(crafting.db, $3, ingredients)
    var %base.success $readini(crafting.db, $3, successrate) $+ $chr(37)

    if ($chr(046) isin %ingredients) { set %replacechar $chr(032) $chr(043) $chr(032)
      %ingredients = $replace(%ingredients, $chr(046), %replacechar)
    }

    .msg $nick [4Name12 $3 $+ 1] [4Gem Required12 %gem.required $+ 1] [4Ingredients12 %ingredients $+ 1] [4Base Success Rate12 %base.success $+ 1] 

  }

}
