----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93030] = {
		[1] = {events = {{triTime = 600, hitEffID = 30443, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.1, arg2 = 500.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
