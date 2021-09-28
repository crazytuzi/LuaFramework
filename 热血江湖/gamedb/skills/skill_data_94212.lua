----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94212] = {
		[1] = {events = {{triTime = 375, hitEffID = 30792, damage = {odds = 10000, arg1 = 1.65, }, }, },},
	},

};
function get_db_table()
	return level;
end
