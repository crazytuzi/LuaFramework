----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90024] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 762, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 763, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72093, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72094, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72095, }, }, }, },},
		[6] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72096, }, }, }, },},
		[7] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72097, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
