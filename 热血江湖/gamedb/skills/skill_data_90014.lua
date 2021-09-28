----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90014] = {
		[1] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 315, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 316, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 317, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 318, }, }, }, },},
		[5] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 319, }, }, }, },},
		[6] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 320, }, }, }, },},
		[7] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 321, }, }, }, },},
		[8] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 322, }, }, }, },},
		[9] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 323, }, }, }, },},
		[10] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 324, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
