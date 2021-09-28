----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[80008] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 3031, }, {odds = 10000, buffID = 3036, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 3032, }, {odds = 10000, buffID = 3037, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 3033, }, {odds = 10000, buffID = 3038, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 3034, }, {odds = 10000, buffID = 3039, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 3035, }, {odds = 10000, buffID = 3040, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
