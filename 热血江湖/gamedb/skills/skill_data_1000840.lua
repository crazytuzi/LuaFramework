----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000841] = {
		[1] = {events = {{triTime = 650, hitEffID = 30250, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000842] = {
		[1] = {events = {{triTime = 775, hitEffID = 30250, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000843] = {
		[1] = {events = {{triTime = 1100, hitEffID = 30250, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
	},
	[1000844] = {
		[1] = {events = {{triTime = 1025, hitEffID = 30250, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1000845] = {
		[1] = {events = {{triTime = 750, hitEffID = 30264, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, }, },spArgs1 = '165', spArgs2 = '0', spArgs3 = '0', },
	},
	[1000846] = {
		[1] = {events = {{triTime = 750, hitEffID = 30264, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, }, },spArgs1 = '165', spArgs2 = '0', spArgs3 = '0', },
	},
	[1000847] = {
		[1] = {events = {{triTime = 750, hitEffID = 30264, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, }, },spArgs1 = '165', spArgs2 = '0', spArgs3 = '0', },
	},
	[1000848] = {
		[1] = {events = {{triTime = 750, hitEffID = 30264, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, }, },spArgs1 = '165', spArgs2 = '0', spArgs3 = '0', },
	},
	[1000861] = {
		[1] = {events = {{triTime = 600, hitEffID = 30218, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 4000, buffID = 106, }, {odds = 4000, buffID = 107, }, }, }, },},
	},
	[1000862] = {
		[1] = {events = {{triTime = 775, hitEffID = 30218, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 4000, buffID = 106, }, {odds = 4000, buffID = 107, }, }, }, },},
	},
	[1000863] = {
		[1] = {events = {{triTime = 800, hitEffID = 30219, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, status = {{odds = 4000, buffID = 10, }, }, }, },},
		[2] = {events = {{triTime = 800, hitEffID = 30219, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, status = {{odds = 5000, buffID = 10, }, }, }, },},
		[3] = {events = {{triTime = 800, hitEffID = 30219, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, status = {{odds = 6000, buffID = 10, }, }, }, },},
		[4] = {events = {{triTime = 800, hitEffID = 30219, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, status = {{odds = 7000, buffID = 10, }, }, }, },},
	},
	[1000864] = {
		[1] = {events = {{triTime = 500, hitEffID = 30220, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 4000, buffID = 44, }, }, }, {triTime = 1000, hitEffID = 30220, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
		[2] = {events = {{triTime = 500, hitEffID = 30220, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 5000, buffID = 44, }, }, }, {triTime = 1000, hitEffID = 30220, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
		[3] = {events = {{triTime = 500, hitEffID = 30220, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 6000, buffID = 44, }, }, }, {triTime = 1000, hitEffID = 30220, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
		[4] = {events = {{triTime = 500, hitEffID = 30220, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, status = {{odds = 7000, buffID = 44, }, }, }, {triTime = 1000, hitEffID = 30220, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 1500, hitEffID = 30195, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
	},
	[1000865] = {
		[1] = {events = {{triTime = 875, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 4000, buffID = 108, }, }, }, },},
		[2] = {events = {{triTime = 875, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 5000, buffID = 108, }, }, }, },},
		[3] = {events = {{triTime = 875, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 6000, buffID = 108, }, }, }, },},
		[4] = {events = {{triTime = 875, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 7000, buffID = 108, }, }, }, },},
	},
	[1000866] = {
		[1] = {events = {{triTime = 1325, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 4000, buffID = 124, }, }, }, },},
		[2] = {events = {{triTime = 1325, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 5000, buffID = 124, }, }, }, },},
		[3] = {events = {{triTime = 1325, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 6000, buffID = 124, }, }, }, },},
		[4] = {events = {{triTime = 1325, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 7000, buffID = 124, }, }, }, },},
	},
	[1000867] = {
		[1] = {events = {{triTime = 600, hitEffID = 30218, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 5000, buffID = 106, }, {odds = 5000, buffID = 107, }, }, }, },},
	},
	[1000868] = {
		[1] = {events = {{triTime = 775, hitEffID = 30218, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 5000, buffID = 106, }, {odds = 5000, buffID = 107, }, }, }, },},
	},
	[1000869] = {
		[1] = {events = {{triTime = 600, hitEffID = 30218, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 6000, buffID = 106, }, {odds = 6000, buffID = 107, }, }, }, },},
	},
	[1000870] = {
		[1] = {events = {{triTime = 775, hitEffID = 30218, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 6000, buffID = 106, }, {odds = 6000, buffID = 107, }, }, }, },},
	},
	[1000871] = {
		[1] = {events = {{triTime = 600, hitEffID = 30218, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 7000, buffID = 106, }, {odds = 7000, buffID = 107, }, }, }, },},
	},
	[1000872] = {
		[1] = {events = {{triTime = 775, hitEffID = 30218, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, status = {{odds = 7000, buffID = 106, }, {odds = 7000, buffID = 107, }, }, }, },},
	},
	[1000873] = {
		[1] = {events = {{triTime = 3875, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 4000, buffID = 108, }, }, }, },},
		[2] = {events = {{triTime = 3875, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 5000, buffID = 108, }, }, }, },},
		[3] = {events = {{triTime = 3875, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 6000, buffID = 108, }, }, }, },},
		[4] = {events = {{triTime = 3875, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 7000, buffID = 108, }, }, }, },},
	},
	[1000874] = {
		[1] = {events = {{triTime = 3825, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 4000, buffID = 124, }, }, }, },},
		[2] = {events = {{triTime = 3825, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 5000, buffID = 124, }, }, }, },},
		[3] = {events = {{triTime = 3825, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 6000, buffID = 124, }, }, }, },},
		[4] = {events = {{triTime = 3825, hitEffID = 30149, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 7000, buffID = 124, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
