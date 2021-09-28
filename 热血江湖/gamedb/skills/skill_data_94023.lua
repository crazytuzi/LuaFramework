----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94023] = {
		[1] = {cool = 15000, events = {{triTime = 800, hitEffID = 30916, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.3, }, status = {{odds = 1000, buffID = 1504, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
