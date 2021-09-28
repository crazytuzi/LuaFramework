----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002405] = {
		[1] = {events = {{triTime = 1700, hitEffID = 30983, hitSoundID = 14, damage = {odds = 10000, arg1 = 4.0, arg2 = 1000000.0, }, status = {{odds = 15000, buffID = 830, }, }, }, },},
	},
	[1002403] = {
		[1] = {events = {{triTime = 1700, hitEffID = 30983, hitSoundID = 14, damage = {odds = 10000, arg1 = 4.0, arg2 = 1000000.0, }, status = {{odds = 15000, buffID = 573, }, }, }, },},
	},
	[1002401] = {
		[1] = {events = {{triTime = 1700, hitEffID = 30983, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.0, arg2 = 800000.0, }, }, },},
	},
	[1002402] = {
		[1] = {events = {{triTime = 1375, hitEffID = 30983, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, arg2 = 600000.0, }, }, {triTime = 2200, hitEffID = 30983, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, arg2 = 600000.0, }, }, },},
	},
	[1002404] = {
		[1] = {events = {{triTime = 1375, hitEffID = 30983, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, arg2 = 800000.0, }, status = {{odds = 15000, buffID = 206, }, }, }, {triTime = 2200, hitEffID = 30983, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, arg2 = 800000.0, }, }, },},
	},
	[1002406] = {
		[1] = {events = {{triTime = 1375, hitEffID = 30983, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, arg2 = 800000.0, }, status = {{odds = 15000, buffID = 831, }, }, }, {triTime = 2200, hitEffID = 30983, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, arg2 = 800000.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
