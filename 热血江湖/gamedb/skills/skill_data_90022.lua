----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90022] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72045, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72046, }, }, }, },},
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72047, }, }, }, },},
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72048, }, }, }, },},
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72049, }, }, }, },},
		[6] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72050, }, }, }, },},
		[7] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72051, }, }, }, },},
		[8] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72052, }, }, }, },},
		[9] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72053, }, }, }, },},
		[10] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 72054, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
