----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94004] = {
		[1] = {cool = 15000, events = {{triTime = 750, status = {{odds = 10000, buffID = 1502, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
