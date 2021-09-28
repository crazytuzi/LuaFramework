----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002092] = {
		[1] = {events = {{triTime = 1050, hitEffID = 30910, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002104] = {
		[1] = {events = {{triTime = 375, hitEffID = 30137, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002081] = {
		[1] = {events = {{triTime = 500, hitEffID = 30905, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002082] = {
		[1] = {events = {{triTime = 1375, hitEffID = 30906, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.5, }, status = {{odds = 10000, buffID = 8, }, }, }, {triTime = 1625, hitEffID = 30906, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1875, hitEffID = 30906, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1002083] = {
		[1] = {events = {{triTime = 1125, hitEffID = 30907, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, {triTime = 1500, hitEffID = 30907, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, {triTime = 1875, hitEffID = 30907, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, },},
	},
	[1002091] = {
		[1] = {events = {{triTime = 575, hitEffID = 30910, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002093] = {
		[1] = {events = {{triTime = 950, hitEffID = 30910, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1250, hitEffID = 30910, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002105] = {
		[1] = {events = {{triTime = 425, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002106] = {
		[1] = {events = {{triTime = 125, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002107] = {
		[1] = {events = {{triTime = 400, hitEffID = 30143, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002101] = {
		[1] = {events = {{triTime = 225, hitEffID = 30140, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002102] = {
		[1] = {events = {{triTime = 125, hitEffID = 30140, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002103] = {
		[1] = {events = {{triTime = 450, hitEffID = 30136, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002108] = {
		[1] = {events = {{triTime = 375, hitEffID = 30143, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002109] = {
		[1] = {events = {{triTime = 450, hitEffID = 30092, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 1150, hitEffID = 30092, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, arg2 = 54.0, }, }, },},
	},
	[1002110] = {
		[1] = {events = {{triTime = 400, hitEffID = 30169, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 875, hitEffID = 30169, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, arg2 = 76.0, }, }, },},
	},
	[1002111] = {
		[1] = {events = {{triTime = 200, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002112] = {
		[1] = {events = {{triTime = 125, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
