----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000631] = {
		[1] = {events = {{triTime = 600, hitEffID = 30212, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000632] = {
		[1] = {events = {{triTime = 775, hitEffID = 30212, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000633] = {
		[1] = {events = {{triTime = 800, hitEffID = 30213, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
		[2] = {events = {{triTime = 800, hitEffID = 30213, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[3] = {events = {{triTime = 800, hitEffID = 30213, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 800, hitEffID = 30213, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[5] = {events = {{triTime = 800, hitEffID = 30213, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, status = {{odds = 15000, buffID = 74001, }, }, }, },},
	},
	[1000634] = {
		[1] = {events = {{triTime = 500, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1000, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
		[2] = {events = {{triTime = 500, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 11, }, }, }, },},
		[3] = {events = {{triTime = 500, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75007, }, }, }, {triTime = 1000, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 500, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75008, }, }, }, {triTime = 1000, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[5] = {events = {{triTime = 500, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75009, }, }, }, {triTime = 1000, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[6] = {events = {{triTime = 500, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 15000, buffID = 74001, }, }, }, {triTime = 1000, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
	},
	[1000635] = {
		[1] = {events = {{triTime = 800, hitEffID = 30213, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 192, }, {odds = 10000, buffID = 16, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
