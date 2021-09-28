----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[92022] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 737, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 738, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 739, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 740, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 741, }, }, }, },},
		[6] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 742, }, }, }, },},
		[7] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 743, }, }, }, },},
		[8] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 744, }, }, }, },},
		[9] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 745, }, }, }, },},
		[10] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 746, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
