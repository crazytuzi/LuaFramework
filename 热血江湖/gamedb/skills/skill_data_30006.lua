----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[30006] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, arg2 = 200.0, }, status = {{odds = 10000, buffID = 61, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
