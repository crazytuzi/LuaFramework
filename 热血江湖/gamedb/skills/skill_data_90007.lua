----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90007] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 270, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 271, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 272, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 273, }, }, }, },},
		[5] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 274, }, }, }, },},
		[6] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 275, }, }, }, },},
		[7] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 276, }, }, }, },},
		[8] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 277, }, }, }, },},
		[9] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 278, }, }, }, },},
		[10] = {events = {{triTime = 100, damage = {atrType = 1, arg1 = 1.0, }, status = {{odds = 10000, buffID = 279, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
