----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1000532] = {
		[1] = {events = {{triTime = 650, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000533] = {
		[1] = {events = {{triTime = 500, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.75, }, }, {triTime = 1000, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.75, }, }, },},
	},
	[1000534] = {
		[1] = {events = {{triTime = 1050, hitEffID = 30197, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.55, }, }, },},
	},
	[1000535] = {
		[1] = {events = {{triTime = 875, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.6, }, }, },},
	},
	[1000536] = {
		[1] = {events = {{triTime = 1000, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.55, }, }, {triTime = 1250, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.55, }, }, {triTime = 1500, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.55, }, }, },},
	},
	[1000551] = {
		[1] = {events = {{triTime = 600, hitEffID = 30198, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000552] = {
		[1] = {events = {{triTime = 500, hitEffID = 30198, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1000553] = {
		[1] = {events = {{triTime = 400, hitEffID = 30198, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7, }, }, {triTime = 800, hitEffID = 30198, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.7, }, }, },},
	},
	[1000554] = {
		[1] = {events = {{triTime = 800, hitEffID = 30198, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},
	[1000531] = {
		[1] = {events = {{triTime = 625, hitEffID = 30196, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
