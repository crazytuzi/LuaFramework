----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94006] = {
		[1] = {cool = 10000, events = {{triTime = 500, hitEffID = 30091, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 1501, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
