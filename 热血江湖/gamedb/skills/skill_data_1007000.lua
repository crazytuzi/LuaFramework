----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1007002] = {
		[1] = {cool = 2000, events = {{triTime = 675, hitEffID = 30295, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1007001] = {
		[1] = {cool = 2000, events = {{triTime = 825, hitEffID = 30294, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 925, hitEffID = 30294, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},
	[1007003] = {
		[1] = {cool = 2000, events = {{triTime = 675, hitEffID = 30293, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, {damage = {arg1 = 1.0, arg2 = 140.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
