----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90012] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 304, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
