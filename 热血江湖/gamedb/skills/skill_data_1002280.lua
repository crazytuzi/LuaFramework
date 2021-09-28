----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1002311] = {
		[1] = {events = {{triTime = 550, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002293] = {
		[1] = {events = {{triTime = 2025, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002292] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 790, }, }, }, },},
		[2] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 791, }, }, }, },skillrealpower = {0,0,0,0,1,}, summonedSkill = {0,0,0,0,1,}, },
		[3] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 792, }, }, }, },skillrealpower = {0,0,0,0,2,}, summonedSkill = {0,0,0,0,2,}, },
		[4] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 793, }, }, }, },skillrealpower = {0,0,0,0,3,}, summonedSkill = {0,0,0,0,3,}, },
		[5] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 794, }, }, }, },skillrealpower = {0,0,0,0,4,}, summonedSkill = {0,0,0,0,4,}, },
		[6] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 795, }, }, }, },skillrealpower = {0,0,0,0,5,}, summonedSkill = {0,0,0,0,5,}, },
		[7] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 796, }, }, }, },skillrealpower = {0,0,0,0,6,}, summonedSkill = {0,0,0,0,6,}, },
		[8] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 797, }, }, }, },skillrealpower = {0,0,0,0,7,}, summonedSkill = {0,0,0,0,7,}, },
		[9] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 798, }, }, }, },skillrealpower = {0,0,0,0,8,}, summonedSkill = {0,0,0,0,8,}, },
	},
	[1002281] = {
		[1] = {events = {{triTime = 625, hitEffID = 30973, damage = {odds = 10000, arg1 = 1.0, arg2 = 50000.0, }, }, },},
	},
	[1002282] = {
		[1] = {events = {{triTime = 625, hitEffID = 30974, damage = {odds = 10000, arg1 = 1.0, arg2 = 50000.0, }, }, },},
	},
	[1002301] = {
		[1] = {events = {{triTime = 500, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002302] = {
		[1] = {events = {{triTime = 500, hitEffID = 30451, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002291] = {
		[1] = {events = {{triTime = 375, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1002283] = {
		[1] = {events = {{triTime = 625, hitEffID = 30975, damage = {odds = 10000, arg1 = 1.0, arg2 = 50000.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
