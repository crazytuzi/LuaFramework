----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[24204] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 585, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
