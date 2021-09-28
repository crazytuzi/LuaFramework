----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93014] = {
		[1] = {cool = 20000, events = {{triTime = 125, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
