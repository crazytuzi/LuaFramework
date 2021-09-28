----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93032] = {
		[1] = {events = {{triTime = 875, damage = {odds = 10000, atrType = 1, arg1 = 1.5, }, }, },},
	},

};
function get_db_table()
	return level;
end
