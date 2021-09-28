----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99075] = {
		[1] = {cool = 4000, events = {{triTime = 1100, hitEffID = 30977, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 7000, buffID = 22, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
