----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93027] = {
		[1] = {events = {{triTime = 1500, damage = {odds = 10000, atrType = 1, arg1 = 2.0, }, status = {{odds = 10000, buffID = 1425, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
