----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[98001] = {
		[1] = {cool = 3000, events = {{triTime = 100, hitEffID = 30489, damage = {odds = 10000, atrType = 1, arg1 = 3.0, }, status = {{odds = 5000, buffID = 22, }, }, }, },},
		[2] = {cool = 3000, events = {{triTime = 100, hitEffID = 30489, damage = {odds = 10000, atrType = 1, arg1 = 2.0, }, }, },},
		[3] = {cool = 3000, events = {{triTime = 100, hitEffID = 30489, damage = {odds = 10000, atrType = 1, arg1 = 3.0, }, }, },},
		[4] = {cool = 3000, events = {{triTime = 100, hitEffID = 30489, damage = {odds = 10000, atrType = 1, arg1 = 4.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
