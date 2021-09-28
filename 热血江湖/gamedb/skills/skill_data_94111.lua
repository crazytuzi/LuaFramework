----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94111] = {
		[1] = {events = {{triTime = 300, hitEffID = 30860, damage = {odds = 10000, arg1 = 1.6, }, }, },},
	},

};
function get_db_table()
	return level;
end
