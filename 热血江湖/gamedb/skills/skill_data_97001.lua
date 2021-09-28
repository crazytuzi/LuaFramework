----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[97001] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 71301, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 71302, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 71303, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 71304, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 71305, }, }, }, },},
		[6] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 71306, }, }, }, },},
		[7] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 71307, }, }, }, },},
		[8] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 71308, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
