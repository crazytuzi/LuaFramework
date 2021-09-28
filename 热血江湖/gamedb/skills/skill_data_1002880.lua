----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002903] = {
		[1] = {events = {{triTime = 625, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002904] = {
		[1] = {events = {{triTime = 475, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002905] = {
		[1] = {events = {{triTime = 275, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 525, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, {triTime = 1000, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, },},
	},
	[1002911] = {
		[1] = {events = {{triTime = 700, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 2025, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, {triTime = 3700, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, },},
	},
	[1002915] = {
		[1] = {events = {{triTime = 2225, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 120502, }, }, }, {triTime = 2725, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 3225, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002901] = {
		[1] = {events = {{triTime = 975, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002902] = {
		[1] = {events = {{triTime = 475, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 625, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, {triTime = 975, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, },},
	},
	[1002906] = {
		[1] = {events = {{triTime = 500, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1250, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, {triTime = 1450, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, },},
	},
	[1002907] = {
		[1] = {events = {{triTime = 850, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002908] = {
		[1] = {events = {{triTime = 1000, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002909] = {
		[1] = {events = {{triTime = 275, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 475, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, },},
	},
	[1002910] = {
		[1] = {events = {{triTime = 1075, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002912] = {
		[1] = {events = {{hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002913] = {
		[1] = {events = {{hitEffID = 30945, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002914] = {
		[1] = {events = {{triTime = 2500, hitEffID = 30945, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 3500, hitEffID = 30945, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 120501, }, }, }, },},
	},
	[1002916] = {
		[1] = {events = {{hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002917] = {
		[1] = {events = {{triTime = 2175, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 120501, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
