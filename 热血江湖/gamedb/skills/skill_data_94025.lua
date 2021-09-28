----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94025] = {
		[1] = {cool = 15000, events = {{triTime = 500, status = {{odds = 10000, buffID = 1505, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
