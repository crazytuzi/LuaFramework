----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000831] = {
		[1] = {events = {{triTime = 600, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000801] = {
		[1] = {events = {{triTime = 600, hitEffID = 30242, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000802] = {
		[1] = {events = {{triTime = 775, hitEffID = 30242, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000803] = {
		[1] = {events = {{triTime = 800, hitEffID = 30243, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
	},
	[1000804] = {
		[1] = {events = {{triTime = 500, hitEffID = 30244, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1000, hitEffID = 30244, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1500, hitEffID = 30244, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
		[2] = {events = {{triTime = 500, hitEffID = 30244, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9, }, status = {{odds = 10000, buffID = 11, }, }, }, {triTime = 1000, hitEffID = 30244, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9, }, }, {triTime = 1500, hitEffID = 30244, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9, }, }, },},
	},
	[1000815] = {
		[1] = {events = {{hitEffID = 30264, hitSoundID = 14, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 180, }, }, }, },spArgs1 = '0', spArgs2 = '0', spArgs3 = '100', },
	},
	[1000816] = {
		[1] = {events = {{hitEffID = 30264, hitSoundID = 14, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 181, }, }, }, },spArgs1 = '0', spArgs2 = '0', spArgs3 = '100', },
	},
	[1000817] = {
		[1] = {events = {{hitEffID = 30264, hitSoundID = 14, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 182, }, }, }, },spArgs1 = '0', spArgs2 = '0', spArgs3 = '100', },
	},
	[1000818] = {
		[1] = {events = {{hitEffID = 30264, hitSoundID = 14, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 183, }, }, }, },spArgs1 = '0', spArgs2 = '0', spArgs3 = '100', },
	},
	[1000832] = {
		[1] = {events = {{triTime = 725, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000833] = {
		[1] = {events = {{triTime = 925, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
		[2] = {events = {{triTime = 925, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 203, }, }, }, },},
		[3] = {events = {{triTime = 925, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 210, }, }, }, },},
		[4] = {events = {{triTime = 925, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75010, }, }, }, },},
		[5] = {events = {{triTime = 925, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75011, }, }, }, },},
		[6] = {events = {{triTime = 925, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75012, }, }, }, },},
		[7] = {events = {{triTime = 925, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, },},
	},
	[1000834] = {
		[1] = {events = {{triTime = 375, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[2] = {events = {{triTime = 375, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 22, }, }, }, },},
		[3] = {events = {{triTime = 375, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 202, }, }, }, },},
	},
	[1000835] = {
		[1] = {events = {{triTime = 1075, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
		[2] = {events = {{triTime = 1075, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75001, }, }, }, },},
		[3] = {events = {{triTime = 1075, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75002, }, }, }, },},
		[4] = {events = {{triTime = 1075, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75003, }, }, }, },},
	},
	[1000836] = {
		[1] = {events = {{triTime = 3275, hitEffID = 30249, hitSoundID = 14, damage = {odds = 10000, arg1 = 3.0, }, status = {{odds = 10000, buffID = 211, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
