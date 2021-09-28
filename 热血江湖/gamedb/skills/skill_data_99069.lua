----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99069] = {
		[1] = {cool = 7000, events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.4, }, status = {{odds = 10000, buffID = 43, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
