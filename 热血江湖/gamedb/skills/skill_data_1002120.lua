----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002122] = {
		[1] = {events = {{triTime = 875, hitEffID = 30914, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 1375, hitEffID = 30914, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 2250, hitEffID = 30914, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002121] = {
		[1] = {events = {{triTime = 975, hitEffID = 30914, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002141] = {
		[1] = {events = {{triTime = 750, hitEffID = 30954, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002142] = {
		[1] = {events = {{triTime = 1125, hitEffID = 30954, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002131] = {
		[1] = {events = {{triTime = 700, hitEffID = 30937, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, arg2 = 200000.0, }, }, {triTime = 875, hitEffID = 30914, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002132] = {
		[1] = {events = {{triTime = 1475, hitEffID = 30938, hitSoundID = 10, damage = {odds = 10000, arg1 = 4.0, arg2 = 500000.0, }, status = {{odds = 15000, buffID = 573, }, }, }, },},
		[2] = {events = {{triTime = 1475, hitEffID = 30938, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002133] = {
		[1] = {events = {{hitEffID = 30939, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.5, arg2 = 400000.0, }, status = {{odds = 15000, buffID = 482, }, }, }, },},
		[2] = {events = {{hitEffID = 30939, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1002151] = {
		[1] = {events = {{triTime = 550, hitEffID = 30955, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002152] = {
		[1] = {events = {{triTime = 875, hitEffID = 30955, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
