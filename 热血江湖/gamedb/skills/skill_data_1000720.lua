----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000721] = {
		[1] = {events = {{triTime = 600, hitEffID = 30231, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000722] = {
		[1] = {events = {{triTime = 550, hitEffID = 30231, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000731] = {
		[1] = {events = {{triTime = 475, hitEffID = 30234, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000733] = {
		[1] = {events = {{triTime = 500, hitEffID = 30234, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
		[2] = {events = {{triTime = 500, hitEffID = 30234, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, status = {{odds = 10000, buffID = 196, }, }, }, },},
	},
	[1000734] = {
		[1] = {events = {{triTime = 475, hitEffID = 30234, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.82, }, }, {triTime = 975, hitEffID = 30234, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.82, }, }, },},
		[2] = {events = {{triTime = 475, hitEffID = 30234, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, status = {{odds = 10000, buffID = 197, }, }, }, {triTime = 975, hitEffID = 30234, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.5, }, status = {{odds = 10000, buffID = 197, }, }, }, },},
	},
	[1000742] = {
		[1] = {events = {{triTime = 475, hitEffID = 30235, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000743] = {
		[1] = {events = {{triTime = 500, hitEffID = 30235, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
	},
	[1000744] = {
		[1] = {events = {{triTime = 475, hitEffID = 30235, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.82, }, }, {triTime = 975, hitEffID = 30235, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.82, }, }, },},
	},
	[1000723] = {
		[1] = {events = {{triTime = 425, hitEffID = 30231, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 800, hitEffID = 30231, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, },},
	},
	[1000724] = {
		[1] = {events = {{triTime = 750, hitEffID = 30231, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
	},
	[1000732] = {
		[1] = {events = {{triTime = 475, hitEffID = 30234, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000741] = {
		[1] = {events = {{triTime = 475, hitEffID = 30235, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
