-- script2.lua
local randscene = function( bot)
	local scenes = {
		11000010
	}
	sceneid = scenes[math.random(1, #scenes)]
	local points = _G.MapPoint[sceneid].monster
	if #points == 0 then points = _G.MapPoint[sceneid].npc  end
	if #points == 0 then points = _G.MapPoint[sceneid].birth  end
	if #points == 0 then return end
				
	pos = points[math.random(1, #points)]
	bot:goscene(sceneid, pos.x, pos.y)
end

local randskill = function( bot )
	local skills = {
			1001001,
			1002001,
			1003001,
			1004001,
			1005001,
			1006001,
			1000101,
			7010001,
			9000001,
			7000101,
			2001001,
			2002001,
			2003001,
			2004001,
			2005001,
			2006001,
			1000101,
			7010001,
			9000001,
			7000101,
			3001001,
			3002001,
			3003001,
			3004001,
			3005001,
			3006001,
			1000101,
			7010001,
			9000001,
			7000101,
			4001001,
			4002001,
			4003001,
			4004001,
			4005001,
			4006001,
			1000101,
			7010001,
			9000001,
			7000101,
	}
	skillid = skills[math.random(1, #skills)]
	bot:skill( skillid )
end

_G.script = function( bot )
	bot:delay( 2000 )
	bot:chat((1, '/addcallfabao/1001')
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
	randscene( bot )
	bot:delay( 1000 )
	
	while true do
		bot:chat(1, '/full')
		randskill( bot )
		bot:delay( 1000 )
		bot:runto( 0, 0 )
	end
	
	bot:quit()
end

_G.process = function( bot, msg )


end