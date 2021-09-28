----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93001] = {
		[1] = {events = {{triTime = 500, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, status = {{odds = 1000, buffID = 1400, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
