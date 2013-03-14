=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Battle Arena Bot - Version 2.0
Programmed by James "Iyouboushi" (Iyouboushi@gmail.com)
FREEWARE!
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Table of Contents:
 About
 Setup
 What's New?
 Patches
 Scripters
 Thanks
 Contact

 _______________________________________________________________________
/                                                                       \
|                                ABOUT                                  |
\_______________________________________________________________________/


This bot is an mIRC game in which you join and kill monsters and bosses to gain orbs and new
weapons/skills/techniques.  It's similar to the hit PS2/PS3 series "Devil May Cry", as that's 
really the inspiration I drew from when I started working on it, but it includes more than just 
DMC monsters/bosses/weapons/items.   The whole purpose was to make an mIRC game that is completely
automated in terms of the battle system. There doesnÅft need to be a DM around to do !next and control
monsters, like in my other major mIRC bot ("Kaiou").

Here players join the battle when the bot announces an open battle. After a few minutes, it will
generate monsters/bosses and have them join the battle and the battle will start. When itÅfs a
monsterÅfs or bossÅf turn, they will automatically do their things. When itÅfs the playerÅfs turn,
thereÅfs a few commands you can do (attack with a weapon, attack with a technique, do a skill, use an
item). If the player idles for too long the bot will force their turn and skip over them. This is
done so that someone canÅft disappear for an hour and cause the battle to drag on forever.

ThereÅfs a bunch of weapons that can be bought and each weapon has a few techniques attached to them.
Unlike in Kaiou, you canÅft make your own techniques but rather have to buy them using red orbs that you
earn from battle. You buy weapons using black orbs when you obtain via winning boss fights and being alive
at the end of one.

As for the main purpose of the game.. well, the only real purpose is to see how long of a winning streak
players can achieve.  The game is designed so that people can hop in and out easily at nearly any time,
just as a way to basically kill some boredom.  There is no ultimate goal to obtain or defend.


 _______________________________________________________________________
/                                                                       \
|                                 SETUP                                 |
\_______________________________________________________________________/


Getting it set up is easy this time around assuming you unpack the zip in a good location on
your computer.  


SETUP:

 1. Do a CLEAN install to C:\BattleArena\  with the complete zip package of the bot.
 2. Patch the bot to the latest versions if there are any patches.
    don't skip versions unless I specifically say it's all right.  
    ALSO NOTE: DO NOT HAVE THE BOT RUNNING WHEN YOU APPLY PATCHES!
 3. Run the mirc.exe included with Complete Package.
 4. The bot will attempt to help you get things set up.  Set the
    bot owner's nick and the IRC channel you wish to game in.  Be sure to set a 
    password for the bot that you'll register to nickserv with.
 5. (as with all mIRC programs) change the nickname and add a server
 6. Connect.
 7. Using another IRC connection as the bot owner's nick, use !new char (nick)
    without the () to get the character creation process started.
 8. Follow what the bot tells you to do.  Be sure to check out player_guide.txt as well.


Note, you do NOT have to install it to C:\BattleArena\ However, it's recommended.
DO NOT INSTALL this bot into a folder that has spaces in the path.  For example,
C:\Program Files\BattleArena   as IT WILL NOT WORK RIGHT.

   
 _______________________________________________________________________
/                                                                       \
|                             WHAT'S NEW?                               |
\_______________________________________________________________________/


As usual be sure to read the versions.txt in the documentation folder
for a full list of everything this version does.  Listed below are some 
of the highlights.

* New Damage Formulas
This version of the bot dumps the version 1.0-1.5 battle formulas for melee and techs and introduces 
two new formulas.  Bot Admins can use !toggle Battle Formula to switch between them.  Formula 2 is 
the default.

* Armor
Added armor! Basic armor can be found in chests, middle grade armor can be crafted and higher level 
armor can be found via special battlefield bosses. To wear armor use: !wear armor name 
to remove: !remove armor name.  Likewise, accessories have changed slightly and you must use 
!wear accessory name  or !remove accessory name to wear/remove them.

* Augments
Added the Augment system. Augments can be considered special enhancements to a player that may enhance
certain skills, damages and other abilities.  Players have the ability to equip a weapon with an augment
on their own, and a lot of middle/high grade armor will have augments already equipped.  For weapons,
first a player must obtain a RUNE (found on bosses and in silver chests).  Once the player has one,
he/she may use the command !augment add (weapon) (rune) to equip it.  Later, if a better augment comes up
or if he/she changes his/her mind, the player may use !augment remove (weapon)  to remove it.  ** Runes are
lost upon use and will not be returned when it's unaugmented.  Use !augment by itself to see a list of 
equipped augments.  Most augments stack and will give better results.  Players can use !augment strength to
see what the current strength of all currently activated augments.

* Ignitions
Added a new stat: Ignition Gauge.  Players can see their current ignition gauge by using !ig or !ignition gauge.
IG can be bought via the shop with !buy stats IG #  Unlike hp/tp, buying them won't full the gauge to full.
Ignition Gauge fills by +1 when the player is in a winning battle or when he/she is killed by a monster.

The Ignition Gauge is then used to activate Ignitions. Ignitions are stronger boosts that are purchased in 
the shop via black orbs. They consume Ignition Gauge to use and to maintain during battle. Each Ignition has
its own special effect and augment bonus that happens when it's activated.  Players can use the command
/me reverts from (Ignition Name) to turn the Ignition off manually before the IG runs out.

* Renkei
Added the ability for non-magical/non-AOE techniques to link together to deal additional damage. It's called
Renkei. If two techniques that qualify (non-magic) are done to a target before the target's next turn, it will
activate a renkei that will deal additional damage to a target. Monsters can use it against players as well.

* Demon Walls
From streak 301 to streak 600 a new boss battle type may randomly generate: Demon Walls. Like in
the Final Fantasy games players are only given a small time to defeat the wall before the battle
is ended in a loss.

* Portal Boss Battles
There are now "portal items" in the shop. These items, when used, will teleport all heroes in a battle to
a special battlefield where they will fight a special boss. These bosses are usually much harder than
normal bosses. Better armor can be found by defeating these special bosses. Successfully beating a portal
boss battle will award all participating heroes with allied notes.

* New Currency Types
New currency types have been added: seals and allied notes. Seals are KindredSeal and BeastmenSeal and are
used to purchase portal items. Allied Notes are used to purchase misc/crafting items and seals. 

* Ability to Grab Monsters (or players, if monsters do it)
There's a new item available in the shop that, when used, will attempt to snag a target and use him/her/it
as a shield.  If successful, it basically causes the target to cover the user, thus when something attacks the
user, the target will be hurt instead.  The odds of the target getting grabbed depend on the level and 
speed of both user and target. If monsters have snatch=1 in their [skills] they will attempt to do it too.
The main difference is that monsters will throw the target away from them on their next turn, thus freeing them
from covering the monster.

* Melee Attacks Can Be Countered & New Player Style
Added the ability for melee attacks to be countered. When this happens, the person who attacks 
will end up taking damage.  The chance of countering an attack can be increased by using the 
new player style, CounterStance, and leveling it.  

* Battlefields
Battlefields are now in the game. At the beginning of each battle it will generate a random battlefield.
Each battlefield has its own scavenge item pool, its own set of weather types that it can pick, and
various random events that may happen during the course of battle.

* New Achievements
More achievements have been added to the bot. Also, it's now possible to see which achievements
have already been obtained. Use !achievements to see your own or !achievements person  to see someone else.

* New Scoreboard Type
The bot can now generate a scoareboard based on the total # of deaths of monsters and bosses.
Use !deathboard <monster/boss>  to see it, though you may have to wait til enough monsters have 
been killed.

* New Status Effects
- Added the "bored" status. When inflicted upon a target, the target will miss a few turns.
- Added the "confused" status. When inflicted upon a target, the target will randomly attack opponents inc. allies
- Added the "reflect" status. If someone casts a spell on someone who has this status, the spell will bounce back and hit the
  caster. Curing spells ignore the reflect status though if they heal.
- Added the "protect" status. When on, it cuts melee attacks down by half.
- Added the "shell" status. When on, it cuts magic damage down by half.

* Added new skills:
- Added the passive skill: TreasureHunter.  This skill will increase the odds of better colored chests when a chest
  is generated, and the odds of getting a random item at the end of battle if the monsters have one to give. This 
  skill is cumulative with everyone who has it but in order to take effect, the players must be alive at the end of battle.
- Added the passive skill: BackGuard.  This skill will decrease the odds of monsters going first in battle. 
  It's cumulative with everyone who has it and is in battle.
- Added the active skill: Konzen-Ittai. This skill, when activated, will allow you to perform a self-Renkei with 
  a non-magic, non-AOE, technique.
- Added the active skill: Seal Break. This skill, when used, will consume Hankai and attempt to break the 
  Melee-Only ancient seal that prevents players and monsters from using techniques that battle.
- Added the active skill: Magic Mirror. This skill, when used, will consume a MirrorShard and give the user 
  the Reflect status.
- Added the active skill: Gamble. This skill, when used, will consume 1000 red orbs to summon a slot machine
  that will do something random.
- Added the active skill: ThirdEye. This skill, when used, will allow the user to dodge 1-2 attacks.
- Added the active skill: Scavenge. This skill, when used, will allow a player to try to dig something up out
  of the battlefield's ground. The items that are possible in the battlefields are set by the bot owner in
  battlefields.lst. Players can use this skill one time per battle, successfully or not. Each level in this 
  skill increases the odds of finding an item.
- Added the active skill: Just Release. This skill will unleash the stored Royal Guard meter at an enemy.  
  The damage done is (skill level)% of your Royal Guard meter.  The damage done with this skill cannot be 
  completely resisted or dodged.  Royal Guard meter is built up by successfully blocking attacks using Royal Guard.
- Added the style skill: Perfect Counter. This skill can only be used one time in battle and the user must
  be using the CounterStance style. When used it will ensure the next melee attack will be countered.
- Added the monster-only skill: Magic Shift. When used, this skill will randomize what element a monster
  is strong/weak to and healed by.
- Added the monster-only skill: DemonPortal. When used, this skill will allow a monster to create a Demon Portal monster.
  On the portal's turn, it will generate another monster onto the battlefield provided there's less than 5 monsters
  on the field. It will only stop when the portal is dead. Monsters with DemonPortal skill can also heal the portal.
- Added the monster-only skill: MonsterConsume. When used, a monster will eat/kill another monster and gain 40% of its stats

* Changes
- Changed the zombie regen to scale a bit better so that lower streaks won't have 100+ hp regenerated.
- Changed the way red orbs are rewarded so that lower streaks have a much lower max orbs and higher streaks 
  can actually give more than 100%. 
- Changed the key and chest drop rates.
- Changed the shop so that there's a cap on the old-style boosts. Players can now only own 500 levels into them.
- Changed the way the bot does the status effects to try and make it show them in the channel better and to block 
  players from being able to control their actions until all of the status effects have been displayed.
- Changed the damage amount that magic special effects (burning, drowning, shocked, etc) do to targets. 
- Changed the Melee-Only type battles so that they no longer appear during boss battles.
- Changed the way status effects work so that multiple status effects may be used at a time on techs/weapons/items.
- Changed AOEs so that if the person who initiated the AOE dies at any point during the AOE, the AOE itself will stop cold.
- Changed Quicksilver so that it can't be used multiple times in a row. There has to be at least 1 turn between uses.
- Changed the way the bot gets the items inside the chests. Now bot owners have more control over it. See chests.lst 
- Changed !items so that the keys are no longer listed there. Use !keys to see the keys you have.
- Changed the Final Getsuga type boost so that while it's on EVERY AUGMENT will be on at the same time.
- Changed the !items code so that it clears out items that the player has 0 of in their files.
- Changed the curse night and melee-only events so that they won't occur below streak 50.
- Changed the orb reward code so that people who flee from battle will not receive the OrbHunter or Accessory orb bonuses.
- Changed the !scoreboard command to show a varying amount of top players depending on how many players are in the game. 
  It will now show the top 3, the top 5, or the top 10.
- Changed !status and the turn status line to show some of the skills active on the person.

* Fixes
- Fixed a bug in which selling a technique might result in 0 orbs back.
- Fixed a bug in which cover would activate when a monster used taunt on a covered target.
- Fixed an issue where setting a high difficulty would still result in low level monsters on lower streaks. 
- Fixed an issue with magic effect deaths in which they wouldn't check for the revive status
- Fixed a bug with chests that gave orbs. It would write a red=orbs orbs orbs line or black=orbs orbs orbs line in the 
  player's item_amount section.  That should be fixed now.
- Fixed a bug with the GIVE command in which a misspelled name would cause an error that would stop the bot in its tracks.
- Fixed a bug in which players could exploit the bot using descriptions.

Again, this isn't everything. Be sure to read the versions.txt in the documentation
folder for a full list of everything 

 _______________________________________________________________________
/                                                                       \
|                               PATCHES                                 |
\_______________________________________________________________________/



Patches are made when I feel there are enough errors or new 
ideas to implement that it deserves to be done.  In other words, you shouldn't 
ask when a patch will be made and released.  Just keep an eye on the website or
message board occasionally and see if I've added a topic about a patch in development 
or if there has been one released recently.  


 _______________________________________________________________________
/                                                                       \
|                              SCRIPTERS                                |
\_______________________________________________________________________/


If you're a scripter who likes to play around or might want to add
something new, this section is for you.

First off, although a lot of the code is new, or improved from Kaiou's source,
there are still tons of code that could probably be rewritten and improved.

If you want to recode stuff, feel free.  I've got nothing against it.  I really
wish you luck.  If you manage to vastly improve anything, I'd love to see it.
Just send me a quick email (listed at the bottom of this document).  


 _______________________________________________________________________
/                                                                       \
|                                THANKS                                 |
\_______________________________________________________________________/


These are people who have helped me by helping me test, making monsters/weapons/etc,
finding bugs, or just by giving me some ideas.

Scott "Smz" of Esper.net
He helped me with a bunch of ideas, made monsters, and made bosses.  Not only that,
he was the first beta tester of version 1.0; Without him, I don't think
I could have done this.

Andrio of Esper.net 
Helped me test out the bot and found a few glitches that needed to be fixed.

AuXFire of Hawkee
Caught a major bug with the passwords which made changing your password from the default impossible.

Raiden of Esper.net
This guy has helped me almost as much as Smz has. He's found countless bugs, gave me ideas for several
accessories and skills and helped host the bot on Esper.net.

Sealdrenxia of Twitter
Discovered a huge bug with !new char that let players use the command over and over to get free orbs.

Rei_Hunter of Esper.net
Helped give me a ton of ideas for the bot (including, but not limited to, moving cooldown timers to the skills.db, monsters being able to absorb elements for healing, AOE healing, and the ability for monsters to ignore darkness/rage mode).

Trunks on Esper.net
Since he was translating the bot into German, it sparked the idea of the translation.dat file to try and make the bot a little more friendly for translation.

 _______________________________________________________________________
/                                                                       \
|                               CONTACT                                 |
\_______________________________________________________________________/


If, for whatever reason, you need to contact me.. my email address is
provided:  Iyouboushi@gmail.com  or you can contact me via twitter:
twitter.com/Iyouboushi

PLEASE, PLEASE, PLEASE, PLEASE, PLEASE, PLEASE, do NOT contact me about HELP
running this bot.  I seriously do not have enough time to help everyone. If
you're really having trouble, check out the message board:

http://iyouboushi.com/forum/index.php?/topic/890-battle-arena-help-thread/

You'll have to make an account (free) to post. But you're more likely to
receive help with the bot there.

HOWEVER, if you run into a serious error, DO (PLEASE) email me about the error.  
I will try to correct all errors for a later patch.  So definitely let me know
about errors.