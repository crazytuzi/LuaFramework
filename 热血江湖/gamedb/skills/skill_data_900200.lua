----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[900201] = {
		[1] = {addSP = 50, cool = 10000, events = {{triTime = 875, hitEffID = 30137, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.275, arg2 = 191.0, }, }, },skillpower = 24, },
	},
	[900203] = {
		[1] = {addSP = 50, cool = 11000, events = {{triTime = 450, hitEffID = 30137, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.7375, arg2 = 230.0, }, }, },skillpower = 24, },
	},
	[900204] = {
		[1] = {addSP = 50, cool = 10000, events = {{triTime = 300, hitEffID = 30136, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.9, arg2 = 76.0, }, }, {triTime = 575, hitEffID = 30138, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.9, arg2 = 76.0, }, }, {triTime = 825, hitEffID = 30137, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.9, arg2 = 76.0, realmAddon = 0.05, }, }, },skillpower = 24, },
	},
	[900202] = {
		[1] = {addSP = 50, cool = 9000, events = {{triTime = 475, hitEffID = 30136, hitSoundID = 10, damage = {odds = 10000, atrType = 1, arg1 = 1.325, arg2 = 111.0, }, }, {triTime = 875, hitEffID = 30138, hitSoundID = 10, damage = {odds = 10000, atrType = 1, arg1 = 1.325, arg2 = 111.0, }, }, },skillpower = 24, },
	},

};
function get_db_table()
	return level;
end
