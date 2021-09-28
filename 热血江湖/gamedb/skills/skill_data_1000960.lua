----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000961] = {
		[1] = {events = {{triTime = 450, hitEffID = 30274, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000962] = {
		[1] = {events = {{triTime = 425, hitEffID = 30275, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000963] = {
		[1] = {events = {{hitEffID = 30274, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.33, }, }, },spArgs1 = '33', spArgs2 = '0', },
	},
	[1000964] = {
		[1] = {events = {{triTime = 475, hitEffID = 30274, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.85, }, }, {triTime = 850, hitEffID = 30274, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.85, }, }, },spArgs1 = '85', spArgs2 = '0', spArgs3 = '0', },
		[2] = {events = {{triTime = 475, hitEffID = 30274, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, status = {{odds = 10000, buffID = 208, }, }, }, {triTime = 850, hitEffID = 30274, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, },spArgs1 = '200', spArgs2 = '0', spArgs3 = '100', },
		[3] = {events = {{triTime = 475, hitEffID = 30274, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.1, }, status = {{odds = 10000, buffID = 448, }, }, }, {triTime = 850, hitEffID = 30274, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.2, }, }, },spArgs1 = '85', spArgs2 = '0', spArgs3 = '0', },
	},
	[1000965] = {
		[1] = {events = {{triTime = 900, hitEffID = 30275, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.8, }, }, },spArgs1 = '180', spArgs2 = '0', spArgs3 = '0', spArgs4 = '0', },
	},
	[1000966] = {
		[1] = {events = {{hitEffID = 30274, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.4, }, }, },spArgs1 = '40', spArgs2 = '0', spArgs3 = '0', },
	},
	[1000967] = {
		[1] = {events = {{hitEffID = 30274, hitSoundID = 14, damage = {odds = 10000, atrType = 1, arg1 = 1.3, }, }, },spArgs1 = '200', spArgs2 = '0', spArgs3 = '0', },
	},

};
function get_db_table()
	return level;
end
