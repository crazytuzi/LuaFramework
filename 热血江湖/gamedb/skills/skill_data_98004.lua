----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[98004] = {
		[1] = {cool = 3000, events = {{triTime = 1375, hitEffID = 30492, damage = {odds = 10000, atrType = 1, }, }, },},
		[2] = {cool = 3000, events = {{triTime = 1375, hitEffID = 30492, damage = {odds = 10000, atrType = 1, }, }, },},
		[3] = {cool = 3000, events = {{triTime = 1375, hitEffID = 30492, damage = {odds = 10000, atrType = 1, }, }, },},
		[4] = {cool = 3000, events = {{triTime = 1375, hitEffID = 30492, damage = {odds = 10000, atrType = 1, }, }, },},
	},

};
function get_db_table()
	return level;
end
