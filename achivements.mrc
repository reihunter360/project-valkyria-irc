;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ACHIEVEMENTS 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias achievement_check {
  if ($readini($char($1), info, flag) != $null) { return } 
  if (%achievement.system = off) { return }

  $achievement_already_unlocked($1, $2) 

  if (%achievement.unlocked = true) {  unset %achievement.unlocked | return  }

  $set_chr_name($1)

  if ($2 = BossKiller) {
    var %black.orbs.spent $readini($char($1), stuff, BlackOrbsSpent)
    if (%black.orbs.spent >= 200) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 5000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = BigSpender) {
    var %red.orbs.spent $readini($char($1), stuff, RedOrbsSpent)
    if (%red.orbs.spent >= 1000000) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 5000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = BattleArenaAnon) {
    var %red.orbs.spent $readini($char($1), stuff, RedOrbsSpent)
    if (%red.orbs.spent >= 100000000 ) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 10000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 10000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = SirDiesALot) {
    var %total.deaths $readini($char($1), stuff, TotalDeaths)
    if (%total.deaths >= 100) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1)
      var %current.goldorbs $readini($char($1), item_amount, GoldOrb) | inc %current.goldorbs 1 | writeini $char($1) Item_Amount GoldOrb %current.goldorbs
    }
  }

  if ($2 = Don'tYouHaveaHome) {
    var %max.shop.level $readini(system.dat, system, maxshoplevel)
    if (%max.shop.level = $null) { var %max.shop.level 25 }

    var %shop.level $readini($char($1), stuff, shoplevel) 

    if (%shop.level >= %max.shop.level) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 1000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = MakeMoney) {
    var %number.of.items.sold $readini($char($1), stuff, ItemsSold)
    if (%number.of.items.sold >= 500) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 3000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 3000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = ScardyCat) {
    var %number.of.flees $readini($char($1), stuff, TimesFled)
    if (%number.of.flees >= 300) {
      $announce_achievement($1, $2, 1)
      var %current.goldorbs $readini($char($1), item_amount, GoldOrb) | inc %current.goldorbs 1 | writeini $char($1) Item_Amount GoldOrb %current.goldorbs
    }
  }

  if ($2 = Cheapskate) {
    var %number.of.discounts $readini($char($1), stuff, DiscountsUsed)
    if (%number.of.discounts >= 5) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 5000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = Can'tKeepAGoodManDown) {
    var %number.of.revives $readini($char($1), stuff, RevivedTimes)
    if (%number.of.revives >= 10) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 5000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = MonsterSlayer) {
    var %number.of.kills $readini($char($1), stuff, MonsterKills)
    if (%number.of.kills >= 500) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1)
      var %current.apples $readini($char($1), item_amount, SilverApple) | inc %current.apples 1 | writeini $char($1) Item_Amount SilverApple %current.apples

    }
  }

  if ($2 = PrettyGemCollector) {
    var %total.mtog $readini($char($1), stuff, MonstersToGems)
    if (%total.mtog >= 200) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1)
      var %current.goldorbs $readini($char($1), item_amount, GoldOrb) | inc %current.goldorbs 1 | writeini $char($1) Item_Amount GoldOrb %current.goldorbs
    }
  }

  if ($2 = MasterOfUnlocking) {
    var %total.chests $readini($char($1), stuff, ChestsOpened)
    if (%total.chests >= 100) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5)
      var %current.goldkeys $readini($char($1), item_amount, GoldKey) | inc %current.goldkeys 5 | writeini $char($1) Item_Amount GoldKey %current.goldkeys
    }
  }

  if ($2 = Santa'sLittleHelper) {
    var %number.of.gifts $readini($char($1), stuff, ItemsGiven)
    if (%number.of.gifts >= 20) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 1000)
      var %current.redorbs $readini($char($1), stuff, redorbs) | inc %current.redorbs 1000 | writeini $char($1) stuff redorbs %current.redorbs
    }
  }

  if ($2 = AreYouTheKeyMaster) {
    var %number.of.keys $readini($char($1), stuff, TotalNumberOfKeys)
    if (%number.of.keys >= 100) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 5)
      var %gold.keys $readini($char($1), item_amount, GoldKey) | inc %gold.keys 5 | writeini $char($1) item_amount GoldKey %gold.keys
    }
  }

}

alias achievement_already_unlocked {
  if ($readini($char($1), achievements, $2) = true) { set %achievement.unlocked true }
}

alias announce_achievement { $set_chr_name($1) | query %battlechan $readini(translation.dat, achievements, $2) }
