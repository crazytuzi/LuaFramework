----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99066] = {
		[1] = {cool = 7000, events = {{triTime = 625, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.3, }, status = {{odds = 10000, buffID = 43, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
