----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1003001] = {
		[1] = {cool = 2000, events = {{triTime = 575, hitEffID = 30891, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1003002] = {
		[1] = {cool = 2000, events = {{triTime = 600, hitEffID = 30891, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1003003] = {
		[1] = {cool = 2000, events = {{triTime = 800, hitEffID = 30888, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
