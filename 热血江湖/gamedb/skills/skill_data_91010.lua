----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[91010] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5081, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5082, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5083, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5084, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5085, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
