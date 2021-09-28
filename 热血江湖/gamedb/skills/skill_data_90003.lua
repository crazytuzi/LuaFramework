----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90003] = {
		[1] = {events = {{triTime = 100, hitEffID = 30144, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 226, }, }, }, },},
		[2] = {events = {{triTime = 100, hitEffID = 30144, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 227, }, }, }, },},
		[3] = {events = {{triTime = 100, hitEffID = 30144, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 228, }, }, }, },},
		[4] = {events = {{triTime = 100, hitEffID = 30144, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 229, }, }, }, },},
		[5] = {events = {{triTime = 100, hitEffID = 30144, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 230, }, }, }, },},
		[6] = {events = {{triTime = 100, hitEffID = 30144, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 72068, }, }, }, },},
		[7] = {events = {{triTime = 100, hitEffID = 30144, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 72069, }, }, }, },},
		[8] = {events = {{triTime = 100, hitEffID = 30144, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 72070, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
