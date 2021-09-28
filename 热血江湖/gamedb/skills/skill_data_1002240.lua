----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002252] = {
		[1] = {events = {{hitEffID = 30957, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002253] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, acrType = 1, arg2 = 500.0, }, }, },},
	},
	[1002241] = {
		[1] = {events = {{triTime = 1625, hitEffID = 30969, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002251] = {
		[1] = {events = {{triTime = 2500, hitEffID = 30749, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 3000, hitEffID = 30749, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 3500, hitEffID = 30749, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002261] = {
		[1] = {events = {{triTime = 1125, hitEffID = 30749, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 1500, hitEffID = 30749, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 1875, hitEffID = 30749, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002262] = {
		[1] = {events = {{hitEffID = 30749, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002263] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, acrType = 1, arg2 = 500.0, }, }, },},
	},
	[1002272] = {
		[1] = {events = {{hitEffID = 30970, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},
	[1002273] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, acrType = 1, arg2 = 500.0, }, }, },},
	},
	[1002242] = {
		[1] = {events = {{triTime = 2075, hitEffID = 30969, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002271] = {
		[1] = {events = {{triTime = 1950, hitEffID = 30970, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 2625, hitEffID = 30970, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
