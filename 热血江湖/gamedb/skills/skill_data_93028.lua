----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93028] = {
		[1] = {events = {{triTime = 2450, damage = {odds = 10000, atrType = 1, arg1 = 2.0, }, }, {triTime = 3450, damage = {odds = 10000, atrType = 1, arg1 = 2.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
