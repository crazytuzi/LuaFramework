----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94414] = {
		[1] = {cool = 12000, events = {{triTime = 875, hitEffID = 30777, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
