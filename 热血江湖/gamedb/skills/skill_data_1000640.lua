----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000671] = {
		[1] = {events = {{triTime = 600, hitEffID = 30218, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000672] = {
		[1] = {events = {{triTime = 775, hitEffID = 30218, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000674] = {
		[1] = {events = {{triTime = 500, hitEffID = 30220, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1000, hitEffID = 30220, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
		[2] = {events = {{triTime = 500, hitEffID = 30220, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 15000, buffID = 74001, }, }, }, {triTime = 1000, hitEffID = 30220, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
	},
	[1000675] = {
		[1] = {events = {{triTime = 875, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.2, }, }, },},
	},
	[1000676] = {
		[1] = {events = {{triTime = 1325, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.2, }, }, },},
	},
	[1000673] = {
		[1] = {events = {{triTime = 800, hitEffID = 30219, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
		[2] = {events = {{triTime = 800, hitEffID = 30219, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, status = {{odds = 12000, buffID = 22, }, }, }, },},
		[3] = {events = {{triTime = 800, hitEffID = 30219, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, status = {{odds = 15000, buffID = 74001, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
