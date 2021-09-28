----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1003205] = {
		[1] = {cool = 6000, events = {{triTime = 750, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1003201] = {
		[1] = {cool = 2000, events = {{triTime = 626, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1003202] = {
		[1] = {cool = 2000, events = {{triTime = 750, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1003203] = {
		[1] = {cool = 2000, events = {{triTime = 500, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1003204] = {
		[1] = {cool = 6000, events = {{triTime = 650, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1003206] = {
		[1] = {cool = 6000, events = {{triTime = 425, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
