----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001081] = {
		[1] = {events = {{triTime = 625, hitEffID = 30145, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001082] = {
		[1] = {events = {{triTime = 500, hitEffID = 30145, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001083] = {
		[1] = {events = {{triTime = 400, hitEffID = 30146, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 1050, hitEffID = 30146, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.8, }, }, },},
		[2] = {events = {{triTime = 400, hitEffID = 30146, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1050, hitEffID = 30146, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1001084] = {
		[1] = {events = {{triTime = 1250, hitEffID = 30146, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.6, }, status = {{odds = 6000, buffID = 116, }, }, }, },},
	},
	[1001091] = {
		[1] = {events = {{triTime = 650, hitEffID = 30194, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001092] = {
		[1] = {events = {{triTime = 500, hitEffID = 30194, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001093] = {
		[1] = {events = {{triTime = 675, hitEffID = 30194, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.6, }, }, },},
	},
	[1001094] = {
		[1] = {events = {{hitEffID = 30194, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.5, }, }, },},
	},
	[1001095] = {
		[1] = {events = {{triTime = 750, hitEffID = 30194, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.7, }, }, },},
	},
	[1001096] = {
		[1] = {events = {{triTime = 850, hitEffID = 30194, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.8, }, }, },},
		[2] = {events = {{triTime = 850, hitEffID = 30194, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.8, }, status = {{odds = 20000, buffID = 43, }, }, }, },},
	},
	[1001101] = {
		[1] = {events = {{triTime = 500, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001102] = {
		[1] = {events = {{triTime = 550, hitEffID = 30178, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001103] = {
		[1] = {events = {{triTime = 500, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.75, }, }, {triTime = 1025, hitEffID = 30178, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.75, }, }, },spArgs1 = '75', spArgs2 = '0', },
		[2] = {events = {{triTime = 500, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 1025, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, }, },},
		[3] = {events = {{triTime = 500, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75001, }, }, }, {triTime = 1025, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 500, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75002, }, }, }, {triTime = 1025, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[5] = {events = {{triTime = 500, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75003, }, }, }, {triTime = 1025, hitEffID = 30177, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1001104] = {
		[1] = {events = {{triTime = 950, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },spArgs1 = '160', spArgs2 = '0', spArgs3 = '0', },
		[2] = {events = {{triTime = 950, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, status = {{odds = 10000, buffID = 11, }, }, }, },spArgs1 = '160', spArgs2 = '0', spArgs3 = '0', },
		[3] = {events = {{triTime = 950, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75007, }, }, }, },spArgs1 = '160', spArgs2 = '0', spArgs3 = '0', },
		[4] = {events = {{triTime = 950, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75008, }, }, }, },spArgs1 = '160', spArgs2 = '0', spArgs3 = '0', },
		[5] = {events = {{triTime = 950, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75009, }, }, }, },spArgs1 = '160', spArgs2 = '0', spArgs3 = '0', },
	},
	[1001105] = {
		[1] = {events = {{triTime = 625, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, }, },spArgs1 = '165', spArgs2 = '0', spArgs3 = '0', spArgs4 = '338', },
		[2] = {events = {{triTime = 575, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, }, {triTime = 700, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, }, {triTime = 875, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, }, },},
		[3] = {events = {{triTime = 575, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75022, }, }, }, {triTime = 700, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 875, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[4] = {events = {{triTime = 575, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75023, }, }, }, {triTime = 700, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 875, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[5] = {events = {{triTime = 575, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 75024, }, }, }, {triTime = 700, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, {triTime = 875, hitEffID = 30179, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1001106] = {
		[1] = {events = {{triTime = 875, hitEffID = 30094, hitSoundID = 14, status = {{odds = 10000, buffID = 25, }, }, }, {triTime = 900, status = {{odds = 10000, buffID = 25, }, }, }, },spArgs1 = '0', },
	},
	[1001111] = {
		[1] = {events = {{triTime = 400, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001112] = {
		[1] = {events = {{triTime = 325, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.0, }, }, },spArgs1 = '202.4', spArgs2 = '104', },
	},
	[1001113] = {
		[1] = {events = {{triTime = 250, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.65, }, }, {triTime = 550, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.65, }, }, {triTime = 1200, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.65, }, }, },spArgs1 = '64.85', spArgs2 = '33', spArgs3 = '60', },
	},
	[1001114] = {
		[1] = {events = {{hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.5, }, }, },spArgs1 = '43.23', spArgs2 = '22', spArgs3 = '50', spArgs4 = '3.45', },
		[2] = {events = {{hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.65, }, }, },spArgs1 = '43.23', spArgs2 = '22', spArgs3 = '50', spArgs4 = '3.45', },
	},
	[1001115] = {
		[1] = {events = {{triTime = 175, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.67, }, }, {triTime = 1000, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.67, }, }, {triTime = 1725, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.67, }, }, },spArgs1 = '82.53', spArgs2 = '42', spArgs3 = '148', spArgs4 = '106', },
		[2] = {events = {{triTime = 175, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 398, }, }, }, {triTime = 1000, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.8, }, status = {{odds = 10000, buffID = 398, }, }, }, {triTime = 1725, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.4, }, status = {{odds = 10000, buffID = 398, }, }, }, },spArgs1 = '82.53', spArgs2 = '42', spArgs3 = '148', spArgs4 = '106', },
		[3] = {events = {{triTime = 175, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 393, }, }, }, {triTime = 1000, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 393, }, }, }, {triTime = 1725, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 3.5, }, status = {{odds = 10000, buffID = 393, }, }, }, },},
	},
	[1001116] = {
		[1] = {events = {{triTime = 875, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.7, }, }, },spArgs1 = '229.14', spArgs2 = '160', spArgs3 = '197', },
		[2] = {events = {{triTime = 875, hitEffID = 30085, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 22, }, }, }, },},
	},
	[1001085] = {
		[1] = {events = {{triTime = 1125, hitEffID = 30146, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.7, }, }, },},
	},
	[1001086] = {
		[1] = {events = {{triTime = 4125, hitEffID = 30146, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 7, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
