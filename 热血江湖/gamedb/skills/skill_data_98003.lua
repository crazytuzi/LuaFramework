----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[98003] = {
		[1] = {cool = 3000, events = {{triTime = 1000, hitEffID = 30491, damage = {odds = 10000, arg2 = 500.0, }, }, },},
		[2] = {cool = 3000, events = {{triTime = 1000, hitEffID = 30491, damage = {odds = 10000, arg2 = 600.0, }, }, },},
		[3] = {cool = 3000, events = {{triTime = 1000, hitEffID = 30491, damage = {odds = 10000, arg2 = 700.0, }, }, },},
		[4] = {cool = 3000, events = {{triTime = 1000, hitEffID = 30491, damage = {odds = 10000, arg2 = 800.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
