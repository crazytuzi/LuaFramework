----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1005001] = {
		[1] = {cool = 2000, events = {{triTime = 775, hitEffID = 30888, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1005002] = {
		[1] = {cool = 2000, events = {{triTime = 950, hitEffID = 30891, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 1000, hitEffID = 30888, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},
	[1005003] = {
		[1] = {cool = 2000, events = {{triTime = 850, hitEffID = 30890, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 900, hitEffID = 30890, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
