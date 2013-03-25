;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; BASIC CONTROL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

raw 421:*:echo -a 4,1Unknown Command: ( $+ $2 $+ ) | echo -a 4,1Location: %debug.location | halt

on 1:QUIT: {  .auser 1 $nick | .flush 1 }
on 1:EXIT: {  .auser 1 $nick | .flush 1 }
on 1:PART:%battlechan:.auser 1 $nick | .flush 1
on 1:KICK:%battlechan:.auser 1 $knick | .flush 1 
on 1:JOIN:%battlechan:{  .auser 1 $nick | .flush 1 }
on 3:NICK: { .auser 1 $nick | mode %battlechan -v $newnick | .flush 1 }
on *:DNS: { 
  if ($isfile($char($nick)) = $true) { writeini $char($nick) info lastIP $iaddress  }
  set %ip.address. [ $+ [ $nick ] ] $iaddress
}

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

    $system_defaults_check
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

    $system_defaults_check

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


on 50:TEXT:!debug dump*:*:{ 
  var %debug.filename debug_dump $+ $day $+ $rand(a,z) $+ $rand(1,1000) $+ $rand(a,z) $+ .txt
  .copy remote.ini %debug.filename

  write %debug.filename ------------------------------------------------------
  write %debug.filename debug location: %debug.location 
  write %debug.filename battlefield: %current.battlefield
  write %debug.filename boss type: %boss.type 
  write %debug.filename portal bonus: %portal.bonus 
  write %debug.filename holy.aura: %holy.aura 
  write %debug.filename five min warning: %darkness.fivemin.warn  
  write %debug.filename battle.rage.darkness: %battle.rage.darkness 
  write %debug.filename battle conditions: %battleconditions 
  write %debug.filename ai target: %ai.target
  write %debug.filename ai tech: %ai.tech

  $display.system.message(4Variables File dumped as file: %debug.filename, private)
}
