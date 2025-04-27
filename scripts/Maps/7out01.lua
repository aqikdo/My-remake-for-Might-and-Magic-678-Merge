-- Emerald Island

local function GetDist(t,x,y,z)
	local px, py, pz  = XYZ(t)
	return math.sqrt((px-x)^2 + (py-y)^2 + (pz-z)^2)
end

local function Dispel()
	for i,v in Map.Monsters do
		if v.NameId == 193 and v.HP < v.FullHP then
			v.HP = v.HP + 1
			Party.SpellBuffs[const.PartyBuff.Fly].ExpireTime = 0
			Party.SpellBuffs[const.PartyBuff.WaterWalk].ExpireTime = 0
			vars.MonsterAttackTime = Game.Time
		end
	end
end 

function events.AfterLoadMap()
	Party.QBits[816] = true	-- DDMapBuff
	Timer(Dispel, 4, false)
end

-- Remove arcomage from Emerald Island's taverns
function events.DrawShopTopics(t)
	if t.HouseType == const.HouseType.Tavern then
		t.Handled = true
		t.NewTopics[1] = const.ShopTopics.RentRoom
		t.NewTopics[2] = const.ShopTopics.BuyFood
		t.NewTopics[3] = const.ShopTopics.Learn
	end
end
