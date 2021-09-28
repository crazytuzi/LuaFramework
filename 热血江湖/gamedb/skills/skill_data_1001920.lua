----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001931] = {
		[1] = {events = {{triTime = 750, hitEffID = 30800, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.2, }, status = {{odds = 8000, buffID = 75011, }, }, }, },},
	},
	[1001932] = {
		[1] = {events = {{triTime = 575, hitEffID = 30800, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001933] = {
		[1] = {events = {{triTime = 1000, hitEffID = 30800, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 8000, buffID = 22, }, }, }, },},
	},
	[1001941] = {
		[1] = {events = {{triTime = 650, hitEffID = 30798, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, },},
	},
	[1001942] = {
		[1] = {events = {{triTime = 725, hitEffID = 30798, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.5, }, status = {{odds = 10000, buffID = 11, }, }, }, },},
	},
	[1001943] = {
		[1] = {events = {{triTime = 1500, hitEffID = 30798, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 0.5, }, status = {{odds = 10000, buffID = 546, }, {odds = 10000, buffID = 545, }, }, }, {triTime = 1825, hitEffID = 30798, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 2150, hitEffID = 30798, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
	},
	[1001945] = {
		[1] = {events = {{triTime = 4000, hitEffID = 30798, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 0.5, }, status = {{odds = 10000, buffID = 546, }, {odds = 10000, buffID = 545, }, }, }, {triTime = 4325, hitEffID = 30798, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 4650, hitEffID = 30798, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
	},
	[1001946] = {
		[1] = {events = {{triTime = 4975, hitEffID = 30798, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 0.5, }, }, {triTime = 5300, hitEffID = 30798, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 5625, hitEffID = 30798, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
	},
	[1001922] = {
		[1] = {events = {{triTime = 475, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 0.8, }, status = {{odds = 10000, buffID = 11, }, }, }, {triTime = 775, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 1125, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, },},
		[2] = {events = {{triTime = 475, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75007, }, }, }, {triTime = 775, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1125, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[3] = {events = {{triTime = 475, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75008, }, }, }, {triTime = 775, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1125, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 475, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75009, }, }, }, {triTime = 775, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1125, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1001924] = {
		[1] = {events = {{triTime = 1750, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7, }, }, {triTime = 2375, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7, }, }, {triTime = 2950, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7, }, }, },},
		[2] = {events = {{triTime = 1750, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 2375, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 2950, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[3] = {events = {{triTime = 1750, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 2375, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 2950, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 1750, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 2375, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 2950, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1001944] = {
		[1] = {events = {{triTime = 2475, hitEffID = 30798, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 0.5, }, }, {triTime = 2800, hitEffID = 30798, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, {triTime = 3125, hitEffID = 30798, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.5, }, }, },},
	},
	[1001951] = {
		[1] = {events = {{triTime = 525, hitEffID = 30792, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001952] = {
		[1] = {events = {{triTime = 800, hitEffID = 30792, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.2, }, status = {{odds = 8000, buffID = 85, }, }, }, {triTime = 1525, hitEffID = 30792, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.2, }, }, },},
	},
	[1001953] = {
		[1] = {events = {{triTime = 500, hitEffID = 30793, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9, }, }, {triTime = 750, hitEffID = 30793, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9, }, }, {triTime = 1000, hitEffID = 30793, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9, }, }, },},
	},
	[1001921] = {
		[1] = {events = {{triTime = 1000, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.0, }, }, },},
		[2] = {events = {{triTime = 1000, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[3] = {events = {{triTime = 1000, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 1000, hitEffID = 30799, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1001923] = {
		[1] = {events = {{triTime = 1250, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 0.9, }, status = {{odds = 10000, buffID = 547, }, }, }, },},
		[2] = {events = {{triTime = 1250, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75001, }, }, }, },},
		[3] = {events = {{triTime = 1250, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75002, }, }, }, },},
		[4] = {events = {{triTime = 1250, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75003, }, }, }, },},
	},
	[1001925] = {
		[1] = {events = {{triTime = 3750, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 0.9, }, status = {{odds = 10000, buffID = 547, }, }, }, },},
	},
	[1001926] = {
		[1] = {events = {{triTime = 4250, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7, }, }, {triTime = 4875, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7, }, }, {triTime = 5450, hitEffID = 30797, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7, }, }, },},
	},

};
function get_db_table()
	return level;
end
