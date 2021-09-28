----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001045] = {
		[1] = {events = {{hitEffID = 30248, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, },spArgs1 = '170', spArgs2 = '0', spArgs3 = '0', spArgs4 = '0', },
	},
	[1001041] = {
		[1] = {events = {{triTime = 425, hitEffID = 30248, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001042] = {
		[1] = {events = {{triTime = 575, hitEffID = 30248, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001043] = {
		[1] = {events = {{triTime = 400, hitEffID = 30248, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 1000, hitEffID = 30248, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, },spArgs1 = '80', spArgs2 = '0', },
		[2] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 201, }, }, }, {triTime = 400, hitEffID = 30248, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, {triTime = 1000, hitEffID = 30248, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, }, },spArgs1 = '0', spArgs2 = '0', },
	},
	[1001044] = {
		[1] = {events = {{triTime = 425, hitEffID = 30248, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, }, },spArgs1 = '165', spArgs2 = '0', spArgs3 = '0', },
		[2] = {events = {{triTime = 425, hitEffID = 30248, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, status = {{odds = 20000, buffID = 573, }, }, }, },spArgs1 = '165', spArgs2 = '0', spArgs3 = '0', },
	},
	[1001047] = {
		[1] = {events = {{triTime = 3450, hitEffID = 30248, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 202, }, }, }, },spArgs1 = '250', spArgs2 = '0', spArgs3 = '100', },
	},
	[1001061] = {
		[1] = {events = {{triTime = 500, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001062] = {
		[1] = {events = {{triTime = 550, hitEffID = 30178, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001063] = {
		[1] = {events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.3, }, }, },spArgs1 = '30', spArgs2 = '0', },
	},
	[1001064] = {
		[1] = {events = {{triTime = 500, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },spArgs1 = '160', spArgs2 = '0', spArgs3 = '0', },
	},
	[1001065] = {
		[1] = {events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.55, }, status = {{odds = 10000, buffID = 26, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.55, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.55, }, }, },spArgs1 = '55', spArgs2 = '0', spArgs3 = '100', spArgs4 = '0', },
		[2] = {events = {{triTime = 300, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.55, }, status = {{odds = 10000, buffID = 26, }, }, }, {triTime = 550, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.55, }, }, {triTime = 1150, hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.55, }, }, },spArgs1 = '55', spArgs2 = '0', spArgs3 = '100', spArgs4 = '0', },
	},
	[1001066] = {
		[1] = {events = {{hitEffID = 30181, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.36, }, }, },spArgs1 = '36', spArgs2 = '0', spArgs3 = '0', },
	},
	[1001071] = {
		[1] = {events = {{triTime = 675, hitEffID = 30306, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001072] = {
		[1] = {events = {{triTime = 675, hitEffID = 30306, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001073] = {
		[1] = {events = {{triTime = 925, hitEffID = 30307, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },spArgs1 = '30', spArgs2 = '0', },
	},
	[1001074] = {
		[1] = {events = {{triTime = 425, hitEffID = 30307, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9, }, }, {triTime = 500, hitEffID = 30307, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9, }, }, },spArgs1 = '160', spArgs2 = '0', spArgs3 = '0', },
	},
	[1001075] = {
		[1] = {events = {{triTime = 875, hitEffID = 30306, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 26, }, }, }, },spArgs1 = '55', spArgs2 = '0', spArgs3 = '100', spArgs4 = '0', },
		[2] = {events = {{triTime = 875, hitEffID = 30306, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 20000, buffID = 44, }, }, }, },spArgs1 = '55', spArgs2 = '0', spArgs3 = '100', spArgs4 = '0', },
	},
	[1001046] = {
		[1] = {events = {{triTime = 950, hitEffID = 30248, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, },spArgs1 = '180', spArgs2 = '0', spArgs3 = '0', },
	},

};
function get_db_table()
	return level;
end
