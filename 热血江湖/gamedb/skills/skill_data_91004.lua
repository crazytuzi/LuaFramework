----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[91004] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5031, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5032, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5033, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5034, }, }, }, },},
		[5] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 5035, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
