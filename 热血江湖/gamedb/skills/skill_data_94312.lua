----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94312] = {
		[1] = {events = {{triTime = 575, hitEffID = 30776, damage = {odds = 10000, arg1 = 2.4, }, }, },},
	},

};
function get_db_table()
	return level;
end
