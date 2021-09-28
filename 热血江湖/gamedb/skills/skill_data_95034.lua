----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[95034] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 7500, buffID = 120315, }, {buffID = 120316, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
