----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000681] = {
		[1] = {events = {{triTime = 600, hitEffID = 30221, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000682] = {
		[1] = {events = {{triTime = 550, hitEffID = 30221, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000684] = {
		[1] = {events = {{triTime = 700, hitEffID = 30221, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
		[2] = {events = {{triTime = 700, hitEffID = 30221, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.2, }, status = {{odds = 10000, buffID = 195, }, }, }, },},
		[3] = {events = {{triTime = 700, hitEffID = 30221, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 15000, buffID = 74001, }, }, }, },},
	},
	[1000702] = {
		[1] = {events = {{triTime = 775, hitEffID = 30223, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000703] = {
		[1] = {events = {{triTime = 1100, hitEffID = 30223, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
		[2] = {events = {{triTime = 1100, hitEffID = 30223, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.2, }, status = {{odds = 10000, buffID = 450, }, }, }, },},
	},
	[1000704] = {
		[1] = {events = {{triTime = 1025, hitEffID = 30223, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[2] = {events = {{triTime = 1025, hitEffID = 30223, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.3, }, status = {{odds = 10000, buffID = 450, }, }, }, },},
	},
	[1000683] = {
		[1] = {events = {{triTime = 425, hitEffID = 30221, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 850, hitEffID = 30221, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, },},
		[2] = {events = {{triTime = 425, hitEffID = 30221, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, status = {{odds = 10000, buffID = 193, }, }, }, {triTime = 850, hitEffID = 30221, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, },},
		[3] = {events = {{triTime = 425, hitEffID = 30221, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, status = {{odds = 15000, buffID = 74001, }, }, }, {triTime = 850, hitEffID = 30221, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, },},
	},
	[1000701] = {
		[1] = {events = {{triTime = 650, hitEffID = 30223, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
