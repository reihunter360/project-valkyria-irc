=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Battle Arena Bot - Version 1.3
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


This version was made more to fix multiple bugs and to fix exploits more
than to add new things.  As usual, see versions.txt for the entire list
of changes/fixes/additions.  Some of the more important ones will be listed
here.

* Added the translation.dat file
This file contains most of the bot messages. You can edit this file to do
translations or just to change the way the various messages read. Open the
translation.dat file in notepad and be sure to read the top of the file 
before you start editing.

* Added the Ability to Sell Items
Use !shop sell items (item name) (amount)  [without the () of course] to
sell an unwanted item back to the shop.  Keep in mind you won't get the
full price back for the item.

* Added AOE Heal Techs
The Heal-AOE type tech will heal all allies on the battlefield. 
This type of tech cannot be used on your enemies, even if they're
undead or zombies.

* Added new skills
- Analysis allows you to analyze a monster. Increased levels of the skill
  will give you more detailed information.
- Zen is a passive skill that increases the amount of TP you get back
  each turn you're not cursed. It's +(5 * skill level)
- Haggling is a passive skill that increase the amount of orbs you
  get for selling items back to the shop.

* Added an Anti-Cheat System On Monster Weapons
If somehow players get ahold of monster weapons they will be useless
to them now and will do 0-5 damage max.  Monster techs will also do
0-5 damage max and boosts will increase the stats by 0.


* Changed the Monster Generation
I changed the way the monsters are generated for battle and put into
the battle to hopefully make it a little more random and to prevent a
future bug that would eventually happen via the old method.

* Changed the Max Damage of Suicide Techs For Players
Due to people exploiting suicide type techs with insane amounts of HP,
I changed the max amount of damage of suicide techs that can be done 
by players to 500.

* Changed the Maximum Number of Times Steal Will Work
Due to an exploit of people using steal on orb fountains on blood moon
resulting in a potential of receiving thousands of free orbs, I've
set the max number of times steal will work on a single target per
battle to two.

* Changed Max HP/TP and Style Points
The maximum number of HP you can have in the game is now 2500. The max
TP is now 500. The style points, while hidden, will now be capped at
5000.  The reason being someone could taunt an orb fountain for an hour
to get their style up to obscene levels and then kill the fountain to
get a gigantic bonus amount of orbs (as bonus is based on style points
upon a monster's death).  

* Changed Location of Skill Cooldown Timers
The cooldown timers are now located in the skills.db.  Bot owners
can now edit these directly to change the skill reuse times. Remember
these times are in seconds.

* Bug Fixes
As usual, there's always a few bugs to squish.  Here's a quick breakdown.

- Fixed zombie regen not wearing off at the end of battle.
- Fixed Amnesia so it actually works now.
- Fixed a bug where some mastery skills weren't working right.
- Fixed a bug in which steal wasn't adding the items correctly
- Fixed a bug in which +TP item descriptions weren't working right.
- Fixed the bot so that it'll give the right access level to all bot owners in the
  list upon start up.
- Fixed a bug in which style levels were occasionally not leveling right.
- Fixed a bug in which players could purchase monster weapons.
- Fixed a bug in which consumable items could be consumed with !use 
- Fixed a bug in which MightyStrike could be used continuously without cooldown.
- Fixed a bug in which fleeing would cause the bot to break in a one vs one battle
  against an orb fountain.



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
He helped test the bot and found a bot-breaking bug in which certain encoded passwords wouldn't
work with the !id and !quick id commands.

Sealdrenxia of Twitter
Discovered a huge bug with !new char that let players use the command over and over to get free orbs.

 _______________________________________________________________________
/                                                                       \
|                               CONTACT                                 |
\_______________________________________________________________________/


If, for whatever reason, you need to contact me.. my email address is
provided:  Iyouboushi@gmail.com

PLEASE, PLEASE, PLEASE, PLEASE, PLEASE, PLEASE, do NOT contact me about HELP
running this bot.  I seriously do not have enough time to help everyone. If
you're really having trouble, check out the message board:

http://iyouboushi.com/forum/index.php?/topic/890-battle-arena-help-thread/

You'll have to make an account (free) to post. But you're more likely to
receive help with the bot there.

HOWEVER, if you run into a serious error, DO (PLEASE) email me about the error.  
I will try to correct all errors for a later patch.  So definitely let me know
about errors.