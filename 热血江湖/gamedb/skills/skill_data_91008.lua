----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[91008] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5061, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5062, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5063, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5064, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5065, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
