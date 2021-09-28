----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1008001] = {
		[1] = {cool = 2000, events = {{triTime = 950, hitEffID = 30300, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 1050, hitEffID = 30300, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},
	[1008002] = {
		[1] = {cool = 2000, events = {{triTime = 950, hitEffID = 30302, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1008003] = {
		[1] = {cool = 2000, events = {{triTime = 675, hitEffID = 30301, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 825, hitEffID = 30293, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
