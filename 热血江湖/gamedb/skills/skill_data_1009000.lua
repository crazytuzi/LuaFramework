----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1009001] = {
		[1] = {cool = 2000, events = {{triTime = 1000, hitEffID = 30310, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 1250, hitEffID = 30310, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},
	[1009002] = {
		[1] = {cool = 2000, events = {{triTime = 850, hitEffID = 30310, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1009003] = {
		[1] = {cool = 2000, events = {{triTime = 875, hitEffID = 30312, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 950, hitEffID = 30312, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
