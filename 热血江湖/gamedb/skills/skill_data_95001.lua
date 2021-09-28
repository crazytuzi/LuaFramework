----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[95001] = {
		[1] = {events = {{triTime = 200, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 593, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
