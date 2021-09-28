----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[30005] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 62, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 78, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 79, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 80, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 81, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
