----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[900301] = {
		[1] = {addSP = 50, cool = 10000, events = {{hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.4375, arg2 = 37.0, }, }, },skillpower = 24, },
	},
	[900302] = {
		[1] = {addSP = 50, cool = 6000, events = {{triTime = 275, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.35, arg2 = 114.0, }, }, {triTime = 825, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 1.35, arg2 = 114.0, }, }, },skillpower = 24, },
	},
	[900303] = {
		[1] = {addSP = 50, cool = 10000, events = {{triTime = 250, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.975, arg2 = 82.0, }, }, {triTime = 650, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.975, arg2 = 82.0, }, }, {triTime = 1300, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.975, arg2 = 82.0, realmAddon = 0.05, }, }, },skillpower = 24, },
	},
	[900304] = {
		[1] = {addSP = 50, cool = 10000, events = {{triTime = 400, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.975, arg2 = 82.0, }, }, {triTime = 700, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.975, arg2 = 82.0, }, }, {triTime = 1000, hitEffID = 30139, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.975, arg2 = 82.0, realmAddon = 0.05, }, }, },skillpower = 24, },
	},

};
function get_db_table()
	return level;
end
