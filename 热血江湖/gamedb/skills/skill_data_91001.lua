----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[91001] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5001, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5002, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5003, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5004, }, }, }, },},
		[5] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5005, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
