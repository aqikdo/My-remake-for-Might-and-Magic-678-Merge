MMExtension repository: https://github.com/GrayFace/MMExtension

MMExtension Reference Manual: https://grayface.github.io/mm/ext/ref

### Structures extended in Community Branch by adding new fields

#### Game

| Field          | Type   |                           |
|----------------|--------|---------------------------|
| Races[Race]    | table  | Race structures           |
| RacesCount     | number | Total count of Races      |
| RaceKindsCount | number | Total count of Race Kinds |

### Structures introduced in Community Branch

#### Race

| Field    | Type   |                                         |
|----------|--------|-----------------------------------------|
| Id       | number | Race Id value from const.Race           |
| StringId | string | Race Id key from const.Race             |
| Kind     | number | Race Kind Id value from const.RaceKinds |
| Name     | string | Race Name /* "Dark Elf" */              |
| Plural   | string | Race Plural Name /* "Dark Elves" */     |
| Adj      | string | Race Adjective /* "Dark Elven" */       |

#### const.RaceKinds

| Values       |   |
|--------------|---|
| Human    = 0 |   |
| Undead   = 1 |   |
| Elf      = 2 |   |
| Minotaur = 3 |   |
| Troll    = 4 |   |
| Dragon   = 5 |   |
| Goblin   = 6 |   |
| Dwarf    = 7 |   |

