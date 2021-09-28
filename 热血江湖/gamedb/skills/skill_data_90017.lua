----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90017] = {
		[1] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 345, }, {odds = 10000, buffID = 355, }, }, }, },},
		[2] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 346, }, {odds = 10000, buffID = 356, }, }, }, },},
		[3] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 347, }, {odds = 10000, buffID = 357, }, }, }, },},
		[4] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 348, }, {odds = 10000, buffID = 358, }, }, }, },},
		[5] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 349, }, {odds = 10000, buffID = 359, }, }, }, },},
		[6] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 72015, }, {odds = 10000, buffID = 72020, }, }, }, },},
		[7] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 72016, }, {odds = 10000, buffID = 72021, }, }, }, },},
		[8] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 72017, }, {odds = 10000, buffID = 72022, }, }, }, },},
		[9] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 72018, }, {odds = 10000, buffID = 72023, }, }, }, },},
		[10] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 72019, }, {odds = 10000, buffID = 72024, }, }, }, },},
		[11] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 72083, }, {odds = 10000, buffID = 72088, }, }, }, },},
		[12] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 72084, }, {odds = 10000, buffID = 72089, }, }, }, },},
		[13] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 72085, }, {odds = 10000, buffID = 72090, }, }, }, },},
		[14] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 72086, }, {odds = 10000, buffID = 72091, }, }, }, },},
		[15] = {events = {{triTime = 100, damage = {arg1 = 1.0, }, status = {{odds = 10000, buffID = 72087, }, {odds = 10000, buffID = 72092, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
