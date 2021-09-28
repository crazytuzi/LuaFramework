----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94035] = {
		[1] = {cool = 15000, events = {{triTime = 400, status = {{odds = 10000, buffID = 1507, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
