----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[50007] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 63, }, {odds = 10000, buffID = 68, }, }, }, {triTime = 200, status = {{odds = 10000, buffID = 73, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 64, }, {odds = 10000, buffID = 69, }, }, }, {triTime = 200, status = {{odds = 10000, buffID = 74, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 65, }, {odds = 10000, buffID = 70, }, }, }, {triTime = 200, status = {{odds = 10000, buffID = 75, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 66, }, {odds = 10000, buffID = 71, }, }, }, {triTime = 200, status = {{odds = 10000, buffID = 76, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 67, }, {odds = 10000, buffID = 72, }, }, }, {triTime = 200, status = {{odds = 10000, buffID = 77, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
