----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000297] = {
		[1] = {events = {{triTime = 4000, hitSoundID = 14, }, },},
	},
	[1000281] = {
		[1] = {events = {{triTime = 100, hitEffID = 30203, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 5000, buffID = 626, }, {odds = 5000, buffID = 627, }, }, }, },},
	},
	[1000282] = {
		[1] = {events = {{hitEffID = 30203, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, },},
	},
	[1000287] = {
		[1] = {events = {{triTime = 200, damage = {odds = 10000, atrType = 1, arg2 = 3720.0, }, status = {{odds = 10000, buffID = 479, }, }, }, },},
	},
	[1000289] = {
		[1] = {events = {{triTime = 200, damage = {odds = 10000, atrType = 1, arg2 = 18112.0, }, status = {{odds = 10000, buffID = 481, }, }, }, },},
	},
	[1000292] = {
		[1] = {events = {{triTime = 825, hitEffID = 30148, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000293] = {
		[1] = {events = {{triTime = 4000, hitSoundID = 14, }, },},
	},
	[1000294] = {
		[1] = {events = {{triTime = 1325, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 10000, buffID = 27, }, }, }, },},
		[2] = {events = {{triTime = 1325, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 10000, buffID = 27, }, }, }, },},
		[3] = {events = {{triTime = 1325, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75010, }, }, }, },},
		[4] = {events = {{triTime = 1325, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75011, }, }, }, },},
		[5] = {events = {{triTime = 1325, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75012, }, }, }, },},
	},
	[1000295] = {
		[1] = {events = {{triTime = 1475, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, status = {{odds = 10000, buffID = 103, }, }, }, },},
		[2] = {events = {{triTime = 1475, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, status = {{odds = 10000, buffID = 103, }, }, }, },},
		[3] = {events = {{triTime = 1475, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75001, }, }, }, },},
		[4] = {events = {{triTime = 1475, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75002, }, }, }, },},
		[5] = {events = {{triTime = 1475, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75003, }, }, }, },},
	},
	[1000296] = {
		[1] = {events = {{triTime = 4000, hitSoundID = 14, }, },},
	},
	[1000283] = {
		[1] = {events = {{triTime = 200, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 457, }, }, }, },},
	},
	[1000284] = {
		[1] = {events = {{triTime = 200, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 458, }, }, }, },},
	},
	[1000285] = {
		[1] = {events = {{triTime = 200, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 459, }, }, }, },},
	},
	[1000286] = {
		[1] = {events = {{triTime = 200, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 460, }, }, }, },},
	},
	[1000288] = {
		[1] = {events = {{triTime = 200, damage = {odds = 10000, atrType = 1, arg2 = 11037.0, }, status = {{odds = 10000, buffID = 480, }, }, }, },},
	},
	[1000298] = {
		[1] = {events = {{triTime = 4000, hitSoundID = 14, }, },},
	},
	[1000290] = {
		[1] = {events = {{triTime = 200, damage = {odds = 10000, atrType = 1, arg2 = 44218.0, }, status = {{odds = 10000, buffID = 482, }, }, }, },},
	},
	[1000291] = {
		[1] = {events = {{triTime = 575, hitEffID = 30148, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
