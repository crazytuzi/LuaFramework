----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[91002] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5011, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5012, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5013, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5014, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 5015, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
