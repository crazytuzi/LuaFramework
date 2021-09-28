----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99041] = {
		[1] = {cool = 7000, events = {{triTime = 500, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.384, arg2 = 894.0, }, }, {triTime = 1000, hitEffID = 30214, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.384, arg2 = 894.0, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.384, arg2 = 894.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
