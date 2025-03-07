local function Invisibility()
	for i,v in Map.Monsters do
		if v.NameId == 184 and v.HP > 0 then
			v.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime = Game.Time + const.Year
			v.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power = 1000
		end
	end
end 

evt.map[6] = function()
	evt.MoveToMap{X = 6036, Y = -7178, Z = 161, Direction = 0, LookAngle = 0, SpeedZ = 0, HouseId = 0, Icon = 0, Name = "outa2.odm"}
end

evt.map[11] = function()
	Message("Dear visitors! The room of the Shadow Guild is in the south-west, the room of Baa is in the north-west, the room of Reagna is in the south-east and my room is in the north-east. Please knock the doors first.")
end

Game.MapEvtLines:RemoveEvent(2)
evt.map[2] = function()
	if evt.CheckItemsCount(672,672,1) == true then
		evt.SetDoorState{Id = 2, State = 1}
	end
end

Game.MapEvtLines:RemoveEvent(3)
evt.map[3] = function()
	if evt.CheckItemsCount(674,674,1) == true then
		evt.SetDoorState{Id = 3, State = 1}
	end
end

Game.MapEvtLines:RemoveEvent(5)
evt.map[5] = function()
	if evt.CheckItemsCount(673,673,1) == true then
		evt.SetDoorState{Id = 5, State = 1}
	end
end

Game.MapEvtLines:RemoveEvent(4)
evt.map[4] = function()
	local cnt = 0
	for i,v in Map.Monsters do
		if v.HP == 0 and (v.NameId == 184 or v.NameId == 190 or v.NameId == 191) then
			cnt = cnt + 1
		end
	end
	if cnt == 3 then
		evt.SetDoorState{Id = 4, State = 1}
	end
end

local function TeleportTimer()
	if vars.TeleportTime and Game.Time >= vars.TeleportTime then
		vars.TeleportTime = nil
		StartCombat()
	end
end

function events.MonsterKilled(mon)
	if mon.NameId == 195 then
		if not vars.FinalCombat then
			vars.FinalCombat = true
			evt.SetNPCGreeting{803, 322}
			NPCTopic{
				NPC		= 803,
				Name	= "Verdant - FinalCombat",
				Branch	= "",
				Slot	= 3,
				CanShow	= function() return true end,
				Ungive  = function(t)
					vars.FinalCombatStart = true
					vars.TeleportTime = Game.Time + 1000
				end,
				Texts	= {
					Topic	= Game.NPCTopic[1769],
					Ungive	= Game.NPCText[2217]
					}
			}
			evt.SpeakNPC{803}
		end
	end
end

function events.LoadMap()
	evt.SetMonGroupBit{NPCGroup = 1, Bit = const.MonsterBits.Hostile, On = true}
	Timer(Invisibility, const.Minute, false)
	Timer(TeleportTimer, 4, false)
end

--[[
local function FinalTimer()
	local fl = true
	for i,v in Map.Monsters do
		if v.HP > 0 then
			fl = false
		end
	end
	if fl == true then
		Timer(TeleportTimer, 4, false)
		if not vars.FinalCombat then
			vars.FinalCombat = true
			evt.SetNPCGreeting{803, 322}
			NPCTopic{
				NPC		= 803,
				Name	= "Verdant - FinalCombat",
				Branch	= "",
				Slot	= 3,
				CanShow	= function() return true end,
				Ungive  = function(t)
					vars.FinalCombatStart = true
					vars.TeleportTime = Game.Time + 1000
				end,
				Texts	= {
					Topic	= Game.NPCTopic[1769],
					Ungive	= Game.NPCText[2217]
					}
			}
			evt.SpeakNPC{803}
		end
	end
end
]]--

