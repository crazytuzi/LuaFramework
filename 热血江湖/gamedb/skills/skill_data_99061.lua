----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99061] = {
		[1] = {cool = 7000, events = {{triTime = 950, hitEffID = 30264, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.2, }, status = {{odds = 10000, buffID = 16, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
