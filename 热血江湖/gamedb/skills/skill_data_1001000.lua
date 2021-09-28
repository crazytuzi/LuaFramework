----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001023] = {
		[1] = {events = {{triTime = 1000, hitEffID = 30286, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },spArgs1 = '160', spArgs2 = '0', },
	},
	[1001024] = {
		[1] = {events = {{triTime = 1025, hitEffID = 30286, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, },spArgs1 = '180', spArgs2 = '0', spArgs3 = '0', },
	},
	[1001001] = {
		[1] = {events = {{triTime = 500, hitEffID = 30280, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001002] = {
		[1] = {events = {{triTime = 500, hitEffID = 30280, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001003] = {
		[1] = {events = {{triTime = 950, hitEffID = 30280, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },spArgs1 = '160', spArgs2 = '0', },
		[2] = {events = {{triTime = 950, hitEffID = 30280, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 198, }, }, }, },spArgs1 = '250', spArgs2 = '0', },
		[3] = {events = {{triTime = 950, hitEffID = 30280, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 205, }, }, }, },spArgs1 = '250', spArgs2 = '0', },
	},
	[1001004] = {
		[1] = {events = {{triTime = 450, hitEffID = 30280, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.75, }, }, },spArgs1 = '175', spArgs2 = '0', spArgs3 = '0', },
	},
	[1001005] = {
		[1] = {events = {{triTime = 1100, hitEffID = 30280, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, },spArgs1 = '180', spArgs2 = '0', spArgs3 = '0', spArgs4 = '0', },
	},
	[1001006] = {
		[1] = {events = {{triTime = 975, hitEffID = 30280, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.95, }, }, },spArgs1 = '195', spArgs2 = '0', spArgs3 = '0', },
		[2] = {events = {{triTime = 975, hitEffID = 30280, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 199, }, }, }, },spArgs1 = '250', spArgs2 = '0', spArgs3 = '100', },
	},
	[1001007] = {
		[1] = {events = {{triTime = 3600, hitEffID = 30280, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 394, }, }, }, },spArgs1 = '200', spArgs2 = '0', spArgs3 = '100', spArgs4 = '0', },
	},
	[1001011] = {
		[1] = {events = {{triTime = 525, hitEffID = 30284, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001012] = {
		[1] = {events = {{triTime = 525, hitEffID = 30284, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001013] = {
		[1] = {events = {{triTime = 525, hitEffID = 30284, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.55, }, }, {triTime = 750, hitEffID = 30284, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.55, }, }, {triTime = 1150, hitEffID = 30284, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.55, }, }, },spArgs1 = '55', spArgs2 = '0', },
	},
	[1001014] = {
		[1] = {events = {{triTime = 500, hitEffID = 30284, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.56, }, }, {triTime = 825, hitEffID = 30284, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.56, }, }, {triTime = 1475, hitEffID = 30284, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.56, }, }, },spArgs1 = '56', spArgs2 = '0', spArgs3 = '0', },
	},
	[1001015] = {
		[1] = {events = {{triTime = 1425, hitEffID = 30284, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, },spArgs1 = '180', spArgs2 = '0', spArgs3 = '0', spArgs4 = '0', },
	},
	[1001016] = {
		[1] = {events = {{hitEffID = 30284, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4, }, }, },spArgs1 = '40', spArgs2 = '0', spArgs3 = '0', },
	},
	[1001021] = {
		[1] = {events = {{triTime = 575, hitEffID = 30286, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001022] = {
		[1] = {events = {{triTime = 675, hitEffID = 30286, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001025] = {
		[1] = {events = {{triTime = 925, hitEffID = 30286, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.9, }, }, },spArgs1 = '190', spArgs2 = '0', spArgs3 = '0', spArgs4 = '0', },
	},
	[1001026] = {
		[1] = {events = {{triTime = 750, hitEffID = 30287, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.66, }, }, {triTime = 1000, hitEffID = 30287, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.66, }, }, {triTime = 1250, hitEffID = 30287, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.66, }, }, },spArgs1 = '66', spArgs2 = '0', spArgs3 = '0', },
	},
	[1001031] = {
		[1] = {events = {{triTime = 575, hitEffID = 30286, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001032] = {
		[1] = {events = {{triTime = 500, hitEffID = 30288, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001033] = {
		[1] = {events = {{hitEffID = 30288, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },spArgs1 = '160', spArgs2 = '0', },
	},
	[1001034] = {
		[1] = {events = {{triTime = 825, hitEffID = 30288, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, },spArgs1 = '180', spArgs2 = '0', spArgs3 = '0', },
	},
	[1001035] = {
		[1] = {events = {{triTime = 1050, hitEffID = 30288, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.9, }, }, },spArgs1 = '190', spArgs2 = '0', spArgs3 = '0', spArgs4 = '0', },
	},
	[1001036] = {
		[1] = {events = {{triTime = 475, hitEffID = 30288, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.66, }, }, {triTime = 850, hitEffID = 30288, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.66, }, }, {triTime = 1400, hitEffID = 30288, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.66, }, }, },spArgs1 = '66', spArgs2 = '0', spArgs3 = '0', },
	},

};
function get_db_table()
	return level;
end
