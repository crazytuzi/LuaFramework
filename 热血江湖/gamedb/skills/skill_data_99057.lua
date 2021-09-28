----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99057] = {
		[1] = {events = {{triTime = 475, hitEffID = 30264, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
