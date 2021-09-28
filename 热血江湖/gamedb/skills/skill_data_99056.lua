----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99056] = {
		[1] = {cool = 7000, events = {{triTime = 350, hitEffID = 30082, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.8, }, status = {{odds = 10000, buffID = 43, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
