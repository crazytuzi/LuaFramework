----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90020] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72025, }, {odds = 5000, buffID = 72025, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72026, }, {odds = 5000, buffID = 72026, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72027, }, {odds = 5000, buffID = 72027, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72028, }, {odds = 5000, buffID = 72028, }, }, }, },},
		[5] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72029, }, {odds = 5000, buffID = 72029, }, }, }, },},
		[6] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72030, }, {odds = 5000, buffID = 72030, }, }, }, },},
		[7] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72031, }, {odds = 5000, buffID = 72031, }, }, }, },},
		[8] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72032, }, {odds = 5000, buffID = 72032, }, }, }, },},
		[9] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72033, }, {odds = 5000, buffID = 72033, }, }, }, },},
		[10] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72034, }, {odds = 5000, buffID = 72034, }, }, }, },},
		[11] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72058, }, {odds = 5000, buffID = 72058, }, }, }, },},
		[12] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72059, }, {odds = 5000, buffID = 72059, }, }, }, },},
		[13] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72060, }, {odds = 5000, buffID = 72060, }, }, }, },},
		[14] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72061, }, {odds = 5000, buffID = 72061, }, }, }, },},
		[15] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 72062, }, {odds = 5000, buffID = 72062, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
