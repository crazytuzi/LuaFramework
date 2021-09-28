----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000011] = {
		[1] = {events = {{triTime = 450, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000012] = {
		[1] = {events = {{triTime = 475, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000013] = {
		[1] = {events = {{triTime = 500, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 825, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1475, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
		[2] = {events = {{triTime = 500, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75010, }, }, }, {triTime = 825, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1475, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[3] = {events = {{triTime = 500, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75011, }, }, }, {triTime = 825, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1475, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 500, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75012, }, }, }, {triTime = 825, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1475, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1000014] = {
		[1] = {events = {{triTime = 375, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.53, }, }, {triTime = 725, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.53, }, }, {triTime = 1225, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.53, }, }, },},
		[2] = {events = {{triTime = 375, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75001, }, }, }, {triTime = 725, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1225, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[3] = {events = {{triTime = 375, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75002, }, }, }, {triTime = 725, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1225, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 375, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75003, }, }, }, {triTime = 725, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1225, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1000015] = {
		[1] = {events = {{triTime = 400, hitEffID = 30083, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, },},
		[2] = {events = {{triTime = 400, hitEffID = 30083, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, status = {{odds = 10000, buffID = 103, }, }, }, },},
	},
	[1000016] = {
		[1] = {events = {{triTime = 550, hitSoundID = 14, damage = {odds = 10000, arg2 = 200.0, }, status = {{odds = 10000, buffID = 14, }, }, }, },},
	},
	[1000017] = {
		[1] = {events = {{triTime = 1875, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.59, }, }, {triTime = 2225, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.59, }, }, {triTime = 2725, hitEffID = 30082, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.59, }, }, },},
	},
	[1000018] = {
		[1] = {events = {{triTime = 2900, hitEffID = 30083, hitSoundID = 14, damage = {odds = 10000, arg1 = 5.1, }, }, },},
		[2] = {events = {{triTime = 2900, hitEffID = 30083, hitSoundID = 14, damage = {odds = 10000, arg1 = 5.1, }, status = {{odds = 10000, buffID = 103, }, }, }, },},
	},
	[1000021] = {
		[1] = {events = {{triTime = 800, hitEffID = 30074, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000022] = {
		[1] = {events = {{triTime = 900, hitEffID = 30074, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000023] = {
		[1] = {events = {{triTime = 1550, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
	},
	[1000024] = {
		[1] = {events = {{triTime = 4000, hitEffID = 30075, hitSoundID = 14, damage = {odds = 10000, }, }, },},
	},
	[1000025] = {
		[1] = {events = {{triTime = 1125, hitEffID = 30076, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, },},
		[2] = {events = {{triTime = 1125, hitEffID = 30076, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, status = {{odds = 10000, buffID = 103, }, }, }, },},
		[3] = {events = {{triTime = 1125, hitEffID = 30076, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 10, }, }, }, },},
		[4] = {events = {{triTime = 1125, hitEffID = 30076, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 392, }, }, }, },},
	},
	[1000026] = {
		[1] = {events = {{triTime = 4000, hitEffID = 30075, hitSoundID = 14, damage = {odds = 10000, }, }, },},
	},
	[1000027] = {
		[1] = {events = {{triTime = 4000, hitEffID = 30075, hitSoundID = 14, damage = {odds = 10000, }, }, },},
	},
	[1000028] = {
		[1] = {events = {{triTime = 3200, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.6, }, status = {{odds = 10000, buffID = 9, }, }, }, },},
		[2] = {events = {{triTime = 3200, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 391, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
