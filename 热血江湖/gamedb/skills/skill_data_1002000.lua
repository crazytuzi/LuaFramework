----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002024] = {
		[1] = {events = {{triTime = 1325, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.0, }, }, },},
	},
	[1002002] = {
		[1] = {events = {{triTime = 725, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1325, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002012] = {
		[1] = {events = {{triTime = 900, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002001] = {
		[1] = {events = {{triTime = 700, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002011] = {
		[1] = {events = {{triTime = 650, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002013] = {
		[1] = {events = {{triTime = 650, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 88, }, }, }, },},
		[2] = {events = {{triTime = 650, hitEffID = 30788, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.2, }, }, },},
	},
	[1002021] = {
		[1] = {events = {{triTime = 375, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 775, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1150, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002022] = {
		[1] = {events = {{triTime = 2750, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002023] = {
		[1] = {events = {{triTime = 500, hitEffID = 30861, hitSoundID = 14, status = {{odds = 10000, buffID = 574, }, {odds = 10000, buffID = 575, }, }, }, },},
	},
	[1002031] = {
		[1] = {events = {{triTime = 375, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 775, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1150, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002032] = {
		[1] = {events = {{triTime = 2750, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 4.0, arg2 = 50000.0, }, }, },},
		[2] = {events = {{triTime = 2750, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 4.0, arg2 = 50000.0, }, }, },},
		[3] = {events = {{triTime = 2750, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 4.0, arg2 = 50000.0, }, }, },},
	},
	[1002033] = {
		[1] = {events = {{triTime = 500, hitEffID = 30861, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 12500, buffID = 573, }, }, }, },},
		[2] = {events = {{triTime = 500, hitEffID = 30861, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 12500, buffID = 573, }, }, }, },},
		[3] = {events = {{triTime = 500, hitEffID = 30861, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 12500, buffID = 573, }, }, }, },},
	},
	[1002034] = {
		[1] = {events = {{triTime = 1325, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 12500, buffID = 546, }, }, }, },},
		[2] = {events = {{triTime = 1325, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 12500, buffID = 546, }, }, }, },},
		[3] = {events = {{triTime = 1325, hitEffID = 30860, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 12500, buffID = 546, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
