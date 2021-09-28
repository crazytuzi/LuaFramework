----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94005] = {
		[1] = {cool = 12000, events = {{triTime = 625, damage = {odds = 10000, arg2 = 28050.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
