;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; BASIC CONTROL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

on 1:QUIT: {  .auser 1 $nick | .flush 1 }
on 1:EXIT: {  .auser 1 $nick | .flush 1 }
on 1:PART:%battlechan:.auser 1 $nick | .flush 1
on 1:KICK:%battlechan:.auser 1 $knick | .flush 1 
on 1:JOIN:%battlechan:{  .auser 1 $nick | .flush 1 }


on 50:TEXT:!quit*:*:{ /quit $battle.version }

on 1:START: {
  echo 12*** Welcome to Battle Arena Bot version $battle.version written by James "Iyouboushi" *** 

  /.titlebar Battle Arena version $battle.version written by James  "Iyouboushi" 

  if (%first.run = false) { 
    set %bot.owner $readini(system.dat, botinfo, bot.owner) 
    if (%bot.owner = $null) { echo 4*** WARNING: There is no bot owner set.  Please fix this now. 
    set %bot.owner $?="Please enter the bot owner's IRC nick" |  writeini system.dat botinfo bot.owner %bot.owner }
    else { echo 12*** The bot owner list is currently set to:4 %bot.owner 12***  |  

      var %value 1 | var %number.of.owners $numtok(%bot.owner, 46)
      while (%value <= %number.of.owners) {
        set %name.of.owner $gettok(%bot.owner,%value,46)
        .auser 50 %name.of.owner
        inc %value 1
      }
      unset %name.of.owner
    }

    set %battlechan $readini(system.dat, botinfo, questchan) 
    if (%battlechan = $null) { echo 4*** WARNING: There is no battle channel set.  Please fix this now. 
    set %battlechan $?="Please enter the IRC channel you're using (include the #)" |  writeini system.dat botinfo questchan %battlechan }
    else { echo 12*** The battle channel is currently set to:4 %battlechan 12*** }

    set %bot.name $readini(system.dat, botinfo, botname)
    if (%bot.name = $null) { echo 4*** WARNING: The bot's nick is not set in the system file.  Please fix this now.
    set %bot.name $?="Please enter the nick you wish the bot to use" | writeini system.dat botinfo botname %bot.name | /nick %bot.name }
    else { /nick %bot.name } 

    var %botpass $readini(system.dat, botinfo, botpass)
    if (%botpass = $null) { 
      echo 12*** Now please set the password you plan to register the bot with
      var %botpass $?="Enter a password"
      writeini system.dat botinfo botpass %botpass
      echo 12*** OK.  Your password has been set to4 %botpass  -- Don't forget to register the bot with nickserv.
    }

    if (%player_folder = $null) { set %player_folder characters\ }
    if (%boss_folder = $null) { set %boss_folder bosses\ }
    if (%monster_folder = $null) { set %monster_folder monsters\ }
    if (%zapped_folder = $null) { set %zapped_folder zapped\ }
    if (%npc_folder = $null) { set %npc_folder npcs\ }
    if (%summon_folder = $null) { set %summon_folder summons\ }
    if (%help_folder = $null) { set %help_folder help-files\ }
    if (%battleis = $null) { set %battleis off }
    if (%battleisopen = $null) { set %battleisopen off }

    if ($readini(system.dat, system, automatedbattlesystem) = $null) { writeini system.dat system automatedbattlesystem on } 
    if ($readini(system.dat, system, aisystem) = $null) { writeini system.dat system aisystem on } 
    if ($readini(system.dat, system, basexp) = $null) { writeini system.dat system basexp 100 } 
    if ($readini(system.dat, system, basebossxp) = $null) { writeini system.dat system basebossxp 500 } 
    if ($readini(system.dat, system, startingorbs) = $null) { writeini system.dat system startingorbs 1000 } 
    if ($readini(system.dat, system, maxHP) = $null) { writeini system.dat system maxHP 2500 } 
    if ($readini(system.dat, system, maxTP) = $null) { writeini system.dat system maxTP 500 } 
    if ($readini(system.dat, system, maxOrbReward) = $null) { writeini system.dat system maxOrbReward 20000 } 
    if ($readini(system.dat, system, maxshoplevel) = $null) { writeini system.dat system maxshoplevel 25 } 
    if ($readini(battlestats.dat, battle, LevelAdjust) = $null) { writeini battlestats.dat battle LevelAdjust 0 }
    if ($readini(system.dat, system, EnableDoppelganger) = $null) { writeini system.dat system EnableDoppelganger true }
  }

  if ((%first.run = true) || (%first.run = $null)) { 
    echo 12*** It seems this is the first time you've ever run the Battle Arena Bot!  The bot will now attempt to help you get things set up.
    echo 12*** Please set your bot's nick/name now.   Normal IRC nick rules apply (no spaces, for example) 
    set %bot.name $?="Please enter the nick you wish the bot to use"
    writeini system.dat botinfo botname %bot.name | /nick %bot.name
    echo 12*** Great.  The bot's nick is now set to4 %bot.name

    echo 12*** Please set a bot owner now.  
    set %bot.owner $?="Please enter the bot owner's IRC nick"
    writeini system.dat botinfo bot.owner %bot.owner
    echo 12*** Great.  The bot owner has been set to4 %bot.owner

    echo 12*** Now please set the IRC channel you plan to use the bot in
    set %battlechan $?="Enter an IRC channel (include the #)"
    writeini system.dat botinfo questchan %battlechan
    echo 12*** The battles will now take place in4 %battlechan

    echo 12*** Now please set the password you plan to register the bot with
    var %botpass $?="Enter a password"
    writeini system.dat botinfo botpass %botpass
    echo 12*** OK.  Your password has been set to4 %botpass  -- Don't forget to register the bot with nickserv.

    set %first.run false
    .auser 50 %bot.owner

    if (%player_folder = $null) { set %player_folder characters\ }
    if (%boss_folder = $null) { set %boss_folder bosses\ }
    if (%monster_folder = $null) { set %monster_folder monsters\ }
    if (%zapped_folder = $null) { set %zapped_folder zapped\ }
    if (%npc_folder = $null) { set %npc_folder npcs\ }
    if (%summon_folder = $null) { set %summon_folder summons\ }
    if (%help_folder = $null) { set %help_folder help-files\ }
    if (%battleis = $null) { set %battleis off }
    if (%battleisopen = $null) { set %battleisopen off }

    if ($readini(system.dat, system, automatedbattlesystem) = $null) { writeini system.dat system automatedbattlesystem on } 
    if ($readini(system.dat, system, aisystem) = $null) { writeini system.dat system aisystem on } 
    if ($readini(system.dat, system, basexp) = $null) { writeini system.dat system basexp 100 } 
    if ($readini(system.dat, system, basebossxp) = $null) { writeini system.dat system basebossxp 500 } 
    if ($readini(system.dat, system, startingorbs) = $null) { writeini system.dat system startingorbs 1000 } 
    if ($readini(system.dat, system, maxHP) = $null) { writeini system.dat system maxHP 2500 } 
    if ($readini(system.dat, system, maxTP) = $null) { writeini system.dat system maxTP 500 } 
    if ($readini(system.dat, system, maxOrbReward) = $null) { writeini system.dat system maxOrbReward 20000 } 
    if ($readini(system.dat, system, maxshoplevel) = $null) { writeini system.dat system maxshoplevel 25 } 
    if ($readini(battlestats.dat, battle, LevelAdjust) = $null) { writeini battlestats.dat battle LevelAdjust 0 }
    if ($readini(system.dat, system, EnableDoppelganger) = $null) { writeini system.dat system EnableDoppelganger true }
  }
}

on 1:CONNECT: {
  ; Start a keep alive timer.
  /.timerKeepAlive 0 300 /ctcp $me PING

  ; Join the channel
  /join %battlechan

  ; Send password
  var %bot.pass $readini(system.dat, botinfo, botpass)
  if (%bot.pass != $null) { /.msg nickserv identify %bot.pass }

  if (%battleis = on) { 
    if ($readini(battle2.txt, BattleInfo, Monsters) = $null) { $clear_battle }
    else { $next }
  }
  if (%battleis = off) { $clear_battle } 
}
