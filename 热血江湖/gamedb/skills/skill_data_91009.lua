----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[91009] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5071, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5072, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5073, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5074, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5075, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
