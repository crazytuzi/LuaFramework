----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93010] = {
		[1] = {events = {{triTime = 500, damage = {odds = 10000, atrType = 1, arg1 = 0.9, }, status = {{odds = 3000, buffID = 1406, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
