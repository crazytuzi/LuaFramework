----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[95014] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 13000, buffID = 867, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
