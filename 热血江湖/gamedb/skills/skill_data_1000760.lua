----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000793] = {
		[1] = {events = {{triTime = 1100, hitEffID = 30241, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
		[2] = {events = {{triTime = 1100, hitEffID = 30241, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.2, }, status = {{odds = 10000, buffID = 450, }, }, }, },},
	},
	[1000762] = {
		[1] = {events = {{triTime = 775, hitEffID = 30237, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000772] = {
		[1] = {events = {{triTime = 525, hitEffID = 30239, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000773] = {
		[1] = {events = {{triTime = 625, hitEffID = 30239, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
		[2] = {events = {{triTime = 625, hitEffID = 30239, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.2, }, }, },},
	},
	[1000774] = {
		[1] = {events = {{triTime = 325, hitEffID = 30239, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 825, hitEffID = 30239, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, },},
		[2] = {events = {{triTime = 325, hitEffID = 30239, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.75, }, }, {triTime = 825, hitEffID = 30239, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.75, }, }, },},
	},
	[1000781] = {
		[1] = {events = {{triTime = 500, hitEffID = 30240, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000782] = {
		[1] = {events = {{triTime = 525, hitEffID = 30240, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000783] = {
		[1] = {events = {{triTime = 625, hitEffID = 30240, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
	},
	[1000784] = {
		[1] = {events = {{triTime = 325, hitEffID = 30240, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 825, hitEffID = 30240, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.8, }, }, },},
	},
	[1000791] = {
		[1] = {events = {{triTime = 650, hitEffID = 30241, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000792] = {
		[1] = {events = {{triTime = 775, hitEffID = 30241, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000771] = {
		[1] = {events = {{triTime = 500, hitEffID = 30239, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000794] = {
		[1] = {events = {{triTime = 1025, hitEffID = 30241, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
		[2] = {events = {{triTime = 1025, hitEffID = 30241, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.3, }, status = {{odds = 10000, buffID = 450, }, }, }, },},
	},
	[1000761] = {
		[1] = {events = {{triTime = 650, hitEffID = 30237, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000763] = {
		[1] = {events = {{triTime = 1100, hitEffID = 30237, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
	},
	[1000764] = {
		[1] = {events = {{triTime = 1025, hitEffID = 30237, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},

};
function get_db_table()
	return level;
end
