----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99045] = {
		[1] = {events = {{triTime = 475, hitEffID = 30235, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
