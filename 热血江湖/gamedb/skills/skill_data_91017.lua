----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[91017] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 1301, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 1302, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 1303, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 1304, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 1305, }, }, }, },},
		[6] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 1306, }, }, }, },},
		[7] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 1307, }, }, }, },},
		[8] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 1308, }, }, }, },},
		[9] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 1309, }, }, }, },},
		[10] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 1310, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
