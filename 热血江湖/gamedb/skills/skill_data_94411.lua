----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94411] = {
		[1] = {events = {{triTime = 625, hitEffID = 30776, damage = {odds = 10000, arg1 = 2.2, }, }, },},
	},

};
function get_db_table()
	return level;
end
