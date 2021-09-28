----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94115] = {
		[1] = {cool = 10000, events = {{triTime = 1325, hitEffID = 30860, damage = {odds = 10000, arg1 = 2.29, }, }, },},
	},

};
function get_db_table()
	return level;
end
