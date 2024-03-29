ON 1:TEXT:!help*:*: { $gamehelp($2, $nick) }
alias gamehelp { 
  set %help.topics $readini %help_folder $+ topics.help Help List | set %help.topics2 $readini %help_folder $+ topics.help Help List2 | set %help.topics3 $readini %help_folder $+ topics.help Help List3
  if ($1 = $null) { $display.private.message(14::[Current Help Topics]::)  | $display.private.message(2 $+ %help.topics) | $display.private.message(2 $+ %help.topics2) | unset %help.topics | unset %help.topics2 | $display.private.message(14::[Type !help <topic> (without the <>) to view the topic]::) | halt }
  if ($1 isin %help.topics) || ($1 isin %help.topics2) || ($1 isin %help.topics3) {  set %topic %help_folder $+ $1 $+ .help |  set %lines $lines(%topic) | set %l 0 | goto help }
  else { .msg $2 3The Librarian searchs through the ancient texts but returns with no results for your inquery!  Please try again | halt }
  :help
  inc %l 1
  if (%l <= %lines) {  
    if ($readini(system.dat, system, botType) = IRC) { /.timerReadHelpFile $+ $rand(1,1000) $+ $rand(a,z) 1 1 /.msg $2 $read(%topic, %l) }
    if ($readini(system.dat, system, botType) = DCCchat) {  $display.private.message($read(%topic, %l)) }
    goto help
  }
  else { goto endhelp }
  :endhelp
  unset %topic | unset %help.topics | unset %help.topics2 | unset %lines | unset %l | unset %help
}

ON 1:TEXT:!view-info*:*: { $view-info($1, $2, $3, $4) }
alias view-info {
  if ($2 = $null) { var %error.message 4Error: The command is missing what you want to view.  Use it like:  !view-info <tech $+ $chr(44) item $+ $chr(44) skill $+ $chr(44) weapon, armor, accessory, ignition> <name> (and remember to remove the < >) | $display.private.message(%error.message) | halt }
  if ($3 = $null) { var %error.message 4Error: The command is missing the name of what you want to view.   Use it like:  !view-info <tech, item, skill, weapon, armor, accessory, ignition> <name> (and remember to remove the < >) | $display.private.message(%error.message) | halt }

  if ($2 = tech) { 
    if ($readini(techniques.db, $3, type) = $null) { $display.private.message($nick, 4Error: Invalid technique) | halt }
    var %info.type $readini(techniques.db, $3, type) |   var %info.tp $readini(techniques.db, $3, TP)
    var %info.basePower $readini(techniques.db, $3, BasePower) | var %info.basecost $readini(techniques.db, $3, Cost)
    var %info.element $readini(techniques.db, $3, Element)
    var %info.ignoredef $readini(techniques.db, $3, IgnoreDefense)
    var %info.hits $readini(techniques.db, n, $3, hits)
    if (%info.hits = $null) { var %info.hits 1 }
    if ($readini(techniques.db, $3, magic) = yes) { var %info.magic  [4Magic12 Yes $+ 1] }
    if ($readini(techniques.db, $3, statusType) != $null) { var %info.statustype [4Stats Type12 $readini(techniques.db, $3, StatusType) $+ 1] }

    if (%info.ignoredef != $null) { var %info.ignoredefense  [4Ignore Target Defense by12 %info.ignoredef $+ $chr(37) $+ 1] }

    if (%info.type != buff) { 
      $display.private.message([4Name12 $3 $+ 1] [4Target Type12 %info.type $+ 1] [4TP needed to use12 %info.tp $+ 1]  [4# of Hits12 %info.hits $+ 1] %info.statustype %info.magic %info.ignoredefense)
      $display.private.message([4Base Power12 %info.basepower $+ 1] [4Base Cost (before Shop Level)12 %info.basecost red orbs1] [4Element of Tech12 %info.element $+ 1]) 
      if (%info.type = FinalGetsuga) { $display.private.message($readini(translation.dat, system, FinalGetsugaWarning)) }
    }
    if (%info.type = buff) { 
      $display.private.message([4Name12 $3 $+ 1] [4Target Type12 %info.type $+ 1] [4TP needed to use12 %info.tp $+ 1])
    }
  }

  if ($2 = ignition) { 
    if ($readini(ignitions.db, $3, name) = $null) { $display.private.message(4Error: Invalid ignition) | halt }
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

    $display.private.message([4Name12 %info.name $+ 1] [4Amount of Ignition Gauge Consumed Upon Use12 %info.trigger $+ 1] [4Amount of Ignition Gauge Needed Each Round12 %info.consume $+ 1] [4Bonus Augment12 %info.augment $+ 1] [4Trigger Effect12 %info.effect %info.status.type $+ 1])   
    $display.private.message([4Stat Multipliers $+ 1] 4Health x12 %info.hp  $+ $chr(124) 4 $+ Strength x12 %info.str  $+ $chr(124) 4 $+ Defense x12 %info.def  $+ $chr(124) 4Intelligence x12 %info.int  $+ $chr(124) 4Speed x12 %info.spd)
  }

  if ($2 = accessory) { 
    if ($readini(items.db, $3, type) = $null) { query $nick 4Invalid item | halt }
    $display.private.message([4Name12 $3 $+ 1] [4Type12 Accessory $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1])
  }
  if ($2 = gem) { 
    if ($readini(items.db, $3, type) = $null) { query $nick 4Invalid item | halt }
    $display.private.message([4Name12 $3 $+ 1] [4Type12 Gem $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1])
  }

  if ($2 = key) { 
    if ($readini(items.db, $3, type) = $null) { query $nick 4Invalid item | halt }
    $display.private.message([4Name12 $3 $+ 1] [4Type12 Key $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1])
  }

  if ($2 = rune) { 
    if ($readini(items.db, $3, augment) = $null) { query $nick 4Invalid item | halt }
    $display.private.message([4Name12 $3 $+ 1] [4Type12 Rune $+ 1] [4Augment12 $readini(items.db, $3, augment) $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1])
  }

  if ($2 = item) { 
    unset %info.fullbring
    if ($readini(items.db, $3, type) = $null) { $display.private.message(4Invalid item) | halt }
    var %info.type $readini(items.db, $3, type) | var %info.amount $readini(items.db, $3, amount)
    var %info.cost $bytes($readini(items.db, $3, cost),b) | var %info.element $readini(items.db, $3, element)
    var %info.target $readini(items.db, $3, target)
    var %info.fullbring $readini(items.db, $3, fullbringlevel)
    var %info.status $readini(items.db, $3, statustype) | var %info.amount $readini(items.db, $3, amount)
    if (%info.fullbring != $null) { set %info.fullbringmsg  [4Fullbring Level12 %info.fullbring $+ 1] } 
    if (%info.target = AOE-monster) { var %info.target All monsters }

    if (%info.type = heal) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Healing $+ 1] [4Heal Amount12 %info.amount $+ 1]  [4Item Cost12 %info.cost red orbs1] %info.fullbringmsg) }
    if (%info.type = IgnitionGauge) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Ignition Gauge Restore $+ 1] [4Restore Amount12 %info.amount $+ 1]  [4Item Cost12 %info.cost red orbs1] %info.fullbringmsg) }
    if (%info.type = Damage) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Damage $+ 1] [4Target12 %info.target $+ 1]  [4Damage Amount12 %info.amount $+ 1] [4Item Cost12 %info.cost red orbs1] %info.fullbringmsg)  }
    if (%info.type = Status) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Status $+ 1] [4Target12 %info.target $+ 1]  [4Damage Amount12 %info.amount $+ 1] [4Status Type12 %info.status $+ 1] [4Item Cost12 %info.cost red orbs1] %info.fullbringmsg) }
    if (%info.type = Food) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Stat Increase $+ 1] [4Stat to Increase12 %info.target $+ 1] [4Increase Amount12 $chr(43) $+ %info.amount $+ 1])   }
    if (%info.type = Consume) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Skill Consumable $+ 1] [4Skill That Uses This Item12 $readini(items.db, $3, skill) $+ 1] [4Item Cost12 %info.cost red orbs1])    }
    if (%info.type = Summon) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Summon $+ 1] [4This item summons12 $readini(items.db, $3, summonname) 4to fight with you $+ 1] [4Item Cost12 %info.cost red orbs1])    }
    if (%info.type = ShopReset) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Shop Level Change $+ 1] [4When used this item reduces your shop level by %info.amount $+ 1] [4Item Cost12 %info.cost red orbs1])    }
    if (%info.type = tp) { $display.private.message([4Name12 $3 $+ 1] [4Type12 TP Restore $+ 1] [4TP Restored Amount12 %info.amount $+ 1]  [4Item Cost12 %info.cost red orbs1] %info.fullbringmsg) }
    if (%info.type = CureStatus) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Cure Status $+ 1] [4Item Cost12 %info.cost red orbs1] [4Note12 This item will not cure Charm or Intimidation $+ 1] %info.fullbringmsg) }
    if (%info.type = accessory) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Accessory $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1])  }
    if (%info.type = revive) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Automatic Revival $+ 1] [4Description12 When used this item will activate the "Automatic Revive" status.  If you die in battle, you will be revived with 1/2 HP.  $+ 1])  }
    if (%info.type = key) { $display.private.message([4Name12 $3 $+ 1] [4Type12 Key $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1])  }
    if (%info.type = gem) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Gem $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1])  }
    if (%info.type = misc) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Crafting Ingredient $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1])  }
    if (%info.type = trade) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Trading Item $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1])  }
    if (%info.type = random) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Random item inside! $+ 1]) }
    if (%info.type = rune) { 
      if ($readini(items.db, $3, augment) = $null) { query $nick 4Invalid item | halt }
      $display.private.message([4Name12 $3 $+ 1] [4Type12 Rune $+ 1] [4Augment12 $readini(items.db, $3, augment) $+ 1] [4Description12 $readini(items.db, $3, desc) $+ 1]) 
    }
    unset %info.fullbringmsg
  }
  if (%info.type = portal) {  $display.private.message([4Name12 $3 $+ 1] [4Type12 Portal $+ 1] [4Lair12 $readini(items.db, $3, Battlefield) $+ 1] [4Description12 This item will teleport all players on the battlefield through a portal to the lair of a strong boss! $+ 1)]  }



  if ($2 = skill) { 
    if ($readini(skills.db, $3, type) = $null) { $display.private.message(4Invalid skill)  | halt }
    var %info.type $readini(skills.db, $3, type) | var %info.desc $readini(skills.db, $3, info)
    var %info.cost $readini(skills.db, $3, cost) | var %info.maxlevel $readini(skills.db, $3, max)
    $display.private.message([4Name12 $3 $+ 1] [4Skill Type12 %info.type $+ 1] [4Base Cost (before shop level)12 %info.cost $+ 1] [4Max Level12 %info.maxlevel $+ 1])
    $display.private.message([4Skill Info12 %info.desc $+ 1])
  }


  if ($2 = armor) { 
    if ($readini(equipment.db, $3, name) = $null) { $display.private.message(4Error: Invalid Armor) | halt }
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

    $display.private.message([4Name12 %info.name $+ 1] [4Armor Location12 %info.location $+ 1]  [4Armor Augment12 %info.augment $+ 1])
    $display.private.message([4Stats on Armor $+ 1] 4Health12 %info.hp  $+ $chr(124) 4TP12 %info.tp   $+ $chr(124) 4 $+ Strength12 %info.str  $+ $chr(124) 4 $+ Defense12 %info.def  $+ $chr(124) 4Intelligence12 %info.int  $+ $chr(124) 4Speed12 %info.spd)
    if (AutoReraise isin %info.augment) { $display.private.message(4The Auto Reraise Augment only works if you have 5 pieces of armor that all have the same augment.  In other words the augment strength must be at least 5 in order to work) } 
  }

  if ($2 = weapon ) {
    if ($readini(weapons.db, $3, type) = $null) { $display.private.message(4Invalid weapon) | halt }
    var %info.type $readini(weapons.db, $3, type) | var %info.hits $readini(weapons.db, n, $3, hits)
    %info.hits = $replacex(%info.hits,$chr(36) $+ rand,random))
    %info.hits = $replacex(%info.hits,$chr(44), $chr(45)))
    var %info.basePower $readini(weapons.db, $3, BasePower) | var %info.basecost $readini(weapons.db, $3, Cost)
    var %info.element $readini(weapons.db, $3, Element) | var %info.abilities $readini(weapons.db, $3, abilities)
    var %info.ignoredef $readini(techniques.db, $3, IgnoreDefense)

    if ($chr(046) isin %info.abilities) { set %replacechar $chr(044) $chr(032)
      %info.abilities = $replace(%info.abilities, $chr(046), %replacechar)
    }

    if (%info.ignoredef != $null) { var %info.ignoredefense  [4Ignore Target Defense by12 %info.ignoredef $+ $chr(37) $+ 1] }

    $display.private.message([4Name12 $3 $+ 1] [4Weapon Type12 %info.type $+ 1] [4# of Hits12 %info.hits $+ 1]) 
    $display.private.message([4Base Power12 %info.basepower $+ 1] [4Cost12 %info.basecost black orb(s)1] [4Element of Weapon12 %info.element $+ 1]) 
    $display.private.message([4Abilities of the Weapon12 %info.abilities $+ 1] %info.ignoredefense)
    $display.private.message([4Weapon Description12 $readini(weapons.db, $3, Info) $+ 1])
  }

  if ($2 = alchemy) {

    if ($3 = list) { 
      unset %crafted.items | unset %crafted.items2 | unset %crafted.items3 | unset %crafted.armor | unset %crafted.armor2 | unset %crafted.armor3 | unset %crafted.armor4 | unset %crafted.armor5 | unset %crafted.armor6 | unset %crafted.armor7

      ; Checking items
      var %value 1 | var %crafted.items.lines $lines(alchemy_items.lst)

      while (%value <= %crafted.items.lines) {
        set %item.name $read -l $+ %value alchemy_items.lst
        if ($numtok(%crafted.items,46) <= 20) { %crafted.items = $addtok(%crafted.items, %item.name, 46) }
        else { 
          if ($numtok(%crafted.items2,46) >= 20) { %crafted.items3 = $addtok(%crafted.items3, %item.name, 46) }
          else { %crafted.items2 = $addtok(%crafted.items2, %item.name, 46) }
        }
        unset %item.name 
        inc %value 1 
      }

      ; Checking armor
      var %value 1 | var %crafted.armor.lines $lines(alchemy_armor.lst)
      while (%value <= %crafted.armor.lines) {

        set %item.name $read -l $+ %value alchemy_armor.lst

        if ($numtok(%crafted.armor,46) <= 12) { %crafted.armor = $addtok(%crafted.armor, %item.name, 46) }
        else { 
          if ($numtok(%crafted.armor2,46) <= 12) { %crafted.armor2 = $addtok(%crafted.armor2, %item.name, 46) }
          else { 
            if ($numtok(%crafted.armor3,46) <= 12) { %crafted.armor3 = $addtok(%crafted.armor3, %item.name, 46) }
            else { 
              if ($numtok(%crafted.armor4,46) <= 12) { %crafted.armor4 = $addtok(%crafted.armor4, %item.name, 46) }
              else { 
                if ($numtok(%crafted.armor5,46) <= 12) { %crafted.armor5 = $addtok(%crafted.armor5, %item.name, 46) }
                else { 
                  if ($numtok(%crafted.armor6,46) <= 12) { %crafted.armor6 = $addtok(%crafted.armor6, %item.name, 46) }
                  else { %crafted.armor7 = $addtok(%crafted.armor7, %item.name, 46) }
                }
              }
            }
          }
        }
        unset %item.name 
        inc %value 1 
      }

      set %replacechar $chr(044) $chr(032)
      %crafted.items = $replace(%crafted.items, $chr(046), %replacechar)
      %crafted.items2 = $replace(%crafted.items2, $chr(046), %replacechar)
      %crafted.items3 = $replace(%crafted.items3, $chr(046), %replacechar)
      %crafted.armor = $replace(%crafted.armor, $chr(046), %replacechar)
      %crafted.armor2 = $replace(%crafted.armor2, $chr(046), %replacechar)
      %crafted.armor3 = $replace(%crafted.armor3, $chr(046), %replacechar)
      %crafted.armor4 = $replace(%crafted.armor4, $chr(046), %replacechar)
      %crafted.armor5 = $replace(%crafted.armor5, $chr(046), %replacechar)
      %crafted.armor6 = $replace(%crafted.armor6, $chr(046), %replacechar)
      %crafted.armor7 = $replace(%crafted.armor7, $chr(046), %replacechar)

      if (%crafted.items != $null) { $display.private.message(4Items that can be crafted:12 %crafted.items) }
      if (%crafted.items2 != $null) { $display.private.message(12 $+ %crafted.items2) }
      if (%crafted.items3 != $null) { $display.private.message(12 $+ %crafted.items3) }

      if (%crafted.armor != $null) { $display.private.message(4Armor that can be crafted:12 %crafted.armor) }
      if (%crafted.armor2 != $null) { $display.private.message(12 $+ %crafted.armor2) }
      if (%crafted.armor3 != $null) { $display.private.message(12 $+ %crafted.armor3) }
      if (%crafted.armor4 != $null) { $display.private.message(12 $+ %crafted.armor4) }
      if (%crafted.armor5 != $null) { $display.private.message(12 $+ %crafted.armor5) }

      unset %crafted.items | unset %crafted.items2 | unset %crafted.items3 | unset %crafted.armor | unset %crafted.armor2 | unset %crafted.armor3 | unset %crafted.armor4 | unset %crafted.armor5 | unset %crafted.armor6 | unset %crafted.armor7
      unset %replacechar

      halt
    }

    var %gem.required $readini(crafting.db, $3, gem)
    if (%gem.required = $null) { $display.private.message($readini(translation.dat, errors, CannotCraftThisItem)) | halt }

    var %ingredients $readini(crafting.db, $3, ingredients)

    echo -a ingredients: %ingredients


    var %total.ingredients $numtok(%ingredients, 46)

    var %value 1
    while (%value <= %total.ingredients) {
      set %item.name $gettok(%ingredients, %value, 46)
      set %amount.needed $readini(crafting.db, $3, %item.name)
      if (%amount.needed = $null) { set %amount.needed 1 }

      set %ingredient.to.add %item.name x $+ %amount.needed
      %ingredient.list = $addtok(%ingredient.list,%ingredient.to.add,46)
      inc %value 1 
    }

    var %base.success $readini(crafting.db, $3, successrate) $+ $chr(37)

    set %replacechar $chr(032) $chr(043) $chr(032)
    %ingredient.list = $replace(%ingredient.list, $chr(046), %replacechar)

    $display.private.message([4Name12 $3 $+ 1] [4Gem Required12 %gem.required $+ 1] [4Ingredients12 %ingredient.list $+ 1] [4Base Success Rate12 %base.success $+ 1])

    unset %replacechar | unset %amount.needed | unset %item.name | unset %ingredient.list
  }

  if ($2 = style) {
    if ($readini(playerstyles.db, Info, $3) = $null) { $display.private.message(4Invalid style) | halt }
    $display.private.message(2 $+ $readini(playerstyles.db, info, $3), private)
  }

}
