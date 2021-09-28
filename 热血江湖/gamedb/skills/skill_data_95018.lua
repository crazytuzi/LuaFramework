----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[95018] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 3.5, }, }, },},
		[2] = {events = {{triTime = 100, damage = {odds = 10000, atrType = 1, arg1 = 4.2, }, }, },},
	},

};
function get_db_table()
	return level;
end
