----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94415] = {
		[1] = {cool = 8000, events = {{triTime = 625, hitEffID = 30777, damage = {odds = 10000, arg1 = 2.7, }, }, },},
	},

};
function get_db_table()
	return level;
end
