----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[91005] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5041, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5042, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5043, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5044, }, }, }, },},
		[5] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5045, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
