----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90009] = {
		[1] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 280, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 281, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 282, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 283, }, }, }, },},
		[5] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 284, }, }, }, },},
		[6] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 285, }, }, }, },},
		[7] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 286, }, }, }, },},
		[8] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 287, }, }, }, },},
		[9] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 288, }, }, }, },},
		[10] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 289, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
