##### Nov 13 2017, 21:17
https://www.celestialheavens.com/forum/10/16657?p=369458#p369458

Hello.

Here is thing i did for past time: merge of mm6, mm7, and mm8 on base of mm8 using MMExtension.

##### Nov 18 2017, 0:20
https://www.celestialheavens.com/forum/10/16657?p=369486#p369486

Have small update, mainly with fixes, notes inside, link in first post.

> mimickxd wrote:
> 
> Well, for now as I can see, we have only humans to choose. Will you change it?

Minotaurs and Dark Elfs added in update.

##### Nov 18 2017, 21:39
https://www.celestialheavens.com/forum/10/16657?p=369493#p369493

> tomchen1989 wrote:
> 
> When I right click on a made potion (without holding any item), instead of showing its description, it usually explodes as if I mix another wrong potion with it. However about 20% of the time, it shows the description correctly

Fixed in today's patch, updated link in the first post, thanks.

##### Nov 19 2017, 9:08
https://www.celestialheavens.com/forum/10/16657?p=369496#p369496

> asthrab wrote:
> 
> In Antagrich, when I was about to finish Warrior Mage quest, I got a debug error screen. My Archer got promoted but I can't access to the sniper's quest

Archer promotions fixed, thanks. Apply last update and load previous savegame, or press ctrl+F1 and execute (ctrl+enter) this code to get topic back:
```
evt.SetNPCTopic{380, 1, 819}
Party.QBits[543] = false
Party.QBits[1584] = true
Party.QBits[1585] = true
```

##### Nov 19 2017, 18:53
https://www.celestialheavens.com/forum/10/16657?p=369498#p369498

> asthrab wrote:
> 
> Colony Zod: After releasing Roland Ironfist the route in 1F is not opened + Roland didn't give any key... Prince of Thieves: Seems I can't find the entrance to the Free Haven Sewer? (already checked all House in Free Haven)

Fixed, apply new patch.

> asthrab wrote:
> 
> Silver helm Outpost: the key needed for gharik's forge is not in the chest.

Fixed, thanks. Chests are refilled each map's refill day or at first visit, to avoid waiting or reloading, execute this code in debug console, while you are inside Silverhelm outpost and reenter map:

`Map.IndoorLastRefillDay = 0`

##### Nov 20 2017, 17:39
https://www.celestialheavens.com/forum/10/16657?p=369509#p369509

> Phobos wrote:
> 
> Some of the barrels seem to provide the wrong stats, at least in Enroth. A yellow one said it increased Accuracy by 2 but raised Intellect instead. Purple ones increase Accuracy, orange ones increase Endurance and green ones increase Speed... Also, when I create a full party of characters, characters 2-5 start at level 10 instead of level 1 with 100000 experience points. Maybe this wasn't the intention?

Fixed in today's patch, thanks.

##### Nov 21 2017, 21:47
https://www.celestialheavens.com/forum/10/16657?p=369531#p369531

Arena, rogue promotion, knight promotion at Enroth, challenges and some travel issues fixed in today's patch, did few tweaks in class tables. Arcomage also fixed. Arcomage championships require to win only in taverns of current continent (11 taverns in Jadam, 13 - in Antagrich, no championship in Enroth). Wins are marked in the autonotes, but you'll have to play arcomage matches again after this patch. Thanks.

##### Nov 23 2017, 8:04
https://www.celestialheavens.com/forum/10/16657?p=369565#p369565

Some minor issues in promotions fixed in last patch. Lich transformation and immunities too. Fixed item enchanting and piligrimages. Thanks.

> Phobos wrote:
> 
> Judge Grey won't die for me... I've waited 5-6 months after fixing the castle, did Elf King and Catherine's quests and brought Judge Grey the Trumpet in May. It's September, and he is still alive and kicking :D Should I wait longer?

Ouch, i've forgot about this way to get rid of Trumpet. Apply last patch, messenger dialog should appear right at next visit to Harmondale.

> kristal wrote:
> 
> Do not work membership in guilds!

Added in last patch.

##### Nov 24 2017, 22:58
https://www.celestialheavens.com/forum/10/16657?p=369592#p369592

Messed up with challenges and Jadam lich promotion, fixed it, but have not put into update, should work now. Obelisk treasure of Antagrich (and "Temple in a bottle") fixed, thanks.

##### Nov 25 2017, 20:06
https://www.celestialheavens.com/forum/10/16657?p=369606#p369606

Apply today's update: no more bugged gold; now challenges display correct number of given skill points in status text; sets of skills available to learn in guilds are corrected; some tweaks in boat-travelling - it should not give bugs anymore.

##### Nov 28 2017, 22:45
https://www.celestialheavens.com/forum/10/16657?p=369606#p369641

I've found issue of Town portal. Hope it won't behave this way anymore. In new games town portal locations won't be suddenly opened. Voices and resistances of liches fixed, though they don't get +20 after transformation, thier resistances became 20 if they were lower before. Some values of monster's AI corrected. Did some changes in challenges, try it. Thanks.

##### Dec 2 2017, 10:33
https://www.celestialheavens.com/forum/10/16657?p=369668#p369668

Patch link in first post updated. A lot of corrections in challenges: distribution, rewards and requirments, thanks very much. Adventurer's Inns placed in Free Haven and Tatalia (near mercenary guild). Some minor fixes. Fixed original bug which caused game crashes because of high amount of summoned monsters on map.

Note: Added AdaptiveMonstersStats.lua script and two tables: "Bolster - monsters.txt" and "Bolster - maps.txt". Script trying to bring monsters in line with overlevelled party (or close to it), using rules form text tables. I'll add readme a bit later. If it will provide gamebreaking behaivor - put script outside of script folder.

##### Dec 4 2017, 7:12
https://www.celestialheavens.com/forum/10/16657?p=369686#p369686

Additional way to cross continents added in today's update, some details in patch notes txt file. Some minor fixes about objects summoning and equipment appearance.

> Lucius wrote:
> 
> And not so minor: Alvar tree X-15440, Y-19600 which was giving unlimited 'STAT boost' potions for character with 7+ master repair does not do it (and does not work for perception character as well)

Fixed, but was it supposed to give unlimited amount of potions, not just one? According to original scripts, it is.

##### Dec 6 2017, 23:06
https://www.celestialheavens.com/forum/10/16657?p=369716#p369716

Elf females added into selection roster of Enroth and Antagrich in today's patch, they will appear as mercenaries as well, some tweaks in monster's txt (some mm6 monsters getting back ranged attacks), thanks.

> Lucius wrote:
> 
> Melody Silver didn't leave party after Crusader promotion in MM6 and therefore stays forever.

Fixed, speak with Humphry again to remove her.

> Lucius wrote:
> 
> Also, Bug with Light guild in Murmurwoods: it says "You must be member of the guild to study there"
> 
> After I dismissed Cauri in Murmurwoods once, she is gone forever and not presen at any Jadame adventurer inn

Should not happen again after today's patch.

To return Cauri: press ctrl+f1 to open debug console, type: `vars.MercenariesProps[30].CurContinent = 1` , -press ctrl+enter to execute this, she'll appear at Jadam's adventurer's inn next time you'll enter map with it.

##### Dec 7 2017, 10:45
https://www.celestialheavens.com/forum/10/16657?p=369725#p369725

Link for latest patch updated - fix for recent troubles (Zombies in Dejya, mm6 sprites, voices, arena, cleric promo; not mm6 fountains and not items-multiplying during party creation).

##### Dec 8 2017, 5:11
https://www.celestialheavens.com/forum/10/16657?p=369739#p369739

Few fixes: magic pedestals; reagents checks for "black potion" quests; sudden friendly monsters in dungeons and their relations; misspells. Thanks.

##### Dec 9 2017, 7:18
https://www.celestialheavens.com/forum/10/16657?p=369748#p369748

Patch link is updated. Item enchantment and mercenary inventories improved. Fixed doors in Temple of Baa, try it again (it did check only skill of first player before). Eel Infested Water should allow to fly now.

##### Dec 15 2017, 8:53
https://www.celestialheavens.com/forum/10/16657?p=369820#p369820

Link to update in first post have been updated. Fixed issue with Mercenary guild side quest in MM7 (triggered by accepting Malwick's fireball wand) - messenger will show up next second visit to Harmondale; Crafters now accept ore from both Jadame and Antagarich: Fixed Acolytes of Baa behaivor and reputation gain in MM6; MM7 afrtifacts (except armors) have been rescripted and will eventually appear in rarest chests, thanks everyone.

##### Dec 15 2017, 21:19
https://www.celestialheavens.com/forum/10/16657?p=369836#p369836

Patch link have been updated, thanks.

##### Dec 17 2017, 1:13
https://www.celestialheavens.com/forum/10/16657?p=369858#p369858

Nicolai's quest and some traveling issues fixed in todays patch, thanks (Nicolai should disappear in one hour of gametime after next game launch).

##### Dec 19 2017, 8:41
https://www.celestialheavens.com/forum/10/16657?p=369884#p369884

New update with some recent fixes is in first post (new artifact's bonuses, black potions hunt and some other), thanks.

##### Dec 21 2017, 22:53
https://www.celestialheavens.com/forum/10/16657?start=180#p369916

Patch's link updated. Fixed divine intervention issue and few other minor bugs, refined Wine cellar and Temple of Baa in Antagarich.

> Phobos wrote:
> 
> Any idea how to fix this so the spells are given to the 1st slot too?

Seems game did not have item list for such case, fixed in today's update.

##### Dec 24 2017, 0:47
https://www.celestialheavens.com/forum/10/16657?p=369942#p369942

Patch link updated. Original sp regen repaired, few fixes in mm6 and mm7 maps and transitions, resistances of mm6 monsters have been changed. I've reproduced UI issue by immediate interrupting rest, but could not figure out how to fix it for now, waiting one-two seconds before interrupt should prevent it.

##### Jan 18 2018, 14:53
https://www.celestialheavens.com/forum/10/16657?p=370163#p370163

Hello, sorry for the delay, some things takeing longer than i expected, i have not drop anything.

Some fixes in today's patch (Alvarian guild and Castle Harmondale won't remove your items anymore, fixes in MM6: Eric's animation and Warlock with Ankh crash). First character's unlimited delay won't happen anymore, that was caused by some effects of MM6 artifacts, fixed now.

##### Feb 4 2018, 15:21
https://www.celestialheavens.com/forum/10/16657?p=370282#p370282

Hello, patch link have been updated. Four new paperdolls added (elfs, man and woman), fixed issue with jumps on non-flat structures in outdoor maps, NWC dungeon in mm6 now gives correct items. I've maden some changes in RemoveHouseRulesLimits.lua, it may affect recent problems with shops, but may not, tell me. Fixed issue with shops in russian localization, redownload and reapply it, thanks.

##### Feb 10 2018, 23:37
https://www.celestialheavens.com/forum/10/16657?p=370392#p370392

Patch link have been updated. Hirelings will refuse to join, if your party is full; resistances of Priests fixed, these 5 points goes to trolls, as it should have to be; missing dark elf is back in selection roster and Shrine of Gods bonus now gives additional resistances; amazing Jamesx' MM6 portraits have been added into game; jump height won't increase over time (i love these funny issues, and feel sad about fixing them; floating cactuses in arena are out of competition though). I did not check cauldrons in temple of Baa, bow skill, and i could not reproduce issue with circus for now, i'll try to find it's reasons and fix them in next update, thanks.

##### Feb 20 2018, 2:20
https://www.celestialheavens.com/forum/10/16657?p=370497#p370497

Patch link have been updated: fixed some items amd arcomage rewards multiplifications; "Of Regeneration" works fine now; Sniper's promotion fixed - talk with Snick again to get quest; Cutscenes about dragon hunters/dragons in MM8 now should work fine; Unarmed and Dodging masters now spell correct texts; cauldrons fixed; I can not reproduce issue with crashes in guilds, but i've changed something, what could cause that, tell me if it helped. Amazing Jamesx' character conversions are implemented in game, we have Goblin race now, but i have not reviewed artifacts yet, so restrictions may not fit item's descriptions. Bow and Disarm skills issues stays for now.

##### Feb 23 2018, 15:27
https://www.celestialheavens.com/forum/10/16657?p=370527#p370527

Patch link is updated - recent bugfixes.

Haha, I think that "boothead" bug shall stay in game. Character with "this" will be able to enter somekind of secret level by using sneaky launchpad at Castle Ironfist (fixed).

##### Mar 4 2018, 20:34
https://www.celestialheavens.com/forum/10/16657?p=370641#p370641

Patch link have been updated, some recent tweaks, plus MouseLook workaround for win10, inspect point five in "known bugs/issues" section in first post.

> justl wrote:
> 
> in mm6, when you wanna id monster gerrard blackames in the silverguards castle, the game crashes.

This was fixed before, issue may stay in old savegames, but will disappear after next map refill.

MM6 map transitions fixed.

##### Apr 1 2018, 16:01
https://www.celestialheavens.com/forum/10/16657?p=371025#p371025

Hello, patch link have been updated. Aside of recent bugfixes, few things have been added:
- implemented main part of cross-continet quests (except one that involves new maps);
- weather effects and monster bolsterizer can be toggled/adjusted through in game controls menu - do not remove/rename gamefiles anymore;
- magic guild have been added to Regna;
- stories of other continents will start in more senseful way now.

Some adjusts were made in artifacts, skills should not be boosted too much from now, thanks.

It is not april fool's joke.

New quests are compatible with old savegames, but may look a bit distracting: some events may happen right away and some maps will require refill for quest items to appear.

Toggling/adjusting bolster will take effect after changing map or loading saved game.

##### Apr 8 2018, 15:52
https://www.celestialheavens.com/forum/10/16657?p=371141#p371141

Hello. Patch link have been updated, some recent bugs fixed (cloaks, attack recovery), except mm6 black potions.

Added proper reward for additional cross-continent quest and modified behaivor of regeneration spell and skill. Crystals in mm6 dungeons can now be harvested with right amount of perception skill, I did not know about this possibility, thanks for noticing.

Links to German, Russian and Polish localizations added into first post, more details there. Thanks everyone, who sent me gamefiles.

##### Apr 10 2018, 13:38
https://www.celestialheavens.com/forum/10/16657?p=371161#p371161

Patch link updated, black potions in Darkmoor fixed (patch will take effect after map refill), dragon ability's bonuses and identify monster skill should work correctly now. I've noticed line shifts in localization files, redownload and reapply localization if you use it.

> Dess wrote:
> 
> *If you start with a "pure MM6 party" in Enroth, you cant get anything better than Basic disarm trap (Knight/Archer) without altering the files.

Added Expert for Warrior mage and Master for second archer's promotion.

##### Apr 15 2018, 14:06
https://www.celestialheavens.com/forum/10/16657?p=371216#p371216

Hello, patch link is updated. Only minor fixes this time and one little tweak for tests.

I've played through Regna with mage, cleric, dark elf and two fighters, all of them performed good except mage, he litteraly run out of mana after second encounter and became useless. One one hand, encounters were oblitterated very fast and other party members almost were not involved, so maybe I've used mage wrong, on other, what else he could do if 90% of sorcerer's spells are offensive? To bring him back in line i had to either exit dungeon and rest or continiously drink mana potions, it is ok, point which disturbs me is: he has three items for mana regeneration, each restores 1 SP per 5 min, it is 5 rounds in tactical mode, what makes him unable to cast even basic spells. I'm changing my mind about voiced idea about percent-based mana regeneration by meditation skill. Problem is, i don't know how run-out-of-SP situations supposed to be handled correct way, i did not notice basic mana regen in any MM (not even in MM10), how do you think, why developers of original games have not implemented it?

In this update i've made tweak: meditation restores SP, formula: SP = SP + FullSP*0.25*2^(Mastery-1)/100, so skill level affects only mana pool, mastery affects regeneration speed: 0.25% at basic level, 0.5% at expert, 1% at master, 2% at grandmaster. It should bring sense to investing skillpoints into meditation and since grandmaster meditation is exclusive for Warlock/Druid, it also shold make these classes more viable and uncommon: they will have biggest mana pool and regen rate (2%), what allows them to spam some spells, which weaker than analogs of Sorcerer/Cleric. And it is not that much to allow spam sharpmetal, for example. Tell me, if it this tweak breaks game or changes combat approach too much.

> justl wrote:
> 
> > Crystals in mm6 dungeons can now be harvested with right amount of perception skill
> how much perception would that need? lvl 7 at master level doesnt seem to suffice.

Accidently I've set it to 10. Now it is 7 skill level, mastery does not matter.

##### Apr 22 2018, 15:46
https://www.celestialheavens.com/forum/10/16657?start=440#p371318

Hello, patch link have been updated, only minor fixes this time. Random hirelings are prevented for appearing with same classes in row now, so more chances to get what you want (i am thinking for additional special class, which's only ability is being able to be promoted to any other basic class, - like recruit who can become knight/cleric/vampire/thief/ranger etc. Nothing except thoughts now). I'll look what can be done with reputation.

Limits of monsters-per-map should be removed now, original values were 500 monsters and 30 of them active, now these can be adjusted. Though, when i've summoned 4500 goblins in New Sorpigal and 500 guards to beat them, my game transformed into slideshow. Note, script is in test state for now, it is disabled by default, to enable it, open "...Scripts\Structs\After" folder, find file name called "RemoveMapMonstersLimits.lua.off" and rename it into "RemoveMapMonstersLimits.lua" (remove ".off"). I've set new limit to 1500 monsters per map and 500 of them active, you can change these values at first lines of script, just open it with any text editor.

I've made little dragon hunters vs nagas warfare to test it (very rough video).

Script template to do the same (open debug console with ctrl+f1 paste code and press ctrl+enter to execute):
```
 floor, rnd = math.floor, math.random
 monT1 = 44 -- Monster type: Crusader
 monT2 = 171  -- Monster type: Naga
 X, Y, Z = XYZ(Party)

-- Force monsters to hate each other
 Game.HostileTxt[floor(monT1/3)][floor(monT2/3)] = 4
 Game.HostileTxt[floor(monT2/3)][floor(monT1/3)] = 4

-- 200 is amount of monsters to summon. Put in diffrent cycles to make diffrent amounts.
 for i = 1, 200 do
    mon = SummonMonster(monT1, rnd(X - 2000, X + 2000), rnd(Y - 2000, Y + 2000), Z + 200)
    mon.Group = 11
    mon = SummonMonster(monT2, rnd(X - 2000, X + 2000), rnd(Y - 2000, Y + 2000), Z + 200)
    mon.Group = 12
 end
```

##### Apr 30 2018, 19:09
https://www.celestialheavens.com/forum/10/16657?p=371436#p371436

Patch link have been updated. Chest in "The Mists" have been fixed, for sure now. I thought challenges beacons supposed to reset each two years, disabled it. Monster scaling have been tweaked a lot: monster kinds now scaled at once, monsters properly gain bonuses to speed movement, AC bonus reduced, chance to hit player now affected by bolster too. Thanks.

Boats do not ship to other continents anymore.

##### May 3 2018, 21:44
https://www.celestialheavens.com/forum/10/16657?p=371513#p371513

Hello, patch link have been updated. I've added new item values, thanks to Xfing. Note: if you use any localization, reapply it's EnglishT.lod as well to make changes happen. Also few fixes, including artifacts doubles and clubs.

##### May 10 2018, 20:06
https://www.celestialheavens.com/forum/10/16657?p=371598#p371598

Patch link have been updated. Unique items were tweaked to match new values, Arena will choose monsters more carefully now, cleric in Jadame will get proper promotion, thanks.

##### May 27 2018, 17:58
https://www.celestialheavens.com/forum/10/16657?p=371732#p371732

Hello, sorry for delay. Patch link have been updated. Items should be corrected now, steps in Dragonsand (and other snady mm6 locations) won't sound as water anymore, skull piles will work now. I've added few new maps, which finishes Verdant's story, if you've already finished stories of all three continents, she will catch you within week of game time (maps might have bugs, notice me, if i've missed something).

Note: first launch will take longer than usual, and don't forget to redownload and reapply localization if you use it.

##### Jun 1 2018, 3:11
https://www.celestialheavens.com/forum/10/16657?p=371764#p371764

Patch link have been updated, just one important fix there, it is enough to download "Scripts" folder and "SFT.txt" from "Data\Tables" folder. In hardware mode game crashed because of new monster (what quiet ironically, if you remember "arena's cactus glitch"), also fixed issue with bolstering already bolstered monsters.

Reactors are vulnerable only for blasters, but only in Enrothian Hive, they should not appear anywhere else anymore (even in Arena). I have not change other points yet.

##### Jun 9 2018, 3:49
https://www.celestialheavens.com/forum/10/16657?p=371852#p371852

Hello, patch link have been updated. Clanker's laborathory now accessible even after Archiebald gets there, having wetsuit in inventory will grant player "water breathing" buff, "Saving Goobers" quest won't disappear again, fruit bowls will work now, and transition texts for some mm6/7 maps have been restored, mm6/7 bounty hunts will increase "monsters hunted" value and will correctly shown in "awards" section of character's sheet (in old savegames you have to complete at least one more bounty hunt to make it appear), fixed issue with Jadamean priest promotion, monsters will correctly cast Dispel now. Blaster have their factial min recover time at 5, but value shown in character's sheet won't be lower than 30 for now, also wands won't make hit sound after passing turn by "B" button, but i have not solved issue yet, it is temporary workaround, sounds still will appear, if player have club in hand. Thanks.

##### Jun 23 2018, 16:19
https://www.celestialheavens.com/forum/10/16657?p=371992#p371992

Hello. Patch link have been updated. Generaly only minor fixes this time: no more issues with sounds of wands/clubs, few correction in removal of quest notes, fixed issue with cleric generation in Jadame (and all other classes with uneven class index).

##### Jul 15 2018, 12:43
https://www.celestialheavens.com/forum/10/16657?p=372154#p372154

Hello, patch link have been updated, only minor fixes this time (Shrine of the Gods, Bounty hunt in indoor maps and few other).

##### Jul 28 2018, 13:43
https://www.celestialheavens.com/forum/10/16657?p=372273#p372273

Hello. Patch link have been updated, .evt scripts from new GrayFace's patches have been implemented, mega dragon - too. I've added eyelights for lich's spellcast animation. I will have more free time soon and going to review problems with stacking of item bonuses and changes in maps. Thanks.

##### Aug 5 2018, 11:07
https://www.celestialheavens.com/forum/10/16657?p=372332#p372332

Hello, patch link have been updated. I've rechecked evt scripts, try again if you had issues before; inventory of random hirelings won't be broken anymore; maps will remember state of their weather effect upon leaving/entering and loading saved game; Algorythm of entering Castle Lambent and Castle Gloaming throne rooms was altered, i hope you won't stuck with forever hostile monsters anymore - you'll always be able to enter if there are no hostiles around (hostile indicator is green); I could not reproduce issues with stacking bonuses of armors and weapons for now, if possible, send me your savegame; same with black potions - in my tests characters could not drink same potion twice; I have not fixed issue with increased height of second and further jumps yet. Thanks.

##### Aug 12 2018, 16:05
https://www.celestialheavens.com/forum/10/16657?p=372396#p372396

Hello. Patch link have been updated - only minor fixes this time (dimension doors will work with any .odm files now).

##### Sep 4 2018, 2:30
https://www.celestialheavens.com/forum/10/16657?p=372555#p372555

Hello. Patch link have been updated, few bugs have been fixed and base for mm67-alike npc hirelings have been added, details below.

Bug with mm7 ending should be fixed now. If you playing light side, speak with Resurectra again and check chests, wetsuits should appear. If you playing dark side and Verdant does not recognize ending of mm7 story, only way is to use debug console to repair save game, sorry. Open it with ctrl+f1 and execute this code with ctrl+enter:
```
Party.QBits[783] = true
```
I've added three lines to Class.txt from EnglishT.lod, so reapply localization files if you use them.

@Roor add new lines to Class.txt of spanish localization, please.

After this update you will be able to hire npc on streets of major towns (everywhere in Enroth, in Steadwick, Avlee, Deyja, Harmondale and Pierpont in Erathia and in Ravenshore, Alvar and Balthazar's lair in Jadam). There are two kinds of hirelings: 1st is classic npc followers from mm6/7, at current moment only few of them working (healers, spellcasters, cooks) and their texts are not localizated; 2nd is peasants - these will join in main frame of your party as active players with class "Peasant", skill teachers can promote them to any first step of other advanced classes (even to vampires). Peasants are always level 1 with 0 exp, with only four skills. Also you can start game as peasant, just why not. I hope it will solve problem with party customization.

##### Sep 15 2018, 13:50
https://www.celestialheavens.com/forum/10/16657?p=372801#p372801

Hello, patch link have been updated.

There are some minor fixes: traps in Basement of the Breach won't fire limitless if you can not disarm them; dimension door at Evenmorn island will trigger as soon as party approach guild of water; potion-hunt quests will work in better way now, there's no option to remove quest notes in current savegames without using debug console, but in new games this problem should not appear again (powerless potions have not been fixed yet, black potion of speed - too); not sure if random crashes have been fixed completely, but there are some tweaks to affect them. Thanks.

NPC-hirelings will work in same way as mm6/7 ones, also flag "joins" in NPCData.txt now work as it should, any NPC with this one will be able to join you, even ones without profession. MM6 hirelings with "Joins" flag have been restored, but they'll start to work only in new games and most of their abilities have not been rescripted yet.

Outdoor peasants will work in a more mm6/7 way: most of them will have names and professions, they still will tell news as simple peasants did, special news can be added by filling "News topics - ..." tables in "Data" folder.

I have not been able to reproduce issue with item enchanting in Barrow Downs causing crashes, if you have savegame with those corrupted items, send it to me, please.

##### Sep 23 2018, 20:13
https://www.celestialheavens.com/forum/10/16657?p=372941#p372941

Hello, patch link have been updated. Many profession's effects works now, and finally npc will take % of money you find. Some other minor things fixed. Thanks.

> GrayFace wrote:
> 
> Here are some additions: DataFiles are there to eliminate 1st startup delay.Data folder for MM6 water.Scripts folder is for a script that sets up proper color correction based on continent. Otherwise colors in MM7 in particular are way off compared to original. I have however tweaked these multipliers to my liking, because why not, the merge should feel fresh after all. I should probably make the script read these values from a table in Data\Tables.Another script is SwitchGold.lua which makes MM6 and MM7 have their gold piles rather than 

Thanks. I've put things in update, but tweaked colors a bit: mm7 looked too desaturated compared to other continents.

> GrayFace wrote:
> 
> "Fix jumping on nonflat structures in outdoor maps" about doubles jump height. First jump goes normally, subsequent jumps are higher.

Yes, but without it, party can not jump on outdoor 3d objects at all, I have not found better solution yet, but want to keep this, because final quest takes place in huge 3d object in outdoor map, where jumping is important.

> GrayFace wrote:
> 
> I've tried an older version of the merge that I have together with the in-the-works version of my patch and there's a conflict between merge's hook at 0046C0A2 and mine at 46C09E. 

Disabled in today's update.

##### Sep 30 2018, 4:45
https://www.celestialheavens.com/forum/10/16657?p=373091#p373091

Hello, patch link have been updated. No idea why I have not thought about "dismiss" button in adventurer's inn, now it is there and allows to easily manage hirelings, thanks. Note, if you'll "dismiss forever" original mm8 characters, they won't come back too, their spots will be taken by random hirelings, so it is the way to get more than 8 random ones.

MM6-alike base for reputation and Beg/Threat/Bribe system have been added. Town halls do not allow to pay fine for now, - temples are only way to clear sins at the moment. Reputation system can be tweaked in new txt table - "Continent settings.txt" as well as saturation and softness values.

Extra water frames and new armors have been added and their effects are rescripted (though, I've combined woman's variation of chainmails and Hareck's leather with mm8 pants, dark elf paperdolls looked weird otherwise), thanks.

I like new plate armors: two more with leg parts for minotaur.

##### Oct 3 2018, 3:50
https://www.celestialheavens.com/forum/10/16657?p=373180#p373180

Hello, patch link have been updated. I've noticed some bugs which lead to crash or constant pop of debug console, if you've encountered any of these - apply update. Also few new profession-effects have been rescripted.

##### Oct 5 2018, 22:56
https://www.celestialheavens.com/forum/10/16657?p=373230#p373230

Hello, patch link have been updated. "NPC Professions" and "NPC BTB" are now localized, and few minor fixes as well. Reapply localization files after this update. @Roor I've changed only "NPCText.txt" table from "EnglishT.lod", texts from "NPCbtb.txt" (mm6) and "NPCprof.txt" (mm6) are there now.

Lists of nonlocalized texts and nonconverted armors have been added in first post. Thanks.

##### Oct 8 2018, 15:34
https://www.celestialheavens.com/forum/10/16657?p=373308#p373308

Hello. Patch link have been updated. There is just one important fix, which should prevent destruction of mercenaries' inventories. If you currently have character with broken inventory, only way to repair him - through console.
1. Open his inventory screen.
2. Drop or move to other inventories items you need.
3. Execute code (ctrl+f1 to open, ctrl+enter to execute):
```
Char = Party[Game.CurrentPlayer]
for i,v in Char.Inventory do
   Char.Inventory[i] = 0
end
for i,v in Char.EquippedItems do
   Char.EquippedItems[i] = 0
end
for i,v in Char.Items do
   v.Number = 0
end
```
Inventory will be cleared out of all items he had (i.e. corrupted ones), new items will be added correctly.

##### Oct 13 2018, 13:24
https://www.celestialheavens.com/forum/10/16657?p=373441#p373441

Hello, patch link have been updated - only minor fixes this time. Blaster is fixed now.

##### Oct 21 2018, 16:12
https://www.celestialheavens.com/forum/10/16657?p=373626#p373626

Hello, patch link have been updated. Mainly minor fixes. Verdant's "Guiding gem" quest now should work correctly even if you use localization. I've added two armors converted by Kristal, thanks. But i want to ask for future conversions: add pants or skirt for female variation of armor if picture does not have it (I've added for these two), - it is not just my opinion, that's how all mm8 armors works and look alike.

##### Oct 27 2018, 18:29
https://www.celestialheavens.com/forum/10/16657?p=373722#p373722

Hello, patch link have been updated. There are empty chests in Breach now, reputation topics have been corrected, dodge by unarmed skill will work correctly now.

##### Nov 12 2018, 3:13
https://www.celestialheavens.com/forum/10/16657?p=373937#p373937

Hello. Thank you very much for new portraits and armor conversions.

Patch link have been updated. Monk promotion quest fixed, for sure now. Game will show mm6/7 loading screens according to continent you playing on (you can edit list of loading pictures in "Continent settings.txt" table in "Data\Tables" folder). Game now will correctly show skills you are able to learn on further promotions, i.e. for example, master and grand master elemental spell schools will be shown as yellow. And couple of other minor fixes.

New portraits have not been implemented yet, as well as new armors. I've found zombie mechanics were totally ripped off from mm8, even though character can have condition "zombie", he still will be able to rest, he won't get stats penalties, and temples won't cure this condition. I need some time to make it work, as it should.

##### Nov 19 2018, 17:58
https://www.celestialheavens.com/forum/10/16657?p=374054#p374054

Hello, patch link have been updated, zombies are in game now and should behave like in mm7. I hope there is not, but if you encountering any zombie-related gamebreaking bug, remove "ZombiePlayers.lua" from "Scripts\General" folder.

Face animations will work correctly again, and skill teachers will mention 3rd and further steps of promotion you have to get to learn skill.

##### Nov 25 2018, 16:07
https://www.celestialheavens.com/forum/10/16657?p=374120#p374120

Hello, patch link have been updated. Only minors this time.

##### Dec 1 2018, 17:06
https://www.celestialheavens.com/forum/10/16657?p=374202#p374202

Patch link have been updated.

Dwarves are in game now, you can start as dwarf at any continent, hire dwaf peasants in Stone City (Antagarich), or meet random dwarf mercenaries in training hall. Dwarf use same helmets as human male, same belts and cloaks as trolls, armors and boots same as trolls but scaled down to 85%.

Main menu now have custom picture.

Arch druid and warlock promotion quests will be accessible despite choosen path, dragon hatcling will be able to behave as party memeber.

> Templayer wrote:
> 
> Since the name of the planet is Enroth (i.e. the same as one of the continents on it), by using the same naming convention, it should be Might and Magic: The World of Enroth.

I agree. Rain effect is in game as well.

##### Dec 4 2018, 21:34
https://www.celestialheavens.com/forum/10/16657?p=374237#p374237

Hello, patch link have been updated. Few minor, but important bugs:
- erathian priest and thief promotions topics have been fixed; random hirelings will have normal condition, when you hire them first time; game title was set to all spots where it supposed to appear; artifact effects handler have been optimized.

Probably any updates won't happen for few next weeks, i will travel due to work purposes and won't have internet connection.

##### Dec 27 2018, 20:55
https://www.celestialheavens.com/forum/10/16657?p=374409#p374409

Hello, patch link have been updated, bunch of minor bugs have been fixed, thank you.

##### Dec 29 2018, 21:24
https://www.celestialheavens.com/forum/10/16657?p=374451#p374451

Hello, patch link have been updated.

Now Smiths, Armorers, Alchemists, Sailors, Navigators, Horsemans and Explorers are available to be hired;

Sounds of mm6 monsters will be quiter/louder depending on distance to party, same as mm7/8 ones;

First levels of Breach's basement will be less swarmed with monsters, also fixed maze generation issue happened at levels below 6th.

##### Jan 26 2019, 18:23
https://www.celestialheavens.com/forum/10/16657?p=374806#p374806

Hello. Patch link have been updated, highlights:
1. Introduced mechanic to learn dark spells in Enroth, certain NPC will offer swap class to it's dark counterpart:
  - Su Lang Manchu, Rebecca Calaway will offer Dark path class swap;
  - Ki Lo Nee, Virginia Standridge, Marton Ferris will offer Light path class swap.
  Pairs able to swap: Priest of Light - Priest of Dark, Archmage - Dark Archmage (new class), Arch Druid - Warlock, Sniper - Master Archer, Hero - Villain.
2. Added graphics for sun cloack, moon cloak, vampire cape; winged boots will be used as graphics fot Hermes' sandals.
3. Minor fixes.

Thank you for reports.

##### Jan 30 2019, 14:30
https://www.celestialheavens.com/forum/10/16657?p=374857#p374857

Hello, patch link have been updated. Changes:
1. High priest and Master wizard classes have been added. Both are able to master dark and light magic. These classes replace Enrothian Archmage and Priest of Light promotions.
2. Random hirelings won't disappear by their own anymore, only way to get rid of them - manually dismiss in Adventurer's Inn.
3. Adventurer's Inn added into The Breach.
4. Main character now dismissable too from Adventurer's Inn screen, but can not be dismissed forever.
5. Outdoor NPC hirelings will be refilled each month instead of map's refill rate.
6. Skill bonus limit removed. Skill cap stays at 60, but items can raise skill level further.
7. Now taverns at Antagarich require your own card deck to play Arcomage.

##### Feb 16 2019, 14:44
https://www.celestialheavens.com/forum/10/16657?p=375040#p375040

Hello, patch link have been updated. Only bugfixes this time (full list below). Thank you for reporting.

##### Feb 22 2019, 20:34
https://www.celestialheavens.com/forum/10/16657?p=375111#p375111

Hello. Patch link have been updated. Bolster was altered a bit, i'm thinking about extending it's tweaking possibilities via text tables. Artifacts respawn fixed, also in current version even chests with defined artifact won't generate same one, so doubles are excluded. To recount found artifacts in your current save game use debug console (ctrl+f1 to open, ctrl+enter to execute):
```
Game.RecountFoundArtifacts()
```

##### Mar 3 2019, 20:31
https://www.celestialheavens.com/forum/10/16657?start=1800#p375251

@Templayer

I've shrinked installation instruction and share files alltogether now. Could you try new clean installation and tell me results afterwards?

If it won't work, i'll put files into zip archive myself, so dropbox won't violate them.

Other than that, patch link have been updated. Game now supports custom interfaces. Inspect "Additional UI.txt" in "...Data\Tables" folder. Use debug console and command "Game.LoadUI(1)" to test them (replace 1 with 2 or 3: 2 is rough mm7 interface example, 3 - mm6 interface by Vinevi). No controls or auto switch for now.

"Race skills.txt" table now accept negative numrical values and works in a bit different way: instead of setting skill mastery to minimal available, it adds valuse from table to class' max value.

##### Mar 8 2019, 10:58
https://www.celestialheavens.com/forum/10/16657?start=1840#p375339

Hello.

I'm having hard work week, maybe this week' update will be delayed.

Here is quickfixes for mentioned crashes during training skills, and for bug with excess loot:

AdaptiveMonstersStats.lua - put into "Scripts\General" folder

RemoveClassLimits.lua - put into "Scripts\Structs\After" folder

or just reapply latest update.

##### Mar 9 2019, 13:40
https://www.celestialheavens.com/forum/10/16657?start=1860#p375361

Patch link have been updated. Only bugfixing this time, I've left comments on tracker. Thank you.

##### Mar 16 2019, 23:08
https://www.celestialheavens.com/forum/10/16657?start=1960#p375499

Hello. Patch link have been updated.

Now game have french localization, look for link in "Localizations" section of first post. Though this is machine combining of original texts, so cross continents quests are not translated.

Bolster adjusted further, i think it is in quiet good state now. Also random draw of monsters on arena is fixed. Few other minors, i'll note them on tracker a bit later. Thank you for reporting.

##### Mar 24 2019, 15:11
https://www.celestialheavens.com/forum/10/16657?p=375643#p375643

Hello, patch link have been updated.

MMPatch 2.2 now included in game files; game interface now can be switched via video controls menu; few minor bugs (marked on tracker).

##### Apr 7 2019, 11:09
https://www.celestialheavens.com/forum/10/16657?p=375840#p375840

Hello, patch link have been updated. Game now use new approach to show weather effects, visualy nothing had changed, but bugs caused by it should disappear now. Fixed couple of minor bugs (marked on tracker). Thank you.

##### Apr 28 2019, 13:26
https://www.celestialheavens.com/forum/10/16657?p=376108#p376108

Hello. I've added quickfix for weather effects and troll's plate armors (yes, somehow i've forgot to add them), reapply latest update, please.

##### May 5 2019, 13:03
https://www.celestialheavens.com/forum/10/16657?p=376216#p376216

Hello, patch link have been updated.

Weather effects now will be displayed properly; fixed crash during learning skills for new classes; it won't be possible anymore to loot items in dungeons if they are too far away; workaround for Stone City crash added to the first post, also some tweaks have been done to fix it, though can not be sure if it is enough, since i can not reproduce it; couple of other minors (will mark them on tracker), thank you for reporting.

##### May 31 2019, 20:55
https://www.celestialheavens.com/forum/10/16657?p=376528#p376528

Hello, patch link have been updated. Thank you for reporting.

##### Jun 10 2019, 1:17
https://www.celestialheavens.com/forum/10/16657?p=376903#p376903

Hello. Patch link have been updated.

I've fixed "Scripts\General" folder; dragon ghost portrait have been added, but dragon's zombie condition still called "Zombie" instead of "Ghost", - need to find good way of applying it. I have not added new voice sets yet. Some minor bugs have been fixed, probably some added. Thank you.

##### Sep 1 2019, 16:08
https://www.celestialheavens.com/forum/10/16657?start=3700#p378565

Hello.

Game files link have been updated. I've marked fixed bugs on tracker (no more crash upon declining item enchantment, control undead and town portal spells have been adjusted, Breach riddles have been fixed...). Please, try these files and tell me if they are broken or not. Also no more 15 min delay upon first start, thanks to GrayFace, algorythm of generating .bin files have been reworked.

I'll add updates for Polish and Russian localizations next weekend.

Thank you for reporting.

##### Sep 8 2019, 20:39
https://www.celestialheavens.com/forum/10/16657?p=378691#p378691

Game files link have been updated.

I have not managed to finish Czesh localization - will try to do it tommorow.

Russian localization by Maslyonok have been added to download link.

I've fixed problem with "Question" function, though it is temporary fix, i think problem have been caused by latest MMPatch, but i have not got response from Grayface yet.

Minotaur zombie and lich paperdolls by SpectralDragon have been added in game, they are awesome, thank you.
Speaking about belts, they are in game too now.

Other fixed bugs are listed in Templayer's message above.

I still have not found reason of reagents spawn. I'm not going to remove this or make it optional, but i'm out of curiosity why that happens.

A bit latter i'll upload modified character unlocker tables, with which you can start as zombie being able to be healed. There will be special portraits with zombie outfit, but belonging to undead subrace (6) instead of zombie (10).

I won't do weekly updates unless there are game breaking bugs, it would be rather monthly than weekly.
Thank you for reporting.

##### Sep 22 2019, 18:37
https://www.celestialheavens.com/forum/10/16657?p=378972#p378972

Game files link have been updated.

I'm still struggling with Czech localization, only 8 files left to localize, but i won't finish it today, sorry.

Changelog:
1. Fixed flickering of monsters inside high populated dungeons.
2. Now monsters will cast spirit lash properly (before they did hit only first character, even if he was dead).
3. Power cure casted by monster will heal nearby monsters of same group aswell.
4. Adventurer's Inn in The Breach will allow to hire character left in any world.
5. Black dragon paperdoll have been imported into game, used as default for baby dragon of warlock's promotion quest.
6. Vampire, Dark elf and Dragon base level racial skills can be learned from skill teachers now.
7. Racial Skills.txt table have been extended, now it allow to make class-race combos and support three-way effects (check table for examples).
8. New text table "Bolster - formulas" allow to edit formulas, which used to boost monsters' stats, also it supports custom formulas for monster kinds.
9. Bunch of minor fixes (removed few invisible walls, disabled ability of boulders to leave blood stains, adjusted SP regen of meditation skill).

##### Sep 24 2019, 16:57
https://www.celestialheavens.com/forum/10/16657?p=379033#p379033

Found issue with Racial Skills table. Patch link in the first post have been updated, apply, please.

> There was glitch upon learning skills via Shops/Taverns/Training Halls caused by script.

##### Sep 25 2019, 15:33
https://www.celestialheavens.com/forum/10/16657?p=379058#p379058

> Kaikhorus wrote:
> 
> Got a crash in Deyja from bolstered Harpies (the game doesn't crash when I enter Deyja with bolstered monsters off). My main character's level is 103 if that helps. Here's a save and the MM8extension debug output below. I'm using the latest patch that I downloaded today. Hope this helps!

Fixed, thank you. Apply latest patch

##### Sep 26 2019, 17:35
https://www.celestialheavens.com/forum/10/16657?p=379084#p379084

> Templayer wrote:
>
> We seem to have something more serious here:
>
> Reported by: Kaikhorus Sep 26 2019, 2:13
> > Temple of light monks crash the game, bolster monsters on/off
> > 
> > In castle lament

Patch link have been updated

Tell me if it will keep happen. Thank you.

##### Sep 27 2019, 21:24
https://www.celestialheavens.com/forum/10/16657?p=379139#p379139

Patch link have been updated

##### Sep 29 2019, 15:59
https://www.celestialheavens.com/forum/10/16657?p=379168#p379168

> Re applied the patch, still same. After overwriting with the file you posted and re applied greyface patch clicking fire expert on Isao Magistrus just crashes the game without giving me the error message it gave me before

Put this file into same folder: RemoveNPCTablesLimits.lua

Should be fixed now, thank you.

##### Oct 8 2019, 19:14
https://www.celestialheavens.com/forum/10/16657?p=379419#p379419

Patch link have been updated. Glitch with disappeared Roland have been fixed

