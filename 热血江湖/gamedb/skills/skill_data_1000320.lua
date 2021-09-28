----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000330] = {
		[1] = {events = {{triTime = 3500, damage = {odds = 10000, }, }, },},
	},
	[1000331] = {
		[1] = {events = {{triTime = 3500, damage = {odds = 10000, }, }, },},
	},
	[1000332] = {
		[1] = {events = {{triTime = 3500, damage = {odds = 10000, }, }, },},
	},
	[1000333] = {
		[1] = {events = {{triTime = 3500, damage = {odds = 10000, }, }, },},
	},
	[1000334] = {
		[1] = {events = {{triTime = 3500, damage = {odds = 10000, }, }, },},
	},
	[1000335] = {
		[1] = {events = {{triTime = 3500, damage = {odds = 10000, }, }, },},
	},
	[1000336] = {
		[1] = {events = {{triTime = 3500, damage = {odds = 10000, }, }, },},
	},
	[1000351] = {
		[1] = {events = {{triTime = 450, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000352] = {
		[1] = {events = {{triTime = 500, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000353] = {
		[1] = {events = {{triTime = 375, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 1175, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, },},
		[2] = {events = {{triTime = 375, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1175, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, }, },},
	},
	[1000354] = {
		[1] = {events = {{triTime = 975, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
		[2] = {studyLvl = 2, events = {{triTime = 975, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 10000, buffID = 84, }, }, }, },},
		[3] = {studyLvl = 3, events = {{triTime = 975, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 10000, buffID = 84, }, }, }, },},
		[4] = {studyLvl = 4, events = {{triTime = 975, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 10000, buffID = 84, }, }, }, },},
		[5] = {studyLvl = 5, events = {{triTime = 975, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 10000, buffID = 84, }, }, }, },},
	},
	[1000355] = {
		[1] = {events = {{hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, }, },},
		[2] = {events = {{hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, }, },},
	},
	[1000356] = {
		[1] = {events = {{triTime = 925, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, },},
		[2] = {events = {{triTime = 925, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, status = {{odds = 20000, buffID = 43, }, }, }, },},
	},
	[1000321] = {
		[1] = {events = {{triTime = 200, hitEffID = 30145, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 100.0, }, }, },},
	},
	[1000322] = {
		[1] = {events = {{triTime = 200, hitEffID = 30145, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 150.0, }, }, },},
	},
	[1000323] = {
		[1] = {events = {{triTime = 200, hitEffID = 30145, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 300.0, }, }, },},
	},
	[1000324] = {
		[1] = {events = {{triTime = 200, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 461, }, }, }, },},
	},
	[1000325] = {
		[1] = {events = {{triTime = 375, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 22, }, }, }, },},
	},
	[1000326] = {
		[1] = {events = {{triTime = 200, hitEffID = 30145, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg2 = 12389.0, }, status = {{odds = 10000, buffID = 576, }, }, }, },},
	},
	[1000327] = {
		[1] = {events = {{triTime = 200, hitEffID = 30094, damage = {odds = 10000, arg2 = 129802.0, }, }, },},
		[2] = {events = {{triTime = 200, hitEffID = 30094, damage = {odds = 10000, arg2 = 161642.0, }, }, },},
		[3] = {events = {{triTime = 200, hitEffID = 30094, damage = {odds = 10000, arg2 = 209729.0, }, }, },},
		[4] = {events = {{triTime = 200, hitEffID = 30094, damage = {odds = 10000, arg2 = 242618.0, }, }, },},
		[5] = {events = {{triTime = 200, hitEffID = 30094, damage = {odds = 10000, arg2 = 355973.0, }, }, },},
		[6] = {events = {{triTime = 200, hitEffID = 30094, damage = {odds = 10000, arg2 = 437338.0, }, }, },},
		[7] = {events = {{triTime = 200, hitEffID = 30094, damage = {odds = 10000, arg2 = 758880.0, }, }, },},
	},
	[1000328] = {
		[1] = {events = {{triTime = 200, damage = {atrType = 1, }, status = {{odds = 20000, buffID = 1212, }, }, }, },},
	},
	[1000337] = {
		[1] = {events = {{triTime = 3500, damage = {odds = 10000, }, }, },},
	},
	[1000338] = {
		[1] = {events = {{triTime = 3500, damage = {odds = 10000, }, }, },},
	},
	[1000339] = {
		[1] = {events = {{triTime = 3500, damage = {odds = 10000, }, }, },},
	},
	[1000340] = {
		[1] = {events = {{triTime = 3500, damage = {odds = 10000, }, }, },},
	},

};
function get_db_table()
	return level;
end
