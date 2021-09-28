----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1006002] = {
		[1] = {cool = 2000, events = {{triTime = 950, hitEffID = 30315, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 1050, hitEffID = 30315, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},
	[1006003] = {
		[1] = {cool = 2000, events = {{triTime = 1150, hitEffID = 30313, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1006001] = {
		[1] = {cool = 2000, events = {{triTime = 750, hitEffID = 30313, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
