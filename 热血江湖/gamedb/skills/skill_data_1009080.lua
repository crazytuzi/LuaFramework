----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1009101] = {
		[1] = {cool = 6000, events = {{triTime = 525, hitEffID = 30941, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 600, hitEffID = 30941, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},
	[1009102] = {
		[1] = {cool = 6000, events = {{triTime = 750, hitEffID = 30310, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 800, hitEffID = 30310, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
