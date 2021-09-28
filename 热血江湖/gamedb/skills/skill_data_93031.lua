----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93031] = {
		[1] = {events = {{triTime = 300, status = {{odds = 10000, buffID = 1424, }, {buffID = 1426, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
