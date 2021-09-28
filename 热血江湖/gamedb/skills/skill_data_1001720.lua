----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1001721] = {
		[1] = {events = {{triTime = 500, hitEffID = 30779, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001722] = {
		[1] = {events = {{triTime = 375, hitEffID = 30779, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1125, hitEffID = 30779, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1450, hitEffID = 30779, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001731] = {
		[1] = {events = {{triTime = 750, hitEffID = 30780, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001732] = {
		[1] = {events = {{triTime = 600, hitEffID = 30780, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1175, hitEffID = 30780, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001741] = {
		[1] = {events = {{triTime = 525, hitEffID = 30781, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001742] = {
		[1] = {events = {{triTime = 600, hitEffID = 30781, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001751] = {
		[1] = {events = {{triTime = 1000, hitEffID = 30782, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1375, hitEffID = 30782, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},
	[1001752] = {
		[1] = {events = {{triTime = 525, hitEffID = 30782, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, {triTime = 1000, hitEffID = 30782, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
