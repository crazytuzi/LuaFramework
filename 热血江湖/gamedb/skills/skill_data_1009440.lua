----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1009469] = {
		[1] = {events = {{triTime = 375, hitEffID = 30286, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 115, }, }, }, },},
	},
	[1009463] = {
		[1] = {events = {{triTime = 125, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg2 = 1.0, }, status = {{odds = 10000, buffID = 1540, }, }, }, },},
	},
	[1009464] = {
		[1] = {events = {{triTime = 275, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg2 = 1.0, }, status = {{odds = 10000, buffID = 1540, }, }, }, },},
	},
	[1009466] = {
		[1] = {cool = 10000, events = {{triTime = 550, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg2 = 1.0, }, status = {{odds = 10000, buffID = 1539, }, }, }, },},
	},
	[1009471] = {
		[1] = {events = {{triTime = 425, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1009473] = {
		[1] = {events = {{triTime = 500, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 800, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
	},
	[1009461] = {
		[1] = {events = {{triTime = 200, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg2 = 1.0, }, status = {{odds = 10000, buffID = 1540, }, }, }, },},
	},
	[1009462] = {
		[1] = {events = {{triTime = 125, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg2 = 1.0, }, status = {{odds = 10000, buffID = 1540, }, }, }, },},
	},
	[1009468] = {
		[1] = {events = {{triTime = 350, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 115, }, }, }, },},
	},
	[1009472] = {
		[1] = {events = {{triTime = 375, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.6, }, }, {triTime = 625, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.6, }, }, },},
	},
	[1009475] = {
		[1] = {events = {{triTime = 1000, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 2250, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 4375, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9, }, }, },},
	},
	[1009476] = {
		[1] = {events = {{triTime = 3000, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, {damage = {arg1 = 0.6, }, }, },},
	},
	[1009477] = {
		[1] = {events = {{triTime = 3000, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, {damage = {arg1 = 0.6, }, }, },},
	},
	[1009478] = {
		[1] = {events = {{triTime = 1250, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.3, }, }, },},
	},
	[1009479] = {
		[1] = {events = {{triTime = 1250, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 2750, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1009467] = {
		[1] = {events = {{triTime = 350, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 115, }, }, }, },},
	},
	[1009465] = {
		[1] = {cool = 10000, events = {{triTime = 300, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg2 = 1.0, }, }, },},
	},
	[1009470] = {
		[1] = {events = {{triTime = 375, hitEffID = 30286, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 10000, buffID = 115, }, }, }, },},
	},
	[1009474] = {
		[1] = {events = {{triTime = 800, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4, }, }, {triTime = 1425, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4, }, }, {triTime = 2000, hitEffID = 30429, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4, }, }, },},
	},

};
function get_db_table()
	return level;
end
