----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94014] = {
		[1] = {cool = 12000, events = {{triTime = 650, damage = {odds = 10000, arg2 = 23375.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
