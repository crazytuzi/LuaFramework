----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[70007] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 655, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 656, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 657, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 658, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 659, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
