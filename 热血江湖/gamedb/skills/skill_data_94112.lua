----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94112] = {
		[1] = {events = {{triTime = 350, hitEffID = 30860, damage = {odds = 10000, arg1 = 1.6, }, }, },},
	},

};
function get_db_table()
	return level;
end
