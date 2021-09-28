----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94015] = {
		[1] = {cool = 15000, events = {{triTime = 875, status = {{odds = 10000, buffID = 1503, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
