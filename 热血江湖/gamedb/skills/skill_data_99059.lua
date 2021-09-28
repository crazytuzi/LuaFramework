----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99059] = {
		[1] = {cool = 7000, events = {{triTime = 800, hitEffID = 30264, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.0, }, status = {{odds = 10000, buffID = 202, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
