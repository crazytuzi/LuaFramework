----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93038] = {
		[1] = {events = {{triTime = 25, status = {{odds = 10000, buffID = 1430, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
