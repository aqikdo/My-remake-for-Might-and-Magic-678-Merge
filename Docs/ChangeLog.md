##### 2019-12-15
- Git repository initialization.

##### 2019-12-23
- Ajusted Bolster HP formula (by fanasilver)
- Debug Tent button at Character Creation (by majaczek)
- Force Zombies to be Undead when made through Character Creation in order not to have the Zombie status (by majaczek)
- Racial Skills are automatically learned if a character was created by using the Character Creation screen (by majaczek)
- Better Autobiographies for Characters Created During Character Creation (by majaczek)

##### 2020-01-13
- Restore Data/Tables CRLF behaviour.

##### 2020-01-14
- Restore CRLF behavior of Scripts/ files to Rodril's one.
- Remove accidental CRLF in two Data/Tables files.

##### 2020-01-15
- Made Rodril's Pack of 22.09.2019 and Patch of 8.10.2019 to be ancestors of Community version.

##### 2020-01-21
- Updated version of Zombies to be Undead workaround.

##### 2020-01-23
- Removed accidental characters from Data/Tables.

##### 2020-01-27
- Added support for various RaceNames via Data/Tables/Races.txt.
- Reworked enhanced autobiographies.

##### 2020-01-30
- Added basic Merge Settings support.
- Added various versions: Pack version, Patch version, Community version, SaveGameFormat version.
- Made enhanced autobiographies a toggleable setting.

##### 2020-02-02
- Added MM7 race/class combination to starting characters (#41).

##### 2020-02-05
- Fixed Majestic Chain Mail and Golden Plate Armor coordinates (#43).

##### 2020-02-10
- Workaround for monsters spawn monsters overflow issue (#51).

##### 2020-02-11
- Made most of Community Branch features togglable (#32).

##### 2020-02-20
- Fixed crash in Zombie GetMaxSkillLevel function (#93).
- Fixed possibly lost Reanimation spell when switching Mirrored Path (#82).

##### 2020-02-21
- Added basic logging support (#15).

##### 2020-03-01
- Added initial custom Race/Class names support (#5).

##### 2020-03-07
- Added MM7 Monster Portraits.

##### 2020-03-08
- Fixed Reputation loss (#45).

##### 2020-03-20
- Merged Rodril's Pack 17.03.2020 (#429).
- Fixed NPC Followers Fly and Water Walk spells (#417).
- Added autolearnable race skills support (#66)
- Added support for race HP and SP modifiers (#67)
- Fixed Eclipse wearing condition  (#137)
- Fixed Sharry Carnegie 6d03 encounter (#447)

##### 2020-03-22
- Fixed Endurance Attunement Effect name (#485)

##### 2020-04-01
- Rework races (80 possible race variants) (#21)
   - 8 base races
   - Undead variant for each base race
   - Vampire variant for each base race
   - Zombie variant for each base race
   - Ghost variant for each base race
   - "Mature" variant for all above
- Rework classes (121 possible classes of 15 kinds) (see #428)
   - Each of 14 base class kinds have possible tier2 Neutral, Good and Evil classes
   - Cleric and Wizard kinds have possible tier0 and tier1 Neutral, Good and Evil classes
   - Lich class has been merged with Master Necromancer
   - Cleric of the Light is now Jadame starting class
   - Troll and War Troll classes are renamed into Berserker and Warmonger (see #56)
- New format of 'Race Skills.txt' table (#472)
- Players now have extra attributes: race and alignment added (#328)
   - Player race is determined by attribute, not by face
- Fixed Prophecies of the Sun and Ebonest not always being removed after promotion quest (#136)
- Fixed Game.SkillNames and Game.SkillDescriptions arrays size
- Fixed Chain being removed instead of Repair after conversion to Lich (#107)
- Fixed Lathean promotes to Lich without check for Lost Book of Kehl (#522)
- Fixed Evil Altar (6d13) doesn't consider fifth player (#531)
- Added setting to keep player voice after conversion to Undead Lich (#90)
- Added setting to not skeletonize character of undead kind races on Lich promotion (#6)
- Added converter from old format savegames (#456)

##### 2020-04-12
- Fixed door of Superior Temple of Baa checked for Repair instead of Perception (#574)
- Fixed broken multilined strings of NPCTopic.txt (#583)

##### 2020-04-16
- Fixed Master Necromancer to be always converted to Undead Lich (#595)
- Set player Attrs via metatable (#589)
- Fixed voice numbers of Dwarves converted to Liches (#601)

##### 2020-04-19
- Updated to Rodril's Pack 19.04.2020
- Added Gold Dragon, Troll Lich, Troll Zombie playable characters (#362, #402, #357)
- Fixed Dragon PCs graphics (#358)
- Fixed Minotaur Lich paperdoll (#481)
- Fixed MenuChooseCharacter to work properly with already initialized PlayersAttrs (#605)

##### 2020-04-21
- Added Rodril's changes that weren't committed into git repo
- Added hooks to show custom class name (#5, #591)

##### 2020-04-28
- Updated to Rodril's Patch 25.04.2020

##### 2020-05-01
- Added more hooks to show custom class name (#5, #591)
- Fixed race to be Updated when converting from Peasant to Vampire

##### 2020-05-09
- Used 255 (0xFF) as maximum skill value (base+bonus) (#156)
- Used 80 (0x50) as maximum skill base value
- Expert, Master and GM skill bits moved from 6,7,8 to 10,11,12
- Fixed Bow skill cycled on 64 regarding Shoot and Recovery Time (#105)
- Fixed Armsmaster skill cycled on 64 regarding Attack and Melee Damage (#105)
- Added setting to include skill value bonus from items for Bow GM damage (enabled by default) (#110)
- Fixed evt.CheckSkill checked for exact Mastery of skill (#617)
