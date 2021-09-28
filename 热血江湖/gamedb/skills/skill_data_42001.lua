----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[42001] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 12000, buffID = 103, }, {odds = 10000, buffID = 667, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
