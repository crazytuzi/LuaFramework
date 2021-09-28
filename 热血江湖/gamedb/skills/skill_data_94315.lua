----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94315] = {
		[1] = {cool = 10000, events = {{triTime = 775, hitEffID = 30777, damage = {odds = 10000, arg1 = 1.6499999999999997, }, }, {triTime = 1575, hitEffID = 30777, damage = {odds = 10000, arg1 = 1.6499999999999997, }, }, },},
	},

};
function get_db_table()
	return level;
end
