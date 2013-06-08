=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Battle Arena Bot - Version 2.1
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




* Added New Skills:
- Added the Killer Trait skills. These skills are passive and will increase melee damage to monster family types.

* Changes


* Fixes
- Fixed an issue with the wrong password counter not being reset sometimes after logging in.
- Fixed an issue in which cure-status type items (such as tonic) would not cure confuse and would actually make it worse.
- Fixed a bug that Raiden found in which new characters wouldn't be able to equip armor.
- Fixed a bug in which monster snatch descriptions weren't being displayed.
- Fixed a bug in which the demon portal's idle description wasn't being displayed.
- Fixed a bug with the error messages in !view-info
- Fixed a bug in which the total deaths of monsters/bosses were being increased by 2 if killed by an AOE.
- Fixed a bug in which battles with monster summons could potentially freeze and never end.
- Fixed a bug in which bot admins would sometimes be unable to force a character to create a shadow clone using the 'does' command.
- Fixed a bug in which the "has no skills" message wouldn't display when a character had no skills.
- Fixed a bug in which DCC battles would potentially freeze if a key is rewarded.

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