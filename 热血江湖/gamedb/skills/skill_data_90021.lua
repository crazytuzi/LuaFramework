----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90021] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72035, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72036, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72037, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72038, }, }, }, },},
		[5] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72039, }, }, }, },},
		[6] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72040, }, }, }, },},
		[7] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72041, }, }, }, },},
		[8] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72042, }, }, }, },},
		[9] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72043, }, }, }, },},
		[10] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72044, }, }, }, },},
		[11] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72063, }, }, }, },},
		[12] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72064, }, }, }, },},
		[13] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72065, }, }, }, },},
		[14] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72066, }, }, }, },},
		[15] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72067, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
