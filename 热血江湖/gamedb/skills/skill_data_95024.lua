----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[95024] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 878, }, }, }, {triTime = 200, damage = {odds = 10000, arg1 = 1.8, }, }, },},
	},

};
function get_db_table()
	return level;
end
