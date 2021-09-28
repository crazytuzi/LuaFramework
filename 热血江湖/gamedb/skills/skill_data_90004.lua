----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90004] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 236, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 237, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 238, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 239, }, }, }, },},
		[5] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 240, }, }, }, },},
		[6] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72000, }, }, }, },},
		[7] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72001, }, }, }, },},
		[8] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72002, }, }, }, },},
		[9] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72003, }, }, }, },},
		[10] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72004, }, }, }, },},
		[11] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72071, }, }, }, },},
		[12] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72072, }, }, }, },},
		[13] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72073, }, }, }, },},
		[14] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72074, }, }, }, },},
		[15] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72075, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
