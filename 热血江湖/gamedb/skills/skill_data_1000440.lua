----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000441] = {
		[1] = {events = {{triTime = 600, hitEffID = 30065, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000442] = {
		[1] = {events = {{triTime = 550, hitEffID = 30065, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000443] = {
		[1] = {events = {{triTime = 425, hitEffID = 30065, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 850, hitEffID = 30065, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, },},
		[2] = {events = {{triTime = 425, hitEffID = 30065, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 53, }, }, }, {triTime = 850, hitEffID = 30065, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 53, }, }, }, },},
		[3] = {events = {{triTime = 425, hitEffID = 30065, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, status = {{odds = 15000, buffID = 74001, }, }, }, {triTime = 850, hitEffID = 30065, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, },},
	},
	[1000444] = {
		[1] = {events = {{triTime = 700, hitEffID = 30065, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
		[2] = {events = {{triTime = 700, hitEffID = 30065, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 54, }, }, }, },},
		[3] = {events = {{triTime = 700, hitEffID = 30065, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 22, }, }, }, },},
		[4] = {events = {{triTime = 700, hitEffID = 30065, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 15000, buffID = 74001, }, }, }, },},
	},
	[1000445] = {
		[1] = {events = {{triTime = 3425, hitEffID = 30065, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 393, }, }, }, {triTime = 3850, hitEffID = 30065, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 393, }, }, }, },},
	},
	[1000451] = {
		[1] = {events = {{triTime = 375, hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000452] = {
		[1] = {events = {{triTime = 600, hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000453] = {
		[1] = {events = {{triTime = 950, hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
		[2] = {events = {{triTime = 950, hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, status = {{odds = 10000, buffID = 22, }, }, }, },},
		[3] = {events = {{triTime = 950, hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 15000, buffID = 74001, }, }, }, },},
	},
	[1000454] = {
		[1] = {events = {{hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.32, }, }, },},
		[2] = {events = {{hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.2, }, status = {{odds = 10000, buffID = 49, }, }, }, },},
		[3] = {events = {{hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.32, }, status = {{odds = 15000, buffID = 74001, }, }, }, },},
	},
	[1000455] = {
		[1] = {events = {{hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 194, }, }, }, },},
	},
	[1000456] = {
		[1] = {events = {{triTime = 3450, hitEffID = 30062, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.0, }, status = {{odds = 10000, buffID = 22, }, }, }, },},
	},
	[1000461] = {
		[1] = {events = {{triTime = 500, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000462] = {
		[1] = {events = {{triTime = 350, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000463] = {
		[1] = {events = {{triTime = 500, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 1000, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, },},
		[2] = {events = {{triTime = 500, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 16, }, {odds = 10000, buffID = 50, }, }, }, {triTime = 1000, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[3] = {events = {{triTime = 500, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75001, }, }, }, {triTime = 1000, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 500, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75002, }, }, }, {triTime = 1000, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[5] = {events = {{triTime = 500, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75003, }, }, }, {triTime = 1000, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1000464] = {
		[1] = {events = {{triTime = 800, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, },},
		[2] = {events = {{triTime = 800, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.1, }, status = {{odds = 10000, buffID = 448, }, }, }, },},
		[3] = {events = {{triTime = 800, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 800, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[5] = {events = {{triTime = 800, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1000466] = {
		[1] = {events = {{triTime = 625, hitEffID = 30189, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.65, }, }, {triTime = 875, hitEffID = 30189, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.65, }, }, {triTime = 1125, hitEffID = 30189, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.65, }, }, },},
	},
	[1000467] = {
		[1] = {events = {{triTime = 3300, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 5.1, }, status = {{odds = 10000, buffID = 85, }, }, }, },},
		[2] = {events = {{triTime = 3300, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 5.1, }, status = {{odds = 10000, buffID = 85, }, }, }, },},
		[3] = {events = {{triTime = 3300, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 5.1, }, status = {{odds = 10000, buffID = 85, }, }, }, },},
	},
	[1000468] = {
		[1] = {events = {{triTime = 2600, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 4.6, }, status = {{odds = 10000, buffID = 16, }, }, }, },},
		[2] = {events = {{triTime = 2600, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 4.6, }, status = {{odds = 10000, buffID = 16, }, }, }, },},
		[3] = {events = {{triTime = 2600, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 4.6, }, status = {{odds = 10000, buffID = 16, }, }, }, },},
	},
	[1000469] = {
		[1] = {events = {{triTime = 3875, status = {{odds = 10000, buffID = 199, }, {odds = 10000, buffID = 400, }, }, }, },},
	},
	[1000471] = {
		[1] = {events = {{triTime = 625, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000472] = {
		[1] = {events = {{triTime = 375, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000473] = {
		[1] = {events = {{triTime = 500, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
		[2] = {events = {{triTime = 500, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 56, }, }, }, },},
		[3] = {events = {{triTime = 500, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 6.0, }, }, },},
		[4] = {events = {{triTime = 500, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75013, }, }, }, },},
		[5] = {events = {{triTime = 500, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75014, }, }, }, },},
		[6] = {events = {{triTime = 500, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75015, }, }, }, },},
	},
	[1000474] = {
		[1] = {events = {{triTime = 875, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, },},
		[2] = {events = {{triTime = 875, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75016, }, }, }, },},
		[3] = {events = {{triTime = 875, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75017, }, }, }, },},
		[4] = {events = {{triTime = 875, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75018, }, }, }, },},
		[5] = {events = {{triTime = 875, hitEffID = 30187, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, status = {{odds = 20000, buffID = 44, }, }, }, },},
	},
	[1000475] = {
		[1] = {events = {{triTime = 3500, status = {{odds = 10000, buffID = 45, }, }, }, },},
	},
	[1000476] = {
		[1] = {events = {{triTime = 3500, status = {{odds = 10000, buffID = 46, }, }, }, },},
	},
	[1000477] = {
		[1] = {events = {{triTime = 3500, status = {{odds = 10000, buffID = 47, }, }, }, },},
	},
	[1000478] = {
		[1] = {events = {{triTime = 3500, status = {{odds = 10000, buffID = 48, }, }, }, },},
	},
	[1000465] = {
		[1] = {events = {{triTime = 600, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, },},
		[2] = {events = {{triTime = 600, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75004, }, }, }, },},
		[3] = {events = {{triTime = 600, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75005, }, }, }, },},
		[4] = {events = {{triTime = 600, hitEffID = 30188, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75006, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
