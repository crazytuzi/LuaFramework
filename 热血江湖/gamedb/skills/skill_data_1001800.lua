----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001822] = {
		[1] = {events = {{triTime = 575, hitEffID = 30776, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001823] = {
		[1] = {events = {{triTime = 925, hitEffID = 30776, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
		[2] = {events = {{triTime = 925, hitEffID = 30776, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 184, }, }, }, },},
		[3] = {events = {{triTime = 925, hitEffID = 30776, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75001, }, }, }, },},
		[4] = {events = {{triTime = 925, hitEffID = 30776, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75002, }, }, }, },},
		[5] = {events = {{triTime = 925, hitEffID = 30776, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75003, }, }, }, },},
	},
	[1001821] = {
		[1] = {events = {{triTime = 675, hitEffID = 30776, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001824] = {
		[1] = {events = {{triTime = 875, hitEffID = 30777, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.2, }, }, },},
		[2] = {events = {{triTime = 875, hitEffID = 30777, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75004, }, }, }, },},
		[3] = {events = {{triTime = 875, hitEffID = 30777, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75005, }, }, }, },},
		[4] = {events = {{triTime = 875, hitEffID = 30777, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75006, }, }, }, },},
	},
	[1001801] = {
		[1] = {events = {{triTime = 625, hitEffID = 30787, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001802] = {
		[1] = {events = {{triTime = 350, hitEffID = 30787, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 600, hitEffID = 30787, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1000, hitEffID = 30787, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001811] = {
		[1] = {events = {{triTime = 650, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001812] = {
		[1] = {events = {{triTime = 725, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001825] = {
		[1] = {events = {{triTime = 775, hitEffID = 30777, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, }, {triTime = 1575, hitEffID = 30777, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, }, },},
		[2] = {events = {{triTime = 775, hitEffID = 30777, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, }, }, }, {triTime = 1575, hitEffID = 30777, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[3] = {events = {{triTime = 775, hitEffID = 30777, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, }, }, }, {triTime = 1575, hitEffID = 30777, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 775, hitEffID = 30777, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, }, }, }, {triTime = 1575, hitEffID = 30777, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1001826] = {
		[1] = {events = {{triTime = 1700, hitEffID = 30778, hitSoundID = 14, damage = {odds = 10000, arg1 = 8.0, }, }, },},
		[2] = {events = {{triTime = 1700, hitEffID = 30778, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75001, }, }, }, },},
		[3] = {events = {{triTime = 1700, hitEffID = 30778, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75002, }, }, }, },},
		[4] = {events = {{triTime = 1700, hitEffID = 30778, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75003, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
