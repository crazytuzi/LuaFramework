----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001602] = {
		[1] = {events = {{triTime = 525, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001631] = {
		[1] = {events = {{triTime = 400, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001632] = {
		[1] = {events = {{triTime = 475, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001633] = {
		[1] = {events = {{triTime = 425, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 8000, buffID = 22, }, }, }, },},
	},
	[1001603] = {
		[1] = {events = {{triTime = 3250, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.0, }, status = {{odds = 10000, buffID = 22, }, }, }, },},
	},
	[1001611] = {
		[1] = {events = {{triTime = 475, hitEffID = 30458, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001612] = {
		[1] = {events = {{triTime = 475, hitEffID = 30458, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001621] = {
		[1] = {events = {{triTime = 450, hitEffID = 30433, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001622] = {
		[1] = {events = {{triTime = 525, hitEffID = 30433, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
		[2] = {events = {{triTime = 525, hitEffID = 30433, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.0, }, }, },},
	},
	[1001604] = {
		[1] = {events = {},},
	},
	[1001601] = {
		[1] = {events = {{triTime = 450, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
