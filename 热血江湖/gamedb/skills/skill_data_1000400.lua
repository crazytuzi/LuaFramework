----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000411] = {
		[1] = {events = {{triTime = 550, hitEffID = 30184, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000412] = {
		[1] = {events = {{triTime = 725, hitEffID = 30184, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000413] = {
		[1] = {events = {{triTime = 450, hitEffID = 30184, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
		[2] = {events = {{triTime = 450, hitEffID = 30184, hitSoundID = 14, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 57, }, }, }, },},
		[3] = {events = {{triTime = 450, hitEffID = 30184, hitSoundID = 14, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 206, }, }, }, },},
	},
	[1000414] = {
		[1] = {events = {{triTime = 700, hitEffID = 30184, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, }, },},
	},
	[1000415] = {
		[1] = {events = {{triTime = 1575, hitEffID = 30184, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, },},
		[2] = {events = {{triTime = 1575, hitEffID = 30184, hitSoundID = 14, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 59, }, {odds = 10000, buffID = 60, }, }, }, },},
	},
	[1000416] = {
		[1] = {events = {{triTime = 3700, hitEffID = 30184, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 58, }, }, }, },},
		[2] = {events = {{triTime = 3700, hitEffID = 30184, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.3, }, status = {{odds = 10000, buffID = 207, }, }, }, },},
	},
	[1000421] = {
		[1] = {events = {{triTime = 475, hitEffID = 30185, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000422] = {
		[1] = {events = {{triTime = 475, hitEffID = 30185, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000431] = {
		[1] = {events = {{triTime = 500, hitEffID = 30186, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000432] = {
		[1] = {events = {{triTime = 475, hitEffID = 30186, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000433] = {
		[1] = {events = {{triTime = 400, hitEffID = 30186, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
		[2] = {events = {{triTime = 400, hitEffID = 30186, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 189, }, }, }, },},
	},
	[1000434] = {
		[1] = {events = {{triTime = 525, hitEffID = 30186, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.82, }, }, {triTime = 800, hitEffID = 30185, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.82, }, }, },},
		[2] = {events = {{triTime = 525, hitEffID = 30186, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.0, }, }, },},
	},
	[1000424] = {
		[1] = {events = {{triTime = 475, hitEffID = 30185, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.82, }, }, {triTime = 975, hitEffID = 30185, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.82, }, }, },},
		[2] = {events = {{triTime = 475, hitEffID = 30185, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 395, }, }, }, {triTime = 975, hitEffID = 30185, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 395, }, }, }, },},
	},
	[1000423] = {
		[1] = {events = {{triTime = 500, hitEffID = 30185, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
		[2] = {events = {{triTime = 500, hitEffID = 30185, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 85, }, {odds = 10000, buffID = 392, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
