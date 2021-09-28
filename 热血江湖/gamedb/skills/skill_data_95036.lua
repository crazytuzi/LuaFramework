----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[95036] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 12000, buffID = 120320, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
