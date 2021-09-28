----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000931] = {
		[1] = {events = {{triTime = 475, hitEffID = 30269, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000932] = {
		[1] = {events = {{triTime = 500, hitEffID = 30269, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000933] = {
		[1] = {events = {{hitEffID = 30269, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.33, }, }, },spArgs1 = '33', spArgs2 = '0', },
		[2] = {events = {{hitEffID = 30269, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 204, }, }, }, },spArgs1 = '200', spArgs2 = '0', },
	},
	[1000934] = {
		[1] = {events = {{triTime = 425, hitEffID = 30269, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, }, },spArgs1 = '165', spArgs2 = '0', spArgs3 = '0', },
		[2] = {events = {{triTime = 425, hitEffID = 30269, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, status = {{odds = 20000, buffID = 573, }, }, }, },spArgs1 = '165', spArgs2 = '0', spArgs3 = '0', },
	},
	[1000935] = {
		[1] = {events = {{triTime = 900, hitEffID = 30269, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.7, }, }, },spArgs1 = '170', spArgs2 = '0', spArgs3 = '0', spArgs4 = '0', },
		[2] = {events = {{triTime = 900, hitEffID = 30269, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 205, }, }, }, },spArgs1 = '250', spArgs2 = '0', spArgs3 = '100', spArgs4 = '0', },
	},
	[1000936] = {
		[1] = {events = {{triTime = 500, hitEffID = 30269, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9, }, }, {triTime = 975, hitEffID = 30269, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9, }, }, },spArgs1 = '90', spArgs2 = '0', spArgs3 = '0', },
	},
	[1000941] = {
		[1] = {events = {{triTime = 475, hitEffID = 30271, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000942] = {
		[1] = {events = {{triTime = 600, hitEffID = 30271, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000943] = {
		[1] = {events = {{hitEffID = 30271, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.3, }, }, },},
	},
	[1000944] = {
		[1] = {events = {{triTime = 950, hitEffID = 30271, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1000951] = {
		[1] = {events = {{triTime = 675, hitEffID = 30272, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000952] = {
		[1] = {events = {{triTime = 600, hitEffID = 30273, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000953] = {
		[1] = {events = {{triTime = 800, hitEffID = 30272, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.33, }, }, },spArgs1 = '33', spArgs2 = '0', },
		[2] = {events = {{triTime = 800, hitEffID = 30272, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 190, }, {odds = 10000, buffID = 22, }, }, }, },spArgs1 = '250', spArgs2 = '0', },
	},
	[1000954] = {
		[1] = {events = {{triTime = 825, hitEffID = 30273, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.65, }, }, },spArgs1 = '165', spArgs2 = '0', spArgs3 = '0', },
		[2] = {events = {{triTime = 825, hitEffID = 30273, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 191, }, {odds = 10000, buffID = 16, }, }, }, },spArgs1 = '200', spArgs2 = '0', spArgs3 = '100', },
	},
	[1000955] = {
		[1] = {events = {{triTime = 750, hitEffID = 30272, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.85, }, }, {triTime = 925, hitEffID = 30273, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.85, }, }, },spArgs1 = '85', spArgs2 = '0', spArgs3 = '0', spArgs4 = '0', },
	},
	[1000956] = {
		[1] = {events = {{triTime = 1050, hitEffID = 30273, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9, }, }, {triTime = 1175, hitEffID = 30272, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.9, }, }, },spArgs1 = '90', spArgs2 = '0', spArgs3 = '0', },
	},

};
function get_db_table()
	return level;
end
