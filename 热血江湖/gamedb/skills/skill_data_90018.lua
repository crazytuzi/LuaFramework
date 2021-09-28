----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90018] = {
		[1] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 365, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 366, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 367, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 368, }, }, }, },},
		[5] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 369, }, }, }, },},
		[6] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 370, }, }, }, },},
		[7] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 371, }, }, }, },},
		[8] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 372, }, }, }, },},
		[9] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 373, }, }, }, },},
		[10] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 374, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
