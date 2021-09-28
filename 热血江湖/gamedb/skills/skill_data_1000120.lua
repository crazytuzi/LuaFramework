----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000121] = {
		[1] = {events = {{triTime = 550, hitEffID = 30096, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000122] = {
		[1] = {events = {{triTime = 625, hitEffID = 30096, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000123] = {
		[1] = {events = {{triTime = 750, hitEffID = 30096, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
		[2] = {events = {{triTime = 750, hitEffID = 30096, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 15, }, }, }, },},
	},
	[1000124] = {
		[1] = {events = {{triTime = 1000, hitEffID = 30097, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
		[2] = {events = {{triTime = 1000, hitEffID = 30097, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 17, }, }, }, },},
	},
	[1000131] = {
		[1] = {events = {{triTime = 600, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000132] = {
		[1] = {events = {{triTime = 400, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000133] = {
		[1] = {events = {{triTime = 425, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7, }, }, {triTime = 850, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7, }, }, },},
		[2] = {events = {{triTime = 425, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75013, }, }, }, {triTime = 850, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[3] = {events = {{triTime = 425, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75014, }, }, }, {triTime = 850, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 425, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75015, }, }, }, {triTime = 850, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1000134] = {
		[1] = {events = {{triTime = 775, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
		[2] = {events = {{triTime = 775, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, status = {{odds = 10000, buffID = 161, }, }, }, },},
		[3] = {events = {{triTime = 775, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75016, }, }, }, },},
		[4] = {events = {{triTime = 775, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75017, }, }, }, },},
		[5] = {events = {{triTime = 775, hitEffID = 30098, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75018, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
