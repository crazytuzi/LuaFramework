----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99028] = {
		[1] = {cool = 5000, events = {{triTime = 1325, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.368, arg2 = 858.0, }, status = {{odds = 10000, buffID = 27, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
