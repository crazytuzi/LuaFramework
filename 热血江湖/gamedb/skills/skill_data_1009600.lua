----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1009603] = {
		[1] = {events = {{triTime = 2300, damage = {odds = 10000, atrType = 1, arg1 = 1.0, arg2 = 10000.0, }, status = {{odds = 10000, buffID = 60204, }, }, }, },},
	},
	[1009601] = {
		[1] = {events = {{triTime = 400, hitEffID = 30429, damage = {odds = 10000, atrType = 1, arg1 = 1.0, arg2 = 10000.0, }, }, },},
	},
	[1009604] = {
		[1] = {events = {{triTime = 2300, damage = {odds = 10000, atrType = 1, arg1 = 1.0, arg2 = 10000.0, }, status = {{odds = 10000, buffID = 60205, }, }, }, },},
	},
	[1009605] = {
		[1] = {events = {{triTime = 2300, damage = {odds = 10000, atrType = 1, arg1 = 1.0, arg2 = 10000.0, }, status = {{odds = 10000, buffID = 60206, }, }, }, },},
	},
	[1009602] = {
		[1] = {events = {{triTime = 2300, damage = {odds = 10000, atrType = 1, arg1 = 1.0, arg2 = 10000.0, }, status = {{odds = 10000, buffID = 60203, }, }, }, },},
	},
	[1009606] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 60202, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
