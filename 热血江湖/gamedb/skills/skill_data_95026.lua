----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[95026] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 880, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 883, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 884, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
