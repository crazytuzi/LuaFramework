----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94213] = {
		[1] = {cool = 6000, events = {{triTime = 1000, hitEffID = 30793, damage = {odds = 10000, arg1 = 0.95, }, status = {{odds = 18000, buffID = 1275, }, }, }, {triTime = 1250, hitEffID = 30793, damage = {odds = 10000, arg1 = 0.95, }, }, },},
	},

};
function get_db_table()
	return level;
end
