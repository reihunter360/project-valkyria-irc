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
  if ($2 = $null) { query $nick 4Error: The command is missing what you want to view.  Use it like:  !view-info <tech, item, skill, weapon> <name> (and remember to remove the < >) | halt }
  if ($3 = $null) { query $nick 4Error: The command is missing the name of what you want to view.   Use it like:  !view-info <tech, item, skill, weapon> <name> (and remember to remove the < >) | halt }

  if ($2 = tech) { 
    if ($readini(techniques.db, $3, type) = $null) { query $nick 4Error: Invalid technique | halt }
    var %info.type $readini(techniques.db, $3, type) |   var %info.tp $readini(techniques.db, $3, TP)
    var %info.basePower $readini(techniques.db, $3, BasePower) | var %info.basecost $readini(techniques.db, $3, Cost)
    var %info.element $readini(techniques.db, $3, Element)
    if ($readini(techniques.db, $3, magic) = yes) { var %info.magic  [4Magic12 Yes $+ 1] }
    if ($readini(techniques.db, $3, type) = status) { var %info.statustype [4Stats Type12 $readini(techniques.db, $3, StatusType) $+ 1] }

    .msg $nick [4Name12 $3 $+ 1] [4Target Type12 %info.type $+ 1] [4TP needed to use12 %info.tp $+ 1]  %info.statustype %info.magic
    .msg $nick [4Base Power12 %info.basepower $+ 1] [4Base Cost (before Shop Level)12 %info.basecost red orbs1] [4Element of Tech12 %info.element $+ 1] 

  }

  if ($2 = item) { unset %info.fullbring
    if ($readini(items.db, $3, type) = $null) { query $nick 4Invalid item | halt }
    var %info.type $readini(items.db, $3, type) | var %info.amount $readini(items.db, $3, amount)
    var %info.cost $bytes($readini(items.db, $3, cost),b) | var %info.element $readini(items.db, $3, element)
    var %info.target $readini(items.db, $3, target)
    var %info.fullbring $readini(items.db, $3, fullbringlevel)
    if (%info.fullbring != $null) { set %info.fullbringmsg  [4Fullbring Level12 %info.fullbring $+ 1] } 
    if (%info.target = AOE-monster) { var %info.target All monsters }

    if (%info.type = heal) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Healing $+ 1] [4Heal Amount12 %info.amount $+ 1]  [4Item Cost12 %info.cost red orbs1] %info.fullbringmsg }
    if (%info.type = Damage) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Damage $+ 1] [4Target12 %info.target $+ 1]  [4Damage Amount12 %info.amount $+ 1] [4Item Cost12 %info.cost red orbs1] %info.fullbringmsg  }
    if (%info.type = Food) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Stat Increase $+ 1] [4Stat to Increase12 %info.target $+ 1] [4Increase Amount12 $chr(43) $+ %info.amount $+ 1]   }
    if (%info.type = Consume) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Skill Consumable $+ 1] [4Skill That Uses This Item12 $readini(items.db, $3, skill) $+ 1] [4Item Cost12 %info.cost red orbs1]    }
    if (%info.type = Summon) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Summon $+ 1] [4This item summons12 $readini(items.db, $3, summonname) 4to fight with you $+ 1] [4Item Cost12 %info.cost red orbs1]    }
    if (%info.type = ShopReset) { .msg $nick [4Name12 $3 $+ 1] [4Type12 Shop Level Change $+ 1] [4When used this item reduces your shop level by %info.amount $+ 1] [4Item Cost12 %info.cost red orbs1]    }

  }

  if ($2 = skill) { 
    if ($readini(skills.db, $3, type) = $null) { query $nick 4Invalid skill  | halt }
    var %info.type $readini(skills.db, $3, type) | var %info.desc $readini(skills.db, $3, info)
    var %info.cost $readini(skills.db, $3, cost) | var %info.maxlevel $readini(skills.db, $3, max)
    .msg $nick [4Name12 $3 $+ 1] [4Skill Type12 %info.type $+ 1] [4Base Cost (before shop level)12 %info.cost $+ 1] [4Max Level12 %info.maxlevel $+ 1] 
    .msg $nick [4Skill Info12 %info.desc $+ 1]
  }

  if ($2 = weapon ) {
    if ($readini(weapons.db, $3, type) = $null) { query $nick 4Invalid weapon | halt }
    var %info.type $readini(weapons.db, $3, type) | var %info.hits $readini(weapons.db, n, $3, hits)
    var %info.basePower $readini(weapons.db, $3, BasePower) | var %info.basecost $readini(weapons.db, $3, Cost)
    var %info.element $readini(weapons.db, $3, Element) | var %info.abilities $readini(weapons.db, $3, abilities)

    if ($chr(046) isin %info.abilities) { set %replacechar $chr(044) $chr(032)
      %info.abilities = $replace(%info.abilities, $chr(046), %replacechar)
    }

    .msg $nick [4Name12 $3 $+ 1] [4Weapon Type12 %info.type $+ 1] [4# of Hits 12 %info.hits $+ 1] 
    .msg $nick [4Base Power12 %info.basepower $+ 1] [4Cost12 %info.basecost black orb(s)1] [4Element of Weapon12 %info.element $+ 1] 
    .msg $nick [4Abilities of the Weapon12 %info.abilities $+ 1]
    .msg $nick [4Weapon Description12 $readini(weapons.db, $3, Info) $+ 1]
  }



}
