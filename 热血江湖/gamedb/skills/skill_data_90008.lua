----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90008] = {
		[1] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 260, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 261, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 262, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 263, }, }, }, },},
		[5] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 264, }, }, }, },},
		[6] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 265, }, }, }, },},
		[7] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 266, }, }, }, },},
		[8] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 267, }, }, }, },},
		[9] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 268, }, }, }, },},
		[10] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 269, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
