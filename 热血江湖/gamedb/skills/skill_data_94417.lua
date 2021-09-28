----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94417] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 1276, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
