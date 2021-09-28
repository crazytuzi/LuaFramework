----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[95031] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 120311, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 120313, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
