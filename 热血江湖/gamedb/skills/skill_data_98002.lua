----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[98002] = {
		[1] = {cool = 3000, events = {{triTime = 1000, hitEffID = 30490, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, },},
		[2] = {cool = 3000, events = {{triTime = 1000, hitEffID = 30490, damage = {odds = 10000, atrType = 1, arg1 = 2.0, }, }, },},
		[3] = {cool = 3000, events = {{triTime = 1000, hitEffID = 30490, damage = {odds = 10000, atrType = 1, arg1 = 3.0, }, }, },},
		[4] = {cool = 3000, events = {{triTime = 1000, hitEffID = 30490, damage = {odds = 10000, atrType = 1, arg1 = 4.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
