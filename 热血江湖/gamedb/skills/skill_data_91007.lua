----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[91007] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5051, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5052, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5053, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5054, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5055, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
