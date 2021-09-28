----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000246] = {
		[1] = {events = {{triTime = 3800, hitEffID = 30124, hitSoundID = 14, damage = {odds = 10000, arg1 = 4.8, }, }, },},
	},
	[1000247] = {
		[1] = {events = {{triTime = 2950, hitEffID = 30123, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, },},
		[2] = {events = {{triTime = 2950, hitEffID = 30123, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, status = {{odds = 10000, buffID = 103, }, }, }, },},
	},
	[1000251] = {
		[1] = {events = {{triTime = 650, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000255] = {
		[1] = {events = {{triTime = 875, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, },},
	},
	[1000256] = {
		[1] = {events = {{triTime = 350, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 1000, buffID = 58, }, {odds = 10000, buffID = 3, }, }, }, {triTime = 1425, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 3, }, }, }, },},
	},
	[1000257] = {
		[1] = {events = {{triTime = 2875, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 209, }, {odds = 10000, buffID = 3, }, }, }, },},
	},
	[1000271] = {
		[1] = {events = {{triTime = 550, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000272] = {
		[1] = {events = {{triTime = 525, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000252] = {
		[1] = {events = {{triTime = 475, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000253] = {
		[1] = {events = {{triTime = 675, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[2] = {events = {{triTime = 675, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 11, }, }, }, },},
	},
	[1000254] = {
		[1] = {events = {{triTime = 350, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 1425, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000273] = {
		[1] = {events = {{triTime = 675, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[2] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 212, }, }, }, {triTime = 675, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.0, }, }, },},
	},
	[1000274] = {
		[1] = {events = {{hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4, }, }, },},
		[2] = {events = {{hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, status = {{odds = 10000, buffID = 214, }, {odds = 10000, buffID = 215, }, }, }, },},
	},
	[1000275] = {
		[1] = {events = {{triTime = 1200, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, },},
		[2] = {events = {{triTime = 1200, hitEffID = 30129, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.0, }, status = {{odds = 10000, buffID = 22, }, }, }, },},
	},
	[1000248] = {
		[1] = {events = {{triTime = 1150, hitEffID = 30295, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 396, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
