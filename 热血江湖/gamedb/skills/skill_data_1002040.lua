----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002041] = {
		[1] = {events = {{triTime = 1100, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002042] = {
		[1] = {events = {{triTime = 875, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.3, }, }, },},
	},
	[1002043] = {
		[1] = {events = {{triTime = 625, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, {triTime = 775, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, {triTime = 950, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, },},
	},
	[1002051] = {
		[1] = {events = {{triTime = 1250, hitEffID = 30900, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002052] = {
		[1] = {events = {{triTime = 2025, hitEffID = 30900, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 2450, hitEffID = 30900, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002053] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, },},
	},
	[1002061] = {
		[1] = {events = {{triTime = 625, hitEffID = 30903, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 2.0, arg2 = 100000.0, }, }, },},
	},
	[1002062] = {
		[1] = {events = {{triTime = 375, hitEffID = 30903, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.5, }, status = {{odds = 20000, buffID = 573, }, }, }, {triTime = 800, hitEffID = 30903, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1325, hitEffID = 30903, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1002063] = {
		[1] = {events = {{triTime = 500, hitEffID = 30903, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.8, }, status = {{odds = 10000, buffID = 637, }, }, }, {triTime = 750, hitEffID = 30903, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, status = {{odds = 10000, buffID = 637, }, }, }, {triTime = 1000, hitEffID = 30903, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, status = {{odds = 10000, buffID = 637, }, }, }, },},
	},
	[1002064] = {
		[1] = {events = {{triTime = 2175, hitEffID = 30903, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 2625, hitEffID = 30903, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 3.0, arg2 = 200000.0, }, }, },},
	},
	[1002065] = {
		[1] = {events = {{triTime = 1400, hitEffID = 30903, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.5, arg2 = 200000.0, }, status = {{odds = 10000, buffID = 637, }, }, }, },},
	},
	[1002071] = {
		[1] = {events = {{triTime = 675, hitEffID = 30904, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 2.0, arg2 = 10000.0, }, status = {{odds = 10000, buffID = 1, }, }, }, },},
	},
	[1002072] = {
		[1] = {events = {{triTime = 3250, hitEffID = 30904, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 2.0, arg2 = 10000.0, }, status = {{odds = 10000, buffID = 85, }, }, }, {triTime = 3375, hitEffID = 30904, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 2.0, arg2 = 10000.0, }, }, {triTime = 3500, hitEffID = 30904, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 2.0, arg2 = 10000.0, }, }, },},
	},
	[1002073] = {
		[1] = {events = {{triTime = 675, hitEffID = 30904, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 2.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
