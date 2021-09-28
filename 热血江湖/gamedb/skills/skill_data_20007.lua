----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[20007] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 37, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 490, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 491, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 492, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 493, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
