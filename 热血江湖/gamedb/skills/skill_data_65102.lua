----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[65102] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 695, }, {odds = 10000, buffID = 705, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 696, }, {odds = 10000, buffID = 706, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 697, }, {odds = 10000, buffID = 707, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 698, }, {odds = 10000, buffID = 708, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 699, }, {odds = 10000, buffID = 709, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
