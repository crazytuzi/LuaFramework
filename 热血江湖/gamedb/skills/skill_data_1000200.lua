----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000238] = {
		[1] = {events = {{triTime = 4000, hitEffID = 30099, hitSoundID = 14, damage = {odds = 10000, }, }, },},
	},
	[1000221] = {
		[1] = {events = {{triTime = 625, hitEffID = 30123, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000222] = {
		[1] = {events = {{triTime = 875, hitEffID = 30123, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000224] = {
		[1] = {events = {{triTime = 1150, hitEffID = 30125, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[2] = {events = {{triTime = 1150, hitEffID = 30125, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 162, }, }, }, },},
	},
	[1000232] = {
		[1] = {events = {{triTime = 875, hitEffID = 30123, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000233] = {
		[1] = {events = {{triTime = 1150, hitEffID = 30295, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 162, }, }, }, },},
		[2] = {events = {{triTime = 1150, hitEffID = 30295, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 162, }, }, }, },},
		[3] = {events = {{triTime = 1150, hitEffID = 30295, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 162, }, {odds = 10000, buffID = 161, }, }, }, },},
		[4] = {events = {{triTime = 1150, hitEffID = 30295, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 162, }, {odds = 10000, buffID = 526, }, }, }, },},
		[5] = {events = {{triTime = 1150, hitEffID = 30295, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75019, }, }, }, },},
		[6] = {events = {{triTime = 1150, hitEffID = 30295, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75020, }, }, }, },},
		[7] = {events = {{triTime = 1150, hitEffID = 30295, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75021, }, }, }, },},
		[8] = {events = {{triTime = 1150, hitEffID = 30295, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1000234] = {
		[1] = {events = {{triTime = 4000, hitEffID = 30099, hitSoundID = 14, damage = {odds = 10000, }, }, },},
	},
	[1000235] = {
		[1] = {events = {{triTime = 1300, hitEffID = 30124, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
		[2] = {events = {{triTime = 1300, hitEffID = 30124, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 397, }, }, }, },},
		[3] = {events = {{triTime = 1300, hitEffID = 30124, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 527, }, }, }, },},
		[4] = {events = {{triTime = 1300, hitEffID = 30124, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[5] = {events = {{triTime = 1300, hitEffID = 30124, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[6] = {events = {{triTime = 1300, hitEffID = 30124, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[7] = {events = {{triTime = 1300, hitEffID = 30124, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1000236] = {
		[1] = {events = {{triTime = 1450, hitEffID = 30123, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, },},
		[2] = {events = {{triTime = 1450, hitEffID = 30123, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, status = {{odds = 10000, buffID = 103, }, }, }, },},
		[3] = {events = {{triTime = 1450, hitEffID = 30123, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, status = {{odds = 10000, buffID = 103, }, }, }, },},
		[4] = {events = {{triTime = 1450, hitEffID = 30123, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75022, }, }, }, },},
		[5] = {events = {{triTime = 1450, hitEffID = 30123, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75023, }, }, }, },},
		[6] = {events = {{triTime = 1450, hitEffID = 30123, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75024, }, }, }, },},
		[7] = {events = {{triTime = 1450, hitEffID = 30123, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 2.0, }, status = {{odds = 10000, buffID = 75024, }, }, }, },},
	},
	[1000237] = {
		[1] = {events = {{triTime = 4000, hitEffID = 30099, hitSoundID = 14, damage = {odds = 10000, }, }, },},
	},
	[1000239] = {
		[1] = {events = {{triTime = 4000, hitEffID = 30099, hitSoundID = 14, damage = {odds = 10000, }, }, },},
	},
	[1000223] = {
		[1] = {events = {{triTime = 1300, hitEffID = 30124, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
	},
	[1000231] = {
		[1] = {events = {{triTime = 625, hitEffID = 30123, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
