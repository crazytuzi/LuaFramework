----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[80007] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 3026, }, {odds = 10000, buffID = 13, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 3027, }, {odds = 10000, buffID = 13, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 3028, }, {odds = 10000, buffID = 13, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 3029, }, {odds = 10000, buffID = 13, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 3030, }, {odds = 10000, buffID = 13, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
