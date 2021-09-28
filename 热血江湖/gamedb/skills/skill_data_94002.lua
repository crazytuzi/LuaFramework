----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94002] = {
		[1] = {events = {{triTime = 100, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.45, }, }, },},
	},

};
function get_db_table()
	return level;
end
