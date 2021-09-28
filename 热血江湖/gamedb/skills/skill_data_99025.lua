----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99025] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 390, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
