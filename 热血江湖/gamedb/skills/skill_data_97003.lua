----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[97003] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 952, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 954, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
