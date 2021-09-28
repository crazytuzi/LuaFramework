----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99029] = {
		[1] = {cool = 7000, events = {{triTime = 1475, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.384, arg2 = 894.0, }, status = {{odds = 10000, buffID = 103, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
