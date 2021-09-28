----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90005] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 246, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 247, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 248, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 249, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 250, }, }, }, },},
		[6] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72005, }, }, }, },},
		[7] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72006, }, }, }, },},
		[8] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72007, }, }, }, },},
		[9] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72008, }, }, }, },},
		[10] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72009, }, }, }, },},
		[11] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72076, }, }, }, },},
		[12] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72077, }, }, }, },},
		[13] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72078, }, }, }, },},
		[14] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72079, }, }, }, },},
		[15] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72080, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
