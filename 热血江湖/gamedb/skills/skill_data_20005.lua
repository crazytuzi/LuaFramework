----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[20005] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 168, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 494, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 495, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 496, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 497, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
