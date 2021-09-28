----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[80009] = {
		[1] = {events = {{triTime = 100, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},

};
function get_db_table()
	return level;
end
