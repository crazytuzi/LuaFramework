----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000481] = {
		[1] = {events = {{triTime = 650, hitEffID = 30190, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000482] = {
		[1] = {events = {{triTime = 775, hitEffID = 30190, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000484] = {
		[1] = {events = {{triTime = 1025, hitEffID = 30190, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[2] = {events = {{triTime = 1025, hitEffID = 30190, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 12000, buffID = 482, }, }, }, },},
	},
	[1000485] = {
		[1] = {events = {{triTime = 2500, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.2, }, }, },},
	},
	[1000486] = {
		[1] = {events = {{triTime = 3375, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.6, }, }, },},
	},
	[1000487] = {
		[1] = {events = {{triTime = 3875, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 213, }, }, }, },},
	},
	[1000491] = {
		[1] = {events = {{triTime = 475, hitEffID = 30191, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000492] = {
		[1] = {events = {{triTime = 475, hitEffID = 30191, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000493] = {
		[1] = {events = {{triTime = 775, hitEffID = 30191, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
		[2] = {events = {{triTime = 775, hitEffID = 30191, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75010, }, }, }, },},
		[3] = {events = {{triTime = 775, hitEffID = 30191, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75011, }, }, }, },},
		[4] = {events = {{triTime = 775, hitEffID = 30191, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75012, }, }, }, },},
	},
	[1000494] = {
		[1] = {events = {{triTime = 900, hitEffID = 30191, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[2] = {events = {{triTime = 900, hitEffID = 30191, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75004, }, }, }, },},
		[3] = {events = {{triTime = 900, hitEffID = 30191, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75005, }, }, }, },},
		[4] = {events = {{triTime = 900, hitEffID = 30191, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75006, }, }, }, },},
	},
	[1000502] = {
		[1] = {events = {{triTime = 525, hitEffID = 30192, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000503] = {
		[1] = {events = {{triTime = 625, hitEffID = 30192, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
		[2] = {events = {{triTime = 625, hitEffID = 30192, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 55, }, }, }, },},
	},
	[1000504] = {
		[1] = {events = {{triTime = 325, hitEffID = 30192, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 825, hitEffID = 30192, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[2] = {events = {{triTime = 325, hitEffID = 30192, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 55, }, }, }, {triTime = 825, hitEffID = 30192, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 55, }, }, }, },},
	},
	[1000512] = {
		[1] = {events = {{triTime = 500, hitEffID = 30193, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000514] = {
		[1] = {events = {{triTime = 800, hitEffID = 30193, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1000513] = {
		[1] = {events = {{triTime = 400, hitEffID = 30193, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7, }, }, {triTime = 800, hitEffID = 30193, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7, }, }, },},
	},
	[1000483] = {
		[1] = {events = {{triTime = 1100, hitEffID = 30190, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
	},
	[1000501] = {
		[1] = {events = {{triTime = 500, hitEffID = 30192, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000511] = {
		[1] = {events = {{triTime = 600, hitEffID = 30193, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
