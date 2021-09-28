----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93029] = {
		[1] = {events = {{triTime = 525, hitEffID = 30443, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, arg2 = 500.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
