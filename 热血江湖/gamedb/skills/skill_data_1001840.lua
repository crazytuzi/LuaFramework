----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001842] = {
		[1] = {events = {{triTime = 625, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001843] = {
		[1] = {events = {{triTime = 600, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, {triTime = 1475, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
		[2] = {events = {{triTime = 600, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 393, }, }, }, {triTime = 1475, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 393, }, }, }, },},
		[3] = {events = {{triTime = 600, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, {triTime = 1475, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
	},
	[1001863] = {
		[1] = {events = {{triTime = 575, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 875, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 1250, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, },},
		[2] = {events = {{triTime = 575, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 397, }, }, }, {triTime = 875, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.2, }, }, {triTime = 1250, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
		[3] = {events = {{triTime = 575, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75001, }, {odds = 10000, buffID = 75022, }, }, }, {triTime = 875, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1250, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 575, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75002, }, {odds = 10000, buffID = 75023, }, }, }, {triTime = 875, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1250, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[5] = {events = {{triTime = 575, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75003, }, {odds = 10000, buffID = 75024, }, }, }, {triTime = 875, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1250, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[6] = {events = {{triTime = 575, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 875, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1250, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1001844] = {
		[1] = {events = {{triTime = 750, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg2 = 10000.0, }, }, },},
	},
	[1001861] = {
		[1] = {events = {{triTime = 525, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 975, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001862] = {
		[1] = {events = {{triTime = 700, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
		[2] = {events = {{triTime = 700, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75010, }, {odds = 10000, buffID = 75004, }, }, }, },},
		[3] = {events = {{triTime = 700, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75011, }, {odds = 10000, buffID = 75005, }, }, }, },},
		[4] = {events = {{triTime = 700, hitEffID = 30790, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75012, }, {odds = 10000, buffID = 75006, }, }, }, },},
	},
	[1001845] = {
		[1] = {events = {{triTime = 1475, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.2, }, }, },},
		[2] = {events = {{triTime = 1475, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 22, }, }, }, },},
		[3] = {events = {{triTime = 1475, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 22, }, }, }, },},
	},
	[1001846] = {
		[1] = {events = {{triTime = 725, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.2, }, }, {triTime = 1525, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.2, }, }, },},
		[2] = {events = {{triTime = 725, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.2, }, }, {triTime = 1525, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.2, }, }, },},
	},
	[1001841] = {
		[1] = {events = {{triTime = 575, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
